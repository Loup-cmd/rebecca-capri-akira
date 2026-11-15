import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    property real brightness: 0
    property var sun: ({})
    property bool nightlight: true
    readonly property var mon: Hyprland.focusedMonitor

    Process {
        running: true
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector { onStreamFinished: root.brightness = (parseInt(text.split(",")[3]) || 0) / 100 }
    }
    Process {
        running: true
        command: [Theme.bin + "/rca-theme", "status"]
        stdout: StdioCollector { onStreamFinished: { try { root.sun = JSON.parse(text); } catch (e) {} } }
    }
    Process {
        running: true
        command: [Theme.bin + "/rca-theme", "nightlight", "status"]
        stdout: StdioCollector { onStreamFinished: root.nightlight = text.trim() === "on" }
    }

    PanelHead {
        title: "Affichage" 
        extra: (root.mon?.name ?? "") + " · ×" + (root.mon?.scale ?? 1)
        number: "RCA/D"
    }

    Section { index: "01";  title: "Luminosité"; extra: Math.round(root.brightness * 100) + " %" }
    Meter {
        Layout.fillWidth: true
        implicitHeight: 14
        value: root.brightness
        interactive: true
        onMoved: v => {
            root.brightness = Math.max(0.01, v);
            Ui.run("brightnessctl -n2 set " + Math.round(root.brightness * 100) + "%");
        }
    }

    Section { index: "02";  title: "Cycle jour / nuit"; extra: "☀ " + (root.sun.sunrise ?? "--:--") + " ☾ " + (root.sun.sunset ?? "--:--") }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰖙"; label: "Jour"; active: !Theme.dark; onClicked: Ui.script("rca-theme", "light") }
        Btn { Layout.fillWidth: true; glyph: "󰖔"; label: "Nuit"; active: Theme.dark; onClicked: Ui.script("rca-theme", "dark") }
        Btn { Layout.fillWidth: true; glyph: "󰔄"; label: "Soleil"; active: root.sun.override === false; onClicked: Ui.run("rm -f ~/.local/state/rca/override && " + Theme.bin + "/rca-theme auto") }
    }
    Toggle { glyph: "󰌵"; label: "Veilleuse"; sub: "Lumière chaude pendant la nuit"; checked: root.nightlight; onToggled: { root.nightlight = !root.nightlight; Ui.script("rca-theme", "nightlight " + (root.nightlight ? "on" : "off")); } }

    Section { index: "03";  title: "Échelle" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: [1, 1.25, 1.6, 2]
            Btn {
                required property var modelData
                Layout.fillWidth: true
                label: "×" + modelData
                active: Math.abs((root.mon?.scale ?? 1) - modelData) < 0.01
                onClicked: Ui.run("hyprctl eval 'hl.monitor({ output = \"" + root.mon.name + "\", mode = \"preferred\", position = \"auto\", scale = " + modelData + " })'")
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰸉"; label: "Fonds d'écran"; onClicked: Ui.openPanel("wallpapers") }
        Btn { Layout.fillWidth: true; glyph: "󰍹"; label: "Écran interne"; onClicked: Ui.script("rca-hypr", "internal toggle") }
    }
}
