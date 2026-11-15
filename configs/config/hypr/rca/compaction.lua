-- Compacte les écrans : quand on quitte un écran complètement vide pour
-- arriver sur un écran occupé, les écrans occupés du même bloc remontent en
-- 1, 2, 3, ... pour combler tous les trous.
--
-- Dix numéros par bloc (1-10, 11-20, ...). La compaction
-- reste donc dans le bloc de dix de l'écran qu'on vient de quitter.
--
-- On ne compacte pas quand l'écran d'arrivée est vide : l'utilisateur est
-- encore en train de naviguer, et cet écran vide disparaîtra de lui-même.
-- La compaction se fera au prochain passage sur un écran occupé.
--
-- Hyprland détruit un écran vide dès qu'on le quitte. change_id peut alors
-- déplacer les écrans occupés vers les numéros libérés, y compris l'écran
-- actif : la fenêtre et le focus suivent.

local SLOTS = 10

-- change_id redéclenche workspace.active ; on ignore nos propres événements.
local compacting = false

local function block_start(id)
  return ((id - 1) // SLOTS) * SLOTS + 1
end

local function compact_block(empty_id)
  local first = block_start(empty_id)
  local last = first + SLOTS - 1
  local occupied = {}

  for _, workspace in ipairs(hl.get_workspaces()) do
    if workspace.id >= first and workspace.id <= last and not workspace.special then
      -- Un écran épinglé garde son numéro : on ne mélange pas le bloc.
      if workspace.is_persistent then
        return
      end
      if (workspace.windows or 0) > 0 then
        occupied[#occupied + 1] = workspace.id
      end
    end
  end

  if #occupied == 0 then
    return
  end

  table.sort(occupied)

  compacting = true
  local target = first

  for _, id in ipairs(occupied) do
    local workspace = hl.get_workspace(id)
    if workspace and not workspace.special and (workspace.windows or 0) > 0 then
      if workspace.id ~= target then
        hl.dispatch(hl.dsp.workspace.change_id({
          workspace = tostring(workspace.id),
          id = target,
        }))
      end
      target = target + 1
    end
  end

  -- Laisse retomber les événements que les déplacements viennent de produire.
  hl.timer(function()
    compacting = false
  end, { type = "oneshot", timeout = 150 })
end

hl.on("workspace.active", function()
  if compacting then
    return
  end

  local previous = hl.get_last_workspace()
  local active = hl.get_active_workspace()

  if not previous or not active or previous.id == active.id then
    return
  end
  if previous.special or previous.id < 1 then
    return
  end
  if (previous.windows or 0) > 0 then
    return
  end

  -- Rester sur un autre écran vide est une étape de navigation, pas une
  -- destination : on attend d'arriver sur un écran occupé pour compacter.
  if active.special or (active.windows or 0) == 0 then
    return
  end

  local empty_id = previous.id
  hl.timer(function()
    compact_block(empty_id)
  end, { type = "oneshot", timeout = 50 })
end)
