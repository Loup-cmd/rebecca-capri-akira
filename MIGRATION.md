# Rebecca-Capri-Akira — transition

Un seul script, à lancer depuis un terminal de ta session :

```bash
~/.hypr-switch/shells/Rebecca-Capri-Akira/transition.sh --dry-run   # aperçu, ne modifie rien
~/.hypr-switch/shells/Rebecca-Capri-Akira/transition.sh             # transition (reprend où il s'est arrêté)
```

| Étape | Ce qu'elle fait | Retour arrière |
|---|---|---|
| 1 Préparer | paquets Arch du ricing, shader, premier rendu du thème | rien à défaire |
| 2 Basculer | `ricing switch`, puis tu valides le bureau | le switch échoue : le bureau actuel reste ; sinon entrée « Snapshots » de Limine |
| 3 Applis | bash, Neovim, btop, VS Code, Firefox, web apps | `~/.local/share/hypr-switch-backups/transition-*` |
| 4 Autres rices | sekaipop indépendant d'Omarchy (`rca-freeze-keymap`) | `~/.local/share/hypr-switch-backups/sekaipop-hyprland.lua.*` |
| 5 Socle Arch | instantané snapper, noyau `linux`, greetd, quickshell d'Arch (testé, sinon retour auto) | entrée « Snapshots » de Limine |
| 6 Retrait | paquets Omarchy retirés, réglages de démarrage sauvegardés puis remis | entrée « Snapshots » de Limine |
| 7 Nettoyage | après redémarrage : noyau, dépôt Omarchy et `/etc/os-release` remis sur Arch | — |

Les étapes 1 à 4 ne touchent pas au système. Si l'étape 6 s'interrompt, ne redémarre pas :
relance le script, il réutilise la sauvegarde (`/var/backups/omarchy-settings-*`).

## Secours

- Verrou qui ne répond pas : CTRL + ALT + F3, session, `pkill -f 'qs -c rca'` puis
  `hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock")'`, retour CTRL + ALT + F1.
- Pas d'écran de connexion après l'étape 6 : CTRL + ALT + F2, session,
  `sudo systemctl disable greetd` puis `uwsm start hyprland.desktop`.
- Démarrage impossible : menu Limine → « Snapshots » → « avant sortie d'Omarchy ».

## Après la transition

- `default` garde tes applis et comptes mais son interface était Omarchy : il est masqué du
  sélecteur (`hidden=true` dans son `ricing.conf`). Ne pas forcer `ricing switch default`.
- sekaipop reste complet : il charge `hypr/omarchy-keymap.frozen.lua` et les commandes de
  `config/rca/compat`. Pour un autre ricing : `~/.config/rca/bin/rca-freeze-keymap <nom>`
  **avant** l'étape 6. Sans Omarchy, hypr-switch ne génère plus d'overlay de keymap et
  n'affiche plus d'avertissement.
- Démarrage : les drop-ins `/etc/mkinitcpio.conf.d/*omarchy*.conf` et
  `/etc/limine-entry-tool.d/omarchy-defaults.conf` sont restaurés comme fichiers locaux et
  **gardés** : ils portent `encrypt` (LUKS) et l'ordre Limine. Ne pas les supprimer sans
  réécrire `HOOKS` ; après modification, `sudo limine-mkinitcpio`.
- Paquets venus du dépôt Omarchy (spotify, visual-studio-code-bin, yay, mise-bin, localsend,
  limine-mkinitcpio-hook, limine-snapper-sync, superwhisper-bin…) : installés mais sans mises à
  jour. Liste : `pacman -Qm` ; les réinstaller depuis l'AUR. Garder les deux paquets `limine-*`.
