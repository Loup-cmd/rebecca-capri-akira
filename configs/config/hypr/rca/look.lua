-- Apparence : fenêtres en biseau, marges minimales, animations nettes.
--
-- rounding_power = 1 transforme l'arrondi en coupe droite à 45° : chaque
-- fenêtre a quatre coins biseautés, sans plugin ni coût en mémoire.

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 3,
    border_size = 2,
    resize_on_border = true,
    extend_border_grab_area = 8,
    hover_icon_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
    -- Couleurs par défaut ; remplacées par le thème plus bas.
    col = {
      active_border = { colors = { "rgba(F74D13ee)", "rgba(4F4029ee)" }, angle = 45 },
      inactive_border = "rgba(4F402966)",
    },
  },

  decoration = {
    rounding = 9,
    rounding_power = 1.0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    dim_special = 0.45,
    shadow = { enabled = false },
    blur = { enabled = false },
  },

  group = {
    groupbar = {
      font_size = 11,
      font_family = "ShureTechMono Nerd Font",
      font_weight_active = "bold",
      font_weight_inactive = "normal",
      indicator_height = 2,
      indicator_gap = 2,
      height = 18,
      gaps_in = 2,
      gaps_out = 0,
      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },

  dwindle = {
    preserve_split = true,
    force_split = 2,
  },

  scrolling = { column_width = 0.49 },
  master = { new_status = "master" },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    focus_on_activate = true,
    anr_missed_pings = 3,
    on_focus_under_fullscreen = 1,
    initial_workspace_tracking = 0,
    allow_session_lock_restore = true,
  },

  cursor = {
    hide_on_key_press = true,
    warp_on_change_workspace = 1,
  },

  render = { cm_auto_hdr = 0 },

  binds = { hide_special_on_workspace_change = true },

  animations = { enabled = true },
})

-- Une seule fenêtre tuilée : elle prend tout l'écran (le pupitre du bas garde
-- sa place), les biseaux laissent voir le fond aux quatre coins.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })

-- Animations : nettes et typées « vieux poste ». Les fenêtres s'ouvrent avec
-- un léger dépassement, et changer d'espace de travail fait défiler l'image à
-- la verticale, comme une chaîne qu'on change. Rien ne boucle en continu.
hl.curve("snap", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("tube", { type = "bezier", points = { { 0.2, 1.4 }, { 0.4, 1 } } })
hl.curve("cut", { type = "bezier", points = { { 0.6, 0 }, { 0.85, 0.2 } } })
hl.curve("roll", { type = "bezier", points = { { 0.7, 0 }, { 0.15, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "snap" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, bezier = "tube", style = "popin 78%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "cut", style = "popin 86%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.2, bezier = "snap" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.4, bezier = "snap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.6, bezier = "cut" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.6, bezier = "snap" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "snap" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.6, bezier = "roll", style = "slidefadevert 22%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "snap", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "snap", style = "fade" })

-- Couleurs du thème jour/nuit courant.
rca.dofile_if_exists(rca.state .. "/theme/hyprland.lua")
