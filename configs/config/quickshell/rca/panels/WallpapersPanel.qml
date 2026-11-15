import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    property var files: []
    property string current: ""
    readonly property string mode: Theme.dark ? "dark" : "light"

    Process {
        id: scan
        running: true
        command: ["sh", "-c", "readlink -f \"$HOME/.local/state/rca/wallpaper\"; find -L \"$HOME/.config/rca/wallpapers/" + root.mode + "\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.current = lines.shift() ?? "";
                root.files = lines.filter(l => l);
            }
        }
    }

    PanelHead { title: "Fonds d'écran";  extra: (Theme.dark ? "NUIT" : "JOUR") + " · " + root.files.length; number: "RCA/BG" }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        columnSpacing: 8
        rowSpacing: 8
        Repeater {
            model: root.files
            Item {
                id: tile
                required property string modelData
                readonly property bool selected: Qt.resolvedUrl("file://" + modelData) == Qt.resolvedUrl("file://" + root.current) || root.current.endsWith(modelData.split("/").pop())
                Layout.fillWidth: true
                implicitHeight: 100
                Image {
                    anchors.fill: parent
                    anchors.margins: 3
                    source: "file://" + tile.modelData
                    sourceSize: Qt.size(320, 180)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
                Cut {
                    anchors.fill: parent
                    cut: 8
                    fill: "transparent"
                    stroke: tile.selected ? Theme.accent : Theme.alpha(Theme.fg, m.containsMouse ? 0.8 : 0.25)
                    strokeWidth: tile.selected ? 3 : 1
                }
                Rectangle {
                    visible: tile.selected
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    width: sel.implicitWidth + 10
                    height: 16
                    color: Theme.accent
                    T { id: sel; anchors.centerIn: parent; text: "ACTIF"; color: Theme.onAccent; font.pixelSize: 9; font.weight: Font.Bold }
                }
                MouseArea {
                    id: m
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.current = tile.modelData;
                        Ui.script("rca-theme", "wallpaper '" + tile.modelData.replace(/'/g, "'\\''") + "'");
                    }
                }
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰉋"; label: "Ouvrir le dossier"; onClicked: { Ui.closeAll(); Ui.run("nautilus ~/.config/rca/wallpapers/" + root.mode); } }
        Btn { Layout.fillWidth: true; glyph: "󰒭"; label: "Suivant"; onClicked: { Ui.script("rca-theme", "wallpaper next"); scan.running = true; } }
    }
    T { text: "Ajoute des images dans wallpapers/" + root.mode + " pour les retrouver ici."; caps: false; color: Theme.muted; font.pixelSize: 9 }
}
