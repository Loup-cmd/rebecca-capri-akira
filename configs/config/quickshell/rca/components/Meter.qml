import QtQuick
import qs.services

// Jauge segmentée (VU-mètre). Cliquer / glisser règle la valeur si `interactive`.
Item {
    id: root

    property real value: 0
    property int segments: 24
    property color color: Theme.accent
    property bool interactive: false
    signal moved(real v)

    implicitHeight: 10
    implicitWidth: 200

    Row {
        anchors.fill: parent
        spacing: 2
        Repeater {
            model: root.segments
            Rectangle {
                required property int index
                width: (root.width - (root.segments - 1) * 2) / root.segments
                height: root.height
                color: (index + 0.5) / root.segments <= root.value ? root.color : Theme.alpha(Theme.fg, 0.14)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
        function set(x) { root.moved(Math.max(0, Math.min(1, x / width))); }
        onPressed: e => set(e.x)
        onPositionChanged: e => { if (pressed) set(e.x); }
        onWheel: e => root.moved(Math.max(0, Math.min(1, root.value + (e.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
