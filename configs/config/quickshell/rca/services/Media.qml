pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Lecteur actif : celui qui joue, sinon le dernier qui a joué.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property MprisPlayer last: null
    readonly property MprisPlayer player: {
        const playing = players.find(p => p.isPlaying);
        if (playing) return playing;
        if (last && players.includes(last)) return last;
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool playing: player?.isPlaying ?? false
    // RCA_DEMO=1 : titres fictifs, pour des captures d'écran sans données personnelles.
    readonly property bool demo: Quickshell.env("RCA_DEMO") === "1"
    readonly property string title: demo ? "Night City Lullaby" : (player?.trackTitle || "")
    readonly property string artist: demo ? "Samurai FM" : (player?.trackArtist || "")
    readonly property string art: player?.trackArtUrl || ""

    onPlayerChanged: if (player?.isPlaying) last = player

    function toggle() { player?.togglePlaying(); }
    function next() { player?.next(); }
    function previous() { player?.previous(); }
}
