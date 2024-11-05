---@diagnostic disable: undefined-global, lowercase-global

---Checks whether a string contains the provided substring and returns true or false.
---@param str string
---@param sub string
function str_contains(str, sub)
  return str:find(sub, 1, true) ~= nil
end

---Returns the number of values in a table. Doesn't count nil fields.
---@param t table
---@return number
function getTableLength(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

---@param hex string
function hexToRGB(hex)
  local r, g, b
  hex = hex:gsub("#", "")
  if hex:len() == 3 then -- short HEX
    r, g, b = (tonumber("0x" .. hex:sub(1, 1)) * 17), (tonumber("0x" .. hex:sub(2, 2)) * 17),
        (tonumber("0x" .. hex:sub(3, 3)) * 17)
  else
    r, g, b = tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
  end
  return r, g, b
end

---@param n number
---@param x integer
function round(n, x)
  return tonumber(string.format("%." .. (x or 0) .. "f", n))
end

function translateLabel(g)
  ---@type string
  local retStr
  if Labels[g] then
    for _, v in pairs(Labels[g]) do
      if LANG == v.iso then
        retStr = v.text
        break
      end
    end
    if retStr == nil or retStr == "" then
      if logMsg then
        gui.show_warning("YimActions",
          "Unsupported language or missing label(s) detected! Defaulting to English.")
        log.warning("Unsupported language or missing label(s) detected! Defaulting to English.")
        retStr = Labels[g][1].text
        logMsg = false
      end
    end
  else
    retStr = string.format("%s [MISSING LABEL!]", g)
  end
  return retStr ~= nil and retStr or string.format("%s [MISSING LABEL!]", g)
end

function initStrings()
  -- Generic
  GENERIC_PLAY_BTN_      = translateLabel("generic_play_btn")
  GENERIC_STOP_BTN_      = translateLabel("generic_stop_btn")
  GENERIC_OPEN_BTN_      = translateLabel("openBtn")
  GENERIC_CLOSE_BTN_     = translateLabel("closeBtn")
  GENERIC_SAVE_BTN_      = translateLabel("saveBtn")
  GENERIC_SPAWN_BTN_     = translateLabel("Spawn")
  GENERIC_DELETE_BTN_    = translateLabel("generic_delete")
  GENERIC_CONFIRM_BTN_   = translateLabel("generic_confirm_btn")
  GENERIC_CLEAR_BTN_     = translateLabel("generic_clear_btn")
  GENERIC_CANCEL_BTN_    = translateLabel("generic_cancel_btn")
  GENERIC_YES_           = translateLabel("yes")
  GENERIC_NO_            = translateLabel("NO")
  GENERIC_SEARCH_HINT_   = translateLabel("search_hint")
  GENERIC_CUSTOM_LABEL_  = translateLabel("generic_custom_label")
  ---------------------------------------------------------------------------
  ANIMATIONS_TAB_        = translateLabel("animations")
  ANIM_FLAGS_DESC_       = translateLabel("flags_tt")
  ANIM_PROPS_DESC_       = translateLabel("DisableProps_tt")
  ANIM_CONTROL_CB_       = translateLabel("Allow Control")
  ANIM_CONTROL_DESC_     = translateLabel("AllowControl_tt")
  ANIM_LOOP_DESC_        = translateLabel("looped_tt")
  ANIM_UPPER_CB_         = translateLabel("Upper Body Only")
  ANIM_UPPER_DESC_       = translateLabel("UpperBodyOnly_tt")
  ANIM_FREEZE_CB_        = translateLabel("Freeze")
  ANIM_FREEZE_DESC_      = translateLabel("Freeze_tt")
  ANIM_STOP_DESC_        = translateLabel("stopAnims_tt")
  ANIM_DETACH_BTN_       = translateLabel("Remove Attachments")
  ANIM_DETACH_DESC_      = translateLabel("RemoveAttachments_tt")
  ANIM_HOTKEYS_DESC_     = translateLabel("animKeys_tt")
  MVMT_OPTIONS_TXT_      = translateLabel("Movement Options:")
  CLUMSY_DESC_           = translateLabel("clumsy_tt")
  ROD_DESC_              = translateLabel("rod_tt")
  RAGDOLL_SOUND_DESC_    = translateLabel("ragdoll_sound_tt")
  ANIM_HOTKEY_BTN_       = translateLabel("animShortcut_btn")
  ANIM_HOTKEY_DESC_      = translateLabel("animShortcut_tt")
  ANIM_HOTKEY_DEL_       = translateLabel("removeShortcut_btn")
  ANIM_HOTKEY_DEL2_      = translateLabel("removeShortcut_btn2")
  DEL_HOTKEY_DESC_       = translateLabel("removeShortcut_tt")
  NO_HOTKEY_TXT_         = translateLabel("no_shortcut_tt")
  INPUT_WAIT_TXT_        = translateLabel("input_waiting")
  HOTKEY_RESERVED_       = translateLabel("reserved_button")
  HOTKEY_SUCCESS1_       = translateLabel("shortcut_success_1/2")
  HOTKEY_SUCCESS2_       = translateLabel("shortcut_success_2/2")
  NPC_ANIMS_TXT_         = translateLabel("Play Animations On NPCs:")
  NPC_GODMODE_DESC_      = translateLabel("Spawn NPCs in God Mode.")
  ANIMATE_NPCS_DESC_     = translateLabel("animateNPCs_tt")
  SCENARIOS_TAB_         = translateLabel("scenarios")
  SCN_STOP_DESC_         = translateLabel("stopScenarios_tt")
  SCN_STOP_SPINNER_      = translateLabel("scenarios_spinner")
  NPC_SCENARIOS_         = translateLabel("Play Scenarios On NPCs:")
  ADD_TO_FAVS_           = translateLabel("add_to_favs")
  REMOVE_FROM_FAVS_      = translateLabel("remove_from_favs")
  FAVORITES_TAB_         = translateLabel("favs_tab")
  FAVS_NIL_TXT_          = translateLabel("favs_nil_txt")
  RECENTS_TAB_           = translateLabel("recents_tab")
  RECENTS_NIL_TXT_       = translateLabel("recents_nil_txt")
  -- Settings
  SETTINGS_TAB_          = translateLabel("settingsTab")
  DISABLE_TOOLTIPS_CB_   = translateLabel("Disable Tooltips")
  DISABLE_UISOUNDS_CB_   = translateLabel("DisableSound")
  DISABLE_UISOUNDS_DESC_ = translateLabel("DisableSound_tt")
  PHONEANIMS_CB_         = translateLabel("PhoneAnimCB")
  PHONEANIMS_DESC_       = translateLabel("PhoneAnim_tt")
  SPRINT_INSIDE_CB_      = translateLabel("SprintInsideCB")
  SPRINT_INSIDE_DESC_    = translateLabel("SprintInside_tt")
  LOCKPICK_CB_           = translateLabel("LockpickCB")
  LOCKPICK_DESC_         = translateLabel("Lockpick_tt")
  CROUCHCB_              = translateLabel("CrouchCB")
  CROUCH_DESC_           = translateLabel("Crouch_tt")
  ACTION_MODE_CB_        = translateLabel("ActionModeCB")
  ACTION_MODE_DESC_      = translateLabel("ActionMode_tt")
  RESET_SETTINGS_BTN_    = translateLabel("reset_settings_Btn")
  LANG_CHANGED_NOTIF_    = translateLabel("lang_success_msg")
  log.info(string.format("Loaded %d %s translations.", getTableLength(Labels), current_lang))
end

---@param col string | table
function getColor(col)
  local r, g, b
  local errorMsg = ""
  if type(col) == "string" then
    if col:find("^#") then
      r, g, b = hexToRGB(col)
      r, g, b = round((r / 255), 1), round((g / 255), 1), round((b / 255), 1)
    elseif col == "black" then
      r, g, b = 0, 0, 0
    elseif col == "white" then
      r, g, b = 1, 1, 1
    elseif col == "red" then
      r, g, b = 1, 0, 0
    elseif col == "green" then
      r, g, b = 0, 1, 0
    elseif col == "blue" then
      r, g, b = 0, 0, 1
    elseif col == "yellow" then
      r, g, b = 1, 1, 0
    elseif col == "orange" then
      r, g, b = 1, 0.5, 0
    elseif col == "pink" then
      r, g, b = 1, 0, 0.5
    elseif col == "purple" then
      r, g, b = 1, 0, 1
    else
      r, g, b = 1, 1, 1
      errorMsg = ("'" .. tostring(col) .. "' is not a valid color for this function.\nOnly these strings can be used as color inputs:\n - 'black'\n - 'white'\n - 'red'\n - 'green'\n - 'blue'\n - 'yellow'\n - 'orange'\n - 'pink'\n - 'purple'")
    end
  elseif type(col) == "table" then
    -- check color input values and convert them to floats between 0 and 1 which is what ImGui accepts for color values.
    if col[1] > 1 then
      col[1] = round((col[1] / 255), 2)
    end
    if col[2] > 1 then
      col[2] = round((col[2] / 255), 2)
    end
    if col[3] > 1 then
      col[3] = round((col[3] / 255), 2)
    end
    r, g, b = col[1], col[2], col[3]
  end
  return r, g, b, errorMsg
end

---Creates a colored ImGui button.
---@param text string
---@param color string | table
---@param hovercolor string | table
---@param activecolor string | table
---@param alpha? integer
---@return boolean
coloredButton = function(text, color, hovercolor, activecolor, alpha)
  local r, g, b, _                   = getColor(color)
  local hoverR, hoverG, hoverB, _    = getColor(hovercolor)
  local activeR, activeG, activeB, _ = getColor(activecolor)
  if type(alpha) ~= "number" or alpha == nil then
    alpha = 1
  end
  if alpha > 1 then
    alpha = 1
  end
  ImGui.PushStyleColor(ImGuiCol.Button, r, g, b, alpha)
  ImGui.PushStyleColor(ImGuiCol.ButtonHovered, hoverR, hoverG, hoverB, alpha)
  ImGui.PushStyleColor(ImGuiCol.ButtonActive, activeR, activeG, activeB, alpha)
  ImGui.PopStyleColor(3)
  return ImGui.Button(text)
end

---@param text string
---@param wrap_size integer
function wrappedText(text, wrap_size)
  ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
  ImGui.TextWrapped(text)
  ImGui.PopTextWrapPos()
end

---Creates a colored ImGui text.
---@param text string
---@param color string | table
---@param alpha? integer
---@param wrap_size number
function coloredText(text, color, alpha, wrap_size)
  r, g, b, errorMsg = getColor(color)
  if type(alpha) ~= "number" or alpha == nil then
    alpha = 1
  end
  if alpha > 1 then
    alpha = 1
  end
  ImGui.PushStyleColor(ImGuiCol.Text, r, g, b, alpha)
  ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
  ImGui.TextWrapped(text)
  ImGui.PopTextWrapPos()
  ImGui.PopStyleColor(1)
  if errorMsg ~= "" then
    if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
      ImGui.SetNextWindowBgAlpha(0.8)
      ImGui.BeginTooltip()
      ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
      ImGui.TextWrapped(errorMsg)
      ImGui.PopTextWrapPos()
      ImGui.EndTooltip()
    end
  end
end

function helpmarker(colorFlag, text, color)
  if not disableTooltips then
    ImGui.SameLine()
    ImGui.TextDisabled("(?)")
    if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
      ImGui.SetNextWindowBgAlpha(0.75)
      ImGui.BeginTooltip()
      if colorFlag == true then
        coloredText(text, color, 1, 20)
      else
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
        ImGui.TextWrapped(text)
        ImGui.PopTextWrapPos()
      end
      ImGui.EndTooltip()
    end
  end
end

function widgetToolTip(colorFlag, text, color)
  if not disableTooltips then
    if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
      ImGui.SetNextWindowBgAlpha(0.75)
      ImGui.BeginTooltip()
      if colorFlag == true then
        coloredText(text, color, 1, 20)
      else
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
        ImGui.TextWrapped(text)
        ImGui.PopTextWrapPos()
      end
      ImGui.EndTooltip()
    end
  end
end

---@param mb string
---@return boolean
function isItemClicked(mb)
  local retBool = false
  if mb == "lmb" then
    retBool = ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(0)
  elseif mb == "rmb" then
    retBool = ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(1)
  else
    error(
      string.format("Error in function isItemClicked(): Invalid param %s. Correct inputs: 'lmb' for Left Mouse Button or 'rmb' for Right Mouse Button.", mb),
      2)
  end
  return retBool
end

---@param sound string
function widgetSound(sound)
  if not disableSound then
    local sounds_T = {
      { name = "Radar",     sound = "RADAR_ACTIVATE",      soundRef = "DLC_BTL_SECURITY_VANS_RADAR_PING_SOUNDS" },
      { name = "Select",    sound = "SELECT",              soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
      { name = "Pickup",    sound = "PICK_UP",             soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
      { name = "W_Pickup",  sound = "PICK_UP_WEAPON",      soundRef = "HUD_FRONTEND_CUSTOM_SOUNDSET" },
      { name = "Fail",      sound = "CLICK_FAIL",          soundRef = "WEB_NAVIGATION_SOUNDS_PHONE" },
      { name = "Notif",     sound = "LOSE_1ST",            soundRef = "GTAO_FM_EVENTS_SOUNDSET" },
      { name = "Delete",    sound = "DELETE",              soundRef = "HUD_DEATHMATCH_SOUNDSET" },
      { name = "Cancel",    sound = "CANCEL",              soundRef = "HUD_FREEMODE_SOUNDSET" },
      { name = "Error",     sound = "ERROR",               soundRef = "HUD_FREEMODE_SOUNDSET" },
      { name = "Nav",       sound = "NAV_LEFT_RIGHT",      soundRef = "HUD_FREEMODE_SOUNDSET" },
      { name = "Nav2",      sound = "NAV_UP_DOWN",         soundRef = "HUD_FREEMODE_SOUNDSET" },
      { name = "Select2",   sound = "CHANGE_STATION_LOUD", soundRef = "RADIO_SOUNDSET" },
      { name = "Focus_In",  sound = "FOCUSIN",             soundRef = "HINTCAMSOUNDS" },
      { name = "Focus_Out", sound = "FOCUSOUT",            soundRef = "HINTCAMSOUNDS" },
    }
    script.run_in_fiber(function()
      for _, snd in ipairs(sounds_T) do
        if sound == snd.name then
          AUDIO.PLAY_SOUND_FRONTEND(-1, snd.sound, snd.soundRef, false)
          break
        end
      end
    end)
  end
end

function getKeyPressed()
  local btn, gpad
  local controls_T = {
    { ctrl = 7,   gpad = "[R3]" },
    { ctrl = 10,  gpad = "[LT]" },
    { ctrl = 11,  gpad = "[RT]" },
    { ctrl = 14,  gpad = "[DPAD RIGHT]" },
    { ctrl = 15,  gpad = "[DPAD LEFT]" },
    { ctrl = 19,  gpad = "[DPAD DOWN]" },
    { ctrl = 20,  gpad = "[DPAD DOWN]" },
    { ctrl = 21,  gpad = "[A]" },
    { ctrl = 22,  gpad = "[X]" },
    { ctrl = 23,  gpad = "[Y]" },
    { ctrl = 27,  gpad = "[DPAD UP]" },
    { ctrl = 29,  gpad = "[R3]" },
    { ctrl = 30,  gpad = "[LEFT STICK]" },
    { ctrl = 34,  gpad = "[LEFT STICK]" },
    { ctrl = 36,  gpad = "[L3]" },
    { ctrl = 37,  gpad = "[LB]" },
    { ctrl = 38,  gpad = "[LB]" },
    { ctrl = 42,  gpad = "[DPAD UP]" },
    { ctrl = 43,  gpad = "[DPAD DOWN]" },
    { ctrl = 44,  gpad = "[RB]" },
    { ctrl = 45,  gpad = "[B]" },
    { ctrl = 46,  gpad = "[DPAD RIGHT]" },
    { ctrl = 47,  gpad = "[DPAD LEFT]" },
    { ctrl = 56,  gpad = "[Y]" },
    { ctrl = 57,  gpad = "[B]" },
    { ctrl = 70,  gpad = "[A]" },
    { ctrl = 71,  gpad = "[RT]" },
    { ctrl = 72,  gpad = "[LT]" },
    { ctrl = 73,  gpad = "[A]" },
    { ctrl = 74,  gpad = "[DPAD RIGHT]" },
    { ctrl = 75,  gpad = "[Y]" },
    { ctrl = 76,  gpad = "[RB]" },
    { ctrl = 79,  gpad = "[R3]" },
    { ctrl = 81,  gpad = "(NONE)" },
    { ctrl = 82,  gpad = "(NONE)" },
    { ctrl = 83,  gpad = "(NONE)" },
    { ctrl = 84,  gpad = "(NONE)" },
    { ctrl = 84,  gpad = "[DPAD LEFT]" },
    { ctrl = 96,  gpad = "(NONE)" },
    { ctrl = 97,  gpad = "(NONE)" },
    { ctrl = 124, gpad = "[LEFT STICK]" },
    { ctrl = 125, gpad = "[LEFT STICK]" },
    { ctrl = 112, gpad = "[LEFT STICK]" },
    { ctrl = 127, gpad = "[LEFT STICK]" },
    { ctrl = 117, gpad = "[LB]" },
    { ctrl = 118, gpad = "[RB]" },
    { ctrl = 167, gpad = "(NONE)" },
    { ctrl = 168, gpad = "(NONE)" },
    { ctrl = 169, gpad = "(NONE)" },
    { ctrl = 170, gpad = "[B]" },
    { ctrl = 172, gpad = "[DPAD UP]" },
    { ctrl = 173, gpad = "[DPAD DOWN]" },
    { ctrl = 174, gpad = "[DPAD LEFT]" },
    { ctrl = 175, gpad = "[DPAD RIGHT]" },
    { ctrl = 178, gpad = "[Y]" },
    { ctrl = 194, gpad = "[B]" },
    { ctrl = 243, gpad = "(NONE)" },
    { ctrl = 244, gpad = "[BACK]" },
    { ctrl = 249, gpad = "(NONE)" },
    { ctrl = 288, gpad = "[A]" },
    { ctrl = 289, gpad = "[X]" },
    { ctrl = 303, gpad = "[DPAD UP]" },
    { ctrl = 307, gpad = "[DPAD RIGHT]" },
    { ctrl = 308, gpad = "[DPAD LEFT]" },
    { ctrl = 311, gpad = "[DPAD DOWN]" },
    { ctrl = 318, gpad = "[START]" },
    { ctrl = 322, gpad = "(NONE)" },
    { ctrl = 344, gpad = "[DPAD RIGHT]" },
  }
  for _, v in ipairs(controls_T) do
    if PAD.IS_CONTROL_JUST_PRESSED(0, v.ctrl) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, v.ctrl) then
      btn, gpad = v.ctrl, v.gpad
    end
  end
  if not PAD.IS_USING_KEYBOARD_AND_MOUSE(0) then
    return btn, gpad
  else
    return nil, nil
  end
end

function isAnyKeyPressed()
  ---@type boolean
  local check
  ---@type integer
  local key_code
  ---@type string
  local key_name
  for _, k in ipairs(VK_T) do
    if k.just_pressed then
      check    = true
      key_code = k.code
      key_name = k.name
      break
    end
  end
  return check, key_code, key_name
end

---@param key integer
function isKeyPressed(key)
  for _, k in ipairs(VK_T) do
    if key == k.code then
      if k.pressed then
        return true
      else
        return false
      end
    end
  end
end

---@param key integer
function isKeyJustPressed(key)
  for _, k in ipairs(VK_T) do
    if key == k.code then
      return k.just_pressed
    end
  end
  return false
end

---@param dict string
function requestAnimDict(dict)
  while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do
    STREAMING.REQUEST_ANIM_DICT(dict)
    coroutine.yield()
  end
  return STREAMING.HAS_ANIM_DICT_LOADED(dict)
end

---@param model integer
function requestModel(model)
  local counter = 0
  while not STREAMING.HAS_MODEL_LOADED(model) do
    STREAMING.REQUEST_MODEL(model)
    coroutine.yield()
    if counter > 100 then
      return
    else
      counter = counter + 1
    end
  end
  return STREAMING.HAS_MODEL_LOADED(model)
end

---@param ped integer
getPedVehicleSeat = function(ped)
  if PED.IS_PED_SITTING_IN_ANY_VEHICLE(ped) then
    ---@type integer
    local pedSeat
    local vehicle  = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    local maxSeats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(vehicle))
    for i = -1, maxSeats do
      if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, true) then
        local sittingPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i, true)
        if sittingPed == ped then
          pedSeat = i
          break
        end
      end
    end
    return pedSeat
  end
