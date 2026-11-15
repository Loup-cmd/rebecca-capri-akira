pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Sortie et entrée par défaut ; l'OSD réagit à chaque changement de volume.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)

    property bool ready: false

    function setVolume(v) {
        if (sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, v));
        }
    }

    function icon(v, m) {
        if (m || v <= 0.001) return "󰝟";
        if (v < 0.34) return "󰕿";
        if (v < 0.67) return "󰖀";
        return "󰕾";
    }

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.streams)
    }

    onVolumeChanged: if (ready) Ui.showOsd("volume", volume, "")
    onMutedChanged: if (ready) Ui.showOsd("volume", muted ? 0 : volume, "")

    // Pas d'OSD au démarrage ni au changement de périphérique.
    Timer {
        interval: 1500
        running: true
        onTriggered: root.ready = true
    }
    onSinkChanged: {
        ready = false;
        readyAgain.restart();
    }
    Timer {
        id: readyAgain
        interval: 800
        onTriggered: root.ready = true
    }
}
