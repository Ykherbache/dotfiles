// XWayland does not see the pointer over Wayland windows, so the label
// would sit at the center of the screen. This sends KWin's cursor instead.
// Coordinates are device pixels: the label is an X11 window on a scaled output.

function pushCursor() {
    var pos = workspace.cursorPos;
    var output = workspace.screenAt(pos);
    var scale = output && output.devicePixelRatio ? output.devicePixelRatio : 1;
    callDBus(
        "org.dotfiles.LayerHint",
        "/org/dotfiles/LayerHint",
        "org.dotfiles.LayerHint",
        "Move",
        Math.round(pos.x * scale) + Math.round(18 * scale),
        Math.round(pos.y * scale) + Math.round(18 * scale)
    );
}

workspace.cursorPosChanged.connect(pushCursor);

pushCursor();