end

function updatefilteredScenarios()
  filteredScenarios = {}
  for _, scene in ipairs(ped_scenarios) do
    if string.find(string.lower(scene.name), string.lower(searchQuery)) then
      table.insert(filteredScenarios, scene)
    end
  end
end

function displayFilteredScenarios()
  updatefilteredScenarios()
  scenarioNames = {}
  for _, scene in ipairs(filteredScenarios) do
    table.insert(scenarioNames, scene.name)
  end
  scenario_index, used = ImGui.ListBox("##scenarioList", scenario_index, scenarioNames, #filteredScenarios)
end

function displayHijackAnims()
  groupAnimNames = {}
  for _, anim in ipairs(hijackOptions) do
    table.insert(groupAnimNames, anim.name)
  end
  grp_anim_index, used = ImGui.Combo("##groupAnims", grp_anim_index, groupAnimNames, #hijackOptions)
end

function updateNpcs()
  filteredNpcs = {}
  for _, npc in ipairs(npcList) do
    table.insert(filteredNpcs, npc)
  end
  table.sort(filteredNpcs, function(a, b)
    return a.name < b.name
  end)
end

function updateRecentlyPlayed()
  filteredRecents = {}
  for _, v in ipairs(recently_played_a) do
    if string.find(string.lower(v.name), string.lower(searchQuery)) then
      table.insert(filteredRecents, v)
    end
  end
end

function displayRecentlyPlayed()
  updateRecentlyPlayed()
  local recentNames = {}
  for _, v in ipairs(filteredRecents) do
    local recentName = v.name
    if v.dict ~= nil then
      recentName = string.format("[Animation]  %s", recentName)
    elseif v.scenario ~= nil then
      recentName = string.format("[Scenario]    %s", recentName)
    end
    table.insert(recentNames, recentName)
  end
  recents_index, used = ImGui.ListBox("##recentsList", recents_index, recentNames, #filteredRecents)
end

function updateFavoriteActions()
  filteredFavs = {}
  for _, v in ipairs(favorite_actions) do
    if string.find(string.lower(v.name), string.lower(searchQuery)) then
      table.insert(filteredFavs, v)
    end
  end
end

function displayFavoriteActions()
  updateFavoriteActions()
  local favNames = {}
  for _, v in ipairs(filteredFavs) do
    local favName = v.name
    if v.dict ~= nil then
      favName = string.format("[Animation]  %s", favName)
    elseif v.scenario ~= nil then
      favName = string.format("[Scenario]    %s", favName)
    end
    table.insert(favNames, favName)
  end
  fav_actions_index, used = ImGui.ListBox("##favsList", fav_actions_index, favNames, #filteredFavs)
end

function displayNpcs()
  updateNpcs()
  npcNames = {}
  for _, npc in ipairs(filteredNpcs) do
    table.insert(npcNames, npc.name)
  end
  npc_index, used = ImGui.Combo("##npcList", npc_index, npcNames, #filteredNpcs)
end

function setmanualflag()
  if looped then
    flag_loop = 1
  else
    flag_loop = 0
  end
  if freeze then
    flag_freeze = 2
  else
    flag_freeze = 0
  end
  if upperbody then
    flag_upperbody = 16
  else
    flag_upperbody = 0
  end
  if controllable then
    flag_control = 32
  else
    flag_control = 0
  end
  flag = flag_loop + flag_freeze + flag_upperbody + flag_control
end

---@param musicSwitch string
---@param station? string
function play_music(musicSwitch, station)
  script.run_in_fiber(function(mp)
    if musicSwitch == "start" then
      local myPos       = self.get_pos()
      local bone_idx    = PED.GET_PED_BONE_INDEX(self.get_ped(), 24818)
      local pbus_model  = 345756458
      local dummy_model = 0xE75B4B1C
      if requestModel(pbus_model) then
        pBus = VEHICLE.CREATE_VEHICLE(pbus_model, myPos.x, myPos.y, (myPos.z - 30), 0, true, false, false)
        ENTITY.SET_ENTITY_VISIBLE(pbus, false, false)
        ENTITY.SET_ENTITY_ALPHA(pBus, 0.0, false)
        ENTITY.FREEZE_ENTITY_POSITION(pBus, true)
        ENTITY.SET_ENTITY_COLLISION(pBus, false, false)
        ENTITY.SET_ENTITY_INVINCIBLE(pBus, true)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(pBus, false, false)
      end
      mp:sleep(500)
      if ENTITY.DOES_ENTITY_EXIST(pBus) then
        entities.take_control_of(pBus, 300)
        if requestModel(dummy_model) then
          dummyDriver = PED.CREATE_PED(4, dummy_model, myPos.x, myPos.y, (myPos.z + 40), 0, true, false)
          if ENTITY.DOES_ENTITY_EXIST(dummyDriver) then
            entities.take_control_of(dummyDriver, 300)
            ENTITY.SET_ENTITY_ALPHA(dummyDriver, 0.0, false)
            PED.SET_PED_INTO_VEHICLE(dummyDriver, pBus, -1)
            PED.SET_PED_CONFIG_FLAG(dummyDriver, 402, true)
            PED.SET_PED_CONFIG_FLAG(dummyDriver, 398, true)
            PED.SET_PED_CONFIG_FLAG(dummyDriver, 167, true)
            PED.SET_PED_CONFIG_FLAG(dummyDriver, 251, true)
            PED.SET_PED_CONFIG_FLAG(dummyDriver, 255, true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(dummyDriver, true)
            AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(pBus, vehicles.get_vehicle_display_name(2765724541))
            VEHICLE.SET_VEHICLE_ENGINE_ON(pBus, true, false, false)
            AUDIO.SET_VEHICLE_RADIO_LOUD(pBus, true)
            VEHICLE.SET_VEHICLE_LIGHTS(pBus, 1)
            mp:sleep(500)
            if station ~= nil then
              AUDIO.SET_VEH_RADIO_STATION(pBus, station)
            end
            mp:sleep(500)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(pBus, self.get_ped(), bone_idx, -14.0, -1.3, -1.0, 0.0, 90.0, -90.0, false,
              true,
              false, true, 1, true, 1)
          else
            gui.show_error("YimActions", "Failed to start music!")
            return
          end
        end
      else
        gui.show_error("YimActions", "Failed to start music!")
        return
      end
    elseif musicSwitch == "stop" then
      if ENTITY.DOES_ENTITY_EXIST(dummyDriver) then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(dummyDriver, true, true)
        mp:sleep(200)
        ENTITY.DELETE_ENTITY(dummyDriver)
        dummyDriver = 0
      end
      if ENTITY.DOES_ENTITY_EXIST(pBus) then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pBus, true, true)
        mp:sleep(200)
        ENTITY.DELETE_ENTITY(pBus)
        pBus = 0
      end
    end
  end)
end

---@param text string
---@param type number
function busySpinnerOn(text, type)
  HUD.BEGIN_TEXT_COMMAND_BUSYSPINNER_ON("STRING")
  HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
  HUD.END_TEXT_COMMAND_BUSYSPINNER_ON(type)
end

busySpinnerOff = function()
  return HUD.BUSYSPINNER_OFF()
end

---@param s script_util
function cleanup(s)
  TASK.CLEAR_PED_TASKS(self.get_ped())
  if plyrProps[1] ~= nil then
    for _, v in ipairs(plyrProps) do
      if ENTITY.DOES_ENTITY_EXIST(v) then
        PED.DELETE_PED(v)
      end
      if ENTITY.DOES_ENTITY_EXIST(v) then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
        s:sleep(100)
        ENTITY.DELETE_ENTITY(v)
      end
    end
  end
  if selfPTFX[1] ~= nil then
    for _, v in ipairs(selfPTFX) do
      GRAPHICS.STOP_PARTICLE_FX_LOOPED(v, false)
    end
  end
  if ENTITY.DOES_ENTITY_EXIST(bbq) then
    ENTITY.DELETE_ENTITY(bbq)
  end
  if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
    local mySeat = getPedVehicleSeat(self.get_ped())
    PED.SET_PED_INTO_VEHICLE(self.get_ped(), self.get_veh(), mySeat)
  else
    local current_coords = self.get_pos()
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true,
      false, false)
  end
end

---@param s script_util
function cleanupNPC(s)
  for _, v in ipairs(spawned_npcs) do
    TASK.CLEAR_PED_TASKS(v)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(v, true)
    if PED.IS_PED_IN_ANY_VEHICLE(v, false) then
      local veh     = PED.GET_VEHICLE_PED_IS_IN(v, false)
      local npcSeat = getPedVehicleSeat(v)
      PED.SET_PED_INTO_VEHICLE(v, veh, npcSeat)
    end
  end
  if npcProps[1] ~= nil then
    for _, v in ipairs(npcProps) do
      if ENTITY.DOES_ENTITY_EXIST(v) then
        PED.DELETE_PED(v)
      end
      if ENTITY.DOES_ENTITY_EXIST(v) then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
        s:sleep(100)
        ENTITY.DELETE_ENTITY(v)
      end
    end
  end
  if ENTITY.DOES_ENTITY_EXIST(npcSexPed) then
    PED.DELETE_PED(npcSexPed)
  end
  if npcPTFX[1] ~= nil then
    for _, v in ipairs(npcPTFX) do
      GRAPHICS.STOP_PARTICLE_FX_LOOPED(v, false)
    end
  end
  if ENTITY.DOES_ENTITY_EXIST(bbq) then
    ENTITY.DELETE_ENTITY(bbq)
  end
end

---@param Info table
---@param target integer
---@param Flag integer
---@param prop1 integer
---@param prop2 integer
---@param loopedFX integer
---@param propPed integer
---@param targetBone integer
---@param targetCoords vec3
---@param targetHeading integer
---@param targetForwardX integer
---@param targetForwardY integer
---@param targetBoneCoords vec3
---@param ent string
---@param propTable table
---@param ptfxTable table
---@param s script_util
function playAnim(Info, target, Flag, prop1, prop2, loopedFX, propPed, targetBone, targetCoords, targetHeading,
  targetForwardX, targetForwardY, targetBoneCoords, ent, propTable, ptfxTable, s)
  local blendInSpeed, blendOutSpeed, duration = 4.0, -4.0, -1
  if target == self.get_ped() then
    if isCrouched then
      PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0)
      isCrouched = false
    end
  end
  if Info.blendin ~= nil then
    blendInSpeed = Info.blendin
  end
  if Info.blendout ~= nil then
    blendOutSpeed = Info.blendout
  end
  if Info.atime ~= nil then
    duration = Info.atime
  end
  if Info.type == 1 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function()
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.prop1) do
          STREAMING.REQUEST_MODEL(Info.prop1)
          coroutine.yield()
        end
        prop1 = OBJECT.CREATE_OBJECT(Info.prop1, 0.0, 0.0, 0.0, true, true, true)
        table.insert(propTable, prop1)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, target, targetBone, Info.posx, Info.posy, Info.posz, Info.rotx, Info.roty,
        Info.rotz, false, false, false, false, 2, true, 1)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  elseif Info.type == 2 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function(type2)
      while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(Info.ptfxdict) do
        STREAMING.REQUEST_NAMED_PTFX_ASSET(Info.ptfxdict)
        coroutine.yield()
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
      
      type2:sleep(Info.ptfxdelay)
      GRAPHICS.USE_PARTICLE_FX_ASSET(Info.ptfxdict)
      loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(Info.ptfxname, target, Info.ptfxOffx,
        Info.ptfxOffy, Info.ptfxOffz, Info.ptfxrotx, Info.ptfxroty, Info.ptfxrotz, targetBone, Info.ptfxscale, false,
        false, false, 0, 0, 0, 0)
      table.insert(ptfxTable, loopedFX)
    end)
  elseif Info.type == 3 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function()
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.prop1) do
          STREAMING.REQUEST_MODEL(Info.prop1)
          coroutine.yield()
        end
        prop1 = OBJECT.CREATE_OBJECT(Info.prop1, targetCoords.x + targetForwardX / 1.7,
          targetCoords.y + targetForwardY / 1.7, targetCoords.z, true, true, false)
        table.insert(propTable, prop1)
        ENTITY.SET_ENTITY_HEADING(prop1, targetHeading + Info.rotz)
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  elseif Info.type == 4 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function(type4)
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.prop1) do
          STREAMING.REQUEST_MODEL(Info.prop1)
          coroutine.yield()
        end
        prop1 = OBJECT.CREATE_OBJECT(Info.prop1, 0.0, 0.0, 0.0, true, true, false)
        table.insert(propTable, prop1)
        ENTITY.SET_ENTITY_COORDS(prop1, targetBoneCoords.x + Info.posx, targetBoneCoords.y + Info.posy,
          targetBoneCoords.z + Info.posz, false, false, false, false)
        type4:sleep(20)
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
        ENTITY.SET_ENTITY_COLLISION(prop1, Info.propColl, Info.propColl)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  elseif Info.type == 5 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function(type5)
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 0.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.prop1) do
          STREAMING.REQUEST_MODEL(Info.prop1)
          coroutine.yield()
        end
        prop1 = OBJECT.CREATE_OBJECT(Info.prop1, 0.0, 0.0, 0.0, true, true, false)
        table.insert(propTable, prop1)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, target, targetBone, Info.posx, Info.posy, Info.posz, Info.rotx, Info.roty,
          Info.rotz, false, false, false, false, 2, true, 1)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
        type5:sleep(50)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(Info.ptfxdict) do
          STREAMING.REQUEST_NAMED_PTFX_ASSET(Info.ptfxdict)
          coroutine.yield()
        end
        type5:sleep(Info.ptfxdelay)
        GRAPHICS.USE_PARTICLE_FX_ASSET(Info.ptfxdict)
        loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(Info.ptfxname, prop1, Info.ptfxOffx,
          Info.ptfxOffy, Info.ptfxOffz, Info.ptfxrotx, Info.ptfxroty, Info.ptfxrotz, Info.ptfxscale, false, false, false,
          0, 0, 0, 0)
      end
    end)
  elseif Info.type == 6 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function()
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.prop1) do
          STREAMING.REQUEST_MODEL(Info.prop1)
          coroutine.yield()
        end
        prop1 = OBJECT.CREATE_OBJECT(Info.prop1, 0.0, 0.0, 0.0, true, true, false)
        table.insert(propTable, prop1)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, target, targetBone, Info.posx, Info.posy, Info.posz, Info.rotx, Info.roty,
          Info.rotz, false, false, false, false, 2, true, 1)
        while not STREAMING.HAS_MODEL_LOADED(Info.prop2) do
          STREAMING.REQUEST_MODEL(Info.prop2)
          coroutine.yield()
        end
        prop2 = OBJECT.CREATE_OBJECT(Info.prop2, 0.0, 0.0, 0.0, true, true, false)
        table.insert(propTable, prop2)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop2, target, PED.GET_PED_BONE_INDEX(target, Info.bone2), Info.posx2, Info.posy2,
          Info.posz2, Info.rotx2, Info.roty2, Info.rotz2, false, false, false, false, 2, true, 1)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  elseif Info.type == 7 then
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function()
      if not disableProps then
        while not STREAMING.HAS_MODEL_LOADED(Info.pedHash) do
          STREAMING.REQUEST_MODEL(Info.pedHash)
          coroutine.yield()
        end
        propPed = PED.CREATE_PED(Info.pedType, Info.pedHash, 0.0, 0.0, 0.0, 0.0, true, false)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(propPed, target, targetBone, Info.posx, Info.posy, Info.posz, Info.rotx, Info.roty, Info.rotz, false, true, false, true, 1, true, 1)
        ENTITY.SET_ENTITY_INVINCIBLE(propPed, true)
        table.insert(propTable, propPed)
        npcNetID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(propPed)
        entities.take_control_of(propPed, 250)
        while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict2) do
          STREAMING.REQUEST_ANIM_DICT(Info.dict2)
          coroutine.yield()
        end
        TASK.TASK_PLAY_ANIM(propPed, Info.dict2, Info.anim2, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
        PED.SET_PED_CONFIG_FLAG(propPed, 179, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(propPed, true)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(propPed)
      end
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 1.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  else
    if ent == "self" then
      cleanup(s)
    elseif ent == "npc" then
      cleanupNPC(s)
    end
    script.run_in_fiber(function()
      while not STREAMING.HAS_ANIM_DICT_LOADED(Info.dict) do
        STREAMING.REQUEST_ANIM_DICT(Info.dict)
        coroutine.yield()
      end
      TASK.TASK_PLAY_ANIM(target, Info.dict, Info.anim, blendInSpeed, blendOutSpeed, duration, Flag, 0.0, false, false, false)
      PED.SET_PED_CONFIG_FLAG(target, 179, true)
    end)
  end
end

---@param ref table
---@param target integer
function playScenario(ref, target)
  script.run_in_fiber(function(script)
    local coords   = ENTITY.GET_ENTITY_COORDS(target, false)
    local heading  = ENTITY.GET_ENTITY_HEADING(target)
    local forwardX = ENTITY.GET_ENTITY_FORWARD_X(target)
    local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(target)
    if target == self.get_ped() then
      if is_playing_anim then
        cleanup(script)
        is_playing_anim = false
      end
      if isCrouched then
        PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0)
      end
    else
      cleanupNPC(script)
    end
    if ref.name == "Cook On BBQ" then
      while not STREAMING.HAS_MODEL_LOADED(286252949) do
        STREAMING.REQUEST_MODEL(286252949)
        coroutine.yield()
      end
      bbq = OBJECT.CREATE_OBJECT(286252949, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true,
        false)
      ENTITY.SET_ENTITY_HEADING(bbq, heading)
      OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(bbq)
      TASK.CLEAR_PED_TASKS_IMMEDIATELY(target)
      TASK.TASK_START_SCENARIO_IN_PLACE(target, ref.scenario, -1, true)
      is_playing_scenario = true
    else
      TASK.CLEAR_PED_TASKS_IMMEDIATELY(target)
      TASK.TASK_START_SCENARIO_IN_PLACE(target, ref.scenario, -1, true)
      is_playing_scenario = true
      if ENTITY.DOES_ENTITY_EXIST(bbq) then
        ENTITY.DELETE_ENTITY(bbq)
      end
    end
  end)
end

---@param ped integer
---@param s script_util
function stopScenario(ped, s)
  if PED.IS_PED_USING_ANY_SCENARIO(ped) then
    busySpinnerOn(SCN_STOP_SPINNER_, 3)
    TASK.CLEAR_PED_TASKS(ped)
    if ENTITY.DOES_ENTITY_EXIST(bbq) then
      ENTITY.DELETE_ENTITY(bbq)
    end
    repeat
      s:sleep(10)
    until not PED.IS_PED_USING_ANY_SCENARIO(ped)
    busySpinnerOff()
  end
end

---@param t table
function addActionToRecents(t)
  ---@type boolean
  local recent_exists
  if recently_played_a[1] ~= nil then
    for _, v in ipairs(recently_played_a) do
      if t.name == v.name then
        recent_exists = true
        break
      else
        recent_exists = false
      end
    end
  end
  if not recent_exists then
    table.insert(recently_played_a, t)
  end
end

function setdrunk()
  script.run_in_fiber(function()
    -- PED.SET_PED_USING_ACTION_MODE(PLAYER.PLAYER_ID(), false, -1, -1)
    while not STREAMING.HAS_CLIP_SET_LOADED("move_m@drunk@verydrunk") and not STREAMING.HAS_CLIP_SET_LOADED("move_strafe@first_person@drunk") do
      STREAMING.REQUEST_CLIP_SET("move_m@drunk@verydrunk")
      STREAMING.REQUEST_CLIP_SET("move_strafe@first_person@drunk")
      coroutine.yield()
    end
    PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_m@drunk@verydrunk", 1.0)
    PED.SET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped(), "move_m@drunk@verydrunk")
    PED.SET_PED_STRAFE_CLIPSET(self.get_ped(), "move_strafe@first_person@drunk")
    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 2231620617)
    currentMvmt  = "move_m@drunk@verydrunk"
    currentWmvmt = "move_m@drunk@verydrunk"
    currentStrf  = "move_strafe@first_person@drunk"
  end)
