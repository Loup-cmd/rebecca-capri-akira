-- Démarrage de session.
--
-- Le shell, hypridle, hyprsunset et le presse-papiers sont déclarés dans
-- ~/.hypr-switch/shells/Rebecca-Capri-Akira/ricing.conf (start=) : hypr-switch
-- les lance au login comme au changement de ricing à chaud.

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd(rca.launch("udiskie --automount --no-notify --no-tray"))
  hl.exec_cmd(rca.launch("herdr server"))

  -- Services propres à cette machine, ignorés ailleurs.
  if rca.file_exists(rca.home .. "/.local/bin/needle-voice") then
    hl.exec_cmd(rca.launch(rca.home .. "/.local/bin/needle-voice daemon"))
  end
  -- Le micro ALC245 (carte Generic_1) sature avec son boost matériel : on le coupe.
  hl.exec_cmd("amixer -c Generic_1 sset 'Mic Boost' 0 >/dev/null 2>&1")
end)

local hs_lib = rca.home .. "/.hypr-switch/lib/hypr-switch.lua"
if rca.file_exists(hs_lib) then
  local ok, hs = pcall(dofile, hs_lib)
  if ok and hs then hs.autostart("Rebecca-Capri-Akira") end
end
