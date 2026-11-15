import QtQuick
import QtQuick.Layouts
import qs.services

// En-tête de panneau, façon en-tête d'imprimé : titre à empattements espacé,
// numéro en « ticket », double filet Art déco avec losange central.
ColumnLayout {
    id: root

    property string title: ""
    property string extra: ""
    property string number: ""

    spacing: 6
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Text {
            text: root.title
            font.family: Theme.engrave
            font.pixelSize: 18
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 3.5
            color: Theme.fgBright
        }
        T {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            horizontalAlignment: Text.AlignRight
            text: root.extra
            color: Theme.muted
            font.pixelSize: 10
        }
        Rectangle {
            visible: root.number !== ""
            implicitWidth: plate.implicitWidth + 12
            implicitHeight: 15
            color: "transparent"
            border.width: 1
            border.color: Theme.brass
            Text { id: plate; anchors.centerIn: parent; text: root.number; font.family: Theme.engrave; font.pixelSize: 8; font.weight: Font.Bold; font.letterSpacing: 1.5; color: Theme.brass }
        }
    }
    Item {
        Layout.fillWidth: true
        implicitHeight: 7
        Rectangle { y: 1; width: parent.width; height: 1; color: Theme.brass }
        Rectangle { y: 5; width: parent.width; height: 1; color: Theme.alpha(Theme.brass, 0.5) }
        Rectangle { anchors.centerIn: parent; width: 22; height: 7; color: Theme.bg }
        Rectangle { anchors.centerIn: parent; width: 6; height: 6; rotation: 45; color: Theme.accent }
    }
}
