import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// Pupitre du bas : toujours en place (il ne se replie jamais tout seul).
// Trois organes seulement : le levier Utilitaires, la jauge de batterie et
// l'heure en chiffres lumineux. Des voyants n'apparaissent qu'en cas de besoin
// (enregistrement en cours, notifications en attente, Capri à l'écoute).
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    WlrLayershell.layer: Quickshell.env("RCA_TEST_DASH") === "1" ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.namespace: "rca-bar"
    anchors { bottom: true; left: true; right: true }
    implicitHeight: Theme.bar
    exclusiveZone: Theme.bar
    color: "transparent"
    visible: Ui.barOpen

    // Les tubes chauffent à l'allumage.
    property real warm
    NumberAnimation on warm { from: 0; to: 1; duration: 1800; easing.type: Easing.InCubic }

    readonly property string hh: Qt.formatTime(Clock.now, "HH")
    readonly property string mm: Qt.formatTime(Clock.now, "mm")

    // Corps du pupitre : bakélite sombre la nuit, émail crème le jour.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: Theme.bgDark }
            GradientStop { position: 1; color: Theme.bgDarker }
        }
    }
    Image { anchors.fill: parent; source: Theme.assets + "/scanlines.png"; fillMode: Image.Tile; opacity: Theme.dark ? 0.22 : 0.06; smooth: false }
    // Rail de laiton et rivets.
    Rectangle {
        width: parent.width; height: 3
        gradient: Gradient {
            GradientStop { position: 0; color: Theme.brassLight }
            GradientStop { position: 1; color: Theme.brassDark }
        }
    }
    Repeater {
        model: [6, root.width / 2 - 3, root.width - 12]
        Rectangle {
            required property real modelData
            x: modelData; y: Theme.bar / 2
            width: 6; height: 6; radius: 3
            color: Theme.brass
            border.width: 1
            border.color: Theme.brassDark
        }
    }
    // Règle gravée, au centre : pure décoration.
    Row {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0
        spacing: 7
        opacity: 0.5
        Repeater {
            model: 31
            Rectangle {
                required property int index
                anchors.bottom: parent.bottom
                visible: index !== 15
                width: 1
                height: index % 5 === 0 ? 7 : 4
                color: Theme.brass
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 3
        anchors.leftMargin: 22
        anchors.rightMargin: 24
        spacing: 12

        // ── Levier « Utilitaires » : ouvre le menu déroulant.
        Item {
            id: lever
            readonly property bool open: Ui.drawer !== "" && Ui.drawerSide === "left"
            implicitWidth: leverRow.implicitWidth + 26
            implicitHeight: 24
            Cut {
                anchors.fill: parent
                cut: 7
                fill: lever.open ? Theme.accent : (leverMouse.containsMouse ? Theme.brassLight : Theme.brass)
                stroke: Theme.brassDark
                strokeWidth: 1
                scale: leverMouse.pressed ? 0.96 : 1
                Behavior on scale { NumberAnimation { duration: Theme.fast } }
            }
            RowLayout {
                id: leverRow
                anchors.centerIn: parent
                spacing: 8
                Lamp { on: lever.open; color: Theme.nixie; d: 7 }
                Text {
                    text: "UTILITAIRES"
                    font.family: Theme.engrave
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    color: lever.open ? Theme.onAccent : Theme.brassInk
                }
                Glyph {
                    text: "󰅃"
                    size: 14
                    color: lever.open ? Theme.onAccent : Theme.brassInk
                    rotation: lever.open ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: Theme.med; easing.type: Easing.OutBack } }
                }
            }
            MouseArea {
                id: leverMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: e => {
                    if (e.button === Qt.RightButton) Ui.openLauncher("apps", "");
                    else if (lever.open) Ui.drawer = "";
                    else Ui.openPanel("utils", "left");
                }
            }
        }

        // ── Voyants (uniquement quand ils ont quelque chose à dire).
        Item {
            visible: Ui.recording
            implicitWidth: recRow.implicitWidth; implicitHeight: 24
            RowLayout {
                id: recRow
                anchors.centerIn: parent
                spacing: 4
                Lamp { on: true; color: Theme.red; blink: true }
                T { text: "REC"; color: Theme.red; font.weight: Font.Bold }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Ui.script("rca-capture", "record stop") }
        }
        Item {
            visible: Notifs.count > 0
            implicitWidth: 18; implicitHeight: 24
            Lamp { anchors.centerIn: parent; on: !Ui.silenced; color: Theme.nixie }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Ui.togglePanel("notifications", "left") }
        }

        Item {
            visible: Ui.voice
            implicitWidth: voiceRow.implicitWidth; implicitHeight: 24
            RowLayout {
                id: voiceRow
                anchors.centerIn: parent
                spacing: 4
                Lamp { on: true; color: Theme.capri2; blink: true }
                T { text: "CAPRI ÉCOUTE"; color: Theme.capri; font.weight: Font.Bold }
            }
        }

        Item { Layout.fillWidth: true }

        // ── Batterie : tube à colonne lumineuse.
        Item {
            visible: Battery.present
            implicitWidth: batRow.implicitWidth + 8
            implicitHeight: 24
            RowLayout {
                id: batRow
                anchors.centerIn: parent
                spacing: 7
                Glyph { text: Battery.charging ? "󱐋" : "󰁹"; size: 13; color: Battery.charging ? Theme.nixie : Theme.fgDim }
                Tube {
                    implicitWidth: 78
                    implicitHeight: 10
                    value: Battery.pct() / 100
                    color: Battery.pct() <= 15 && !Battery.charging ? Theme.red : Theme.nixie
                    pulse: Battery.charging && Battery.pct() < 99
                }
                T { text: Battery.pct() + "%"; font.pixelSize: 12; color: Battery.pct() <= 15 && !Battery.charging ? Theme.red : Theme.fg; Layout.minimumWidth: 30 }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Ui.togglePanel("power", "right") }
        }

        Rectangle { implicitWidth: 1; implicitHeight: 22; color: Theme.alpha(Theme.brass, 0.6) }

        // ── Heure : chiffres de terminal, léger halo.
        Item {
            implicitWidth: clock.implicitWidth
            implicitHeight: 24
            Neon {
                id: clock
                anchors.centerIn: parent
                text: root.hh + ":" + root.mm
                color: Theme.nixie
                glow: Theme.accent
                strength: 0.35 * root.warm
                opacity: 0.3 + 0.7 * root.warm
                font.pixelSize: 19
                font.letterSpacing: 2
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Ui.togglePanel("calendar", "right") }
        }
    }
}
