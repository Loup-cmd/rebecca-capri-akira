import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import qs.services
import qs.components

// Demande d'authentification (sudo graphique, montage de disque…).
PanelWindow {
    id: root

    required property var flow

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-polkit"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: Theme.alpha(Theme.bgDarker, 0.6)

    Card {
        id: card
        anchors.centerIn: parent
        width: 480
        height: col.implicitHeight + 40
        padding: 20
        cut: 16
        animate: true
        rivets: true
        fill: Theme.bg
        stroke: root.flow?.failed ? Theme.red : Theme.accent
        strokeWidth: 2

        ColumnLayout {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            PanelHead { title: "Autorisation";  extra: "POLKIT"; number: "RCA/AUTH" }

            Text {
                Layout.fillWidth: true
                text: root.flow?.message ?? ""
                font.family: Theme.sans
                font.pixelSize: 13
                color: Theme.fgBright
                wrapMode: Text.Wrap
            }
            T {
                Layout.fillWidth: true
                text: root.flow?.actionId ?? ""
                caps: false
                color: Theme.muted
                font.pixelSize: 9
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 42
                Cut { anchors.fill: parent; cut: 8; fill: Theme.bgLight; stroke: root.flow?.failed ? Theme.red : Theme.fg; strokeWidth: 1.5 }
                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: (root.flow?.responseVisible ?? false) ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "■"
                    color: Theme.fgBright
                    font.family: Theme.hud
                    font.pixelSize: 16
                    focus: true
                    Component.onCompleted: forceActiveFocus()
                    onAccepted: { root.flow.submit(text); text = ""; }
                    Keys.onEscapePressed: root.flow.cancelAuthenticationRequest()
                }
                T {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: root.flow?.failed ? "REFUSÉ — RÉESSAYER" : (root.flow?.inputPrompt || "MOT DE PASSE")
                    color: root.flow?.failed ? Theme.red : Theme.muted
                }
            }
            T {
                visible: (root.flow?.supplementaryMessage ?? "") !== ""
                text: root.flow?.supplementaryMessage ?? ""
                caps: false
                color: (root.flow?.supplementaryIsError ?? false) ? Theme.red : Theme.muted
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Btn { Layout.fillWidth: true; label: "Annuler"; onClicked: root.flow.cancelAuthenticationRequest() }
                Btn { Layout.fillWidth: true; label: "Autoriser"; active: true; onClicked: { root.flow.submit(input.text); input.text = ""; } }
            }
        }
    }
}
