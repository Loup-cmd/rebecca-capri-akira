import QtQuick
import QtQuick.Layouts
import qs.services

// Intertitre de notice : « Nº 02  AUDIO ·········· 20 % ».
RowLayout {
    id: root

    property string index: "01"
    property string title: ""
    property string extra: ""

    spacing: 7
    Layout.fillWidth: true

    Text { text: "Nº " + root.index; font.family: Theme.engrave; font.italic: true; font.pixelSize: 11; color: Theme.brass }
    Text { text: root.title; font.family: Theme.engrave; font.pixelSize: 11; font.weight: Font.DemiBold; font.capitalization: Font.AllUppercase; font.letterSpacing: 2; color: Theme.fg }
    Item {
        Layout.fillWidth: true
        implicitHeight: 2
        clip: true
        Row {
            spacing: 4
            Repeater { model: 120; Rectangle { width: 2; height: 2; radius: 1; color: Theme.alpha(Theme.fg, 0.35) } }
        }
    }
    T { text: root.extra; visible: root.extra !== ""; color: Theme.muted; font.pixelSize: 10; Layout.maximumWidth: 180 }
}
