import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10
    focus: true

    property int cursor: 0
    Keys.onUpPressed: cursor = Math.max(0, cursor - 1)
    Keys.onDownPressed: cursor = Math.min(Notifs.history.length - 1, cursor + 1)
    Keys.onDeletePressed: if (Notifs.history[cursor]) Notifs.forget(Notifs.history[cursor].id)

    PanelHead { title: "Notifications";  extra: Notifs.count + " ENTRÉES"; number: "RCA/07" }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: Ui.silenced ? "󰂛" : "󰂚"; label: Ui.silenced ? "Silence actif" : "Silence"; active: Ui.silenced; onClicked: Ui.silenced = !Ui.silenced }
        Btn { Layout.fillWidth: true; glyph: "󰎟"; label: "Tout effacer"; onClicked: Notifs.clearHistory() }
    }

    T {
        visible: Notifs.history.length === 0
        Layout.fillWidth: true
        Layout.topMargin: 16
        Layout.bottomMargin: 16
        horizontalAlignment: Text.AlignHCenter
        text: "— AUCUNE TRANSMISSION —"
        color: Theme.muted
    }

    ListView {
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, 460)
        clip: true
        spacing: 6
        model: Notifs.history
        currentIndex: root.cursor
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: entry
            required property var modelData
            required property int index
            width: ListView.view.width
            implicitHeight: col.implicitHeight + 16
            readonly property bool urgent: modelData.urgency === 2

            Cut {
                anchors.fill: parent
                cut: Theme.cutSmall
                fill: entry.index === root.cursor ? Theme.alpha(Theme.accent, 0.1) : Theme.alpha(Theme.fg, 0.04)
                stroke: entry.urgent ? Theme.red : Theme.alpha(Theme.fg, 0.25)
                strokeWidth: 1
            }
            Rectangle { width: 3; height: parent.height - 12; y: 6; x: 0; color: entry.urgent ? Theme.red : Theme.accent }

            ColumnLayout {
                id: col
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                anchors.leftMargin: 12
                spacing: 2
                RowLayout {
                    Layout.fillWidth: true
                    T { text: entry.modelData.app; color: Theme.accent; font.pixelSize: 9; Layout.fillWidth: true }
                    T { text: Qt.formatTime(entry.modelData.time, "HH:mm"); color: Theme.muted; font.pixelSize: 9 }
                    Glyph {
                        text: "󰅖"; size: 12; color: Theme.muted
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Notifs.forget(entry.modelData.id) }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: entry.modelData.summary
                    font.family: Theme.sans
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: Theme.fgBright
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: entry.modelData.body
                    textFormat: Text.StyledText
                    font.family: Theme.sans
                    font.pixelSize: 11
                    color: Theme.fgDim
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }
            }
        }
    }
}