end

function sethoe()
  script.run_in_fiber(function()
    while not STREAMING.HAS_CLIP_SET_LOADED("move_f@maneater") do
      STREAMING.REQUEST_CLIP_SET("move_f@maneater")
      coroutine.yield()
    end
    PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
    PED.RESET_PED_STRAFE_CLIPSET(self.get_ped())
    PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_f@maneater", 1.0)
    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 1830115867)
    currentMvmt  = "move_f@maneater"
    currentWmvmt = ""
    currentStrf  = ""
  end)
end

function setgangsta()
  script.run_in_fiber(function()
    while not STREAMING.HAS_CLIP_SET_LOADED("move_m@gangster@ng") do
      STREAMING.REQUEST_CLIP_SET("move_m@gangster@ng")
      coroutine.yield()
    end
    while not STREAMING.HAS_CLIP_SET_LOADED("move_strafe@gang") do
      STREAMING.REQUEST_CLIP_SET("move_strafe@gang")
      coroutine.yield()
    end
    PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
    PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_m@gangster@ng", 0.3)
    PED.SET_PED_STRAFE_CLIPSET(self.get_ped(), "move_strafe@gang")
    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 1917483703)
    currentMvmt  = "move_m@gangster@ng"
    currentStrf  = "move_strafe@gang"
    currentWmvmt = ""
  end)
