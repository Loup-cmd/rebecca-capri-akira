pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Spectre audio pour le fond d'écran : cava ne tourne que pendant la lecture.
Singleton {
    id: root

    property int bars: 48
    property var values: []
    property bool wanted: false
    readonly property bool running: wanted && Media.playing

    readonly property string config: [
        "[general]", "bars = " + bars, "framerate = 30", "autosens = 1",
        "[input]", "method = pulse", "source = auto",
        "[smoothing]", "noise_reduction = 70",
        "[output]", "method = raw", "raw_target = /dev/stdout", "data_format = ascii",
        "ascii_max_range = 100", "bar_delimiter = 59", "frame_delimiter = 10"
    ].join("\n")

    Process {
        running: root.running
        command: ["sh", "-c", "f=\"$XDG_RUNTIME_DIR/rca-cava.conf\"; printf '%s\\n' \"$1\" > \"$f\" && exec cava -p \"$f\"", "sh", root.config]
        stdout: SplitParser {
            onRead: line => root.values = line.split(";").filter(v => v !== "").map(v => parseInt(v) / 100)
        }
        onRunningChanged: if (!running) root.values = []
    }
}
