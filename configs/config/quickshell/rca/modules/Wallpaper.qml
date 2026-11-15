import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.components

// Fond d'écran : l'image Rebecca, de fines lignes de balayage, et deux éléments
// dessinés dans le lettrage du titre — l'heure (orange Rebecca) et le numéro de
// l'espace de travail (vert Capri). Quand l'espace est vide, la radio et les
// manomètres s'allument entre les deux ; ils s'éteignent dès qu'une fenêtre s'ouvre.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    // RCA_TEST_DASH=1 : aperçu du bureau vide par-dessus les fenêtres.
    readonly property bool preview: Quickshell.env("RCA_TEST_DASH") === "1"

    WlrLayershell.layer: preview ? WlrLayer.Overlay : WlrLayer.Background
    WlrLayershell.namespace: "rca-wallpaper"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: Theme.bgDarker

    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property int ws: monitor?.activeWorkspace?.id ?? 1
    readonly property int windows: monitor?.activeWorkspace?.toplevels?.values?.length ?? 0
    readonly property bool empty: preview || windows === 0
    readonly property string path: "file://" + Theme.state + "/wallpaper"
    readonly property real floor: height - (Ui.barOpen ? Theme.bar : 0) - 22

    function refresh() {
        front.source = "";
        front.source = root.path;
    }
    Component.onCompleted: refresh()
    Connections {
        target: Theme
        function onPChanged() { root.refresh(); }
    }
    Connections {
        target: Ui
        function onWallpaperChanged() { root.refresh(); }
    }

    Image {
        id: back
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        asynchronous: true
        cache: false
    }
    Image {
        id: front
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        asynchronous: true
        cache: false
        opacity: 0
        onStatusChanged: if (status === Image.Ready) fade.restart()
        NumberAnimation on opacity {
            id: fade
            from: 0; to: 1
            duration: 500
            easing.type: Easing.OutCubic
            running: false
            onFinished: {
                back.source = "";
                back.source = root.path;
            }
        }
    }
    // Effet cathodique léger : teinte chaude et lignes de balayage, image nette.
    Rectangle { anchors.fill: parent; color: "#FF9A5C"; opacity: Theme.crtShader ? (Theme.dark ? 0.05 : 0.03) : 0 }
    Image { anchors.fill: parent; visible: Theme.crtShader; source: Theme.assets + "/scanlines.png"; fillMode: Image.Tile; opacity: Theme.dark ? 0.16 : 0.05; smooth: false }

    // Heure, dans le lettrage du titre.
    Slab {
        id: time
        text: Clock.time
        h: Math.round(root.height * 0.13)
        x: Math.round(root.width * 0.03)
        y: root.floor - h
        color: Theme.accent
        colonColor: Theme.capri2
        transformOrigin: Item.BottomLeft
    }
    // Numéro de l'espace de travail, aux couleurs de Capri.
    Slab {
        id: num
        text: Theme.pad2(root.ws)
        h: time.h
        x: Math.round(root.width * 0.97) - width
        y: time.y
        color: Theme.capri
        transformOrigin: Item.BottomRight
    }
    Rectangle { x: num.x; y: num.y - 14; width: num.width; height: 5; color: Theme.capri2 }

    Loader {
        x: time.x + time.width + 30
        y: time.y
        width: num.x - 30 - x
        height: time.h
        active: root.empty && !Ui.zen
        sourceComponent: Dashboard {}
    }
}