end

function setlester()
  script.run_in_fiber(function()
    while not STREAMING.HAS_CLIP_SET_LOADED("move_heist_lester") do
      STREAMING.REQUEST_CLIP_SET("move_heist_lester")
      coroutine.yield()
    end
    PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
    PED.RESET_PED_STRAFE_CLIPSET(self.get_ped())
    PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_heist_lester", 0.4)
    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 2231620617)
    currentMvmt  = "move_heist_lester"
    currentWmvmt = ""
    currentStrf  = ""
  end)
end

function setballistic()
  script.run_in_fiber(function()
    while not STREAMING.HAS_CLIP_SET_LOADED("anim_group_move_ballistic") and not STREAMING.HAS_CLIP_SET_LOADED("move_strafe@ballistic") do
      STREAMING.REQUEST_CLIP_SET("anim_group_move_ballistic")
      STREAMING.REQUEST_CLIP_SET("move_strafe@ballistic")
      coroutine.yield()
    end
    PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
    PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "anim_group_move_ballistic", 1)
    PED.SET_PED_STRAFE_CLIPSET(self.get_ped(), "move_strafe@ballistic")
    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 1429513766)
    currentMvmt = "anim_group_move_ballistic"
    currentStrf = "move_strafe@ballistic"
    currentWmvmt = ""
  end)
