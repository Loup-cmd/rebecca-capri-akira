-- Petits outils partagés par la config Hyprland du ricing.

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

rca.file_exists = file_exists

function rca.dofile_if_exists(path)
  if not file_exists(path) then return end
  local ok, err = pcall(dofile, path)
  if not ok then print("[rca] " .. path .. " : " .. tostring(err)) end
end

function rca.quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function rca.has(command)
  for dir in ((os.getenv("PATH") or "/usr/bin") .. ":"):gmatch("([^:]*):") do
    if file_exists((dir ~= "" and dir or ".") .. "/" .. command) then return true end
  end
  return false
end

local uwsm = rca.has("uwsm-app")

-- Lance une application dans sa propre unité systemd (comme Omarchy), pour
-- qu'un plantage ou une fermeture d'Hyprland ne l'emporte pas.
function rca.launch(command)
  if uwsm then return "uwsm-app -- " .. command end
  return command
end

-- Commande d'un script du ricing.
function rca.script(name, args)
  return rca.bin .. "/" .. name .. (args and (" " .. args) or "")
end

-- Appel IPC du shell Quickshell.
function rca.ipc(target, method, args)
  return "qs -c rca ipc call " .. target .. " " .. method .. (args and (" " .. args) or "")
end

local function to_dispatcher(action)
  if type(action) == "string" then return hl.dsp.exec_cmd(action) end
  return action
end

-- rca.bind(touches, description, action, options)
-- action : commande shell, fonction Lua ou dispatcher hl.dsp.*
-- La description est relue par l'aide des raccourcis (SUPER + K).
function rca.bind(keys, description, action, options)
  local opts = {}
  for k, v in pairs(options or {}) do opts[k] = v end
  if description then opts.description = description end
  hl.bind(keys, to_dispatcher(action), opts)
end

-- Appui / relâchement (push-to-talk). Le relâchement est transparent et
-- ignore les modificateurs, et ne s'exécute qu'après son propre appui.
function rca.bind_hold(keys, description, press, release, options)
  local held = false
  local function run(action)
    if type(action) == "string" then
      hl.exec_cmd(action)
    elseif type(action) == "function" then
      action()
    else
      hl.dispatch(action)
    end
  end

  local press_opts, release_opts = {}, {}
  for k, v in pairs(options or {}) do press_opts[k], release_opts[k] = v, v end
  press_opts.description = description
  release_opts.release = true
  release_opts.transparent = true
  release_opts.ignore_mods = true
  release_opts.non_consuming = true

  hl.bind(keys, function()
    held = true
    run(press)
  end, press_opts)
  hl.bind(keys, function()
    if held then
      held = false
      run(release)
    end
  end, release_opts)
end

function rca.window(match, rules)
  rules.match = rules.match or {}
  if type(match) == "string" then
    rules.match.class = match
  else
    for k, v in pairs(match) do rules.match[k] = v end
  end
  hl.window_rule(rules)
end
