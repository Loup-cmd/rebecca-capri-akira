import QtQuick
import qs.services

// Icône Nerd Font.
Text {
    property real size: 14
    color: Theme.fg
    font.family: Theme.icons
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
