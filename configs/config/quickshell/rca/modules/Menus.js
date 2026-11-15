.pragma library

// Menus de la palette de commandes (équivalents du menu Omarchy).
// Chaque entrée : { glyph, label, sub, kana, menu | mode | panel | cmd | script | action }

function items(name) {
    switch (name) {
    case "root":
        return [
            { glyph: "󰀻", label: "Applications", sub: "Lancer une app", mode: "apps" },
            { glyph: "󰄀", label: "Capture", sub: "Écran, zone, vidéo, texte", menu: "capture" },
            { glyph: "󰔡", label: "Bascules", sub: "Barre, silence, veille, marges…", menu: "toggle" },
            { glyph: "󰏘", label: "Thème", sub: "Jour, nuit, fonds d'écran", menu: "theme" },
            { glyph: "󰍛", label: "Matériel", sub: "Son, réseau, Bluetooth, écran", menu: "hardware" },
            { glyph: "󰅍", label: "Presse-papiers", sub: "Historique", mode: "clipboard" },
            { glyph: "󰞅", label: "Émojis", sub: "Copier et insérer", mode: "emoji" },
            { glyph: "󰀠", label: "Rappel", sub: "Programmer une alerte", mode: "reminder" },
            { glyph: "󰌌", label: "Raccourcis", sub: "Tous les raccourcis clavier", mode: "keys" },
            { glyph: "󰒔", label: "Partager", sub: "LocalSend", menu: "share" },
            { glyph: "󰚰", label: "Mettre à jour", sub: "Paquets Arch et AUR", script: "rca-update run" },
            { glyph: "󰐥", label: "Système", sub: "Verrou, veille, redémarrage", menu: "system" }
        ];
    case "capture":
        return [
            { glyph: "󰩭", label: "Capture de zone", sub: "IMPR", script: "rca-capture shot region" },
            { glyph: "󰖯", label: "Capture de fenêtre", script: "rca-capture shot window" },
            { glyph: "󰍹", label: "Capture de l'écran", script: "rca-capture shot screen" },
            { glyph: "󰻃", label: "Enregistrer une zone", sub: "ALT + IMPR", script: "rca-capture record region" },
            { glyph: "󰕧", label: "Enregistrer l'écran", script: "rca-capture record screen" },
            { glyph: "󰓛", label: "Arrêter l'enregistrement", script: "rca-capture record stop" },
            { glyph: "󰊄", label: "Extraire le texte (OCR)", sub: "SUPER + CTRL + IMPR", script: "rca-capture ocr" },
            { glyph: "󰈊", label: "Pipette à couleur", sub: "SUPER + IMPR", script: "rca-capture color" }
        ];
    case "record":
        return [
            { glyph: "󰩭", label: "Enregistrer une zone", script: "rca-capture record region" },
            { glyph: "󰍹", label: "Enregistrer l'écran", script: "rca-capture record screen" }
        ];
    case "toggle":
        return [
            { glyph: "󰐃", label: "Afficher / masquer le pupitre", sub: "SUPER + MAJ + ESPACE", action: "pin" },
            { glyph: "󰂛", label: "Silence des notifications", sub: "SUPER + CTRL + ALT + ,", action: "silence" },
            { glyph: "󰅶", label: "Verrouillage auto", sub: "SUPER + CTRL + I", script: "rca-idle toggle" },
            { glyph: "󰌵", label: "Veilleuse", script: "rca-theme nightlight toggle" },
            { glyph: "󰕰", label: "Marges des fenêtres", sub: "SUPER + MAJ + ⌫", script: "rca-hypr gaps" },
            { glyph: "󰊓", label: "Bureau plein écran", sub: "SUPER + CTRL + ALT + F", script: "rca-hypr zen" },
            { glyph: "󰆾", label: "Aspect carré", sub: "SUPER + CTRL + ⌫", script: "rca-hypr square" },
            { glyph: "󰕮", label: "Disposition suivante", sub: "SUPER + L", script: "rca-hypr layout next" }
        ];
    case "theme":
        return [
            { glyph: "󰖙", label: "Jour", sub: "Rebecca clair, jusqu'au coucher du soleil", script: "rca-theme light" },
            { glyph: "󰖔", label: "Nuit", sub: "Rebecca Dark, jusqu'au lever du soleil", script: "rca-theme dark" },
            { glyph: "󰔄", label: "Suivre le soleil", sub: "Annule le forçage", cmd: "rm -f ~/.local/state/rca/override && ~/.config/rca/bin/rca-theme auto" },
            { glyph: "󰸉", label: "Choisir un fond", sub: "SUPER + CTRL + ESPACE", panel: "wallpapers" },
            { glyph: "󰒭", label: "Fond suivant", script: "rca-theme wallpaper next" }
        ];
    case "hardware":
        return [
            { glyph: "󰕾", label: "Audio", sub: "SUPER + CTRL + A", panel: "audio" },
            { glyph: "󰖩", label: "Réseau", sub: "SUPER + CTRL + N", panel: "network" },
            { glyph: "󰂯", label: "Bluetooth", sub: "SUPER + CTRL + B", panel: "bluetooth" },
            { glyph: "󰍹", label: "Affichage", sub: "SUPER + CTRL + D", panel: "display" },
            { glyph: "󰂄", label: "Énergie", sub: "SUPER + CTRL + P", panel: "power" },
            { glyph: "󰍛", label: "Moniteur système", sub: "SUPER + CTRL + 1", panel: "monitor" }
        ];
    case "share":
        return [
            { glyph: "󰒔", label: "Ouvrir LocalSend", cmd: "uwsm-app -- localsend || localsend" },
            { glyph: "󰅍", label: "Envoyer le presse-papiers", sub: "Texte copié vers un fichier LocalSend", cmd: "f=/tmp/presse-papiers-$(date +%H%M%S).txt; wl-paste > \"$f\" && (uwsm-app -- localsend \"$f\" || localsend \"$f\")" }
        ];
    case "system":
        return [
            { glyph: "󰌾", label: "Verrouiller", sub: "SUPER + CTRL + L", action: "lock" },
            { glyph: "󰤄", label: "Veille", script: "rca-power suspend" },
            { glyph: "󰍃", label: "Se déconnecter", script: "rca-power logout" },
            { glyph: "󰜉", label: "Redémarrer", script: "rca-power reboot" },
            { glyph: "󰐥", label: "Éteindre", script: "rca-power poweroff" }
        ];
    }
    return [];
}

