import QtQuick
import QtQuick.Effects
import qs.services

// Texte lumineux : phosphore d'écran ou tube néon, avec halo.
Text {
    id: root
    property color glow: color
    property real strength: 0.3
    color: Theme.phosphor
    font.family: Theme.hud
    renderType: Text.QtRendering
    layer.enabled: strength > 0
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: root.glow
        shadowBlur: 1.0
        shadowOpacity: root.strength
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        blurMax: 26
        autoPaddingEnabled: true
    }
}