end

function displayProgressBar()
  local function progressBar()
    x = x + 0.01
    if x > 1 then
      x = 1
      progessMessage = "Settings Successfully Reset."
    else
      widgetSound("Nav2")
      progessMessage = "Please Wait..."
    end
  end
  ImGui.Text(progessMessage)
  progressBar()
  ImGui.ProgressBar(x, 250, 25)
end

function displayLangs()
  filteredLangs = {}
  for _, lang in ipairs(lang_T) do
    table.insert(filteredLangs, lang.name)
  end
  lang_idx, lang_idxUsed = ImGui.Combo("##langs", lang_idx, filteredLangs, #lang_T)
  if isItemClicked("lmb") then
    widgetSound("Nav")
  end
end

function resetCheckBoxes()
  disableTooltips  = false
  phoneAnim        = false
  disableProps     = false
  sprintInside     = false
  lockpick         = false
  manualFlags      = false
  controllable     = false
  looped           = false
  upperbody        = false
  freeze           = false
  usePlayKey       = false
  replaceSneakAnim = false
  disableSound     = false
  npc_godMode      = false
end

-- Returns whether the player is currently using any mobile or computer app.
function isBrowsingApps()
  for _, v in ipairs(app_script_names_T) do
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat(v)) > 0 then
      return true
    end
  end
  return false
