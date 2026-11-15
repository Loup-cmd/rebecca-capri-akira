import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Écran de verrouillage : affiche Akira — horloge géante, bandeau orange,
// champ de mot de passe biseauté. Une surface par écran.
WlSessionLock {
    locked: Lock.locked

    WlSessionLockSurface {
        color: Theme.bgDarker
        LockContent { anchors.fill: parent }
    }
}
