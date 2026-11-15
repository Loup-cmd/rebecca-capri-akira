import QtQuick
import qs.services

// Tube à barre lumineuse (façon IN-13) : la colonne s'allonge avec la valeur.
Item {
    id: root
    property real value: 0
    property color color: Theme.nixie
    property bool pulse: false
    implicitWidth: 96
    implicitHeight: 14

    Rectangle { anchors.fill: parent; radius: height / 2; color: Theme.glass; border.width: 1; border.color: Theme.alpha(Theme.brass, 0.75) }
    Rectangle { x: 7; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 14; height: 1; color: Theme.alpha(Theme.brassLight, 0.22) }
    Neon {
        id: column
        x: 7
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(3, (root.width - 14) * Math.max(0, Math.min(1, root.value)))
        height: 4
        text: ""
        strength: 0.9
        glow: root.color
        Rectangle { anchors.fill: parent; radius: 2; color: root.color }
        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        SequentialAnimation on opacity {
            running: root.pulse
            loops: Animation.Infinite
            NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
        }
    }
    Rectangle { x: 0; width: 5; height: parent.height; radius: 2; color: Theme.brassDark; border.width: 1; border.color: Theme.brass }
    Rectangle { x: parent.width - 5; width: 5; height: parent.height; radius: 2; color: Theme.brassDark; border.width: 1; border.color: Theme.brass }
    Rectangle { x: 6; y: 2; width: parent.width - 12; height: 1; color: Qt.rgba(1, 1, 1, 0.14) }
}