end

function canCrouch()
  return not PED.IS_PED_RAGDOLL(self.get_ped())
      and not gui.is_open() and not is_playing_anim and not is_playing_scenario
      and not is_typing and not is_setting_hotkeys and not isCrouched
      and not HUD.IS_MP_TEXT_CHAT_TYPING() and not isBrowsingApps()
end

function canUsePhoneAnims()
  return not ENTITY.IS_ENTITY_DEAD(self.get_ped(), false) and not is_playing_anim and not is_playing_scenario
  and PED.COUNT_PEDS_IN_COMBAT_WITH_TARGET(self.get_ped()) == 0
end

function playPhoneAnims(toggle)
  for i = 242, 244 do
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), i, true) == toggle then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), i, not toggle)
    end
  end
end

---Enables phone gestures in GTA Online.
---@param s script_util
function playPhoneGestures(s)
  local is_phone_in_hand   = SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(
    joaat("CELLPHONE_FLASHHAND")
  ) > 0
  local is_browsing_email  = SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(
    joaat("APPMPEMAIL")
  ) > 0
  local call_anim_dict     = "anim@scripted@freemode@ig19_mobile_phone@male@"
  local call_anim          = "base"
  local call_anim_boneMask = "BONEMASK_HEAD_NECK_AND_R_ARM"
  if AUDIO.IS_MOBILE_PHONE_CALL_ONGOING() then
    if requestAnimDict(call_anim_dict) then
      TASK.TASK_PLAY_PHONE_GESTURE_ANIMATION(
        self.get_ped(), call_anim_dict, call_anim,
        call_anim_boneMask, 0.25, 0.25, true, false
      )
      repeat
        s:sleep(10)
      until
        AUDIO.IS_MOBILE_PHONE_CALL_ONGOING() == false
      TASK.TASK_STOP_PHONE_GESTURE_ANIMATION(self.get_ped(), 0.25)
    end
  end
  if is_phone_in_hand then
    MOBILE.CELL_HORIZONTAL_MODE_TOGGLE(is_browsing_email)
    for _, v in ipairs(cell_inputs_T) do
      if PAD.IS_CONTROL_JUST_PRESSED(0, v.control) then
        MOBILE.CELL_SET_INPUT(v.input)
      end
    end
  end
