import QtQuick
import qs.services

// Voyant : petite ampoule sertie de laiton, avec halo quand elle est allumée.
Item {
    id: root
    property bool on: false
    property color color: Theme.accent
    property real d: 9
    property bool blink: false
    implicitWidth: d + 6
    implicitHeight: d + 6

    Rectangle { anchors.centerIn: parent; width: root.d + 4; height: width; radius: width / 2; color: Theme.brassDark; border.width: 1; border.color: Theme.brass }
    Neon {
        anchors.centerIn: parent
        width: root.d; height: root.d
        text: ""
        glow: root.color
        strength: root.on ? 1 : 0
        Rectangle { anchors.fill: parent; radius: width / 2; color: root.on ? Qt.lighter(root.color, 1.25) : Theme.alpha(root.color, 0.2) }
        SequentialAnimation on opacity {
            running: root.blink && root.on
            loops: Animation.Infinite
            NumberAnimation { to: 0.25; duration: 550 }
            NumberAnimation { to: 1; duration: 550 }
        }
    }
}
