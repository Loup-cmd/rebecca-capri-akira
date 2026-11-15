import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// Tiroir de panneaux, au-dessus du pupitre. Il ne se ferme que sur une action
// nette : Échap, clic en dehors, ou nouveau clic sur son bouton. Un seul panneau
// chargé à la fois ; tout est libéré après l'extinction.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-drawer"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    margins { bottom: Ui.barOpen ? Theme.bar : 0 }
    color: "transparent"

    signal released()

    property string shownName: ""
    Component.onCompleted: shownName = Ui.drawer
    readonly property bool left: Ui.drawerSide === "left"
    readonly property bool wide: shownName === "wallpapers" || shownName === "calendar" || shownName === "utils"

    Connections {
        target: Ui
        function onDrawerChanged() {
            if (Ui.drawer === "") {
                card.powerOff();
            } else {
                root.shownName = Ui.drawer;
                card.powerOn();
            }
        }
    }

    // Clic en dehors : fermeture.
    MouseArea { anchors.fill: parent; onClicked: Ui.drawer = "" }

    Card {
        id: card
        x: root.left ? 10 : root.width - width - 10
        y: root.height - height - 8
        width: root.wide ? 560 : 400
        height: Math.min(panel.want, root.height - 24)
        padding: 0
        cut: 14
        rivets: true
        animate: true
        fill: Theme.bg
        stroke: Theme.brass
        strokeWidth: 1.5
        onOffDone: root.released()

        MouseArea { anchors.fill: parent }

        Loader {
            id: panel
            anchors.fill: parent
            anchors.margins: Theme.pad + 4
            focus: true
            Keys.onEscapePressed: Ui.drawer = ""
            readonly property real want: (item?.implicitHeight ?? 0) + (Theme.pad + 4) * 2
            source: {
                switch (root.shownName) {
                case "utils": return "../panels/UtilPanel.qml";
                case "control": return "../panels/ControlPanel.qml";
                case "notifications": return "../panels/NotifPanel.qml";
                case "audio": return "../panels/AudioPanel.qml";
                case "bluetooth": return "../panels/BluetoothPanel.qml";
                case "network": return "../panels/NetworkPanel.qml";
                case "display": return "../panels/DisplayPanel.qml";
                case "power": return "../panels/PowerPanel.qml";
                case "calendar": return "../panels/CalendarPanel.qml";
                case "worldclock": return "../panels/WorldClockPanel.qml";
                case "weather": return "../panels/WeatherPanel.qml";
                case "monitor": return "../panels/MonitorPanel.qml";
                case "reminders": return "../panels/RemindersPanel.qml";
                case "wallpapers": return "../panels/WallpapersPanel.qml";
                default: return "";
                }
            }
            onLoaded: forceActiveFocus()
        }

        // Retour au menu Utilitaires quand le panneau en vient.
        Btn {
            visible: root.left && root.shownName !== "utils"
            anchors.left: parent.left
            anchors.bottom: parent.top
            anchors.bottomMargin: 4
            glyph: "󰁍"
            label: "Utilitaires"
            onClicked: Ui.openPanel("utils", "left")
        }
    }
}
