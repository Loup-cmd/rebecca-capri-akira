pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Serveur de notifications : bulles à l'écran + historique en mémoire.
Singleton {
    id: root

    property var popups: []      // notifications vivantes affichées
    property var history: []     // instantanés {id, app, summary, body, time, urgency, icon}
    property int historyLimit: 60
    readonly property int count: history.length

    function snapshot(n) {
        return {
            id: n.id,
            app: n.appName || "Système",
            summary: n.summary || "",
            body: n.body || "",
            icon: n.image || n.appIcon || "",
            urgency: n.urgency,
            time: new Date()
        };
    }

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function act() {
        const n = popups.length > 0 ? popups[popups.length - 1] : null;
        if (!n) {
            Ui.togglePanel("notifications");
            return;
        }
        const def = n.actions.find(a => a.identifier === "default") ?? n.actions[0];
        if (def) def.invoke();
        else n.dismiss();
    }

    function dismissOne() {
        const n = popups.length > 0 ? popups[popups.length - 1] : null;
        if (n) n.dismiss();
    }

    function dismissAll() {
        for (const n of popups.slice()) n.dismiss();
        popups = [];
    }

    function clearHistory() {
        history = [];
    }

    function forget(id) {
        history = history.filter(h => h.id !== id);
    }

    // RCA_TEST=1 : instance de test à côté d'un autre shell, sans serveur.
    LazyLoader {
        active: Quickshell.env("RCA_TEST") !== "1"
        component: NotificationServer {
            id: server
            keepOnReload: true
            actionsSupported: true
            imageSupported: true
            bodySupported: true
            bodyMarkupSupported: true
            bodyHyperlinksSupported: false
            persistenceSupported: true

            onNotification: n => {
                n.tracked = true;
                const entry = root.snapshot(n);
                root.history = [entry].concat(root.history).slice(0, root.historyLimit);
                const critical = n.urgency === NotificationUrgency.Critical;
                if (!Ui.silenced || critical) {
                    root.popups = root.popups.concat([n]).slice(-4);
                }
                n.closed.connect(() => root.removePopup(n));
            }
        }
    }

    IpcHandler {
        target: "notifs"
        function act(): void { root.act(); }
        function dismissOne(): void { root.dismissOne(); }
        function dismissAll(): void { root.dismissAll(); }
        function history(): void { Ui.togglePanel("notifications"); }
        function keyboard(): void { Ui.openPanel("notifications"); }
        function silence(): void {
            Ui.silenced = !Ui.silenced;
            if (Ui.silenced) root.dismissAll();
        }
    }
}
