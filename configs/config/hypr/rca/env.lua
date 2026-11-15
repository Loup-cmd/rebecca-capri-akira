-- Environnement de session : Wayland partout, thèmes GTK/Qt du ricing.

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "hyprland-")
hl.env("XCOMPOSEFILE", rca.home .. "/.XCompose")

-- Les scripts du ricing passent devant dans le PATH.
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
if not (":" .. path .. ":"):find(":" .. rca.bin .. ":", 1, true) then
  hl.env("PATH", rca.bin .. ":" .. path)
end

hl.config({
  xwayland = { force_zero_scaling = true },
  ecosystem = { no_update_news = true, no_donation_nag = true },
})
