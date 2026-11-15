import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.components

RowLayout {
    id: root
    spacing: 16

    property date shown: new Date(Clock.now.getFullYear(), Clock.now.getMonth(), 1)
    property var reminders: []

    Process {
        running: true
        command: [Theme.bin + "/rca-reminder", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.reminders = text.trim() === "" ? [] : text.trim().split("\n").map(l => l.split("\t"))
        }
    }

    ColumnLayout {
        Layout.preferredWidth: 300
        Layout.alignment: Qt.AlignTop
        spacing: 8

        PanelHead {
            title: Qt.locale("fr_FR").standaloneMonthName(root.shown.getMonth())
            extra: root.shown.getFullYear()
            number: "RCA/09"
        }

        RowLayout {
            Layout.fillWidth: true
            Btn { compact: true; glyph: "󰅁"; onClicked: root.shown = new Date(root.shown.getFullYear(), root.shown.getMonth() - 1, 1) }
            Item { Layout.fillWidth: true }
            Btn { label: "Aujourd'hui"; onClicked: root.shown = new Date(Clock.now.getFullYear(), Clock.now.getMonth(), 1) }
            Item { Layout.fillWidth: true }
            Btn { compact: true; glyph: "󰅂"; onClicked: root.shown = new Date(root.shown.getFullYear(), root.shown.getMonth() + 1, 1) }
        }

        GridLayout {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2
            Layout.fillWidth: true

            Repeater {
                model: ["LU", "MA", "ME", "JE", "VE", "SA", "DI"]
                Text {
                    required property string modelData
                    required property int index
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.family: Theme.hud
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: index >= 5 ? Theme.accent : Theme.muted
                }
            }
            Repeater {
                model: 42
                Item {
                    id: cell
                    required property int index
                    readonly property int offset: (root.shown.getDay() + 6) % 7
                    readonly property date day: new Date(root.shown.getFullYear(), root.shown.getMonth(), index - offset + 1)
                    readonly property bool inMonth: day.getMonth() === root.shown.getMonth()
                    readonly property bool today: day.toDateString() === Clock.now.toDateString()
                    Layout.fillWidth: true
                    implicitHeight: 32
                    Cut {
                        anchors.fill: parent
                        cut: 4
                        fill: cell.today ? Theme.accent : "transparent"
                        stroke: cell.today ? Theme.accent : Theme.alpha(Theme.fg, cell.inMonth ? 0.15 : 0.05)
                        strokeWidth: 1
                    }
                    T {
                        anchors.centerIn: parent
                        text: Theme.pad2(cell.day.getDate())
                        font.pixelSize: 12
                        font.weight: cell.today ? Font.Bold : Font.Normal
                        color: cell.today ? Theme.onAccent : (cell.inMonth ? Theme.fg : Theme.alpha(Theme.fg, 0.3))
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: 8

        Text {
            text: Clock.time
            font.family: Theme.hud
            font.pixelSize: 54
            color: Theme.fgBright
        }
        T { text: Clock.longDate; caps: false; font.family: Theme.sans; font.pixelSize: 12; color: Theme.fgDim; Layout.fillWidth: true }

        Section { index: "01";  title: "Rappels"; extra: root.reminders.length + "" }
        T { visible: root.reminders.length === 0; text: "— RIEN DE PRÉVU —"; color: Theme.muted }
        Repeater {
            model: root.reminders
            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 6
                T { text: modelData[0]; color: Theme.accent; font.weight: Font.Bold }
                T { Layout.fillWidth: true; text: modelData[1] ?? ""; caps: false; font.family: Theme.sans }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Btn { Layout.fillWidth: true; glyph: "󰀠"; label: "Nouveau"; onClicked: Ui.openLauncher("reminder", "") }
            Btn { Layout.fillWidth: true; glyph: "󰥔"; label: "Monde"; onClicked: Ui.openPanel("worldclock") }
        }
    }
}
