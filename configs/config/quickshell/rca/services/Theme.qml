pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Palette du thème courant (réécrite par rca-theme), typographie et mesures.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string state: home + "/.local/state/rca"
    readonly property string rcaHome: Quickshell.env("RCA_HOME") || (home + "/.config/rca")
    readonly property string bin: rcaHome + "/bin"
    readonly property string assets: Qt.resolvedUrl("../assets")

    property var p: ({})
    readonly property bool dark: (p.mode ?? "light") === "dark"

    // Couleurs (valeurs de repli : Rebecca clair).
    readonly property color accent: p.accent ?? "#F74D13"
    readonly property color bg: p.background ?? "#FFFEFD"
    readonly property color bgDark: p.darkBackground ?? "#F3EBE2"
    readonly property color bgDarker: p.darkerBackground ?? "#E9DCCD"
    readonly property color bgLight: p.lighterBackground ?? "#FFFFFF"
    readonly property color fg: p.foreground ?? "#3A2E1F"
    readonly property color fgDim: p.darkForeground ?? "#6B5B45"
    readonly property color fgBright: p.brightForeground ?? "#1E160E"
    readonly property color muted: p.muted ?? "#8A7A63"
    readonly property color selection: p.selection ?? "#F6D5C5"
    readonly property color rule: p.rule ?? "#D5CCC1"
    readonly property color red: p.red ?? "#C7361A"
    readonly property color green: p.green ?? "#3F7A34"
    readonly property color yellow: p.yellow ?? "#8A6A12"
    readonly property color cyan: p.cyan ?? "#20707A"
    readonly property color blue: p.blue ?? "#2F5C8A"

    readonly property color brown: p.brown ?? "#7A5230"

    // Capri : vert et magenta de l'image, réservés aux interfaces techniques.
    readonly property color capri: p.capriGreen ?? "#0DE95B"
    readonly property color capri2: p.capriMagenta ?? "#EF034C"

    // Encre sur l'accent : toujours le fond le plus clair, comme une sérigraphie.
    readonly property color onAccent: dark ? "#1B140E" : "#FFFEFD"

    // Matières : laiton, verre de tube, phosphore, cadran émaillé.
    readonly property color brass: mix(yellow, brown, 0.42)
    readonly property color brassLight: Qt.lighter(brass, dark ? 1.35 : 1.7)
    readonly property color brassDark: Qt.darker(brass, 1.9)
    readonly property color brassInk: "#1E160E"
    readonly property color glass: "#120D09"
    readonly property color nixie: "#FF8848"
    readonly property color phosphor: dark ? "#FFB27A" : accent
    readonly property color dial: "#F3EBE2"
    readonly property color dialInk: "#2B2116"

    // Typographie : terminal cathodique, plaques gravées, chiffres de tube Nixie.
    readonly property string display: "ShureTechMono Nerd Font"
    readonly property string hud: "ShureTechMono Nerd Font"
    readonly property string sans: "IBM Plex Sans"
    readonly property string engrave: "IBM Plex Serif"
    readonly property string nixieFont: "IBM Plex Sans Condensed"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string icons: "JetBrainsMono Nerd Font"

    // Mesures.
    readonly property int edge: 0
    readonly property int bar: 32           // pupitre du bas (toujours visible)
    readonly property int cut: 10           // biseau des cartes (comme les fenêtres)
    readonly property int cutSmall: 5
    readonly property int pad: 14
    readonly property int gap: 8

    // Effet cathodique : lignes et teinte sur le fond, shader complet sur le verrou
    // (crt_shader=off dans settings.conf pour tout couper).
    property bool crtShader: true

    // Durées : nettes, jamais lentes.
    readonly property int fast: 110
    readonly property int med: 180
    readonly property int slow: 260

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t, a.b * (1 - t) + b.b * t, 1);
    }

    function pad2(n) {
        return n < 10 ? "0" + n : "" + n;
    }


    FileView {
        path: root.rcaHome + "/settings.conf"
        onLoaded: root.crtShader = !/^\s*crt_shader\s*=\s*off/m.test(text())
    }

    FileView {
        id: palette
        path: root.state + "/theme/palette.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.p = JSON.parse(text());
            } catch (e) {
                console.warn("palette.json illisible : " + e);
            }
        }
    }

    // Au tout premier démarrage, rca-theme peut écrire la palette après nous.
    Timer {
        interval: 2000
        repeat: true
        running: root.p.mode === undefined
        onTriggered: palette.reload()
    }
}
