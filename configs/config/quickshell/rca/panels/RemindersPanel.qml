import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10
    property var items: []

    Process {
        id: list
        running: true
        command: [Theme.bin + "/rca-reminder", "list"]
        stdout: StdioCollector { onStreamFinished: root.items = text.trim() === "" ? [] : text.trim().split("\n").map(l => l.split("\t")) }
    }

    PanelHead { title: "Rappels";  extra: root.items.length + " ACTIFS"; number: "RCA/R" }
    T { visible: root.items.length === 0; text: "— AUCUN RAPPEL —"; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
    Repeater {
        model: root.items
        Item {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: 36
            Cut { anchors.fill: parent; cut: 5; fill: Theme.alpha(Theme.fg, 0.04); stroke: Theme.alpha(Theme.fg, 0.2); strokeWidth: 1 }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                T { text: modelData[0]; color: Theme.accent; font.weight: Font.Bold; font.pixelSize: 13 }
                T { Layout.fillWidth: true; text: modelData[1] ?? ""; caps: false; font.family: Theme.sans; font.pixelSize: 12 }
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰀠"; label: "Nouveau"; onClicked: Ui.openLauncher("reminder", "") }
        Btn { Layout.fillWidth: true; glyph: "󰎟"; label: "Tout effacer"; onClicked: { Ui.script("rca-reminder", "clear"); root.items = []; } }
    }
}
