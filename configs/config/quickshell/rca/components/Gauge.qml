import QtQuick
import qs.services

// Manomètre : lunette de laiton, cadran émaillé, aiguille montée sur ressort.
Item {
    id: root
    property real value: 0          // 0..1
    property string label: ""
    property string reading: ""
    property real size: 104
    property color needle: Theme.red
    implicitWidth: size
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0; color: Theme.brassLight }
            GradientStop { position: 0.5; color: Theme.brass }
            GradientStop { position: 1; color: Theme.brassDark }
        }
    }
    Rectangle {
        id: face
        anchors.fill: parent
        anchors.margins: root.size * 0.065
        radius: width / 2
        color: Theme.dial
        border.width: 1
        border.color: Theme.brassDark
    }
    Repeater {
        model: 13
        Item {
            required property int index
            anchors.fill: parent
            rotation: -120 + index * 20
            Rectangle {
                x: parent.width / 2 - width / 2
                y: root.size * 0.1
                width: index % 3 === 0 ? 2 : 1
                height: root.size * (index % 3 === 0 ? 0.1 : 0.06)
                color: index >= 10 ? root.needle : Theme.dialInk
                antialiasing: true
            }
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.size * 0.6
        text: root.label
        font.family: Theme.engrave
        font.pixelSize: Math.round(root.size * 0.095)
        font.weight: Font.Bold
        font.letterSpacing: 1
        color: Theme.dialInk
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.size * 0.71
        text: root.reading
        font.family: Theme.hud
        font.pixelSize: Math.round(root.size * 0.12)
        color: Theme.dialInk
    }
    Item {
        anchors.fill: parent
        rotation: -120 + Math.max(0, Math.min(1, root.value)) * 240
        Behavior on rotation { SpringAnimation { spring: 2.4; damping: 0.2; epsilon: 0.2 } }
        Rectangle {
            x: parent.width / 2 - 1
            y: root.size * 0.15
            width: 2
            height: root.size * 0.43
            color: root.needle
            antialiasing: true
        }
    }
    Rectangle {
        anchors.centerIn: parent
        width: root.size * 0.13; height: width; radius: width / 2
        color: Theme.brass
        border.width: 1
        border.color: Theme.brassDark
    }
    // Reflet du verre.
    Rectangle {
        anchors.fill: face
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.28) }
            GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
}
