pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property date now: clock.date
    readonly property string time: Qt.formatTime(now, "HH:mm")
    readonly property string seconds: Qt.formatTime(now, "ss")
    readonly property string day: Qt.locale("fr_FR").dayName(now.getDay(), Locale.ShortFormat).replace(".", "").toUpperCase()
    readonly property string date: Qt.formatDate(now, "dd.MM")
    readonly property string longDate: Qt.locale("fr_FR").toString(now, "dddd d MMMM yyyy")

    property bool wantSeconds: false

    SystemClock {
        id: clock
        precision: root.wantSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }
}
