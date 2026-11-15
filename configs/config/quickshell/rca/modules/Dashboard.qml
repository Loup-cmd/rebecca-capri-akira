import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Bureau vide : un seul bandeau, entre l'heure et le numéro d'espace.
// À gauche la radio (lecture en cours, oscilloscope), à droite les manomètres
// de la machine, aux couleurs de Capri. N'existe que tant que l'espace est vide.
Item {
    id: dash

    Component.onCompleted: { Sys.users++; Cava.wanted = true; }
    Component.onDestruction: { Sys.users--; Cava.wanted = false; }

    Plate {
        anchors.fill: parent
        title: "RADIO  ·  MACHINERIE"
        inset: 10

        RowLayout {
            anchors.fill: parent
            spacing: 14

            // Oscilloscope.
            Rectangle {
                id: scope
                Layout.preferredWidth: 132
                Layout.fillHeight: true
                radius: 10
                color: Theme.glass
                border.width: 2
                border.color: Theme.brass
                clip: true
                Repeater {
                    model: 4
                    Rectangle { required property int index; x: (index + 1) * scope.width / 5; width: 1; height: scope.height; color: Theme.alpha(Theme.capri, 0.14) }
                }
                Rectangle { y: scope.height / 2; height: 1; width: scope.width; color: Theme.alpha(Theme.capri, 0.2) }
                Row {
                    anchors.fill: parent
                    anchors.margins: 7
                    spacing: 1
                    Repeater {
                        model: Cava.bars
                        Item {
                            required property int index
                            width: (scope.width - 14 - (Cava.bars - 1)) / Cava.bars
                            height: parent.height
                            readonly property real v: Cava.values[index] ?? 0
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: Math.max(1.5, parent.height * parent.v)
                                color: Theme.nixie
                                Behavior on height { NumberAnimation { duration: 70 } }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 1
                T { text: Media.player ? (Media.player.identity || "LECTEUR") : "AUCUNE STATION"; color: Theme.accent; font.pixelSize: 9; font.letterSpacing: 2 }
                Text {
                    Layout.fillWidth: true
                    text: Media.title || "Silence radio"
                    font.family: Theme.engrave
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: Theme.fgBright
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                T { Layout.fillWidth: true; text: Media.artist; caps: false; font.family: Theme.sans; font.pixelSize: 11; color: Theme.fgDim }
                Item { Layout.fillHeight: true }
                RowLayout {
                    spacing: 5
                    visible: Media.player !== null
                    Key { implicitHeight: 22; glyph: "󰒮"; onClicked: Media.previous() }
                    Key { implicitHeight: 22; glyph: Media.playing ? "󰏤" : "󰐊"; active: Media.playing; onClicked: Media.toggle() }
                    Key { implicitHeight: 22; glyph: "󰒭"; onClicked: Media.next() }
                    Item { Layout.fillWidth: true }
                    Glyph { text: Audio.icon(Audio.volume, Audio.muted); size: 12; color: Theme.fgDim }
                    Tube { implicitWidth: 70; implicitHeight: 10; value: Audio.muted ? 0 : Audio.volume }
                }
            }

            Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: Theme.alpha(Theme.brass, 0.6) }

            Row {
                spacing: 10
                Layout.alignment: Qt.AlignVCenter
                Gauge { size: Math.min(78, dash.height - 34); label: "CPU"; value: Sys.cpu; reading: Math.round(Sys.cpu * 100) + "%"; needle: Theme.capri2 }
                Gauge { size: Math.min(78, dash.height - 34); label: "MEM"; value: Sys.mem; reading: Sys.memUsedGb.toFixed(1) + "G"; needle: Theme.capri2 }
                Gauge { size: Math.min(78, dash.height - 34); label: "TEMP"; value: Sys.temp / 100; reading: Math.round(Sys.temp) + "°"; needle: Theme.capri2 }
                MouseArea { width: 0; height: 0 }
            }
        }
        onClicked: Ui.togglePanel("monitor", "right")
    }
}
