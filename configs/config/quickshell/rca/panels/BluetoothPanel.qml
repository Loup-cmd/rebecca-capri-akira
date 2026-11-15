import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    Component.onCompleted: if (Net.btOn) Net.btScan(true)
    Component.onDestruction: Net.btScan(false)

    PanelHead { title: "Bluetooth";  extra: Net.adapter?.name ?? "AUCUN ADAPTATEUR"; number: "RCA/04" }

    Toggle { glyph: Net.btGlyph(); label: Net.btOn ? "Activé" : "Coupé"; sub: Net.adapter?.discovering ? "Recherche en cours…" : ""; checked: Net.btOn; onToggled: { Net.toggleBt(); if (!Net.btOn) Net.btScan(true); } }

    Section { index: "01";  title: "Appareils"; extra: Net.btDevices.length + "" ; visible: Net.btOn }

    ListView {
        visible: Net.btOn
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, 380)
        clip: true
        spacing: 4
        model: Net.btDevices
        delegate: Item {
            id: d
            required property var modelData
            width: ListView.view.width
            implicitHeight: 40
            Cut {
                anchors.fill: parent
                cut: 5
                fill: d.modelData.connected ? Theme.alpha(Theme.capri, 0.12) : (m.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent")
                stroke: d.modelData.connected ? Theme.capri : Theme.alpha(Theme.fg, 0.2)
                strokeWidth: 1
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8
                Glyph {
                    text: (d.modelData.icon ?? "").includes("audio") || (d.modelData.icon ?? "").includes("head") ? "󰋋"
                        : (d.modelData.icon ?? "").includes("phone") ? "󰏲"
                        : (d.modelData.icon ?? "").includes("mouse") ? "󰍽"
                        : (d.modelData.icon ?? "").includes("keyboard") ? "󰌌" : "󰂯"
                    color: d.modelData.connected ? Theme.capri : Theme.fg
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    T { Layout.fillWidth: true; text: d.modelData.name || d.modelData.address; caps: false; font.family: Theme.sans; font.pixelSize: 12; font.weight: Font.DemiBold }
                    T {
                        text: d.modelData.pairing ? "APPAIRAGE…" : d.modelData.connected ? "CONNECTÉ" + (d.modelData.batteryAvailable ? " · " + Math.round(d.modelData.battery * 100) + " %" : "") : d.modelData.paired ? "APPAIRÉ" : "DISPONIBLE"
                        font.pixelSize: 9
                        color: d.modelData.connected ? Theme.capri : Theme.muted
                    }
                }
                Glyph {
                    visible: d.modelData.paired
                    text: "󰆴"; size: 12; color: Theme.muted
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: d.modelData.forget() }
                }
            }
            MouseArea {
                id: m
                anchors.fill: parent
                anchors.rightMargin: 30
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (d.modelData.connected) d.modelData.disconnect();
                    else if (d.modelData.paired) d.modelData.connect();
                    else d.modelData.pair();
                }
            }
        }
    }
}
