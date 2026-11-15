pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Statistiques système, lues seulement quand un panneau les affiche.
Singleton {
    id: root

    // Panneaux qui demandent le détail (températures, disque, processus).
    property int users: 0
    readonly property bool detailed: users > 0
    readonly property bool active: detailed

    property real cpu: 0
    property real mem: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real swap: 0
    property real temp: 0
    property real disk: 0
    property string diskText: ""
    property var history: []   // 40 derniers relevés CPU
    property var top: []       // processus les plus gourmands en mémoire

    property var lastIdle: 0
    property var lastTotal: 0

    FileView { id: stat; path: "/proc/stat" }
    FileView { id: meminfo; path: "/proc/meminfo" }

    Process {
        id: sensors
        command: ["sh", "-c", "for z in /sys/class/thermal/thermal_zone*; do t=$(cat $z/type); case $t in x86_pkg_temp|acpitz|cpu*|k10temp|coretemp) cat $z/temp; exit;; esac; done; cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: StdioCollector { onStreamFinished: root.temp = (parseInt(text) || 0) / 1000 }
    }

    Process {
        id: df
        command: ["df", "-B1", "--output=used,size", "/home"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\n").pop().trim().split(/\s+/);
                const used = parseFloat(f[0]), size = parseFloat(f[1]);
                root.disk = size > 0 ? used / size : 0;
                root.diskText = (used / 1e9).toFixed(0) + " / " + (size / 1e9).toFixed(0) + " Go";
            }
        }
    }

    Process {
        id: ps
        command: ["sh", "-c", "ps -eo rss=,comm= --sort=-rss | head -n 6"]
        stdout: StdioCollector {
            onStreamFinished: root.top = text.trim().split("\n").map(l => {
                const m = l.trim().match(/^(\d+)\s+(.*)$/);
                return m ? { name: m[2], mb: Math.round(parseInt(m[1]) / 1024) } : null;
            }).filter(x => x)
        }
    }

    function sample() {
        stat.reload();
        meminfo.reload();
        const line = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = line[3] + (line[4] || 0);
        const total = line.reduce((a, b) => a + b, 0);
        if (lastTotal > 0) {
            const dt = total - lastTotal;
            cpu = dt > 0 ? 1 - (idle - lastIdle) / dt : 0;
        }
        lastIdle = idle;
        lastTotal = total;
        history = history.concat([cpu]).slice(-40);

        const info = {};
        for (const l of meminfo.text().split("\n")) {
            const m = l.match(/^(\w+):\s+(\d+)/);
            if (m) info[m[1]] = parseInt(m[2]);
        }
        const total_kb = info.MemTotal || 1;
        const avail = info.MemAvailable || 0;
        mem = 1 - avail / total_kb;
        memUsedGb = (total_kb - avail) / 1048576;
        memTotalGb = total_kb / 1048576;
        swap = info.SwapTotal ? 1 - (info.SwapFree || 0) / info.SwapTotal : 0;
        if (detailed) sensors.running = true;
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: root.sample()
    }

    Timer {
        interval: 10000
        repeat: true
        running: root.detailed
        triggeredOnStart: true
        onTriggered: {
            df.running = true;
            ps.running = true;
        }
    }
}
