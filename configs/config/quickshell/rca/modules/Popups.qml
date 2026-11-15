import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.services
import qs.components

// Bulles de notification : en bas à droite, au-dessus du filet. La fenêtre
// n'existe que s'il y a des bulles (voir shell.qml).
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-notifications"
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true; right: true }
    margins { bottom: Theme.edge + (Ui.barOpen ? Theme.bar : 0) + 10; right: 12 }
    implicitWidth: 380
    implicitHeight: column.implicitHeight
    color: "transparent"

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups

            Item {
                id: bubble
                required property var modelData
                readonly property var n: modelData
                readonly property bool urgent: n.urgency === NotificationUrgency.Critical
                readonly property int timeout: urgent ? 0 : (n.expireTimeout > 0 ? n.expireTimeout : 6000)
                property real progress: 1

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 22

                // Entrée : glisse depuis la droite.
                x: 40
                opacity: 0
                Component.onCompleted: { x = 0; opacity = 1; }
                Behavior on x { NumberAnimation { duration: Theme.med; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.fast } }

                NumberAnimation on progress {
                    id: countdown
                    running: bubble.timeout > 0 && !hover.hovered
                    from: bubble.progress
                    to: 0
                    duration: bubble.timeout * bubble.progress
                    onFinished: bubble.n.expire()
                }

                Card {
                    anchors.fill: parent
                    padding: 0
                    cut: 12
                    animate: true
                    fill: Theme.bg
                    stroke: bubble.urgent ? Theme.red : Theme.brass
                    strokeWidth: 1.5
                }
                Rectangle { x: 0; y: 10; width: 4; height: parent.height - 20; color: bubble.urgent ? Theme.red : Theme.accent }

                RowLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    anchors.leftMargin: 16
                    spacing: 10

                    Item {
                        visible: icon.status === Image.Ready
                        Layout.alignment: Qt.AlignTop
                        implicitWidth: 42
                        implicitHeight: 42
                        Image {
                            id: icon
                            anchors.fill: parent
                            source: bubble.n.image || (bubble.n.appIcon ? Quickshell.iconPath(bubble.n.appIcon, true) : "")
                            sourceSize: Qt.size(84, 84)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            T { text: bubble.n.appName || "SYSTÈME"; color: bubble.urgent ? Theme.red : Theme.accent; font.pixelSize: 9; font.weight: Font.Bold }
                            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.alpha(Theme.fg, 0.2) }
                            T { text: Clock.time; color: Theme.muted; font.pixelSize: 9 }
                            Glyph {
                                text: "󰅖"; size: 12; color: Theme.muted
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bubble.n.dismiss() }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: bubble.n.summary
                            font.family: Theme.sans
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: Theme.fgBright
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: bubble.n.body
                            textFormat: Text.StyledText
                            font.family: Theme.sans
                            font.pixelSize: 12
                            color: Theme.fgDim
                            wrapMode: Text.Wrap
                            maximumLineCount: 5
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            visible: bubble.n.actions.length > 0
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            spacing: 6
                            Repeater {
                                model: bubble.n.actions
                                Btn {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    label: modelData.text || modelData.identifier
                                    onClicked: modelData.invoke()
                                }
                            }
                        }
                    }
                }

                // Compte à rebours en pied de bulle.
                Rectangle {
                    visible: bubble.timeout > 0
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 12
                    anchors.bottomMargin: 4
                    width: (parent.width - 24) * bubble.progress
                    height: 2
                    color: Theme.accent
                }

                HoverHandler { id: hover }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        const def = bubble.n.actions.find(a => a.identifier === "default");
                        if (def) def.invoke();
                        else bubble.n.dismiss();
                    }
                }
                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: bubble.n.dismiss()
                }
            }
        }
    }
}
