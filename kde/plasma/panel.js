// Plasma desktop script, run by bootstrap/kde.sh through org.kde.PlasmaShell.evaluateScript.
// Stands in for the GNOME workspaces-by-open-apps and statistig extensions. Safe to re-run.
for (const panel of panels()) {
  const pagers = panel.widgets("org.kde.plasma.pager");
  if (pagers.length === 0) continue;

  for (const pager of pagers) {
    pager.currentConfigGroup = ["General"];
    pager.writeConfig("displayedText", "None");
    pager.writeConfig("showWindowIcons", true);
  }

  let ram = panel.widgets("org.kde.plasma.systemmonitor.memory")[0];
  if (!ram) ram = panel.addWidget("org.kde.plasma.systemmonitor.memory");
  ram.currentConfigGroup = ["Appearance"];
  ram.writeConfig("chartFace", "org.kde.ksysguard.textonly");
  ram.writeConfig("title", "RAM");
  ram.currentConfigGroup = ["Sensors"];
  ram.writeConfig("highPrioritySensorIds", '["memory/physical/usedPercent"]');
  ram.writeConfig("lowPrioritySensorIds", "[]");
  ram.writeConfig("totalSensors", "[]");
  ram.currentConfigGroup = ["SensorLabels"];
  ram.writeConfig("memory/physical/usedPercent", "RAM");
  ram.reloadConfig();
}
