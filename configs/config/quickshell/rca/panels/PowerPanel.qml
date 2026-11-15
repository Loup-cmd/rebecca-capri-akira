import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    PanelHead { title: "Énergie";  extra: Battery.charging ? "SUR SECTEUR" : "SUR BATTERIE"; number: "RCA/06" }

    RowLayout {
        visible: Battery.present
        Layout.fillWidth: true
        spacing: 12
        Text {
            text: Battery.pct()
            font.family: Theme.hud
            font.pixelSize: 72
            font.weight: Font.Normal
            color: Battery.pct() <= 15 && !Battery.charging ? Theme.red : Theme.fgBright
        }
        ColumnLayout {
            spacing: 2
            T { text: "%"; font.pixelSize: 18; color: Theme.accent }
            T { text: Battery.charging ? "CHARGE" : "AUTONOMIE"; font.pixelSize: 10; color: Theme.muted }
            T { text: Battery.duration() || "—"; font.pixelSize: 14; font.weight: Font.Bold }
        }
    }
    Meter { visible: Battery.present; Layout.fillWidth: true; implicitHeight: 14; segments: 30; value: Battery.pct() / 100; color: Battery.pct() <= 15 ? Theme.red : Theme.accent }

    Section { index: "01";  title: "Profil" }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰾆"; label: "Éco"; active: Battery.profile === "saver"; onClicked: Battery.setProfile("saver") }
        Btn { Layout.fillWidth: true; glyph: "󰾅"; label: "Équilibre"; active: Battery.profile === "balanced"; onClicked: Battery.setProfile("balanced") }
        Btn { Layout.fillWidth: true; glyph: "󰓅"; label: "Perf"; active: Battery.profile === "performance"; onClicked: Battery.setProfile("performance") }
    }

    Section { index: "02";  title: "Session" }
    GridLayout {
        Layout.fillWidth: true
        columns: 3
        columnSpacing: 6
        rowSpacing: 6
        Btn { Layout.fillWidth: true; glyph: "󰌾"; label: "Verrouiller"; onClicked: Lock.lock() }
        Btn { Layout.fillWidth: true; glyph: "󰤄"; label: "Veille"; onClicked: { Ui.closeAll(); Ui.script("rca-power", "suspend"); } }
        Btn { Layout.fillWidth: true; glyph: "󰍃"; label: "Quitter"; onClicked: Ui.script("rca-power", "logout") }
        Btn { Layout.fillWidth: true; glyph: "󰜉"; label: "Redémarrer"; onClicked: Ui.script("rca-power", "reboot") }
        Btn { Layout.fillWidth: true; glyph: "󰐥"; label: "Éteindre"; tint: Theme.red; onClicked: Ui.script("rca-power", "poweroff") }
        Btn { Layout.fillWidth: true; glyph: Ui.idleOn ? "󰒲" : "󰅶"; label: Ui.idleOn ? "Veille auto" : "Éveillé"; active: !Ui.idleOn; onClicked: Ui.script("rca-idle", "toggle") }
    }
}
