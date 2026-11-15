import QtQuick
import QtQuick.Layouts
import qs.services

// Carte du lecteur en cours : pochette, titre, contrôles, progression.
Item {
    id: root
    implicitHeight: 84

    Cut {
        anchors.fill: parent
        cut: Theme.cutSmall
        fill: Theme.alpha(Theme.fg, 0.05)
        stroke: Theme.alpha(Theme.fg, 0.3)
        strokeWidth: 1
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Item {
            implicitWidth: 64
            implicitHeight: 64
            Rectangle { anchors.fill: parent; color: Theme.accent }
            Image {
                anchors.fill: parent
                source: Media.art
                sourceSize: Qt.size(128, 128)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: Media.art === ""
                text: "󰎈"
                font.family: Theme.icons
                font.pixelSize: 28
                font.weight: Font.Normal
                color: Theme.onAccent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            T { text: Media.player?.identity ?? ""; color: Theme.accent; font.pixelSize: 9 }
            Text {
                Layout.fillWidth: true
                text: Media.title || "—"
                font.family: Theme.hud
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.fgBright
                elide: Text.ElideRight
            }
            T { Layout.fillWidth: true; text: Media.artist; caps: false; font.family: Theme.sans; font.pixelSize: 11; color: Theme.fgDim }
            RowLayout {
                spacing: 4
                Btn { compact: true; glyph: "󰒮"; onClicked: Media.previous() }
                Btn { compact: true; glyph: Media.playing ? "󰏤" : "󰐊"; active: true; onClicked: Media.toggle() }
                Btn { compact: true; glyph: "󰒭"; onClicked: Media.next() }
            }
        }
    }
}
