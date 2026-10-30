// Same letter order as keyboard/mba.kbd and bootstrap/kde.sh.
const letters = "ASDFGZXCVQWER";

for (let i = 0; i < letters.length; i++) {
  const n = i + 1;
  registerShortcut(
    `Move Window and Follow to Desktop ${n}`,
    `Move Window and Follow to Desktop ${n}`,
    `Meta+Alt+Shift+${letters[i]}`,
    () => {
      const win = workspace.activeWindow;
      const desktop = workspace.desktops[n - 1];
      if (!win || !desktop) return;
      win.desktops = [desktop];
      workspace.currentDesktop = desktop;
    }
  );
}
