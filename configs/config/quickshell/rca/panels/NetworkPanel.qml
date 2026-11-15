import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    property var asking: null   // réseau qui attend son mot de passe

    Component.onCompleted: Net.scan(true)
    Component.onDestruction: Net.scan(false)

    PanelHead { title: "Réseau";  extra: Net.name; number: "RCA/03" }

    Toggle { glyph: Net.glyph(); label: Net.wifiOn ? "Wi-Fi activé" : "Wi-Fi coupé"; sub: Net.wiredUp ? "Câble branché" : ""; checked: Net.wifiOn; onToggled: Net.toggleWifi() }

    Section { index: "01";  title: "Réseaux"; extra: Net.networks.length + ""; visible: Net.wifiOn }

    ListView {
        visible: Net.wifiOn
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, 360)
        clip: true
        spacing: 4
        model: Net.networks
        delegate: Item {
            id: n
            required property var modelData
            width: ListView.view.width
            implicitHeight: 36
            readonly property bool secured: modelData.security !== WifiSecurityType.Open && modelData.security !== WifiSecurityType.Owe
            readonly property real s: modelData.signalStrength > 1 ? modelData.signalStrength / 100 : modelData.signalStrength
            Cut {
                anchors.fill: parent
                cut: 5
                fill: n.modelData.connected ? Theme.alpha(Theme.capri, 0.12) : (m.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent")
                stroke: n.modelData.connected ? Theme.capri : Theme.alpha(Theme.fg, 0.2)
                strokeWidth: 1
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8
                Glyph { text: n.s > 0.75 ? "󰤨" : n.s > 0.5 ? "󰤥" : n.s > 0.25 ? "󰤢" : "󰤟"; color: n.modelData.connected ? Theme.capri : Theme.fg }
                T { Layout.fillWidth: true; text: n.modelData.name; caps: false; font.family: Theme.sans; font.pixelSize: 12; font.weight: n.modelData.connected ? Font.Bold : Font.Normal }
                T { text: n.modelData.stateChanging ? "…" : n.modelData.connected ? "CONNECTÉ" : n.modelData.known ? "CONNU" : ""; font.pixelSize: 9; color: Theme.muted }
                Glyph { visible: n.secured; text: "󰌾"; size: 11; color: Theme.muted }
            }
            MouseArea {
                id: m
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (n.modelData.connected) n.modelData.disconnect();
                    else if (n.modelData.known || !n.secured) n.modelData.connect();
                    else { root.asking = n.modelData; pass.text = ""; pass.forceActiveFocus(); }
                }
            }
        }
    }

    // Mot de passe d'un nouveau réseau.
    ColumnLayout {
        visible: root.asking !== null
        Layout.fillWidth: true
        spacing: 6
        T { text: "CLÉ POUR « " + (root.asking?.name ?? "") + " »"; color: Theme.capri; font.pixelSize: 10 }
        Item {
            Layout.fillWidth: true
            implicitHeight: 32
            Cut { anchors.fill: parent; cut: 5; fill: Theme.bgLight; stroke: Theme.capri; strokeWidth: 1 }
            TextInput {
                id: pass
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Theme.fg
                font.family: Theme.hud
                font.pixelSize: 13
                onAccepted: {
                    if (root.asking) root.asking.connectWithPsk(text);
                    root.asking = null;
                }
                Keys.onEscapePressed: root.asking = null
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰑓"; label: "Rechercher"; onClicked: { Net.scan(false); Net.scan(true); } }
        Btn { Layout.fillWidth: true; glyph: "󰒓"; label: "Avancé"; onClicked: { Ui.closeAll(); Ui.run("kitty --class rca.float -e nmtui"); } }
    }
}
