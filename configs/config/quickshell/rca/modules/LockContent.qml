import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Écran de verrouillage : mire de fin d'émission. Horloge phosphore géante,
// tube néon vertical, champ de mot de passe serti de laiton, le tout derrière
// le verre du tube cathodique. (Aperçu : RCA_TEST=1 … ipc call test lock.)
Rectangle {
    id: root
    color: "black"

    Component.onCompleted: Clock.wantSeconds = true
    Component.onDestruction: Clock.wantSeconds = false

    Item {
        anchors.fill: parent
        layer.enabled: Theme.crtShader
        layer.effect: CrtScreen { curvature: 0.03; vignette: 0.75 }

        Image {
            anchors.fill: parent
            source: "file://" + Theme.state + "/wallpaper"
            sourceSize: Qt.size(root.width, root.height)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
        }
        Rectangle { anchors.fill: parent; color: Theme.alpha(Theme.glass, Theme.dark ? 0.78 : 0.7) }

        // Tube néon vertical.
        Neon {
            x: root.width * 0.075; y: root.height * 0.12
            width: 5; height: root.height * 0.76
            text: ""
            glow: Theme.accent
            strength: 1
            Rectangle { anchors.fill: parent; radius: 2.5; color: Theme.nixie }
        }

        ColumnLayout {
            x: root.width * 0.075 + 44
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            RowLayout {
                spacing: 10
                Lamp { on: true; color: Theme.red; blink: true }
                Neon { text: "POSTE VERROUILLÉ  ·  REBECCA CAPRI AKIRA"; font.pixelSize: 14; font.letterSpacing: 4; strength: 0.5 }
            }
            RowLayout {
                spacing: 10
                Neon { text: Clock.time; font.pixelSize: 220; font.letterSpacing: 6; strength: 0.9 }
                Neon { Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 44; text: Clock.seconds; font.pixelSize: 44; color: Theme.nixie; strength: 0.7 }
            }
            Neon { text: Clock.longDate.toUpperCase(); font.pixelSize: 26; font.letterSpacing: 5; strength: 0.45 }

            // Champ de mot de passe.
            Item {
                id: field
                Layout.topMargin: 40
                implicitWidth: 480
                implicitHeight: 58
                property real shakeX: 0
                transform: Translate { x: field.shakeX }

                Rectangle { anchors.fill: parent; radius: 8; color: Theme.alpha(Theme.glass, 0.92); border.width: 2; border.color: Lock.failed ? Theme.red : Theme.brass }
                Rectangle { anchors.fill: parent; anchors.margins: 5; radius: 5; color: "transparent"; border.width: 1; border.color: Theme.alpha(Lock.failed ? Theme.red : Theme.nixie, 0.5) }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 12
                    Glyph { text: Lock.checking ? "󰔟" : "󰌾"; size: 20; color: Lock.failed ? Theme.red : Theme.nixie }
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        TextInput {
                            id: pass
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            color: Theme.nixie
                            font.family: Theme.hud
                            font.pixelSize: 20
                            font.letterSpacing: 5
                            focus: true
                            enabled: !Lock.checking
                            onAccepted: Lock.submit(text)
                            Keys.onEscapePressed: text = ""
                            Component.onCompleted: forceActiveFocus()
                        }
                        Neon {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: pass.text === ""
                            text: Lock.failed ? Lock.message : Lock.checking ? "VÉRIFICATION…" : "MOT DE PASSE ▮"
                            color: Lock.failed ? Theme.red : Theme.alpha(Theme.nixie, 0.75)
                            strength: 0.4
                            font.pixelSize: 14
                            font.letterSpacing: 3
                        }
                    }
                }
                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: field; property: "shakeX"; to: -14; duration: 50 }
                    NumberAnimation { target: field; property: "shakeX"; to: 12; duration: 60 }
                    NumberAnimation { target: field; property: "shakeX"; to: -8; duration: 60 }
                    NumberAnimation { target: field; property: "shakeX"; to: 0; duration: 60 }
                }
                Connections {
                    target: Lock
                    function onShake() {
                        pass.text = "";
                        shake.restart();
                    }
                }
            }

            RowLayout {
                visible: Media.player !== null
                Layout.topMargin: 22
                spacing: 8
                Key { glyph: "󰒮"; onClicked: Media.previous() }
                Key { glyph: Media.playing ? "󰏤" : "󰐊"; active: true; onClicked: Media.toggle() }
                Key { glyph: "󰒭"; onClicked: Media.next() }
                T { text: Media.title + (Media.artist ? " — " + Media.artist : ""); caps: false; font.family: Theme.sans; font.pixelSize: 13; color: Theme.dial; Layout.maximumWidth: 400 }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 40
            spacing: 14
            Row {
                visible: Battery.present
                spacing: 8
                Tube { anchors.verticalCenter: parent.verticalCenter; value: Battery.pct() / 100 }
                T { text: Battery.pct() + "%"; color: Theme.dial; font.pixelSize: 13 }
            }
            T { text: Net.name; color: Theme.dial; font.pixelSize: 13 }
        }
    }
}
