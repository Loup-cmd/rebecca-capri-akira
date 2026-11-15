import QtQuick
import QtQuick.Layouts
import qs.services

// Bouton biseauté. `active` = aplat orange (sérigraphie), sinon filet fin.
Item {
    id: root

    property string glyph: ""
    property string label: ""
    property string sub: ""
    property bool active: false
    property bool compact: false
    property real cut: Theme.cutSmall
    property color tint: Theme.accent
    readonly property bool hovered: mouse.containsMouse
    signal clicked()
    signal rightClicked()

    implicitWidth: compact ? 30 : Math.max(row.implicitWidth + 20, 30)
    implicitHeight: compact ? 26 : (sub !== "" ? 42 : 30)

    Cut {
        anchors.fill: parent
        cut: root.cut
        fill: root.active ? root.tint : (root.hovered ? Theme.alpha(Theme.fg, 0.08) : "transparent")
        stroke: root.active ? root.tint : Theme.alpha(Theme.fg, root.hovered ? 0.7 : 0.3)
        strokeWidth: 1
        scale: mouse.pressed ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: Theme.fast } }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
        Glyph {
            visible: root.glyph !== ""
            text: root.glyph
            size: root.compact ? 13 : 14
            color: root.active ? Theme.onAccent : Theme.fg
        }
        ColumnLayout {
            visible: root.label !== "" && !root.compact
            spacing: 0
            T {
                text: root.label
                color: root.active ? Theme.onAccent : Theme.fg
                font.weight: Font.Bold
            }
            T {
                visible: root.sub !== ""
                text: root.sub
                font.pixelSize: 9
                color: root.active ? Theme.alpha(Theme.onAccent, 0.8) : Theme.muted
                Layout.maximumWidth: 140
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
