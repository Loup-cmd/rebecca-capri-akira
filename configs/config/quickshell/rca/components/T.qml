import QtQuick
import qs.services

// Texte HUD par défaut (monospace technique, capitales).
Text {
    property bool caps: true
    color: Theme.fg
    font.family: Theme.hud
    font.pixelSize: 11
    font.capitalization: caps ? Font.AllUppercase : Font.MixedCase
    font.letterSpacing: caps ? 0.6 : 0
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
