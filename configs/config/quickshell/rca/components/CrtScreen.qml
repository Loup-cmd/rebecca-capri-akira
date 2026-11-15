import QtQuick
import qs.services

// Effet de tube cathodique (à utiliser en layer.effect) : voir shaders/crt.frag.
ShaderEffect {
    property real curvature: 0.022
    property real scan: Theme.dark ? 0.18 : 0.08
    property real lines: height / 3
    property real vignette: Theme.dark ? 0.6 : 0.3
    property real aberration: 0.0007
    property real noise: 0
    property real time: 0
    property vector4d tint: Theme.dark ? Qt.vector4d(1.0, 0.82, 0.66, 0.26) : Qt.vector4d(1.0, 0.95, 0.86, 0.4)
    fragmentShader: Qt.resolvedUrl("../shaders/crt.frag.qsb")
}
