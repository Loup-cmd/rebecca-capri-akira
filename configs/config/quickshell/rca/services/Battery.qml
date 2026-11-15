pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev?.isLaptopBattery ?? false
    readonly property real level: dev?.percentage ?? 0
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging || dev?.state === UPowerDeviceState.FullyCharged
    readonly property real timeLeft: charging ? (dev?.timeToFull ?? 0) : (dev?.timeToEmpty ?? 0)

    function pct() {
        // UPower donne 0–1 ou 0–100 selon la version.
        return Math.round(level > 1 ? level : level * 100);
    }

    function icon() {
        const p = pct();
        if (charging) return "󰂄";
        const set = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        return set[Math.min(10, Math.floor(p / 10))];
    }

    function duration() {
        const s = timeLeft;
        if (!s || s <= 0) return "";
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        return h > 0 ? h + " h " + Theme.pad2(m) : m + " min";
    }

    readonly property string profile: {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver: return "saver";
        case PowerProfile.Performance: return "performance";
        default: return "balanced";
        }
    }

    function setProfile(name) {
        PowerProfiles.profile = name === "saver" ? PowerProfile.PowerSaver
            : name === "performance" ? PowerProfile.Performance : PowerProfile.Balanced;
    }
}
