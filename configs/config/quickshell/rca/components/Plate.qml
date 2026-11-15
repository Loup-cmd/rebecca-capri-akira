import QtQuick
import qs.services

// Bloc d'instrument du bureau : carte cathodique avec plaque de laiton gravée.
Item {
    id: root
    default property alias content: body.data
    property string title: ""
    property int delay: 0
    property int inset: 16
    signal clicked()

    Card {
        anchors.fill: parent
        animate: true
        delay: root.delay
        padding: 0
        fill: Theme.alpha(Theme.bg, Theme.dark ? 0.84 : 0.9)
        stroke: Theme.alpha(Theme.brass, 0.9)
        strokeWidth: 1.5

        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked() }
        Rectangle {
            x: 22; y: -1
            width: label.implicitWidth + 20; height: 17
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.brassLight }
                GradientStop { position: 1; color: Theme.brass }
            }
            border.width: 1
            border.color: Theme.brassDark
            Text {
                id: label
                anchors.centerIn: parent
                text: root.title
                font.family: Theme.engrave
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 1.6
                color: Theme.brassInk
            }
        }
        Item { id: body; anchors.fill: parent; anchors.margins: root.inset; anchors.topMargin: root.inset + 10 }
    }
}
