import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components

ColumnLayout {
    id: root
    spacing: 10

    Component.onCompleted: Weather.refresh(false)

    PanelHead { title: "Météo";  extra: Weather.area; number: "RCA/02" }

    T { visible: Weather.error !== ""; text: Weather.error; color: Theme.red }

    RowLayout {
        visible: Weather.data !== null
        Layout.fillWidth: true
        spacing: 14
        Glyph { text: Weather.data ? Weather.glyph(Weather.data.current_condition[0].weatherCode) : ""; size: 54; color: Theme.accent }
        Text { text: Weather.temp; font.family: Theme.hud; font.pixelSize: 64; font.weight: Font.Normal; color: Theme.fgBright }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            T { Layout.fillWidth: true; text: Weather.desc; font.weight: Font.Bold; wrapMode: Text.Wrap; maximumLineCount: 2 }
            T { text: "RESSENTI " + Weather.feels; color: Theme.muted; font.pixelSize: 10 }
            T { text: "VENT " + Weather.wind + " · HUM " + Weather.humidity; color: Theme.muted; font.pixelSize: 10 }
        }
    }

    Section { index: "01";  title: "Prévisions"; visible: Weather.days.length > 0 }
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: Weather.days
            Item {
                id: day
                required property var modelData
                required property int index
                Layout.fillWidth: true
                implicitHeight: 92
                Cut { anchors.fill: parent; cut: 6; fill: day.index === 0 ? Theme.alpha(Theme.accent, 0.12) : Theme.alpha(Theme.fg, 0.04); stroke: Theme.alpha(Theme.fg, 0.2); strokeWidth: 1 }
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    T { Layout.alignment: Qt.AlignHCenter; text: day.index === 0 ? "AUJ." : Qt.locale("fr_FR").dayName(new Date(day.modelData.date).getDay(), Locale.ShortFormat); font.pixelSize: 10; color: Theme.muted }
                    Glyph { Layout.alignment: Qt.AlignHCenter; text: Weather.glyph(day.modelData.hourly[4].weatherCode); size: 24 }
                    T { Layout.alignment: Qt.AlignHCenter; text: day.modelData.maxtempC + "° / " + day.modelData.mintempC + "°"; font.weight: Font.Bold }
                }
            }
        }
    }
    Btn { Layout.fillWidth: true; glyph: "󰑓"; label: "Actualiser"; onClicked: Weather.refresh(true) }
}
