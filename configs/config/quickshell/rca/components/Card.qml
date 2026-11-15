import QtQuick
import qs.services

// Carte « écran cathodique » : verre biseauté, double filet, lignes de balayage,
// rivets de laiton. Avec animate, elle s'allume comme un tube (trait horizontal
// qui s'ouvre) ; powerOff() l'éteint de la même façon puis émet offDone().
Item {
    id: root

    default property alias content: inner.data
    property color fill: Theme.bg
    property color stroke: Theme.alpha(Theme.fg, 0.55)
    property real strokeWidth: 1
    property real cut: Theme.cut
    property bool tl: true
    property bool tr: false
    property bool br: true
    property bool bl: false
    property real padding: Theme.pad
    property bool texture: true
    property bool rivets: false
    property bool animate: false
    property int delay: 0
    signal offDone()

    function powerOn() { off.stop(); on.restart(); }
    function powerOff() { on.stop(); off.restart(); }

    opacity: animate ? 0 : 1
    transform: Scale { id: sc; origin.x: root.width / 2; origin.y: root.height / 2 }
    Component.onCompleted: if (animate) on.start()

    SequentialAnimation {
        id: on
        PauseAnimation { duration: root.delay }
        PropertyAction { target: sc; property: "yScale"; value: 0.012 }
        PropertyAction { target: flash; property: "opacity"; value: 0.9 }
        PropertyAction { target: root; property: "opacity"; value: 1 }
        NumberAnimation { target: sc; property: "xScale"; from: 0.25; to: 1; duration: 90; easing.type: Easing.OutCubic }
        ParallelAnimation {
            NumberAnimation { target: sc; property: "yScale"; to: 1; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 0.7 }
            NumberAnimation { target: flash; property: "opacity"; to: 0; duration: 300; easing.type: Easing.OutQuad }
        }
    }
    SequentialAnimation {
        id: off
        ParallelAnimation {
            NumberAnimation { target: sc; property: "yScale"; to: 0.012; duration: 110; easing.type: Easing.InCubic }
            NumberAnimation { target: flash; property: "opacity"; to: 0.9; duration: 110 }
        }
        NumberAnimation { target: sc; property: "xScale"; to: 0; duration: 90; easing.type: Easing.InCubic }
        PropertyAction { target: root; property: "opacity"; value: 0 }
        ScriptAction { script: { sc.xScale = 1; sc.yScale = 1; flash.opacity = 0; root.offDone(); } }
    }

    Cut {
        anchors.fill: parent
        fill: root.fill
        stroke: root.stroke
        strokeWidth: root.strokeWidth
        cut: root.cut
        tl: root.tl; tr: root.tr; br: root.br; bl: root.bl
    }
    // Second filet de laiton, en retrait (double filet Art déco).
    Cut {
        visible: root.texture && root.width > 80 && root.height > 60
        anchors.fill: parent
        anchors.margins: 4
        fill: "transparent"
        stroke: Theme.alpha(Theme.brass, 0.55)
        strokeWidth: 1
        cut: Math.max(0, root.cut - 3)
        tl: root.tl; tr: root.tr; br: root.br; bl: root.bl
    }
    Item {
        anchors.fill: parent
        anchors.margins: root.strokeWidth + 1
        clip: true
        visible: root.texture
        Image { anchors.fill: parent; source: Theme.assets + "/grain.png"; fillMode: Image.Tile; opacity: Theme.dark ? 0.1 : 0.06; smooth: false }
        Image { anchors.fill: parent; source: Theme.assets + "/scanlines.png"; fillMode: Image.Tile; opacity: Theme.dark ? 0.1 : 0.04; smooth: false }
    }
    Repeater {
        model: root.rivets ? [[root.tl ? root.cut + 6 : 7, 7], [root.width - (root.tr ? root.cut + 6 : 7) - 5, 7], [root.bl ? root.cut + 6 : 7, root.height - 12], [root.width - (root.br ? root.cut + 6 : 7) - 5, root.height - 12]] : []
        Rectangle {
            required property var modelData
            x: modelData[0]; y: modelData[1]
            width: 5; height: 5; radius: 2.5
            color: Theme.brass
            border.width: 1
            border.color: Theme.brassDark
        }
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
    }

    Rectangle { id: flash; anchors.fill: parent; color: Qt.lighter(Theme.phosphor, 1.3); opacity: 0; z: 99 }
}