end

function onAnimInterrupt()
  if is_playing_anim and not ENTITY.IS_ENTITY_DEAD(self.get_ped(), true) and not isKeyJustPressed(keybinds.stop_anim.code)
    and not ENTITY.IS_ENTITY_PLAYING_ANIM(self.get_ped(), curr_playing_anim.dict, curr_playing_anim.anim, 3) then
    if requestAnimDict(curr_playing_anim.dict) then
      TASK.CLEAR_PED_TASKS(self.get_ped())
      TASK.TASK_PLAY_ANIM(self.get_ped(), curr_playing_anim.dict, curr_playing_anim.anim, 4.0, -4.0, -1,
      curr_playing_anim.flag, 1.0, false, false, false)
    end
  end
end

---@param s script_util
function reset_(s)
  TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
  PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.0)
  PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
  PED.RESET_PED_STRAFE_CLIPSET(self.get_ped())
  PED.SET_PED_RAGDOLL_ON_COLLISION(self.get_ped(), false)
  WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 3839837909)
  currentMvmt  = ""
  currentStrf  = ""
  currentWmvmt = ""
  isCrouched   = false
  if is_playing_anim then
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
    STREAMING.REMOVE_ANIM_DICT(info.dict)
    if selfPTFX ~= nil then
      for k, v in ipairs(selfPTFX) do
        GRAPHICS.STOP_PARTICLE_FX_LOOPED(v, false)
        table.remove(selfPTFX, k)
      end
    end
    -- //fix player clipping through the ground after ending low-positioned anims//
    local current_coords = self.get_pos()
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), false) then
      local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
      PED.SET_PED_INTO_VEHICLE(self.get_ped(), veh, -1)
    else
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true,
        false, false)
    end
    is_playing_anim = false
    if plyrProps[1] ~= nil then
      for k, v in ipairs(plyrProps) do
        if ENTITY.DOES_ENTITY_EXIST(v) then
          ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, true, true)
          ENTITY.DELETE_ENTITY(v)
        end
        table.remove(plyrProps, k)
      end
    end
  end
  if spawned_npcs[1] ~= nil then
    cleanupNPC(s)
    for k, v in ipairs(spawned_npcs) do
      if ENTITY.DOES_ENTITY_EXIST(v) then
        ENTITY.DELETE_ENTITY(v)
      end
      table.remove(spawned_npcs, k)
    end
  end
  if is_playing_scenario then
    stopScenario(self.get_ped(), s)
    is_playing_scenario = false
  end
  if ENTITY.DOES_ENTITY_EXIST(bbq) then
    ENTITY.DELETE_ENTITY(bbq)
  end
  if plyrProps[1] ~= nil then
    for k, v in ipairs(plyrProps) do
      if ENTITY.DOES_ENTITY_EXIST(v) then
        ENTITY.DELETE_ENTITY(v)
        table.remove(plyrProps, k)
      end
    end
  end
