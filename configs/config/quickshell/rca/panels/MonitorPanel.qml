import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    Component.onCompleted: Sys.users++
    Component.onDestruction: Sys.users--

    PanelHead { title: "Système";  extra: Math.round(Sys.temp) + " °C"; number: "RCA/01" }

    Section { index: "01";  title: "Processeur"; extra: Math.round(Sys.cpu * 100) + " %" }
    // Historique CPU : barres verticales façon oscilloscope.
    Item {
        Layout.fillWidth: true
        implicitHeight: 56
        Rectangle { anchors.fill: parent; color: Theme.alpha(Theme.fg, 0.04); border.width: 1; border.color: Theme.alpha(Theme.fg, 0.15) }
        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2
            Repeater {
                model: 40
                Item {
                    required property int index
                    width: (parent.width - 39 * 2) / 40
                    height: parent.height
                    readonly property real v: Sys.history[index - (40 - Sys.history.length)] ?? 0
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(1, parent.height * parent.v)
                        color: parent.v > 0.8 ? Theme.capri2 : Theme.capri
                    }
                }
            }
        }
    }

    Section { index: "02";  title: "Mémoire"; extra: Sys.memUsedGb.toFixed(1) + " / " + Sys.memTotalGb.toFixed(1) + " Go" }
    Meter { Layout.fillWidth: true; implicitHeight: 12; segments: 30; value: Sys.mem; color: Sys.mem > 0.85 ? Theme.capri2 : Theme.capri }
    RowLayout {
        Layout.fillWidth: true
        T { text: "SWAP"; color: Theme.muted; font.pixelSize: 9 }
        Meter { Layout.fillWidth: true; implicitHeight: 6; segments: 30; value: Sys.swap; color: Theme.fgDim }
        T { text: Math.round(Sys.swap * 100) + "%"; color: Theme.muted; font.pixelSize: 9 }
    }

    Section { index: "03";  title: "Disque"; extra: Sys.diskText }
    Meter { Layout.fillWidth: true; implicitHeight: 8; segments: 30; value: Sys.disk; color: Theme.fg }

    Section { index: "04";  title: "Gros consommateurs" }
    Repeater {
        model: Sys.top
        RowLayout {
            required property var modelData
            Layout.fillWidth: true
            T { Layout.fillWidth: true; text: modelData.name; caps: false; font.pixelSize: 11 }
            T { text: modelData.mb + " MO"; color: Theme.capri; font.pixelSize: 10 }
        }
    }
    Btn { Layout.fillWidth: true; glyph: "󰨇"; label: "btop"; onClicked: { Ui.closeAll(); Ui.script("rca-tui", "btop btop"); } }
}
