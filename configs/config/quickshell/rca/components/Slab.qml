import QtQuick
import QtQuick.Shapes
import "Slab.js" as Glyphs

// Texte (chiffres et « : ») dans le lettrage en blocs du fond Rebecca.
Row {
    id: root
    property string text: ""
    property real h: 100
    property color color: "#F74D13"
    property color colonColor: color
    spacing: Math.round(h * 0.065)

    onTextChanged: pop.restart()
    SequentialAnimation {
        id: pop
        NumberAnimation { target: root; property: "scale"; to: 0.94; duration: 60 }
        NumberAnimation { target: root; property: "scale"; to: 1; duration: 220; easing.type: Easing.OutBack }
    }

    Repeater {
        model: root.text.split("")
        Shape {
            id: glyph
            required property string modelData
            readonly property var g: Glyphs.get(modelData)
            width: g.w * root.h / 100
            height: root.h
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: glyph.modelData === ":" ? root.colonColor : root.color
                strokeColor: "transparent"
                fillRule: ShapePath.OddEvenFill
                scale: Qt.size(root.h / 100, root.h / 100)
                PathSvg { path: glyph.g.d }
            }
        }
    }
}
