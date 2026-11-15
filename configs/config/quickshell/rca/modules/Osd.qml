import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// Affichage du volume, de la luminosité, de l'heure ou de la batterie : petit
// cartouche en bas au centre, au-dessus du filet. Se ferme seul.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-osd"
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true }
    margins { bottom: Theme.edge + (Ui.barOpen ? Theme.bar : 0) + 24 }
    implicitWidth: 340
    implicitHeight: 74
    color: "transparent"

    signal done()

    readonly property string kind: Ui.osdKind
    readonly property bool gauge: kind === "volume" || kind === "brightness" || kind === "keyboard"

    readonly property var info: {
        switch (kind) {
        case "volume": return { glyph: Audio.icon(Audio.volume, Audio.muted), title: "Volume", value: Audio.muted ? "MUET" : Math.round(Audio.volume * 100) + "" };
        case "brightness": return { glyph: "󰃠", title: "Luminosité", value: Math.round(Ui.osdValue * 100) + "" };
        case "keyboard": return { glyph: "󰌌", title: "Clavier", value: Math.round(Ui.osdValue * 100) + "" };
        case "mic": return { glyph: Audio.micMuted ? "󰍭" : "󰍬", title: "Micro", value: Audio.micMuted ? "COUPÉ" : "ACTIF" };
        case "time": return { glyph: "󰥔", title: Clock.longDate, value: Clock.time };
        case "battery": return { glyph: Battery.icon(), title: Battery.charging ? "En charge" : (Battery.duration() ? "Reste " + Battery.duration() : "Batterie"), value: Battery.pct() + "%" };
        default: return { glyph: "", title: "", value: "" };
        }
    }

    Timer {
        id: hide
        interval: root.gauge ? 1400 : 2600
        running: true
        onTriggered: card.powerOff()
    }
    Connections {
        target: Ui
        function onOsdRequested() { if (card.opacity < 1) card.powerOn(); hide.restart(); }
    }

    Card {
        id: card
        anchors.fill: parent
        padding: 12
        cut: 12
        fill: Theme.bg
        stroke: Theme.brass
        strokeWidth: 1.5
        animate: true
        onOffDone: root.done()

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Cut {
                implicitWidth: 46
                implicitHeight: 46
                cut: 8
                fill: Theme.accent
                Glyph { anchors.centerIn: parent; text: root.info.glyph; size: 22; color: Theme.onAccent }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    T { text: root.info.title; font.weight: Font.Bold; Layout.fillWidth: true }
                }
                Meter {
                    visible: root.gauge
                    Layout.fillWidth: true
                    implicitHeight: 12
                    segments: 20
                    value: root.kind === "volume" ? (Audio.muted ? 0 : Audio.volume) : Ui.osdValue
                }
                T { visible: !root.gauge; text: root.kind === "time" ? Clock.day + " " + Clock.date : ""; color: Theme.muted; font.pixelSize: 10 }
            }

            Text {
                text: root.info.value
                font.family: Theme.hud
                font.pixelSize: root.gauge ? 28 : 30
                color: Theme.fgBright
                Layout.minimumWidth: 56
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