function title(name) {
    return {
        root: ["Menu", ""],
        capture: ["Capture", ""],
        record: ["Enregistrer", ""],
        toggle: ["Bascules", ""],
        theme: ["Thème", ""],
        hardware: ["Matériel", ""],
        share: ["Partager", ""],
        system: ["Système", ""]
    }[name] ?? ["Menu", ""];
}

// Calcul sûr : chiffres, opérateurs et fonctions Math usuelles seulement.
function calc(expr) {
    let e = expr.replace(/,/g, ".").replace(/×/g, "*").replace(/÷/g, "/").replace(/\^/g, "**").trim();
    if (e === "") return null;
    const allowed = /^[\d\s+\-*/%.()]*$/;
    const fns = ["sqrt", "sin", "cos", "tan", "log", "abs", "round", "floor", "ceil", "pi", "e", "pow", "min", "max"];
    let check = e;
    for (const f of fns) check = check.split(f).join("");
    if (!allowed.test(check.replace(/\*\*/g, "*"))) return null;
    for (const f of fns) {
        const repl = f === "pi" ? "Math.PI" : f === "e" ? "Math.E" : "Math." + f;
        e = e.replace(new RegExp("\\b" + f + "\\b", "g"), repl);
    }
    try {
        const v = Function("return (" + e + ")")();
        if (typeof v !== "number" || !isFinite(v)) return null;
        return Math.round(v * 1e10) / 1e10;
    } catch (err) {
        return null;
    }
}

// Score de recherche simple : préfixe > début de mot > contient > sous-séquence.
function score(text, query) {
    if (!query) return 1;
    const t = text.toLowerCase(), q = query.toLowerCase();
    if (t.startsWith(q)) return 100 - t.length * 0.1;
    if (t.includes(" " + q) || t.includes("-" + q)) return 70;
    if (t.includes(q)) return 50;
    let i = 0;
    for (const c of t) if (c === q[i]) i++;
    return i === q.length ? 20 : 0;
}

// Formatage d'un raccourci Hyprland ({ modmask, key }) en texte lisible.
function keyName(bind) {
    const mods = [];
    const m = bind.modmask || 0;
    if (m & 64) mods.push("SUPER");
    if (m & 4) mods.push("CTRL");
    if (m & 8) mods.push("ALT");
    if (m & 1) mods.push("MAJ");
    let key = bind.key || "";
    const azerty = { "code:10": "&", "code:11": "é", "code:12": "\"", "code:13": "'", "code:14": "(", "code:15": "-",
        "code:16": "è", "code:17": "_", "code:18": "ç", "code:19": "à", "code:20": ")", "code:21": "=", "code:49": "²" };
    key = azerty[key] ?? key;
    key = key.replace(/^mouse:272$/, "CLIC G").replace(/^mouse:273$/, "CLIC D").replace(/^mouse_down$/, "MOLETTE ↓").replace(/^mouse_up$/, "MOLETTE ↑");
    return mods.concat([key.toUpperCase()]).join(" + ");
}
