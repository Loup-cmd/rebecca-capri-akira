import QtQuick
import qs.services

// Petite touche (lecture, pause…) en rectangles simples : utilisée sur les
// surfaces passées au shader CRT (bureau, verrou), où son état change souvent.
Rectangle {
    id: root
    property string glyph: ""
    property bool active: false
    signal clicked()

    implicitWidth: 32
    implicitHeight: 26
    radius: 4
    color: active ? Theme.accent : (mouse.containsMouse ? Theme.alpha(Theme.fg, 0.14) : "transparent")
    border.width: 1
    border.color: active ? Theme.accent : Theme.alpha(Theme.fg, mouse.containsMouse ? 0.75 : 0.38)
    scale: mouse.pressed ? 0.92 : 1
    Behavior on scale { NumberAnimation { duration: Theme.fast } }

    Glyph { anchors.centerIn: parent; text: root.glyph; size: 13; color: root.active ? Theme.onAccent : Theme.fg }
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked() }
}
