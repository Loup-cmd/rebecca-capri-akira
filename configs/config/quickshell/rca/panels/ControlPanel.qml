import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    property real brightness: 0
    property bool nightlight: true

    Process {
        id: readBrightness
        running: true
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector { onStreamFinished: root.brightness = (parseInt(text.split(",")[3]) || 0) / 100 }
    }
    Process {
        id: readNight
        running: true
        command: [Theme.bin + "/rca-theme", "nightlight", "status"]
        stdout: StdioCollector { onStreamFinished: root.nightlight = text.trim() === "on" }
    }

    PanelHead { title: "Contrôle";  extra: Clock.day + " " + Clock.date; number: "RCA/08" }

    GridLayout {
        columns: 2
        columnSpacing: 6
        rowSpacing: 6
        Layout.fillWidth: true

        Toggle { glyph: Net.glyph(); label: "Wi-Fi"; sub: Net.name; checked: Net.wifiOn; onToggled: Net.toggleWifi() }
        Toggle { glyph: Net.btGlyph(); label: "Bluetooth"; sub: Net.btConnected.length > 0 ? Net.btConnected[0].name : (Net.btOn ? "Aucun appareil" : "Coupé"); checked: Net.btOn; onToggled: Net.toggleBt() }
        Toggle { glyph: Theme.dark ? "󰖔" : "󰖙"; label: Theme.dark ? "Nuit" : "Jour"; sub: "Inverser jusqu'au soleil"; checked: Theme.dark; onToggled: Ui.script("rca-theme", "toggle") }
        Toggle { glyph: "󰌵"; label: "Veilleuse"; sub: "Lumière chaude la nuit"; checked: root.nightlight; onToggled: { root.nightlight = !root.nightlight; Ui.script("rca-theme", "nightlight " + (root.nightlight ? "on" : "off")); } }
        Toggle { glyph: Ui.silenced ? "󰂛" : "󰂚"; label: "Silence"; sub: "Bulles masquées"; checked: Ui.silenced; onToggled: Ui.silenced = !Ui.silenced }
        Toggle { glyph: "󰌾"; label: "Verrou auto"; sub: Ui.idleOn ? "Après 5 min" : "Écran toujours allumé"; checked: Ui.idleOn; onToggled: Ui.script("rca-idle", "toggle") }
        Toggle { glyph: "󰐃"; label: "Pupitre"; sub: "SUPER ⇧ ESPACE"; checked: !Ui.barHidden; onToggled: Ui.barHidden = !Ui.barHidden }
        Toggle { glyph: "󰻃"; label: "Enregistrer"; sub: Ui.recording ? "En cours" : "Zone de l'écran"; checked: Ui.recording; onToggled: { Ui.closeAll(); Ui.script("rca-capture", Ui.recording ? "record stop" : "record region"); } }
    }

    Section { index: "02";  title: "Son"; extra: Audio.muted ? "MUET" : Math.round(Audio.volume * 100) + " %" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Btn { compact: true; glyph: Audio.icon(Audio.volume, Audio.muted); active: Audio.muted; onClicked: if (Audio.sink?.audio) Audio.sink.audio.muted = !Audio.sink.audio.muted }
        Meter { Layout.fillWidth: true; implicitHeight: 12; value: Audio.volume; interactive: true; onMoved: v => Audio.setVolume(v) }
    }

    Section { index: "03";  title: "Lumière"; extra: Math.round(root.brightness * 100) + " %" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Btn { compact: true; glyph: "󰃠" }
        Meter {
            Layout.fillWidth: true
            implicitHeight: 12
            value: root.brightness
            interactive: true
            onMoved: v => {
                root.brightness = Math.max(0.01, v);
                Ui.run("brightnessctl -n2 set " + Math.round(root.brightness * 100) + "%");
            }
        }
    }

    Section { index: "04";  title: "Énergie"; extra: Battery.present ? Battery.pct() + " %" : "SECTEUR" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰾆"; label: "Éco"; active: Battery.profile === "saver"; onClicked: Battery.setProfile("saver") }
        Btn { Layout.fillWidth: true; glyph: "󰾅"; label: "Équilibre"; active: Battery.profile === "balanced"; onClicked: Battery.setProfile("balanced") }
        Btn { Layout.fillWidth: true; glyph: "󰓅"; label: "Perf"; active: Battery.profile === "performance"; onClicked: Battery.setProfile("performance") }
    }

    MediaCard { Layout.fillWidth: true; visible: Media.player !== null }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰌾"; label: "Verrou"; onClicked: Lock.lock() }
        Btn { Layout.fillWidth: true; glyph: "󰄀"; label: "Capture"; onClicked: Ui.openLauncher("menu", "capture") }
        Btn { Layout.fillWidth: true; glyph: "󰐥"; label: "Système"; onClicked: Ui.openLauncher("menu", "system") }
    }
}
