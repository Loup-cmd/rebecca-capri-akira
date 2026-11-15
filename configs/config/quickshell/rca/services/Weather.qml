pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Météo wttr.in, rafraîchie à l'ouverture du panneau (au plus toutes les 20 min).
Singleton {
    id: root

    property var data: null
    property string error: ""
    property real fetched: 0
    property string location: ""

    readonly property string temp: data ? data.current_condition[0].temp_C + "°" : "—"
    readonly property string desc: data ? (data.current_condition[0].lang_fr?.[0]?.value ?? data.current_condition[0].weatherDesc[0].value) : ""
    readonly property string feels: data ? data.current_condition[0].FeelsLikeC + "°" : ""
    readonly property string wind: data ? data.current_condition[0].windspeedKmph + " km/h" : ""
    readonly property string humidity: data ? data.current_condition[0].humidity + " %" : ""
    readonly property string area: data ? (data.nearest_area?.[0]?.areaName?.[0]?.value ?? "") : ""
    readonly property var days: data ? data.weather.slice(0, 3) : []

    Process {
        id: settings
        running: true
        command: ["sh", "-c", "sed -n 's/^[[:space:]]*weather_location[[:space:]]*=[[:space:]]*//p' \"$HOME/.config/rca/settings.conf\" | tail -n1"]
        stdout: StdioCollector { onStreamFinished: root.location = text.trim() }
    }

    Process {
        id: fetch
        command: ["curl", "-sf", "--max-time", "8", "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1&lang=fr"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.data = JSON.parse(text);
                    root.error = "";
                    root.fetched = Date.now();
                } catch (e) {
                    root.error = "MÉTÉO INDISPONIBLE";
                }
            }
        }
        onExited: code => { if (code !== 0) root.error = "MÉTÉO INDISPONIBLE"; }
    }

    function refresh(force) {
        if (fetch.running) return;
        if (!force && data && Date.now() - fetched < 20 * 60 * 1000) return;
        fetch.running = true;
    }

    function glyph(code) {
        const c = parseInt(code);
        if (c === 113) return "󰖙";
        if (c === 116) return "󰖕";
        if (c === 119 || c === 122) return "󰖐";
        if ([143, 248, 260].includes(c)) return "󰖑";
        if ([200, 386, 389, 392, 395].includes(c)) return "󰖓";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c)) return "󰖘";
        return "󰖗";
    }
}
