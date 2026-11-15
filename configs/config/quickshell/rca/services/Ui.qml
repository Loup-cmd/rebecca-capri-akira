pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// État de l'interface et points d'entrée IPC (qs -c rca ipc call …).
Singleton {
    id: root

    // Pupitre du bas : toujours visible, sauf masqué (SUPER + MAJ + ESPACE) ou en mode zen.
    property bool barHidden: false
    property bool zen: false
    readonly property bool barOpen: !zen && !barHidden

    // Tiroir de panneaux (au-dessus de la barre, à droite) : "" = fermé.
    property string drawer: ""
    property string drawerSide: "right"     // "left" quand le panneau vient du menu Utilitaires
    signal channelChanged()

    // Palette de commandes (lanceur, menus, presse-papiers, émojis…).
    property bool launcherOpen: false
    property string launcherMode: "apps"
    property string launcherArg: ""

    // Indicateurs.
    property bool recording: false
    property bool voice: false           // l'assistant vocal ou la dictée écoute
    onVoiceChanged: if (voice) voiceGuard.restart()
    Timer { id: voiceGuard; interval: 90000; onTriggered: root.voice = false }
    property bool idleOn: true
    property bool silenced: false
    property int updates: 0

    // OSD.
    property string osdKind: ""
    property real osdValue: 0
    property string osdText: ""
    signal osdRequested()
    signal wallpaperChanged()

    function run(command) {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    function script(name, args) {
        run(Theme.bin + "/" + name + (args ? " " + args : ""));
    }

    function togglePanel(name, side) {
        // L'aide des raccourcis est une liste cherchable : elle vit dans la palette.
        if (name === "keybinds") {
            if (launcherOpen && launcherMode === "keys") launcherOpen = false;
            else openLauncher("keys", "");
            return;
        }
        if (drawer === name) drawer = "";
        else openPanel(name, side);
    }

    function openPanel(name, side) {
        launcherOpen = false;
        drawerSide = side || (name === "utils" ? "left" : "right");
        drawer = name;
    }

    function openLauncher(mode, arg) {
        drawer = "";
        launcherMode = mode || "apps";
        launcherArg = arg || "";
        launcherOpen = true;
    }

    function closeAll() {
        launcherOpen = false;
        drawer = "";
    }

    function showOsd(kind, value, text) {
        osdKind = kind;
        osdValue = value;
        osdText = text || "";
        osdRequested();
    }

    // État persistant des bascules lu au démarrage.
    Process {
        running: true
        command: ["sh", "-c", "test -f \"$HOME/.local/state/rca/stay-awake\" && echo off || echo on"]
        stdout: StdioCollector {
            onStreamFinished: root.idleOn = text.trim() !== "off"
        }
    }

    // Mises à jour : toutes les deux heures, sans bloquer.
    Process {
        id: updateCheck
        command: [Theme.bin + "/rca-update", "count"]
        stdout: StdioCollector {
            onStreamFinished: root.updates = parseInt(text.trim()) || 0
        }
    }
    Timer {
        interval: 2 * 3600 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!updateCheck.running) updateCheck.running = true
    }

    IpcHandler {
        target: "bar"
        function pin(): void { root.barHidden = !root.barHidden; }
        function zen(on: bool): void { root.zen = on; }
    }

    IpcHandler {
        target: "panel"
        function toggle(name: string): void { root.togglePanel(name, ""); }
        function open(name: string): void { root.openPanel(name, ""); }
        function close(): void { root.closeAll(); }
    }

    IpcHandler {
        target: "launcher"
        function open(mode: string): void { root.openLauncher(mode, ""); }
        function toggle(): void {
            if (root.launcherOpen) root.launcherOpen = false;
            else root.openLauncher("apps", "");
        }
    }

    IpcHandler {
        target: "menu"
        function open(name: string): void { root.openLauncher("menu", name); }
    }

    IpcHandler {
        target: "status"
        function recording(on: bool): void { root.recording = on; }
        function voice(on: bool): void { root.voice = on; }
        function idle(on: bool): void { root.idleOn = on; }
        function refresh(): void { if (!updateCheck.running) updateCheck.running = true; }
    }

    IpcHandler {
        target: "wallpaper"
        function reload(): void { root.wallpaperChanged(); }
    }

    IpcHandler {
        target: "osd"
        function brightness(pct: int): void { root.showOsd("brightness", pct / 100, ""); }
        function keyboard(pct: int): void { root.showOsd("keyboard", pct / 100, ""); }
        function mic(): void { root.showOsd("mic", 0, ""); }
        function time(): void { root.showOsd("time", 0, ""); }
        function battery(): void { root.showOsd("battery", 0, ""); }
    }
}