end

function set_hotkey(keybind)
  ImGui.Dummy(1, 10)
  if key_name == nil then
    start_loading_anim = true
    coloredText(string.format("%s%s", INPUT_WAIT_TXT_, loading_label), "#FFFFFF", 0.75, 20)
    key_pressed, key_code, key_name = isAnyKeyPressed()
  else
    start_loading_anim = false
    for _, key in pairs(reserved_keys_T.kb) do
      if key_code == key then
        _reserved = true
        break
      else
        _reserved = false
      end
    end
    if not _reserved then
      ImGui.Text("New Key: "); ImGui.SameLine(); ImGui.Text(key_name)
    else
      coloredText(HOTKEY_RESERVED_, "red", 0.86, 20)
    end
    ImGui.SameLine(); ImGui.Dummy(5, 1); ImGui.SameLine()
    if coloredButton(string.format(" %s ##Shortcut", GENERIC_CLEAR_BTN_), "#FFDB58", "#FFFAA0", "#FFFFF0", 0.7) then
      widgetSound("Cancel")
      key_code, key_name = nil, nil
    end
  end
  ImGui.Dummy(1, 10)
  if not _reserved and key_code ~= nil then
    if ImGui.Button(string.format("%s##keybinds", GENERIC_CONFIRM_BTN_)) then
      widgetSound("Select")
      keybind.code, keybind.name = key_code, key_name
      CFG.save("keybinds", keybinds)
      key_code, key_name = nil, nil
      is_setting_hotkeys = false
      ImGui.CloseCurrentPopup()
    end
    ImGui.SameLine(); ImGui.Spacing(); ImGui.SameLine()
  end
  if ImGui.Button(string.format("%s##keybinds", GENERIC_CANCEL_BTN_)) then
    widgetSound("Cancel")
    key_code, key_name = nil, nil
    start_loading_anim = false
    is_setting_hotkeys = false
    ImGui.CloseCurrentPopup()
  end
end

function openHotkeyWindow(window_name, keybind)
  ImGui.PushItemWidth(120)
  ImGui.BulletText(window_name)
  ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
  keybind.name, _ = ImGui.InputText(string.format("##%s", window_name), keybind.name, 32, ImGuiInputTextFlags.ReadOnly)
  ImGui.PopItemWidth()
  if isItemClicked('lmb') then
    widgetSound("Select2")
    ImGui.OpenPopup(window_name)
    is_setting_hotkeys = true
  end
  ImGui.SameLine(); ImGui.BeginDisabled(keybind.code == 0x0)
  if ImGui.Button(string.format("Remove##%s", window_name)) then
    widgetSound("Delete")
    keybind.code, keybind.name = 0x0, "[Unbound]"
    CFG.save("keybinds", keybinds)
  end
  ImGui.EndDisabled()
  ImGui.SetNextWindowPos(780, 400, ImGuiCond.Appearing)
  ImGui.SetNextWindowSizeConstraints(240, 60, 600, 400)
  ImGui.SetNextWindowBgAlpha(0.8)
  if ImGui.BeginPopupModal(window_name, true, ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoTitleBar) then
    is_setting_hotkeys = true
    set_hotkey(keybind)
    ImGui.End()
  end
end

set_gpad_hotkey = function(keybind)
  ImGui.Dummy(1, 10)
  if gpad_keyName == nil then
    start_loading_anim = true
    coloredText(string.format("%s%s", INPUT_WAIT_TXT_, loading_label), "#FFFFFF", 0.75, 20)
    gpad_keyCode, gpad_keyName = getKeyPressed()
  else
    start_loading_anim = false
    for _, key in pairs(reserved_keys_T.gpad) do
      if gpad_keyCode == key then
        _reserved = true
        break
      else
        _reserved = false
      end
    end
    if not _reserved then
      ImGui.Text("New Key: "); ImGui.SameLine(); ImGui.Text(gpad_keyName)
    else
      coloredText(HOTKEY_RESERVED_, "red", 0.86, 20)
    end
    ImGui.SameLine(); ImGui.Dummy(5, 1); ImGui.SameLine()
    if coloredButton(string.format(" %s ##gpadkeybinds", GENERIC_CLEAR_BTN_), "#FFDB58", "#FFFAA0", "#FFFFF0", 0.7) then
      widgetSound("Cancel")
      gpad_keyCode, gpad_keyName = nil, nil
    end
  end
  ImGui.Dummy(1, 10)
  if not _reserved and gpad_keyCode ~= nil then
    if ImGui.Button(string.format("%s##gpadkeybinds", GENERIC_CONFIRM_BTN_)) then
      widgetSound("Select")
      keybind.code, keybind.name = gpad_keyCode, gpad_keyName
      CFG.save("gpad_keybinds", gpad_keybinds)
      gpad_keyCode, gpad_keyName = nil, nil
      is_setting_hotkeys = false
      ImGui.CloseCurrentPopup()
    end
    ImGui.SameLine(); ImGui.Spacing(); ImGui.SameLine()
  end
  if ImGui.Button(string.format("%s##gpadkeybinds", GENERIC_CANCEL_BTN_)) then
    widgetSound("Cancel")
    gpad_keyCode, gpad_keyName = nil, nil
    start_loading_anim = false
    is_setting_hotkeys = false
    ImGui.CloseCurrentPopup()
  end
end

function gpadHotkeyWindow(window_name, keybind)
  ImGui.PushItemWidth(120)
  ImGui.BulletText(window_name)
  ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
  keybind.name, _ = ImGui.InputText(string.format("##%s", window_name), keybind.name, 32, ImGuiInputTextFlags.ReadOnly)
  ImGui.PopItemWidth()
  if isItemClicked('lmb') then
    widgetSound("Select2")
    ImGui.OpenPopup(window_name)
    is_setting_hotkeys = true
  end
  ImGui.SameLine(); ImGui.BeginDisabled(keybind.code == 0)
  if ImGui.Button(string.format("Remove##%s", window_name)) then
    widgetSound("Delete")
    keybind.code, keybind.name = 0, "[Unbound]"
    CFG.save("gpad_keybinds", gpad_keybinds)
  end
  ImGui.EndDisabled()
  ImGui.SetNextWindowPos(780, 400, ImGuiCond.Appearing)
  ImGui.SetNextWindowSizeConstraints(240, 60, 600, 400)
  ImGui.SetNextWindowBgAlpha(0.8)
  if ImGui.BeginPopupModal(window_name, true, ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoTitleBar) then
    set_gpad_hotkey(keybind)
    ImGui.End()
  end
end
