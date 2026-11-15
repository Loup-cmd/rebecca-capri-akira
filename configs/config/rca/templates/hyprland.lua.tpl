-- Généré par rca-theme ({{ mode }}). Ne pas modifier.
local active = { colors = { "rgba({{ accent_strip }}ee)", "rgba({{ foreground_strip }}aa)" }, angle = 45 }
local inactive = "rgba({{ muted_strip }}55)"

hl.config({
  general = { col = { active_border = active, inactive_border = inactive } },
  group = {
    col = { border_active = active, border_inactive = inactive },
    groupbar = {
      text_color = "rgb({{ bright_foreground_strip }})",
      text_color_inactive = "rgba({{ dark_foreground_strip }}cc)",
      col = { active = "rgba({{ accent_strip }}dd)", inactive = "rgba({{ dark_background_strip }}dd)" },
    },
  },
  misc = { background_color = "rgb({{ darker_background_strip }})" },
})
