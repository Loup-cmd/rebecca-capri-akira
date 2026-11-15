pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth

// Réseau (NetworkManager) et Bluetooth (BlueZ).
Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired) ?? null
    readonly property bool wiredUp: wired?.connected ?? false
    readonly property var networks: wifi ? wifi.networks.values.slice().sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)) : []
    readonly property var active: networks.find(n => n.connected) ?? null
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property string name: Quickshell.env("RCA_DEMO") === "1" ? "NIGHT-CITY-NET" : wiredUp ? "FILAIRE" : (active?.name ?? (wifiOn ? "HORS LIGNE" : "WI-FI OFF"))
    readonly property real strength: active?.signalStrength ?? 0

    function glyph() {
        if (wiredUp) return "󰈀";
        if (!wifiOn) return "󰖪";
        if (!active) return "󰤯";
        const s = strength > 1 ? strength / 100 : strength;
        return s > 0.75 ? "󰤨" : s > 0.5 ? "󰤥" : s > 0.25 ? "󰤢" : "󰤟";
    }

    function toggleWifi() { Networking.wifiEnabled = !Networking.wifiEnabled; }
    function scan(on) { if (wifi) wifi.scannerEnabled = on; }

    // Bluetooth.
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter?.enabled ?? false
    readonly property var btDevices: adapter ? adapter.devices.values.slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)) : []
    readonly property var btConnected: btDevices.filter(d => d.connected)

    function btGlyph() {
        if (!btOn) return "󰂲";
        return btConnected.length > 0 ? "󰂱" : "󰂯";
    }

    function toggleBt() { if (adapter) adapter.enabled = !adapter.enabled; }
    function btScan(on) { if (adapter) adapter.discovering = on; }
}
