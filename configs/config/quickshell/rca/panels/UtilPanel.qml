import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

// Menu déroulant « Utilitaires » : tout ce qui n'est plus sur le pupitre.
ColumnLayout {
    id: root
    spacing: 10

    readonly property var groups: [
        { title: "Lancer", items: [
            { g: "󰀻", l: "Applications", launcher: "apps" },
            { g: "󰅍", l: "Presse-papiers", launcher: "clipboard" },
            { g: "󰞅", l: "Émojis", launcher: "emoji" },
            { g: "󰌌", l: "Raccourcis", launcher: "keys" } ] },
        { title: "Réglages", items: [
            { g: "󰒓", l: "Contrôle", panel: "control" },
            { g: "󰕾", l: "Audio", panel: "audio" },
            { g: "󰖩", l: "Réseau", panel: "network" },
            { g: "󰂯", l: "Bluetooth", panel: "bluetooth" },
            { g: "󰍹", l: "Affichage", panel: "display" },
            { g: "󰸉", l: "Fonds", panel: "wallpapers" },
            { g: "󰂄", l: "Énergie", panel: "power" },
            { g: "󰏘", l: "Jour / nuit", menu: "theme" } ] },
        { title: "Tableau de bord", items: [
            { g: "󰂚", l: "Notifications", panel: "notifications" },
            { g: "󰍛", l: "Système", panel: "monitor" },
            { g: "󰖐", l: "Météo", panel: "weather" },
            { g: "󰃭", l: "Calendrier", panel: "calendar" },
            { g: "󰀠", l: "Rappels", panel: "reminders" },
            { g: "󰥔", l: "Monde", panel: "worldclock" } ] },
        { title: "Outils", items: [
            { g: "󰄀", l: "Capture", menu: "capture" },
            { g: "󰔡", l: "Bascules", menu: "toggle" },
            { g: "󰒔", l: "Partager", menu: "share" },
            { g: "󰚰", l: Ui.updates > 0 ? "Mise à jour (" + Ui.updates + ")" : "Mise à jour", script: "rca-update run" },
            { g: "󰌾", l: "Verrouiller", lock: true },
            { g: "󰐥", l: "Session", menu: "system" } ] }
    ]

    function run(it) {
        if (it.panel) Ui.openPanel(it.panel, "left");
        else if (it.launcher) Ui.openLauncher(it.launcher, "");
        else if (it.menu) Ui.openLauncher("menu", it.menu);
        else if (it.script) { Ui.closeAll(); Ui.script(it.script.split(" ")[0], it.script.split(" ").slice(1).join(" ")); }
        else if (it.lock) { Ui.closeAll(); Lock.lock(); }
    }

    PanelHead { title: "Utilitaires"; extra: Clock.day + " " + Clock.date; number: "R.C.A" }

    Repeater {
        model: root.groups
        ColumnLayout {
            id: group
            required property var modelData
            required property int index
            Layout.fillWidth: true
            spacing: 6
            Section { index: "0" + (group.index + 1); title: group.modelData.title }
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 6
                rowSpacing: 6
                Repeater {
                    model: group.modelData.items
                    Item {
                        id: cell
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 100
                        implicitHeight: 50
                        Cut {
                            anchors.fill: parent
                            cut: 6
                            fill: cellMouse.containsMouse ? Theme.accent : Theme.alpha(Theme.fg, 0.05)
                            stroke: cellMouse.containsMouse ? Theme.accent : Theme.alpha(Theme.brass, 0.7)
                            strokeWidth: 1
                            scale: cellMouse.pressed ? 0.95 : 1
                            Behavior on scale { NumberAnimation { duration: Theme.fast } }
                        }
                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: cell.modelData.g; size: 18; color: cellMouse.containsMouse ? Theme.onAccent : Theme.accent }
                            T { anchors.horizontalCenter: parent.horizontalCenter; text: cell.modelData.l; font.pixelSize: 9; color: cellMouse.containsMouse ? Theme.onAccent : Theme.fg }
                        }
                        MouseArea { id: cellMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.run(cell.modelData) }
                    }
                }
            }
        }
    }
}
