import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.components

// Changement d'espace de travail = changement de chaîne : « CH 03 » en
// phosphore dans le coin, comme sur un vieux téléviseur, puis extinction.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-channel"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 26; right: 34 }
    implicitWidth: 300
    implicitHeight: 128
    color: "transparent"
    mask: Region {}

    signal done()

    readonly property int ws: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var used: Hyprland.workspaces.values.filter(w => w.id > 0 && w.toplevels.values.length > 0).map(w => w.id)
    readonly property int count: Hyprland.focusedWorkspace?.toplevels?.values?.length ?? 0

    function show() { anim.restart(); }
    Component.onCompleted: show()
    Connections {
        target: Ui
        function onChannelChanged() { root.show(); }
    }

    SequentialAnimation {
        id: anim
        // Accroche du signal : deux sautes d'image puis image stable.
        PropertyAction { target: box; property: "opacity"; value: 1 }
        PropertyAction { target: box; property: "x"; value: 14 }
        PauseAnimation { duration: 40 }
        PropertyAction { target: box; property: "opacity"; value: 0.35 }
        PropertyAction { target: box; property: "x"; value: -6 }
        PauseAnimation { duration: 45 }
        PropertyAction { target: box; property: "opacity"; value: 1 }
        NumberAnimation { target: box; property: "x"; to: 0; duration: 120; easing.type: Easing.OutBack }
        PauseAnimation { duration: 950 }
        NumberAnimation { target: box; property: "opacity"; to: 0; duration: 260 }
        ScriptAction { script: root.done() }
    }

    Item {
        id: box
        width: parent.width
        height: parent.height

        Neon {
            id: big
            color: Theme.capri
            anchors.right: parent.right
            text: "CH " + Theme.pad2(root.ws)
            font.pixelSize: 62
            font.letterSpacing: 3
            style: Text.Outline
            styleColor: Theme.alpha(Theme.glass, 0.85)
        }
        Row {
            id: pips
            anchors.right: parent.right
            anchors.top: big.bottom
            anchors.topMargin: 2
            spacing: 5
            Repeater {
                model: 10
                Rectangle {
                    required property int index
                    readonly property bool current: index + 1 === root.ws
                    readonly property bool busy: root.used.includes(index + 1)
                    width: current ? 22 : 12
                    height: 6
                    color: current ? Theme.capri : (busy ? Theme.alpha(Theme.capri, 0.55) : Theme.alpha(Theme.glass, 0.7))
                    border.width: 1
                    border.color: Theme.alpha(Theme.capri, current || busy ? 0.9 : 0.35)
                }
            }
        }
        Neon {
            anchors.right: parent.right
            anchors.top: pips.bottom
            anchors.topMargin: 6
            text: root.count === 0 ? "CANAL LIBRE" : root.count + (root.count > 1 ? " FENÊTRES" : " FENÊTRE")
            font.pixelSize: 13
            font.letterSpacing: 2
            strength: 0.5
            color: Theme.capri
            style: Text.Outline
            styleColor: Theme.alpha(Theme.glass, 0.85)
        }
    }
}
