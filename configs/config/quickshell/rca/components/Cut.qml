import QtQuick
import QtQuick.Shapes
import qs.services

// Rectangle aux coins biseautés (comme les fenêtres). Choisir les coins coupés
// avec tl / tr / br / bl ; le biseau suit Theme.cut par défaut.
Shape {
    id: root

    property color fill: Theme.bg
    property color stroke: "transparent"
    property real strokeWidth: 0
    property real cut: Theme.cut
    property bool tl: true
    property bool tr: false
    property bool br: true
    property bool bl: false

    readonly property real c: Math.min(cut, width / 2, height / 2)
    readonly property real o: strokeWidth / 2

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.fill
        strokeColor: root.strokeWidth > 0 ? root.stroke : "transparent"
        strokeWidth: root.strokeWidth
        joinStyle: ShapePath.MiterJoin

        startX: root.o + (root.tl ? root.c : 0); startY: root.o
        PathLine { x: root.width - root.o - (root.tr ? root.c : 0); y: root.o }
        PathLine { x: root.width - root.o; y: root.o + (root.tr ? root.c : 0) }
        PathLine { x: root.width - root.o; y: root.height - root.o - (root.br ? root.c : 0) }
        PathLine { x: root.width - root.o - (root.br ? root.c : 0); y: root.height - root.o }
        PathLine { x: root.o + (root.bl ? root.c : 0); y: root.height - root.o }
        PathLine { x: root.o; y: root.height - root.o - (root.bl ? root.c : 0) }
        PathLine { x: root.o; y: root.o + (root.tl ? root.c : 0) }
        PathLine { x: root.o + (root.tl ? root.c : 0); y: root.o }
    }
}
