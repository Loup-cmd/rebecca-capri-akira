-- Ce que la machine impose : écran du portable, clavier AZERTY, pavé tactile.
-- Repris des réglages de `default` (Omarchy) pour garder les mêmes sensations.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.25 })

-- Disposition du clavier lue dans /etc/vconsole.conf (fr chez toi), comme le
-- faisait Omarchy, sans son option XKB maison.
local layout, variant = "fr", ""
do
  local file = io.open("/etc/vconsole.conf", "r")
  if file then
    for line in file:lines() do
      local k, v = line:match('^%s*([%w_]+)%s*=%s*"?([^"]*)"?%s*$')
      if k == "XKBLAYOUT" and v ~= "" then layout = v end
      if k == "XKBVARIANT" then variant = v end
    end
    file:close()
  end
end

hl.config({
  input = {
    kb_layout = layout,
    kb_variant = variant,
    kb_model = "",
    -- Maj + Verr.Maj = touche Compose tant que le symbole XKB d'Omarchy existe.
    kb_options = rca.file_exists("/etc/xkb/symbols/omarchy") and "omarchy:shift_caps_compose" or "",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = false,
      clickfinger_behavior = false,
      scroll_factor = 0.4,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Défilement plus rapide dans le terminal, comme sous Omarchy.
rca.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
rca.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Glisser à trois doigts pour changer d'espace de travail.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
