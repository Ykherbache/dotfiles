import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import St from 'gi://St';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const HINTS = {
    hyper: {text: 'workspace', cursor: Clutter.CursorType.CROSSHAIR},
    move: {text: 'déplacer', cursor: Clutter.CursorType.MOVE},
};

const DBUS_PATH = '/org/gnome/Shell/Extensions/KeydLayerHint';
const DBUS_IFACE = `
<node>
  <interface name="org.gnome.Shell.Extensions.KeydLayerHint">
    <method name="Switch">
      <arg type="s" name="target" direction="in"/>
    </method>
    <method name="MoveOrSwitch">
      <arg type="s" name="target" direction="in"/>
    </method>
    <method name="Toggle"/>
  </interface>
</node>`;

export default class KeydLayerHint extends Extension {
    enable() {
        this._active = new Set();
        this._label = new St.Label({
            text: '',
            style_class: 'keyd-layer-hint',
            visible: false,
            reactive: false,
        });
        Main.uiGroup.add_child(this._label);

        this._motionId = global.stage.connect('captured-event', (_actor, event) => {
            if (event.type() === Clutter.EventType.MOTION)
                this._place();
            return Clutter.EVENT_PROPAGATE;
        });

        this._current = global.workspace_manager.get_active_workspace();
        this._previous = null;
        this._workspaceId = global.workspace_manager.connect(
            'notify::active-workspace', () => this._track());

        this._closed = false;
        this._startListen();
        this._exportBus();
    }

    _workspace(target) {
        const manager = global.workspace_manager;
        const name = String(target);
        if (name === 'last')
            return manager.get_workspace_by_index(manager.n_workspaces - 1);
        const index = Number(name);
        if (!Number.isInteger(index) || index < 1 || index > manager.n_workspaces)
            return null;
        return manager.get_workspace_by_index(index - 1);
    }

    _track() {
        const active = global.workspace_manager.get_active_workspace();
        if (this._current && active !== this._current)
            this._previous = this._current;
        this._current = active;
    }

    _toggle() {
        if (!this._previous)
            return;
        this._previous.activate(global.get_current_time());
    }

    _switch(target) {
        const workspace = this._workspace(target);
        if (!workspace || workspace.active)
            return;
        workspace.activate(global.get_current_time());
    }

    _moveOrSwitch(target) {
        const workspace = this._workspace(target);
        if (!workspace)
            return;
        const win = global.display.focus_window;
        const current = global.workspace_manager.get_active_workspace();
        const movable = win
            && win.get_workspace() === current
            && !win.is_always_on_all_workspaces();
        if (!movable) {
            this._switch(target);
            return;
        }
        if (workspace.active)
            return;
        win.change_workspace(workspace);
        workspace.activate_with_focus(win, global.get_current_time());
    }

    _exportBus() {
        try {
            this._dbus = Gio.DBusExportedObject.wrapJSObject(DBUS_IFACE, {
                Switch: target => this._switch(target),
                MoveOrSwitch: target => this._moveOrSwitch(target),
                Toggle: () => this._toggle(),
            });
            this._dbus.export(Gio.DBus.session, DBUS_PATH);
        } catch (e) {
            console.warn(`keyd layer hint: ${e}`);
            this._dbus = null;
        }
    }

    _place() {
        if (!this._label.visible)
            return;
        const [x, y] = global.get_pointer();
        this._label.set_position(x + 18, y + 18);
    }

    _apply() {
        const mode = this._active.has('move') ? 'move'
            : this._active.has('hyper') ? 'hyper'
            : null;
        if (!mode) {
            this._label.hide();
            global.stage.set_cursor_type(Clutter.CursorType.INHERIT);
            return;
        }
        const hint = HINTS[mode];
        this._label.text = hint.text;
        this._label.show();
        this._place();
        global.stage.set_cursor_type(hint.cursor);
    }

    _startListen() {
        const bin = GLib.find_program_in_path('keyd.rvaiya')
            ?? GLib.find_program_in_path('keyd');
        if (!bin)
            return;

        try {
            this._proc = Gio.Subprocess.new(
                [bin, 'listen'],
                Gio.SubprocessFlags.STDOUT_PIPE,
            );
        } catch (e) {
            console.warn(`keyd layer hint: ${e}`);
            return;
        }

        this._stdout = new Gio.DataInputStream({
            base_stream: this._proc.get_stdout_pipe(),
            close_base_stream: true,
        });
        this._readLine();
    }

    _readLine() {
        this._stdout.read_line_async(GLib.PRIORITY_DEFAULT, null, (stream, result) => {
            if (this._stdout !== stream)
                return;
            let line;
            try {
                [line] = stream.read_line_finish_utf8(result);
            } catch (e) {
                return;
            }
            if (line === null) {
                this._stdout = null;
                this._proc = null;
                if (this._closed)
                    return;
                GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
                    if (!this._closed)
                        this._startListen();
                    return GLib.SOURCE_REMOVE;
                });
                return;
            }
            this._onLine(line);
            this._readLine();
        });
    }

    _onLine(line) {
        const text = line.trim();
        if (text.length < 2)
            return;
        const sign = text[0];
        const name = text.slice(1);
        if (name !== 'hyper' && name !== 'move')
            return;
        if (sign === '+')
            this._active.add(name);
        else if (sign === '-')
            this._active.delete(name);
        else
            return;
        this._apply();
    }

    disable() {
        this._closed = true;
        this._dbus?.unexport();
        this._dbus = null;
        if (this._workspaceId) {
            global.workspace_manager.disconnect(this._workspaceId);
            this._workspaceId = 0;
        }
        if (this._motionId) {
            global.stage.disconnect(this._motionId);
            this._motionId = 0;
        }
        global.stage.set_cursor_type(Clutter.CursorType.INHERIT);
        this._stdout = null;
        this._proc?.force_exit();
        this._proc = null;
        this._label?.destroy();
        this._label = null;
        this._active = new Set();
    }
}
