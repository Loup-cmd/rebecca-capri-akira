//@ pragma IconTheme Papirus
//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import qs.services
import qs.modules

// Rebecca-Capri-Akira — un seul processus Quickshell pour toute l'interface (pupitre, fond, panneaux, verrou).
// Toujours chargés : fond, pupitre, verrou (inactif), services.
// Chargés à la demande puis libérés : palette, tiroir, bulles, OSD, canal, polkit.
ShellRoot {
    id: shell

    readonly property bool testing: Quickshell.env("RCA_TEST") === "1"

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    LockScreen {}

    LazyLoader {
        active: Ui.launcherOpen
        Launcher {}
    }

    LazyLoader {
        id: drawer
        property bool keep: false
        active: Ui.drawer !== "" || keep
        onActiveChanged: if (active) keep = true
        Drawer {
            onReleased: if (Ui.drawer === "") drawer.keep = false
        }
    }

    LazyLoader {
        active: Notifs.popups.length > 0 && !Lock.locked
        Popups {}
    }

    LazyLoader {
        id: osd
        property bool shown: false
        active: shown && !Lock.locked
        Osd {
            onDone: osd.shown = false
        }
    }
    Connections {
        target: Ui
        function onOsdRequested() { osd.shown = true; }
    }

    // Changement d'espace de travail : affichage « CH 03 ».
    property bool ready: false
    Timer { interval: 1500; running: true; onTriggered: shell.ready = true }
    LazyLoader {
        id: channel
        property bool shown: false
        active: shown && !Lock.locked
        ChannelOsd {
            onDone: channel.shown = false
        }
    }
    function showChannel() {
        if (channel.shown) Ui.channelChanged();
        else channel.shown = true;
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { if (shell.ready) shell.showChannel(); }
    }

    // Agent polkit : remplace celui d'Omarchy (et mate-polkit).
    LazyLoader {
        id: polkit
        property bool on: true
        active: !shell.testing && on
        PolkitAgent {}
    }
    // L'agent du shell précédent peut encore être inscrit au moment d'une bascule
    // à chaud : on retente jusqu'à obtenir l'inscription.
    Timer {
        property int tries: 0
        interval: 4000
        repeat: true
        running: !shell.testing && tries < 5 && !(polkit.item?.isRegistered ?? false)
        onTriggered: {
            tries++;
            polkit.on = false;
            Qt.callLater(() => polkit.on = true);
        }
    }
    LazyLoader {
        active: (polkit.item?.isActive ?? false) && polkit.item?.flow != null
        PolkitDialog {
            flow: polkit.item.flow
        }
    }

    // Mode test : aperçu de l'écran de verrouillage dans une fenêtre normale.
    LazyLoader {
        id: lockPreview
        property bool on: false
        active: shell.testing && on
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "rca-lock-preview"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            LockContent { anchors.fill: parent }
        }
    }
    IpcHandler {
        target: "test"
        function lock(): void { lockPreview.on = !lockPreview.on; }
        function channel(): void { shell.showChannel(); }
    }
}
