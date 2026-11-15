import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 8

    property var zones: []

    // Heure de chaque fuseau via `date` (fiable, indépendant de Qt).
    Process {
        id: read
        running: true
        command: ["sh", "-c", "sed -n 's/^[[:space:]]*worldclock[[:space:]]*=[[:space:]]*//p' \"$HOME/.config/rca/settings.conf\" | while IFS='|' read -r tz label; do printf '%s|%s|%s\\n' \"$label\" \"$(TZ=$tz date +%H:%M)\" \"$(TZ=$tz date +'%a %d · UTC%:z')\"; done"]
        stdout: StdioCollector { onStreamFinished: root.zones = text.trim().split("\n").filter(l => l).map(l => l.split("|")) }
    }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: read.running = true }

    PanelHead { title: "Horloge mondiale";  extra: "ICI " + Clock.time; number: "RCA/W" }

    Repeater {
        model: root.zones
        Item {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: 52
            Cut { anchors.fill: parent; cut: 6; fill: Theme.alpha(Theme.fg, 0.04); stroke: Theme.alpha(Theme.fg, 0.2); strokeWidth: 1 }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                ColumnLayout {
                    spacing: 0
                    T { text: modelData[0]; font.weight: Font.Bold; font.pixelSize: 12 }
                    T { text: modelData[2]; color: Theme.muted; font.pixelSize: 9 }
                }
                Item { Layout.fillWidth: true }
                Text { text: modelData[1]; font.family: Theme.hud; font.pixelSize: 30; font.weight: Font.Normal; color: Theme.fgBright }
            }
        }
    }
    T { text: "Villes : worldclock= dans ~/.config/rca/settings.conf"; caps: false; color: Theme.muted; font.pixelSize: 9 }
}
