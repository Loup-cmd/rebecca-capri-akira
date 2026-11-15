import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    PanelHead { title: "Audio";  extra: Audio.sink?.description ?? ""; number: "RCA/05" }

    Section { index: "01";  title: "Sortie"; extra: Math.round(Audio.volume * 100) + " %" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Btn { compact: true; glyph: Audio.icon(Audio.volume, Audio.muted); active: Audio.muted; onClicked: if (Audio.sink?.audio) Audio.sink.audio.muted = !Audio.sink.audio.muted }
        Meter { Layout.fillWidth: true; implicitHeight: 12; value: Audio.volume; interactive: true; onMoved: v => Audio.setVolume(v) }
    }
    Repeater {
        model: Audio.sinks
        Device { required property var modelData; node: modelData; current: Audio.sink === modelData; onPicked: Pipewire.preferredDefaultAudioSink = modelData }
    }

    Section { index: "02";  title: "Entrée"; extra: Audio.micMuted ? "MUET" : Math.round((Audio.source?.audio?.volume ?? 0) * 100) + " %" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Btn { compact: true; glyph: Audio.micMuted ? "󰍭" : "󰍬"; active: Audio.micMuted; onClicked: if (Audio.source?.audio) Audio.source.audio.muted = !Audio.source.audio.muted }
        Meter { Layout.fillWidth: true; implicitHeight: 12; value: Audio.source?.audio?.volume ?? 0; interactive: true; onMoved: v => { if (Audio.source?.audio) Audio.source.audio.volume = v; } }
    }
    Repeater {
        model: Audio.sources
        Device { required property var modelData; node: modelData; current: Audio.source === modelData; onPicked: Pipewire.preferredDefaultAudioSource = modelData }
    }

    Section { index: "03";  title: "Applications"; visible: Audio.streams.length > 0 }
    Repeater {
        model: Audio.streams
        RowLayout {
            id: stream
            required property var modelData
            Layout.fillWidth: true
            spacing: 8
            T {
                Layout.preferredWidth: 110
                text: stream.modelData.properties["application.name"] ?? stream.modelData.description ?? stream.modelData.name
                font.pixelSize: 10
            }
            Meter {
                Layout.fillWidth: true
                implicitHeight: 8
                segments: 20
                color: Theme.fg
                value: stream.modelData.audio?.volume ?? 0
                interactive: true
                onMoved: v => { if (stream.modelData.audio) stream.modelData.audio.volume = v; }
            }
        }
    }

    Btn { Layout.fillWidth: true; glyph: "󰓃"; label: "Mixeur avancé"; onClicked: { Ui.closeAll(); Ui.run("pavucontrol || kitty --class rca.wiremix -e wiremix"); } }

    component Device: Item {
        id: dev
        property var node
        property bool current: false
        signal picked()
        Layout.fillWidth: true
        implicitHeight: 30
        Cut {
            anchors.fill: parent
            cut: 5
            fill: dev.current ? Theme.alpha(Theme.accent, 0.12) : (m.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent")
            stroke: dev.current ? Theme.accent : "transparent"
            strokeWidth: 1
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            Rectangle { implicitWidth: 6; implicitHeight: 6; color: dev.current ? Theme.accent : Theme.alpha(Theme.fg, 0.3) }
            T { Layout.fillWidth: true; text: dev.node?.description ?? dev.node?.name ?? ""; caps: false; font.family: Theme.sans; font.pixelSize: 11 }
        }
        MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dev.picked() }
    }
}
