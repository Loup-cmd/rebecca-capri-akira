import QtQuick
import QtQuick.Layouts
import qs.services

// Interrupteur en ligne : libellé à gauche, bloc ON/OFF à droite.
// Ancrages simples (pas de layouts imbriqués) : taille stable, aucun recalcul en boucle.
Item {
    id: root

    property string glyph: ""
    property string label: ""
    property string sub: ""
    property bool checked: false
    signal toggled()

    implicitWidth: 120
    implicitHeight: 40
    Layout.fillWidth: true
    Layout.preferredWidth: 120

    Cut {
        anchors.fill: parent
        cut: Theme.cutSmall
        fill: root.checked ? Theme.alpha(Theme.accent, 0.12) : (mouse.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent")
        stroke: root.checked ? Theme.accent : Theme.alpha(Theme.fg, 0.3)
        strokeWidth: 1
    }

    Glyph {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: root.glyph !== "" ? 16 : 0
        text: root.glyph
        color: root.checked ? Theme.accent : Theme.fg
    }

    Cut {
        id: pill
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 16
        cut: 4
        fill: root.checked ? Theme.accent : "transparent"
        stroke: root.checked ? Theme.accent : Theme.alpha(Theme.fg, 0.5)
        strokeWidth: 1
    }
    T {
        anchors.centerIn: pill
        text: root.checked ? "ON" : "OFF"
        font.pixelSize: 9
        font.weight: Font.Bold
        color: root.checked ? Theme.onAccent : Theme.muted
    }

    T {
        id: title
        anchors.left: icon.right
        anchors.leftMargin: 8
        anchors.right: pill.left
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.topMargin: root.sub !== "" ? 6 : 0
        height: root.sub !== "" ? 16 : parent.height
        text: root.label
        font.weight: Font.Bold
    }
    T {
        visible: root.sub !== ""
        anchors.left: title.left
        anchors.right: title.right
        anchors.top: title.bottom
        text: root.sub
        color: Theme.muted
        font.pixelSize: 9
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
