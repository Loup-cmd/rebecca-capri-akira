import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.components
import "Menus.js" as Menus

// Palette de commandes. Modes : apps, menu, clipboard, emoji, calc, run,
// web, reminder, keys. Préfixes dans le mode apps :
//   =  calcul    :  émojis    >  commande    ?  recherche web    !  rappel
// Échap ferme (ou remonte d'un menu), Retour arrière sur un champ vide aussi.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rca-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property string mode: Ui.launcherMode
    // Modes techniques (calcul, commande, raccourcis) : couleur de Capri.
    readonly property color tone: ["calc", "run", "keys"].includes(effective.mode) ? Theme.capri : Theme.accent
    property string menu: Ui.launcherArg || "root"
    property var stack: []
    property string query: ""
    property var results: []
    property int current: 0

    // Données chargées à la demande.
    property var clips: []
    property var emojis: []
    property var binds: []
    property var usage: ({})

    readonly property var effective: {
        if (mode !== "apps") return { mode: mode, q: query };
        const c = query.charAt(0);
        const rest = query.slice(1).trim();
        if (c === "=") return { mode: "calc", q: rest };
        if (c === ":") return { mode: "emoji", q: rest };
        if (c === ">") return { mode: "run", q: rest };
        if (c === "?") return { mode: "web", q: rest };
        if (c === "!") return { mode: "reminder", q: rest };
        return { mode: "apps", q: query };
    }

    readonly property var heading: {
        switch (effective.mode) {
        case "menu": return Menus.title(menu);
        case "clipboard": return ["Presse-papiers", ""];
        case "emoji": return ["Émojis", ""];
        case "calc": return ["Calcul", ""];
        case "run": return ["Commande", ""];
        case "web": return ["Recherche", ""];
        case "reminder": return ["Rappel", ""];
        case "keys": return ["Raccourcis", ""];
        default: return ["Lancer", ""];
        }
    }

    function close() {
        card.powerOff();
    }

    function enterMenu(name) {
        stack = stack.concat([{ mode: mode, menu: menu }]);
        mode = "menu";
        menu = name;
        input.text = "";
    }

    function enterMode(m) {
        stack = stack.concat([{ mode: mode, menu: menu }]);
        mode = m;
        input.text = "";
        load();
    }

    function back() {
        if (stack.length === 0) {
            close();
            return;
        }
        const prev = stack[stack.length - 1];
        stack = stack.slice(0, -1);
        mode = prev.mode;
        menu = prev.menu;
        input.text = "";
    }

    function load() {
        if (mode === "clipboard" && !clipProc.running) clipProc.running = true;
        if ((mode === "emoji" || effective.mode === "emoji") && emojis.length === 0) emojiFile.reload();
        if (mode === "keys" && !bindsProc.running) bindsProc.running = true;
    }

    function refresh() {
        const e = effective;
        const q = e.q;
        let list = [];
        switch (e.mode) {
        case "apps": {
            const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);
            list = apps.map(a => {
                const s = Math.max(Menus.score(a.name, q), Menus.score(a.genericName || "", q) * 0.6, Menus.score((a.keywords || []).join(" "), q) * 0.5);
                return { glyph: "", icon: a.icon, label: a.name, sub: a.genericName || a.comment || "", entry: a, s: s + (usage[a.id] || 0) * (q ? 2 : 10) };
            }).filter(x => x.s > 0).sort((a, b) => b.s - a.s).slice(0, 50);
            break;
        }
        case "menu":
            list = Menus.items(menu).filter(i => !q || Menus.score(i.label + " " + (i.sub || ""), q) > 0);
            break;
        case "clipboard":
            list = clips.filter(c => !q || c.text.toLowerCase().includes(q.toLowerCase())).slice(0, 80).map(c => ({
                glyph: c.image ? "󰋩" : "󰅍", label: c.text, sub: c.image ? "IMAGE" : "", clip: c.id
            }));
            break;
        case "emoji":
            list = (q ? emojis.filter(x => x.k.includes(q.toLowerCase())) : emojis).slice(0, 120).map(x => ({
                emoji: x.e, label: x.k.split(" ").slice(0, 4).join(" "), sub: ""
            }));
            break;
        case "calc": {
            const v = Menus.calc(q);
            list = v === null ? [{ glyph: "󰃬", label: q ? "Expression invalide" : "Tape un calcul : 12*(3+4), sqrt(2), 2^10…", sub: "" }]
                : [{ glyph: "󰃬", label: "= " + v, sub: "Entrée : copier le résultat", copy: "" + v }];
            break;
        }
        case "run":
            list = [{ glyph: "󰆍", label: q || "Commande à lancer", sub: "Entrée : lancer · Ctrl+Entrée : dans un terminal", run: q }];
            break;
        case "web":
            list = [{ glyph: "󰖟", label: q ? "Rechercher « " + q + " »" : "Recherche web", sub: "DuckDuckGo", web: q }];
            break;
        case "reminder": {
            const m = q.match(/^(\S+)\s+(.+)$/);
            list = [{ glyph: "󰀠", label: m ? "Dans " + m[1] + " : " + m[2] : "Délai puis texte : 10m Sortir le linge · 18:30 Appeler",
                sub: m ? "Entrée : programmer" : "Délai : 45s, 10m, 1h30m ou une heure HH:MM", remind: m ? [m[1], m[2]] : null }];
            break;
        }
        case "keys":
            list = binds.filter(b => !q || Menus.score(b.desc + " " + b.keys, q) > 0).map(b => ({ glyph: "󰌌", label: b.desc, sub: "", keys: b.keys }));
            break;
        }
        results = list;
        current = 0;
    }

    function activate(item, alt) {
        if (!item) return;
        const e = effective.mode;
        if (item.menu) { enterMenu(item.menu); return; }
        if (item.mode) { enterMode(item.mode); return; }
        if (item.panel) { Ui.openPanel(item.panel); return; }
        if (item.entry) {
            const a = item.entry;
            usage[a.id] = (usage[a.id] || 0) + 1;
            usageFile.setText(JSON.stringify(usage));
            const cmd = a.command;
            if (a.runInTerminal) Quickshell.execDetached(["uwsm-app", "--", "kitty", "-e"].concat(cmd));
            else Quickshell.execDetached(["uwsm-app", "--"].concat(cmd));
        } else if (item.clip !== undefined) {
            Ui.run("cliphist decode " + item.clip + " | wl-copy");
        } else if (item.emoji) {
            Quickshell.execDetached(["wl-copy", item.emoji]);
            Ui.run("sleep 0.25; wtype " + "'" + item.emoji + "'");
        } else if (item.copy !== undefined) {
            Quickshell.execDetached(["wl-copy", item.copy]);
        } else if (item.run) {
            if (alt) Ui.run("uwsm-app -- kitty --hold -e sh -c " + "'" + item.run.replace(/'/g, "'\\''") + "'");
            else Ui.run(item.run);
        } else if (item.web !== undefined) {
            Ui.script("rca-browser", "'https://duckduckgo.com/?q=" + encodeURIComponent(item.web) + "'");
        } else if (item.remind) {
            Quickshell.execDetached([Theme.bin + "/rca-reminder", "set", item.remind[0], item.remind[1]]);
        } else if (item.script) {
            Ui.script(item.script.split(" ")[0], item.script.split(" ").slice(1).join(" "));
        } else if (item.cmd) {
            Ui.run(item.cmd);
        } else if (item.action === "pin") {
            Ui.barHidden = !Ui.barHidden;
        } else if (item.action === "silence") {
            Ui.silenced = !Ui.silenced;
        } else if (item.action === "lock") {
            close();
            Lock.lock();
            return;
        } else {
            return;
        }
        close();
    }

    onEffectiveChanged: { load(); refresh(); }
    onMenuChanged: refresh()
    onClipsChanged: refresh()
    onEmojisChanged: refresh()
    onBindsChanged: refresh()
    Component.onCompleted: {
        load();
        refresh();
        input.forceActiveFocus();
    }

    FileView {
        id: usageFile
        path: Theme.state + "/launcher-usage.json"
        onLoaded: { try { root.usage = JSON.parse(text()); } catch (e) { root.usage = {}; } root.refresh(); }
    }

    FileView {
        id: emojiFile
        path: Theme.rcaHome + "/data/emojis.json"
        blockLoading: false
        onLoaded: { try { root.emojis = JSON.parse(text()); } catch (e) {} }
    }

    Process {
        id: clipProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.clips = text.split("\n").filter(l => l).map(l => {
                const tab = l.indexOf("\t");
                const t = l.slice(tab + 1);
                return { id: l.slice(0, tab), text: t, image: t.startsWith("[[ binary data") };
            })
        }
    }

    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const seen = {};
                    root.binds = JSON.parse(text).filter(b => b.description && !b.release).map(b => ({ desc: b.description, keys: Menus.keyName(b) }))
                        .filter(b => { const k = b.desc + b.keys; if (seen[k]) return false; seen[k] = true; return true; });
                } catch (e) {}
            }
        }
    }

    // Voile : clic hors de la carte pour fermer.
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bgDarker, Theme.dark ? 0.55 : 0.35)
        opacity: card.opacity
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    Card {
        id: card
        width: Math.min(720, parent.width - 80)
        height: Math.min(520, parent.height - 160)
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        padding: 0
        cut: 18
        fill: Theme.bg
        stroke: Theme.brass
        strokeWidth: 1.5
        animate: true
        rivets: true
        onOffDone: Ui.launcherOpen = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            // Titre + fil d'Ariane.
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Lamp { on: true; color: root.tone }
                Neon {
                    text: root.heading[0]
                    font.pixelSize: 22
                    font.letterSpacing: 2
                    font.capitalization: Font.AllUppercase
                    strength: Theme.dark ? 0.7 : 0.35
                }
                T {
                    visible: root.stack.length > 0
                    text: "◀ ÉCHAP"
                    color: Theme.muted
                    font.pixelSize: 9
                }
                Item { Layout.fillWidth: true }
                T { text: root.results.length + " · " + Clock.time; color: Theme.muted; font.pixelSize: 10 }
            }

            // Champ de saisie.
            Item {
                Layout.fillWidth: true
                implicitHeight: 42
                Cut { anchors.fill: parent; cut: 8; fill: Theme.bgLight; stroke: root.tone; strokeWidth: 1.5 }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    T { text: "▶"; color: root.tone; font.pixelSize: 13 }
                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        color: Theme.fgBright
                        selectionColor: root.tone
                        selectedTextColor: Theme.onAccent
                        font.family: Theme.sans
                        font.pixelSize: 17
                        focus: true
                        clip: true
                        onTextChanged: { root.query = text; root.refresh(); }
                        Keys.onEscapePressed: root.back()
                        Keys.onPressed: e => {
                            if (e.key === Qt.Key_Down || (e.key === Qt.Key_N && e.modifiers & Qt.ControlModifier) || e.key === Qt.Key_Tab) {
                                root.current = Math.min(root.results.length - 1, root.current + 1); e.accepted = true;
                            } else if (e.key === Qt.Key_Up || (e.key === Qt.Key_P && e.modifiers & Qt.ControlModifier) || e.key === Qt.Key_Backtab) {
                                root.current = Math.max(0, root.current - 1); e.accepted = true;
                            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                root.activate(root.results[root.current], e.modifiers & Qt.ControlModifier); e.accepted = true;
                            } else if (e.key === Qt.Key_Backspace && text === "" && root.stack.length > 0) {
                                root.back(); e.accepted = true;
                            } else if (e.key === Qt.Key_Delete && e.modifiers & Qt.ShiftModifier && root.mode === "clipboard") {
                                const it = root.results[root.current];
                                if (it && it.clip !== undefined) {
                                    Ui.run("cliphist list | grep -P '^" + it.clip + "\\t' | cliphist delete");
                                    root.clips = root.clips.filter(c => c.id !== it.clip);
                                }
                                e.accepted = true;
                            }
                        }
                    }
                    T {
                        visible: root.mode === "apps" && root.query === ""
                        text: "=  :  >  ?  !"
                        color: Theme.muted
                        font.pixelSize: 11
                    }
                }
            }

            // Grille d'émojis ou liste.
            GridView {
                id: emojiGrid
                visible: root.effective.mode === "emoji"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / 10
                cellHeight: cellWidth
                model: visible ? root.results : []
                currentIndex: root.current
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: emojiGrid.cellWidth
                    height: emojiGrid.cellHeight
                    Cut {
                        anchors.fill: parent
                        anchors.margins: 2
                        cut: 5
                        fill: index === root.current ? Theme.alpha(root.tone, 0.2) : "transparent"
                        stroke: index === root.current ? root.tone : "transparent"
                        strokeWidth: 1
                    }
                    Text { anchors.centerIn: parent; text: modelData.emoji; font.pixelSize: 26; font.family: "Noto Color Emoji" }
                    MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: root.current = index; onClicked: root.activate(modelData) }
                }
                Keys.forwardTo: [input]
            }

            ListView {
                id: list
                visible: !emojiGrid.visible
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: visible ? root.results : []
                currentIndex: root.current
                highlightMoveDuration: Theme.fast
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === root.current
                    width: list.width
                    height: modelData.sub ? 44 : 34

                    Cut {
                        anchors.fill: parent
                        cut: 6
                        fill: row.sel ? root.tone : (rowMouse.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent")
                    }
                    // Numéro de ligne façon index de catalogue.
                    T {
                        id: num
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: Theme.pad2(row.index + 1)
                        font.pixelSize: 9
                        color: row.sel ? Theme.alpha(Theme.onAccent, 0.7) : Theme.muted
                    }
                    Item {
                        id: ico
                        anchors.left: num.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24; height: 24
                        Image {
                            anchors.fill: parent
                            visible: (row.modelData.icon ?? "") !== ""
                            source: visible ? Quickshell.iconPath(row.modelData.icon, "application-x-executable") : ""
                            sourceSize: Qt.size(48, 48)
                            asynchronous: true
                        }
                        Glyph {
                            anchors.centerIn: parent
                            visible: (row.modelData.icon ?? "") === ""
                            text: row.modelData.glyph ?? ""
                            size: 17
                            color: row.sel ? Theme.onAccent : root.tone
                        }
                    }
                    ColumnLayout {
                        anchors.left: ico.right
                        anchors.leftMargin: 10
                        anchors.right: right.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.label
                            font.family: Theme.sans
                            font.pixelSize: 14
                            font.weight: row.sel ? Font.Bold : Font.Medium
                            color: row.sel ? Theme.onAccent : Theme.fgBright
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }
                        T {
                            Layout.fillWidth: true
                            visible: (row.modelData.sub ?? "") !== ""
                            text: row.modelData.sub ?? ""
                            caps: false
                            font.family: Theme.sans
                            font.pixelSize: 11
                            color: row.sel ? Theme.alpha(Theme.onAccent, 0.8) : Theme.muted
                        }
                    }
                    Row {
                        id: right
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        T {
                            visible: (row.modelData.keys ?? "") !== ""
                            text: row.modelData.keys ?? ""
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: row.sel ? Theme.onAccent : root.tone
                        }
                        Glyph {
                            visible: row.modelData.menu !== undefined || row.modelData.mode !== undefined
                            text: "󰅂"
                            size: 13
                            color: row.sel ? Theme.onAccent : Theme.muted
                        }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.current = row.index
                        onClicked: root.activate(row.modelData)
                    }
                }
            }

            // Pied : aide contextuelle.
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle { implicitWidth: 24; implicitHeight: 2; color: root.tone }
                T {
                    Layout.fillWidth: true
                    text: root.mode === "clipboard" ? "ENTRÉE COPIER · MAJ+SUPPR EFFACER · ÉCHAP RETOUR"
                        : root.effective.mode === "run" ? "ENTRÉE LANCER · CTRL+ENTRÉE DANS UN TERMINAL"
                        : "↑↓ CHOISIR · ENTRÉE VALIDER · ÉCHAP " + (root.stack.length > 0 ? "RETOUR" : "FERMER")
                    color: Theme.muted
                    font.pixelSize: 9
                }
                T { text: "R.C.A — CONSOLE"; color: root.tone; font.pixelSize: 9 }
            }
        }
    }
}
