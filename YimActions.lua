---@diagnostic disable: undefined-global, lowercase-global

SCRIPT_NAME    = "YimActions"
SCRIPT_VERSION = "v1.3"
CFG            = require("utils/YimConfig")
DEFAULT_CONFIG = {
  disableTooltips   = false,
  phoneAnim         = false,
  disableProps      = false,
  sprintInside      = false,
  lockpick          = false,
  manualFlags       = false,
  controllable      = false,
  looped            = false,
  upperbody         = false,
  freeze            = false,
  usePlayKey        = false,
  replaceSneakAnim  = false,
  disableSound      = false,
  npc_godMode       = false,
  disableActionMode = false,
  LANG              = 'en-US',
  current_lang      = 'English',
  lang_idx          = 0,
  shortcut_anim     = {},
  favorite_actions  = {},
  keybinds          = {
    rodBtn        = { code = 0x58, name = "[X]" },
    stop_anim     = { code = 0x47, name = "[G]" },
    play_anim     = { code = 0x2E, name = "[DEL]" },
    previous_anim = { code = 0x21, name = "[PAGE UP]" },
    next_anim     = { code = 0x22, name = "[PAGE DOWN]" },
    panik         = { code = 0x7B, name = "[F12]" },
  },
  gpad_keybinds     = {
    stop_anim = { code = 0, name = "[Unbound]" },
    rodBtn    = { code = 0, name = "[Unbound]" },
  },
}

YimActions     = gui.add_tab("YimActions")
log.info(string.format("version %s", SCRIPT_VERSION))
-----------------------------------------------------------
filteredAnims       = {}
filteredScenarios   = {}
npc_blips           = {}
spawned_npcs        = {}
plyrProps           = {}
npcProps            = {}
selfPTFX            = {}
npcPTFX             = {}
curr_playing_anim   = {}
chosen_anim         = {}
recently_played_a   = {}
phoneAnim           = CFG.read("phoneAnim")
sprintInside        = CFG.read("sprintInside")
lockPick            = CFG.read("lockPick")
manualFlags         = CFG.read("manualFlags")
controllable        = CFG.read("controllable")
looped              = CFG.read("looped")
upperbody           = CFG.read("upperbody")
freeze              = CFG.read("freeze")
usePlayKey          = CFG.read("usePlayKey")
replaceSneakAnim    = CFG.read("replaceSneakAnim")
disableProps        = CFG.read("disableProps")
disableTooltips     = CFG.read("disableTooltips")
npc_godMode         = CFG.read("npc_godMode")
disableSound        = CFG.read("disableSound")
disableActionMode   = CFG.read("disableActionMode")
shortcut_anim       = CFG.read("shortcut_anim")
favorite_actions    = CFG.read("favorite_actions")
keybinds            = CFG.read("keybinds")
gpad_keybinds       = CFG.read("gpad_keybinds")
LANG                = CFG.read("LANG")
current_lang        = CFG.read("current_lang")
lang_idx            = CFG.read("lang_idx")
is_playing_anim     = false
is_playing_scenario = false
is_typing           = false
clumsy              = false
rod                 = false
isCrouched          = false
hijack_started      = false
phoneAnimsEnabled   = false
anim_music          = false
is_setting_hotkeys  = false
start_loading_anim  = false
fav_exists          = false
is_shortcut_anim    = false
searchBar           = true
tab1Sound           = true
tab2Sound           = true
tab3Sound           = true
anim_index          = 0
actions_switch      = 0
scenario_index      = 0
bbq                 = 0
recents_index       = 0
fav_actions_index   = 0
grp_anim_index      = 0
npc_index           = 0
switch              = 0
anim_sortby_idx     = 0
x                   = 0
counter             = 0
searchQuery         = ""
currentMvmt         = ""
currentStrf         = ""
currentWmvmt        = ""
stopButton          = ""
loading_label       = ""
local selected_lang

KBM_ROD_BUTTON      = keybinds.rodBtn.name
GPAD_ROD_BUTTON     = gpad_keybinds.rodBtn.name

require("lib/ya_translations")
require("lib/actions_data")
require("utils/actions_utils")
initStrings()

local animSortbyList <const> = {
  "All",
  "Actions",
  "Activities",
  "Gestures",
  "In-Vehicle",
  "Movements",
  "MISC",
  "NSFW",
}

local function updatefilteredAnims()
  filteredAnims = {}
  for _, anim in ipairs(animlist) do
    if anim_sortby_idx == 0 then
      if string.find(string.lower(anim.name), string.lower(searchQuery)) then
        table.insert(filteredAnims, anim)
      end
    else
      if anim.cat == animSortbyList[anim_sortby_idx + 1] then
        if string.find(string.lower(anim.name), string.lower(searchQuery)) then
          table.insert(filteredAnims, anim)
        end
      end
    end
  end
  table.sort(animlist, function(a, b)
    return a.name < b.name
  end)
end

function displayFilteredAnims()
  updatefilteredAnims()
  animNames = {}
  for _, anim in ipairs(filteredAnims) do
    table.insert(animNames, anim.name)
  end
  anim_index, used = ImGui.ListBox("##animlistbox", anim_index, animNames, #filteredAnims)
end

local function showSearchBar()
  if searchBar then
    ImGui.PushItemWidth(500)
    searchQuery, used = ImGui.InputTextWithHint("##searchBar", GENERIC_SEARCH_HINT_, searchQuery, 32)
    if ImGui.IsItemActive() then
      is_typing = true
    else
      is_typing = false
    end
  end
end

YimActions:add_imgui(function()
  showSearchBar()
  ImGui.BeginTabBar("YimActions", ImGuiTabBarFlags.None)
  if ImGui.BeginTabItem(ANIMATIONS_TAB_) then
    if tab1Sound then
      widgetSound("Nav")
      tab1Sound = false
      tab2Sound = true
      tab3Sound = true
    end
    ImGui.Spacing(); ImGui.BulletText("Filter Animations: "); ImGui.SameLine()
    ImGui.PushItemWidth(220)
    anim_sortby_idx, animSortUsed = ImGui.Combo("##animCategories", anim_sortby_idx, animSortbyList, #animSortbyList)
    ImGui.PopItemWidth()
    if animSortUsed then
      widgetSound("Nav2")
    end
    ImGui.Spacing(); ImGui.Separator(); ImGui.PushItemWidth(510)
    displayFilteredAnims()
    ImGui.PopItemWidth()
    if filteredAnims ~= nil then
      info = filteredAnims[anim_index + 1]
    end
    ImGui.Separator(); manualFlags, used = ImGui.Checkbox("Edit Flags", manualFlags)
    if used then
      CFG.save("manualFlags", manualFlags)
      widgetSound("Nav2")
    end
    helpmarker(false, ANIM_FLAGS_DESC_)
    ImGui.SameLine(); disableProps, used = ImGui.Checkbox("Disable Props", disableProps)
    if used then
      CFG.save("disableProps", disableProps)
      widgetSound("Nav2")
    end
    helpmarker(false, ANIM_PROPS_DESC_)
    if manualFlags then
      ImGui.Separator()
      controllable, used = ImGui.Checkbox(ANIM_CONTROL_CB_, controllable)
      if used then
        CFG.save("controllable", controllable)
        widgetSound("Nav2")
      end
      helpmarker(false, ANIM_CONTROL_DESC_)
      ImGui.SameLine(); ImGui.Dummy(27, 1); ImGui.SameLine()
      looped, used = ImGui.Checkbox("Loop", looped)
      if used then
        CFG.save("looped", looped)
        widgetSound("Nav2")
      end
      helpmarker(false, ANIM_LOOP_DESC_)
      upperbody, used = ImGui.Checkbox(ANIM_UPPER_CB_, upperbody)
      if used then
        CFG.save("upperbody", upperbody)
        widgetSound("Nav2")
      end
      helpmarker(false, ANIM_UPPER_DESC_)
      ImGui.SameLine(); ImGui.Dummy(1, 1); ImGui.SameLine()
      freeze, used = ImGui.Checkbox(ANIM_FREEZE_CB_, freeze)
      if used then
        CFG.save("freeze", freeze)
        widgetSound("Nav2")
      end
      helpmarker(false, ANIM_FREEZE_DESC_)
    end
    if ImGui.Button(string.format("%s##selfAnim", GENERIC_PLAY_BTN_)) then
      script.run_in_fiber(function(pa)
        if info.cat == "In-Vehicle" and (PED.IS_PED_ON_FOOT(self.get_ped())
          or not VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(self.get_veh()))) then
          widgetSound("Error")
          gui.show_error("YimActions", "This animation can only be played while sitting inside a vehicle (cars and trucks only).")
        else
          widgetSound("Select")
          local coords     = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
          local heading    = ENTITY.GET_ENTITY_HEADING(self.get_ped())
          local forwardX   = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
          local forwardY   = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
          local boneIndex  = PED.GET_PED_BONE_INDEX(self.get_ped(), info.boneID)
          local bonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), info.boneID, 0.0, 0.0, 0.0)
          if manualFlags then
            setmanualflag()
          else
            flag = info.flag
          end
          curr_playing_anim = info
          if str_contains(curr_playing_anim.name, "DJ") then
            if not anim_music then
              play_music("start", "RADIO_22_DLC_BATTLE_MIX1_RADIO")
              anim_music = true
            end
          else
            if anim_music then
              play_music("stop")
              anim_music = false
            end
          end
          playAnim(
            info, self.get_ped(), flag, selfprop1, selfprop2, selfloopedFX, selfSexPed, boneIndex, coords, heading,
            forwardX, forwardY, bonecoords, "self", plyrProps, selfPTFX, pa)
          is_playing_anim = true
          addActionToRecents(info)
        end
      end)
    end
    ImGui.SameLine()
    if ImGui.Button(string.format("%s##anim", GENERIC_STOP_BTN_)) then
      if is_playing_anim then
        widgetSound("Cancel")
        script.run_in_fiber(function(cu)
          cleanup(cu)
          is_playing_anim = false
          if anim_music then
            play_music("stop")
            anim_music = false
          end
        end)
      else
        widgetSound("Error")
      end
    end
    widgetToolTip(false, ANIM_STOP_DESC_)
    ImGui.SameLine(); ImGui.Dummy(12, 1); ImGui.SameLine()
    local errCol = {}
    local errSound = false
    if plyrProps[1] ~= nil then
      errCol = { 104, 247, 114, 0.2 }
      errSound = false
    else
      errCol = { 225, 0, 0, 0.5 }
      errSound = true
    end
    if coloredButton(ANIM_DETACH_BTN_, {104, 247, 114}, {104, 247, 114}, errCol, 0.6) then
      if not errSound then
        widgetSound("Cancel")
      else
        widgetSound("Error")
      end
      script.run_in_fiber(function(detacher)
        if all_objects == nil then
          all_objects = entities.get_all_objects_as_handles()
        end
        for _, v in ipairs(all_objects) do
          local modelHash      = ENTITY.GET_ENTITY_MODEL(v)
          local attachedObject = ENTITY.GET_ENTITY_OF_TYPE_ATTACHED_TO_ENTITY(self.get_ped(), modelHash)
          if ENTITY.DOES_ENTITY_EXIST(attachedObject) then
            ENTITY.DETACH_ENTITY(attachedObject, true, true)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(attachedObject)
            TASK.CLEAR_PED_TASKS(self.get_ped())
          end
        end
        if all_peds == nil then
          all_peds = entities.get_all_peds_as_handles()
        end
        for _, p in ipairs(all_peds) do
          local pedHash     = ENTITY.GET_ENTITY_MODEL(p)
          local attachedPed = ENTITY.GET_ENTITY_OF_TYPE_ATTACHED_TO_ENTITY(self.get_ped(), pedHash)
          if ENTITY.DOES_ENTITY_EXIST(attachedPed) then
            ENTITY.DETACH_ENTITY(attachedPed, true, true)
            TASK.CLEAR_PED_TASKS(self.get_ped())
            TASK.CLEAR_PED_TASKS(attachedPed)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(attachedPed)
          end
        end
        is_playing_anim = false
        if is_playing_scenario then
          stopScenario(self.get_ped(), detacher)
          is_playing_scenario = false
        end
        if plyrProps[1] ~= nil then
          for k, _ in ipairs(plyrProps) do
            table.remove(plyrProps, k)
          end
        end
      end)
    end
    widgetToolTip(false, ANIM_DETACH_DESC_)
    ImGui.SameLine()
    if info ~= nil then
      if shortcut_anim.name ~= info.name then
        if ImGui.Button(ANIM_HOTKEY_BTN_) then
          chosen_anim        = info
          is_setting_hotkeys = true
          widgetSound("Select2")
          ImGui.OpenPopup("Set Shortcut")
        end
        widgetToolTip(false, ANIM_HOTKEY_DESC_)
        ImGui.SetNextWindowPos(760, 400, ImGuiCond.Appearing)
        ImGui.SetNextWindowBgAlpha(0.9)
        if ImGui.BeginPopupModal("Set Shortcut", true, ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoTitleBar) then
          coloredText("Selected Animation:  ", "green", 0.9, 20); ImGui.SameLine(); ImGui.Text(string.format("« %s »",
            chosen_anim.name))
          ImGui.Dummy(1, 10)
          if btn_name == nil then
            start_loading_anim = true
            coloredText(string.format("%s %s", INPUT_WAIT_TXT_, loading_label), "#FFFFFF", 0.75, 20)
            is_pressed, btn, btn_name = isAnyKeyPressed()
          else
            start_loading_anim = false
            for _, key in pairs(reserved_keys_T.kb) do
              if btn == key then
                _reserved = true
                break
              else
                _reserved = false
              end
            end
            if not _reserved then
              ImGui.Text("Shortcut Button: "); ImGui.SameLine(); ImGui.Text(btn_name)
            else
              coloredText(HOTKEY_RESERVED_, "red", 0.86, 20)
            end
            ImGui.SameLine(); ImGui.Dummy(5, 1); ImGui.SameLine()
            if coloredButton(string.format("%s##shortcut", GENERIC_CLEAR_BTN_), "#FFDB58", "#FFFAA0", "#FFFFF0", 0.7) then
              widgetSound("Error")
              btn, btn_name = nil, nil
            end
          end
          ImGui.Dummy(1, 10)
          if not _reserved and btn ~= nil then
            if ImGui.Button(string.format("%s##shortcut", GENERIC_CONFIRM_BTN_)) then
              widgetSound("Select")
              if manualFlags then
                setmanualflag()
              else
                flag = chosen_anim.flag
              end
              shortcut_anim     = chosen_anim
              shortcut_anim.btn = btn
              CFG.save("shortcut_anim", shortcut_anim)
              gui.show_success("YimActions", string.format("%s %s %s", HOTKEY_SUCCESS1_, btn_name, HOTKEY_SUCCESS2_))
              btn, btn_name      = nil, nil
              is_setting_hotkeys = false
              ImGui.CloseCurrentPopup()
            end
            ImGui.SameLine(); ImGui.Spacing(); ImGui.SameLine()
          end
          if ImGui.Button(string.format("%s##shortcut", GENERIC_CANCEL_BTN_)) then
            widgetSound("Cancel")
            btn, btn_name      = nil, nil
            start_loading_anim = false
            is_setting_hotkeys = false
            ImGui.CloseCurrentPopup()
          end
          ImGui.End()
        end
      else
        if ImGui.Button(ANIM_HOTKEY_DEL_) then
          widgetSound("Delete")
          shortcut_anim = {}
          CFG.save("shortcut_anim", {})
          gui.show_success("YimActions", "Animation shortcut has been reset.")
        end
        widgetToolTip(false, DEL_HOTKEY_DESC_)
      end
      if favorite_actions[1] ~= nil then
        for _, v in ipairs(favorite_actions) do
          if info.name == v.name then
            fav_exists = true
            break
          else
            fav_exists = false
          end
        end
      else
        if fav_exists then
          fav_exists = false
        end
      end
      if not fav_exists then
        if ImGui.Button(string.format("%s##anims", ADD_TO_FAVS_)) then
          widgetSound("Select")
          table.insert(favorite_actions, info)
          CFG.save("favorite_actions", favorite_actions)
        end
      else
        if ImGui.Button(REMOVE_FROM_FAVS_) then
          widgetSound("Delete")
          for k, v in ipairs(favorite_actions) do
            if v == info then
              table.remove(favorite_actions, k)
            end
          end
          CFG.save("favorite_actions", favorite_actions)
        end
      end
    end
    ImGui.Spacing(); ImGui.SeparatorText(MVMT_OPTIONS_TXT_); ImGui.Spacing()
    local isChanged = false
    actions_switch, isChanged = ImGui.RadioButton("Normal", actions_switch, 0)
    if isChanged then
      widgetSound("Nav")
      script.run_in_fiber(function()
        PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.3)
        PED.RESET_PED_STRAFE_CLIPSET(self.get_ped())
        PED.RESET_PED_WEAPON_MOVEMENT_CLIPSET(self.get_ped())
        WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(self.get_ped(), 3839837909)
        currentMvmt  = ""
        currentStrf  = ""
        currentWmvmt = ""
        isChanged    = false
      end)
    end
    ImGui.SameLine(); ImGui.Dummy(23, 1); ImGui.SameLine()
    actions_switch, isChanged = ImGui.RadioButton("Drunk", actions_switch, 1)
    if isChanged then
      setdrunk()
      widgetSound("Nav")
    end
    ImGui.SameLine(); ImGui.Dummy(22, 1); ImGui.SameLine()
    actions_switch, isChanged = ImGui.RadioButton("Hoe", actions_switch, 2)
    if isChanged then
      sethoe()
      widgetSound("Nav")
    end
    actions_switch, isChanged = ImGui.RadioButton("Gangsta ", actions_switch, 3)
    if isChanged then
      widgetSound("Nav")
      setgangsta()
    end
    ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
    actions_switch, isChanged = ImGui.RadioButton(" Lester ", actions_switch, 4)
    if isChanged then
      widgetSound("Nav")
      setlester()
    end
    ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
    actions_switch, isChanged = ImGui.RadioButton("Heavy", actions_switch, 5)
    if isChanged then
      widgetSound("Nav")
      setballistic()
    end
    ImGui.Spacing(); ImGui.SeparatorText(NPC_ANIMS_TXT_)
    ImGui.PushItemWidth(220)
    displayNpcs()
    ImGui.PopItemWidth()
    ImGui.SameLine()
    npc_godMode, ngodused = ImGui.Checkbox("Invincible", npc_godMode)
    if ngodused then
      widgetSound("Nav")
      CFG.save("npc_godMode", npc_godMode)
      if spawned_npcs[1] ~= nil then
        script.run_in_fiber(function()
          for _, npc in ipairs(spawned_npcs) do
            if ENTITY.DOES_ENTITY_EXIST(npc) and not ENTITY.IS_ENTITY_DEAD(npc, true) then
              ENTITY.SET_ENTITY_INVINCIBLE(npc, npc_godMode)
            end
          end
        end)
      end
    end
    widgetToolTip(false, NPC_GODMODE_DESC_)
    if ImGui.Button(string.format("%s##anims_npc", GENERIC_SPAWN_BTN_)) then
      widgetSound("Select")
      script.run_in_fiber(function()
        local npcData     = filteredNpcs[npc_index + 1]
        local pedCoords   = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
        local pedHeading  = ENTITY.GET_ENTITY_HEADING(self.get_ped())
        local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
        local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
        local myGroup     = PED.GET_PED_GROUP_INDEX(self.get_ped())
        if not PED.DOES_GROUP_EXIST(myGroup) then
          myGroup = PED.CREATE_GROUP(0)
        end
        PED.SET_GROUP_SEPARATION_RANGE(myGroup, 16960)
        while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
          STREAMING.REQUEST_MODEL(npcData.hash)
          coroutine.yield()
        end
        npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4,
          pedCoords.z, true, false, false)
        ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
        PED.SET_PED_AS_GROUP_MEMBER(npc, myGroup)
        PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
        npcBlip = HUD.ADD_BLIP_FOR_ENTITY(npc)
        table.insert(npc_blips, npcBlip)
        HUD.SET_BLIP_AS_FRIENDLY(npcBlip, true)
        HUD.SET_BLIP_SCALE(npcBlip, 0.8)
        HUD.SHOW_HEADING_INDICATOR_ON_BLIP(npcBlip, true)
        WEAPON.GIVE_WEAPON_TO_PED(npc, 350597077, 9999, false, true)
        PED.SET_GROUP_FORMATION(myGroup, 2)
        PED.SET_GROUP_FORMATION_SPACING(myGroup, 1.0, 1.0, 1.0)
        PED.SET_PED_CONFIG_FLAG(npc, 179, true)
        PED.SET_PED_CONFIG_FLAG(npc, 294, true)
        PED.SET_PED_CONFIG_FLAG(npc, 398, true)
        PED.SET_PED_CONFIG_FLAG(npc, 401, true)
        PED.SET_PED_CONFIG_FLAG(npc, 443, true)
        PED.SET_PED_COMBAT_ABILITY(npc, 2)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 2, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 3, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 5, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 13, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 20, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 21, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 22, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 27, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 28, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 31, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 34, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 41, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 42, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 46, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 50, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 58, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 61, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 71, true)
        if npc_godMode then
          ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
        end
        table.insert(spawned_npcs, npc)
      end)
    end
    ImGui.SameLine()
    if ImGui.Button(string.format("%s##anim_npc", GENERIC_DELETE_BTN_)) then
      widgetSound("Delete")
      script.run_in_fiber(function(cu)
        cleanupNPC(cu)
        for k, v in ipairs(spawned_npcs) do
          if ENTITY.DOES_ENTITY_EXIST(v) then
            PED.REMOVE_PED_FROM_GROUP(v)
            ENTITY.DELETE_ENTITY(v)
          end
          table.remove(spawned_npcs, k)
        end
        is_playing_anim = false
      end)
    end
    ImGui.SameLine(); ImGui.BeginDisabled(spawned_npcs[1] == nil)
    if ImGui.Button(string.format("%s##anim_npc", GENERIC_PLAY_BTN_)) then
      script.run_in_fiber(function(npca)
        if info.cat == "In-Vehicle" and PED.IS_PED_ON_FOOT(self.get_ped())
          or not VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(self.get_veh())) then
          widgetSound("Error")
          gui.show_error("YimActions", "This animation can only be played while sitting inside a vehicle (cars and trucks only).")
        else
          widgetSound("Select")
          for _, v in ipairs(spawned_npcs) do
            if ENTITY.DOES_ENTITY_EXIST(v) then
              local npcCoords      = ENTITY.GET_ENTITY_COORDS(v, true)
              local npcHeading     = ENTITY.GET_ENTITY_HEADING(v)
              local npcForwardX    = ENTITY.GET_ENTITY_FORWARD_X(v)
              local npcForwardY    = ENTITY.GET_ENTITY_FORWARD_Y(v)
              local npcBoneIndex   = PED.GET_PED_BONE_INDEX(v, info.boneID)
              local npcBboneCoords = PED.GET_PED_BONE_COORDS(v, info.boneID, 0.0, 0.0, 0.0)
              if manualFlags then
                setmanualflag()
              else
                flag = info.flag
              end
              playAnim(
                info, v, flag, npcprop1, npcprop2, npcloopedFX, npcSexPed, npcBoneIndex, npcCoords, npcHeading,
                npcForwardX, npcForwardY, npcBboneCoords, "cunt", npcProps, npcPTFX, npca
              )
            end
          end
        end
      end)
    end
    ImGui.SameLine()
    if ImGui.Button(string.format("%s##npc_anim", GENERIC_STOP_BTN_)) then
      widgetSound("Cancel")
      script.run_in_fiber(function(npca)
        cleanupNPC(npca)
        is_playing_anim = false
      end)
    end
    ImGui.EndDisabled()
    usePlayKey, upkUsed = ImGui.Checkbox("Enable Animation Hotkeys", usePlayKey)
    widgetToolTip(false, ANIM_HOTKEYS_DESC_)
    if upkUsed then
      CFG.save("usePlayKey", usePlayKey)
      widgetSound("Nav2")
    end
    ImGui.EndTabItem()
  end
  if ImGui.BeginTabItem(SCENARIOS_TAB_) then
    if tab2Sound then
      widgetSound("Nav2")
      tab2Sound = false
      tab1Sound = true
      tab3Sound = true
    end
    ImGui.PushItemWidth(510)
    displayFilteredScenarios()
    ImGui.PopItemWidth()
    if filteredScenarios ~= nil then
      data = filteredScenarios[scenario_index + 1]
    end
    ImGui.Separator()
    if ImGui.Button(string.format("%s##selfSC", GENERIC_PLAY_BTN_)) then
      script.run_in_fiber(function(psc)
        if PED.IS_PED_ON_FOOT(self.get_ped()) then
          widgetSound("Select")
          if is_playing_anim then
            cleanup(psc)
          end
          playScenario(data, self.get_ped())
          addActionToRecents(data)
          is_playing_scenario = true
        else
          widgetSound("Error")
          gui.show_error("YimActions", "You can not play scenarios in vehicles.")
        end
      end)
    end
    ImGui.SameLine(); ImGui.Dummy(60, 1); ImGui.SameLine()
    if ImGui.Button(string.format("%s##selfSC", GENERIC_STOP_BTN_)) then
      if is_playing_scenario then
        widgetSound("Cancel")
        script.run_in_fiber(function(stp)
          stopScenario(self.get_ped(), stp)
        end)
      else
        widgetSound("Error")
      end
    end
    widgetToolTip(false, SCN_STOP_DESC_)
    ImGui.Spacing()
    if favorite_actions[1] ~= nil and filteredScenarios[1] ~= nil then
      for _, v in ipairs(favorite_actions) do
        if data.name == v.name then
          fav_exists = true
          break
        else
          fav_exists = false
        end
      end
    else
      if fav_exists then
        fav_exists = false
      end
    end
    if not fav_exists then
      if ImGui.Button(string.format("%s##favs", ADD_TO_FAVS_)) then
        widgetSound("Select")
        table.insert(favorite_actions, data)
        CFG.save("favorite_actions", favorite_actions)
      end
    else
      if ImGui.Button(string.format("%s##favs", REMOVE_FROM_FAVS_)) then
        widgetSound("Delete")
        for k, v in ipairs(favorite_actions) do
          if v == data then
            table.remove(favorite_actions, k)
          end
        end
        CFG.save("favorite_actions", favorite_actions)
      end
    end
    ImGui.Spacing(); ImGui.SeparatorText(NPC_SCENARIOS_)
    ImGui.PushItemWidth(220)
    displayNpcs()
    ImGui.PopItemWidth()
    ImGui.SameLine()
    npc_godMode, ngodused = ImGui.Checkbox("Invincible", npc_godMode)
    if ngodused then
      widgetSound("Nav")
      CFG.save("npc_godMode", npc_godMode)
      if spawned_npcs[1] ~= nil then
        script.run_in_fiber(function()
          for _, npc in ipairs(spawned_npcs) do
            if ENTITY.DOES_ENTITY_EXIST(npc) and not ENTITY.IS_ENTITY_DEAD(npc, true) then
              ENTITY.SET_ENTITY_INVINCIBLE(npc, npc_godMode)
            end
          end
        end)
      end
    end
    widgetToolTip(false, NPC_GODMODE_DESC_)
    local npcData = filteredNpcs[npc_index + 1]
    if ImGui.Button(string.format("%s##scenario_npc", GENERIC_SPAWN_BTN_)) then
      widgetSound("Select")
      script.run_in_fiber(function()
        local pedCoords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
        local pedHeading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
        local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
        local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
        local myGroup = PED.GET_PED_GROUP_INDEX(self.get_ped())
        if not PED.DOES_GROUP_EXIST(myGroup) then
          myGroup = PED.CREATE_GROUP(0)
        end
        while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
          STREAMING.REQUEST_MODEL(npcData.hash)
          coroutine.yield()
        end
        npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4,
          pedCoords.z, true, false, false)
        ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
        PED.SET_PED_AS_GROUP_MEMBER(npc, myGroup)
        PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
        npcBlip = HUD.ADD_BLIP_FOR_ENTITY(npc)
        HUD.SET_BLIP_AS_FRIENDLY(npcBlip, true)
        HUD.SET_BLIP_SCALE(npcBlip, 0.8)
        HUD.SHOW_HEADING_INDICATOR_ON_BLIP(npcBlip, true)
        HUD.SET_BLIP_SPRITE(npcBlip, 280)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4,
          pedCoords.z, true, false, false)
        ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
        WEAPON.GIVE_WEAPON_TO_PED(npc, 350597077, 9999, false, true)
        PED.SET_GROUP_FORMATION(myGroup, 2)
        PED.SET_GROUP_FORMATION_SPACING(myGroup, 1.0, 1.0, 1.0)
        PED.SET_PED_CONFIG_FLAG(npc, 179, true)
        PED.SET_PED_CONFIG_FLAG(npc, 294, true)
        PED.SET_PED_CONFIG_FLAG(npc, 398, true)
        PED.SET_PED_CONFIG_FLAG(npc, 401, true)
        PED.SET_PED_CONFIG_FLAG(npc, 443, true)
        PED.SET_PED_COMBAT_ABILITY(npc, 3)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 2, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 3, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 5, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 13, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 20, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 21, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 22, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 27, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 28, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 31, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 34, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 41, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 42, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 46, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 50, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 58, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 61, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(npc, 71, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true)
        if npc_godMode then
          ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
        end
        table.insert(spawned_npcs, npc)
      end)
    end
    ImGui.SameLine()
    if ImGui.Button(string.format("%s##scenarios", GENERIC_DELETE_BTN_)) then
      widgetSound("Delete")
      script.run_in_fiber(function()
        for k, v in ipairs(spawned_npcs) do
          if ENTITY.DOES_ENTITY_EXIST(v) then
            PED.REMOVE_PED_FROM_GROUP(v)
            ENTITY.DELETE_ENTITY(v)
          end
          table.remove(spawned_npcs, k)
        end
      end)
    end
    ImGui.SameLine(); ImGui.BeginDisabled(spawned_npcs[1] == nil)
    if ImGui.Button(string.format("%s##npc_scenarios", GENERIC_PLAY_BTN_)) then
      widgetSound("Select")
      script.run_in_fiber(function(npcsc)
        for _, npc in ipairs(spawned_npcs) do
          if PED.IS_PED_ON_FOOT(npc) then
            if is_playing_anim then
              cleanupNPC(npcsc)
              is_playing_anim = false
            end
            playScenario(data, npc)
            is_playing_scenario = true
          else
            gui.show_error("YimActions", "Scenarios can not be played inside vehicles.")
          end
        end
      end)
    end
    ImGui.SameLine()
    if ImGui.Button(string.format("%s##npc_scenarios", GENERIC_STOP_BTN_)) then
      if is_playing_scenario then
        widgetSound("Cancel")
        script.run_in_fiber(function(stp)
          for _, npc in ipairs(spawned_npcs) do
            stopScenario(npc, stp)
          end
          is_playing_scenario = false
        end)
      end
    end
    ImGui.EndDisabled(); ImGui.EndTabItem()
  end
  if ImGui.BeginTabItem(FAVORITES_TAB_) then
    if favorite_actions[1] ~= nil then
      ImGui.PushItemWidth(510)
      displayFavoriteActions()
      ImGui.PopItemWidth()
      local selected_favorite = filteredFavs[fav_actions_index + 1]
      ImGui.Spacing()
      if ImGui.Button(string.format("%s##favs", GENERIC_PLAY_BTN_)) then
        script.run_in_fiber(function(pf)
          if selected_favorite.dict ~= nil then -- animation type
            if selected_favorite.cat == "In-Vehicle" and PED.IS_PED_ON_FOOT(self.get_ped())
              or not VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(self.get_veh())) then
              widgetSound("Error")
              gui.show_error("YimActions", "This animation can only be played while sitting inside a vehicle (cars and trucks only).")
            else
              widgetSound("Select")
              local coords     = self.get_pos()
              local heading    = ENTITY.GET_ENTITY_HEADING(self.get_ped())
              local forwardX   = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
              local forwardY   = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
              local boneIndex  = PED.GET_PED_BONE_INDEX(self.get_ped(), selected_favorite.boneID)
              local bonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), selected_favorite.boneID, 0.0, 0.0, 0.0)
              if str_contains(selected_favorite.name, "DJ") then
                if not anim_music then
                  play_music("start", "RADIO_22_DLC_BATTLE_MIX1_RADIO")
                  anim_music = true
                end
              else
                if anim_music then
                  play_music("stop")
                  anim_music = false
                end
              end
              playAnim(
                selected_favorite, self.get_ped(), selected_favorite.flag, selfprop1, selfprop2, selfloopedFX,
                selfSexPed, boneIndex, coords, heading, forwardX, forwardY, bonecoords, "self", plyrProps, selfPTFX, pf
              )
              curr_playing_anim = selected_favorite
              is_playing_anim   = true
            end
          elseif selected_favorite.scenario ~= nil then -- scenario type
            widgetSound("Select")
            playScenario(selected_favorite, self.get_ped())
            is_playing_scenario = true
          end
          addActionToRecents(selected_favorite)
        end)
      end
      ImGui.SameLine(); ImGui.Dummy(40, 1); ImGui.SameLine()
      if ImGui.Button(string.format("%s##favs", GENERIC_STOP_BTN_)) then
        widgetSound("Cancel")
        script.run_in_fiber(function(fav)
          if is_playing_anim then
            cleanup(fav)
            is_playing_anim = false
            if anim_music then
              play_music("stop")
              anim_music = false
            end
          elseif is_playing_scenario then
            stopScenario(self.get_ped(), fav)
            is_playing_scenario = false
          end
        end)
      end
      ImGui.SameLine(); ImGui.Dummy(37, 1); ImGui.SameLine()
      if coloredButton(string.format("%s##favs", REMOVE_FROM_FAVS_), "#FF0000", "#B30000", "#FF8080", 1) then
        widgetSound("Delete")
        for k, v in ipairs(favorite_actions) do
          if v == selected_favorite then
            table.remove(favorite_actions, k)
          end
        end
        CFG.save("favorite_actions", favorite_actions)
      end
    else
      ImGui.Dummy(1, 5)
      wrappedText(FAVS_NIL_TXT_, 20)
    end
    ImGui.EndTabItem()
  end
  if ImGui.BeginTabItem(RECENTS_TAB_) then
    if recently_played_a[1] ~= nil then
      ImGui.PushItemWidth(510)
      displayRecentlyPlayed()
      ImGui.PopItemWidth()
      local selected_recent = filteredRecents[recents_index + 1]
      if ImGui.Button(string.format("%s##recents", GENERIC_PLAY_BTN_)) then
        script.run_in_fiber(function(pr)
          if selected_recent.dict ~= nil then -- animation type
            if selected_recent.cat == "In-Vehicle" and PED.IS_PED_ON_FOOT(self.get_ped())
              or not VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(self.get_veh())) then
              widgetSound("Error")
              gui.show_error("YimActions", "This animation can only be played while sitting inside a vehicle (cars and trucks only).")
            else
              widgetSound("Select")
              local coords     = self.get_pos()
              local heading    = ENTITY.GET_ENTITY_HEADING(self.get_ped())
              local forwardX   = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
              local forwardY   = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
              local boneIndex  = PED.GET_PED_BONE_INDEX(self.get_ped(), selected_recent.boneID)
              local bonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), selected_recent.boneID, 0.0, 0.0, 0.0)
              if str_contains(selected_recent.name, "DJ") then
                if not anim_music then
                  play_music("start", "RADIO_22_DLC_BATTLE_MIX1_RADIO")
                  anim_music = true
                end
              else
                if anim_music then
                  play_music("stop")
                  anim_music = false
                end
              end
              playAnim(
                selected_recent, self.get_ped(), selected_recent.flag, selfprop1, selfprop2, selfloopedFX, selfSexPed,
                boneIndex, coords, heading, forwardX, forwardY, bonecoords, "self", plyrProps, selfPTFX, pr
              )
              curr_playing_anim = selected_recent
              is_playing_anim   = true
            end
          elseif selected_recent.scenario ~= nil then -- scenario type
            widgetSound("Select")
            playScenario(selected_recent, self.get_ped())
            is_playing_scenario = true
          end
        end)
      end
      ImGui.SameLine(); ImGui.Dummy(40, 1); ImGui.SameLine()
      if ImGui.Button(string.format("%s##recents", GENERIC_STOP_BTN_)) then
        widgetSound("Cancel")
        script.run_in_fiber(function(recent)
          if is_playing_anim then
            cleanup(recent)
            is_playing_anim = false
            if anim_music then
              play_music("stop")
              anim_music = false
            end
          elseif is_playing_scenario then
            stopScenario(self.get_ped(), recent)
            is_playing_scenario = false
          end
        end)
      end
    else
      ImGui.Dummy(1, 5); wrappedText(RECENTS_NIL_TXT_, 20)
    end
    ImGui.EndTabItem()
  end
  if ImGui.BeginTabItem(SETTINGS_TAB_) then
    searchBar = false
    if tab3Sound then
      widgetSound("Nav2")
      tab3Sound = false
      tab2Sound = true
      tab1Sound = true
    end
    ImGui.Dummy(1, 10)
    ImGui.SeparatorText("Game Options")
    disableTooltips, dttused = ImGui.Checkbox(DISABLE_TOOLTIPS_CB_, disableTooltips)
    if dttused then
      CFG.save("disableTooltips", disableTooltips)
      widgetSound("Nav")
    end
    ImGui.SameLine(); ImGui.Dummy(71, 1); ImGui.SameLine(); disableSound, dsused = ImGui.Checkbox(DISABLE_UISOUNDS_CB_, disableSound)
    if dsused then
      CFG.save("disableSound", disableSound)
      widgetSound("Nav")
    end
    widgetToolTip(false, DISABLE_UISOUNDS_DESC_)
    phoneAnim, paused = ImGui.Checkbox(PHONEANIMS_CB_, phoneAnim)
    if paused then
      CFG.save("phoneAnim", phoneAnim)
      widgetSound("Nav")
    end
    widgetToolTip(false, PHONEANIMS_DESC_)
    ImGui.SameLine(); ImGui.Dummy(1, 1); ImGui.SameLine(); sprintInside, siused = ImGui.Checkbox(SPRINT_INSIDE_CB_, sprintInside)
    if siused then
      CFG.save("sprintInside", sprintInside)
      widgetSound("Nav")
    end
    widgetToolTip(false, SPRINT_INSIDE_DESC_)
    lockPick, loused = ImGui.Checkbox(LOCKPICK_CB_, lockPick)
    if loused then
      CFG.save("lockPick", lockPick)
      widgetSound("Nav")
    end
    widgetToolTip(false, LOCKPICK_DESC_)
    ImGui.SameLine(); ImGui.Dummy(12, 1); ImGui.SameLine(); replaceSneakAnim, rsaused = ImGui.Checkbox(CROUCHCB_, replaceSneakAnim)
    if rsaused then
      CFG.save("replaceSneakAnim", replaceSneakAnim)
      widgetSound("Nav")
    end
    widgetToolTip(false, CROUCH_DESC_)
    disableActionMode, daused = ImGui.Checkbox(ACTION_MODE_CB_, disableActionMode)
    if daused then
      CFG.save("disableActionMode", disableActionMode)
      widgetSound("Nav")
    end
    widgetToolTip(false, ACTION_MODE_DESC_)
    ImGui.Spacing()
    if shortcut_anim.anim ~= nil then
      if ImGui.Button(ANIM_HOTKEY_DEL2_) then
        widgetSound("Delete")
        shortcut_anim = {}
        CFG.save("shortcut_anim", {})
        gui.show_success("Samurais Scripts", "Animation shortcut has been reset.")
      end
      widgetToolTip(false, DEL_HOTKEY_DESC_)
    else
      ImGui.BeginDisabled()
      ImGui.Button(ANIM_HOTKEY_DEL2_)
      ImGui.EndDisabled()
      widgetToolTip(false, NO_HOTKEY_TXT_)
    end

    ImGui.SeparatorText("Language")

    ImGui.PushItemWidth(260)
    displayLangs()
    ImGui.PopItemWidth()
    selected_lang = lang_T[lang_idx + 1]
    if lang_idxUsed then
      widgetSound("Select")
      LANG         = selected_lang.iso
      current_lang = selected_lang.name
      CFG.save("lang_idx", lang_idx)
      CFG.save("LANG", LANG)
      CFG.save("current_lang", current_lang)
      initStrings()
      gui.show_success("YimActions", LANG_CHANGED_NOTIF_)
    end

    ImGui.SeparatorText("Keyboard Hotkeys")

    openHotkeyWindow("Ragdoll On Demand       ", keybinds.rodBtn)
    openHotkeyWindow("Stop Anim Button          ", keybinds.stop_anim)
    openHotkeyWindow("Play Anim Button          ", keybinds.play_anim)
    openHotkeyWindow("Previous Anim Button   ", keybinds.previous_anim)
    openHotkeyWindow("Next Anim Button          ", keybinds.next_anim)
    openHotkeyWindow("Panic Button                 ", keybinds.panik)

    ImGui.SeparatorText("Controller Hotkeys")

    gpadHotkeyWindow("Ragdoll On Demand      ", gpad_keybinds.rodBtn)
    openHotkeyWindow("Stop Anim Button          ", gpad_keybinds.stop_anim)
    ImGui.Dummy(1, 5); ImGui.Separator()
    if coloredButton(string.format("%s", RESET_SETTINGS_BTN_), { 142, 0, 0, 1 }, { 142, 0, 0, 0.7 }, { 142, 0, 0, 0.5 }, 1) then
      local current_config = {
        disableTooltips  = disableTooltips,
        phoneAnim        = phoneAnim,
        disableProps     = disableProps,
        sprintInside     = sprintInside,
        lockpick         = lockpick,
        manualFlags      = manualFlags,
        controllable     = controllable,
        looped           = looped,
        upperbody        = upperbody,
        freeze           = freeze,
        usePlayKey       = usePlayKey,
        replaceSneakAnim = replaceSneakAnim,
        disableSound     = disableSound,
        npc_godMode      = npc_godMode,
      }
      for _, v in pairs(current_config) do
        if tostring(v) == "true" then
          saved_config = true
          break
        else
          saved_config = false
        end
      end
      if saved_config then
        widgetSound("Select")
        ImGui.OpenPopup("##ProgressBar")
      else
        widgetSound("Error")
        gui.show_warning("YimActions", "You don't have any saved settings.")
      end
    end
    widgetToolTip(false, "Revert saved settings and disable all checkboxes.")
    ImGui.SetNextWindowBgAlpha(0)
    if ImGui.BeginPopupModal("##ProgressBar", ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoScrollWithMouse | ImGuiWindowFlags.AlwaysAutoResize) then
      displayProgressBar()
      CFG.reset()
      phoneAnim           = CFG.read("phoneAnim")
      sprintInside        = CFG.read("sprintInside")
      lockPick            = CFG.read("lockPick")
      manualFlags         = CFG.read("manualFlags")
      controllable        = CFG.read("controllable")
      looped              = CFG.read("looped")
      upperbody           = CFG.read("upperbody")
      freeze              = CFG.read("freeze")
      usePlayKey          = CFG.read("usePlayKey")
      replaceSneakAnim    = CFG.read("replaceSneakAnim")
      disableProps        = CFG.read("disableProps")
      disableTooltips     = CFG.read("disableTooltips")
      npc_godMode         = CFG.read("npc_godMode")
      disableSound        = CFG.read("disableSound")
      disableActionMode   = CFG.read("disableActionMode")
      shortcut_anim       = CFG.read("shortcut_anim")
      favorite_actions    = CFG.read("favorite_actions")
      keybinds            = CFG.read("keybinds")
      gpad_keybinds       = CFG.read("gpad_keybinds")
      LANG                = CFG.read("LANG")
      current_lang        = CFG.read("current_lang")
      lang_idx            = CFG.read("lang_idx")
      if x == 1 then
        counter = counter + 1
        if counter > 100 then
          ImGui.CloseCurrentPopup()
          counter, x = 0, 0
          resetCheckBoxes()
        else
          return
        end
      end
      ImGui.EndPopup()
    end
    ImGui.EndTabItem()
  else
    searchBar = true
  end
  ImGui.EndTabBar()
end)
YimActions:add_imgui(function()
  ImGui.Dummy(460, 1); ImGui.SameLine(); ImGui.TextDisabled(SCRIPT_VERSION)
end)

-- Threads

script.register_looped("CTRLS", function()
  if is_typing or is_setting_hotkeys then
    PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
  end
  if PAD.IS_USING_KEYBOARD_AND_MOUSE(0) then
    stopButton = keybinds.stop_anim.name
  else
    stopButton = gpad_keybinds.stop_anim.name
  end
  if replaceSneakAnim and PED.IS_PED_ON_FOOT(self.get_ped()) then
    PAD.DISABLE_CONTROL_ACTION(0, 36, true)
  end
  stopButtonCode = PAD.IS_USING_KEYBOARD_AND_MOUSE(0) and keybinds.stop_anim.code or gpad_keybinds.stop_anim.code
end)

script.register_looped("BALT", function(balt) -- Basic Ass Loading Text
  balt:yield()
  if start_loading_anim then
    loading_label = "-   "
    balt:sleep(80)
    loading_label = "--  "
    balt:sleep(80)
    loading_label = "--- "
    balt:sleep(80)
    loading_label = "----"
    balt:sleep(80)
    loading_label = " ---"
    balt:sleep(80)
    loading_label = "  --"
    balt:sleep(80)
    loading_label = "   -"
    balt:sleep(80)
    loading_label = "    "
    balt:sleep(80)
    return
  end
end)

script.register_looped("SF", function(sf)
  if replaceSneakAnim then
    if PED.IS_PED_ON_FOOT(self.get_ped()) and not ENTITY.IS_ENTITY_IN_WATER(self.get_ped()) then
      if PAD.IS_DISABLED_CONTROL_PRESSED(0, 36) and canCrouch() then
        sf:sleep(200)
        if is_handsUp then
          is_handsUp = false
          TASK.CLEAR_PED_TASKS(self.get_ped())
        end
        while not STREAMING.HAS_CLIP_SET_LOADED("move_ped_crouched") and not STREAMING.HAS_CLIP_SET_LOADED("move_aim_strafe_crouch_2h") do
          STREAMING.REQUEST_CLIP_SET("move_ped_crouched")
          STREAMING.REQUEST_CLIP_SET("move_aim_strafe_crouch_2h")
          coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_ped_crouched", 0.3)
        PED.SET_PED_STRAFE_CLIPSET(self.get_ped(), "move_aim_strafe_crouch_2h")
        sf:sleep(500)
        isCrouched = true
      end
    end
    if isCrouched and PAD.IS_DISABLED_CONTROL_PRESSED(0, 36)
        and not HUD.IS_MP_TEXT_CHAT_TYPING() and not isBrowsingApps() then
      sf:sleep(200)
      PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.3)
      sf:sleep(500)
      isCrouched = false
    end
  end
  if phoneAnim then
    if network.is_session_started() and canUsePhoneAnims() then
      playPhoneAnims(true)
      playPhoneGestures(sf)
      phoneAnimsEnabled = true
    end
  else
    if phoneAnimsEnabled then
      playPhoneAnims(false)
      phoneAnimsEnabled = false
    end
  end
  if sprintInside then
    if not PED.GET_PED_CONFIG_FLAG(self.get_ped(), 427, true) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, true)
    end
  else
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 427, true) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, false)
    end
  end

  -- Lockpick animation
  if lockPick then
    if not PED.GET_PED_CONFIG_FLAG(self.get_ped(), 426, true) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, true)
    end
  else
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 426, true) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, false)
    end
  end
end)
-- Action Mode
script.register_looped("AMODE", function(amode)
  if disableActionMode then
    if PED.IS_PED_USING_ACTION_MODE(self.get_ped()) then
      PLAYER.SET_DISABLE_AMBIENT_MELEE_MOVE(self.get_id(), true)
      PED.SET_PED_USING_ACTION_MODE(self.get_ped(), false, -1, "DEFAULT_ACTION")
    else
      amode:sleep(500)
    end
    amode:yield()
  end
end)
script.register_looped("Anim S/VFX", function(animSfx)
  if is_playing_anim then
    if curr_playing_anim.sfx ~= nil then
      local soundCoords = self.get_pos()
      AUDIO.PLAY_AMBIENT_SPEECH_FROM_POSITION_NATIVE(curr_playing_anim.sfx, curr_playing_anim.sfxName, soundCoords.x,
        soundCoords.y,
        soundCoords.z, curr_playing_anim.sfxFlg)
      animSfx:sleep(10000)
    elseif string.find(string.lower(curr_playing_anim.name), "police torch") then
      local myPos = self.get_pos()
      local torch = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(myPos.x, myPos.y, myPos.z, 1, curr_playing_anim.prop1, false, false,
        false)
      if ENTITY.DOES_ENTITY_EXIST(torch) then
        local torchPos = ENTITY.GET_ENTITY_COORDS(torch, false)
        local torchFwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(torch)
        GRAPHICS.DRAW_SPOT_LIGHT(
          torchPos.x, torchPos.y, torchPos.z - 0.2,
          (torchFwd.x * -1), (torchFwd.y * -1), torchFwd.z, 226, 130, 78,
          100.0, 40.0, 1.0, 10.0, 0.0
        )
      end
    end
  end
end)

script.register_looped("animation hotkey", function(script)
  if not HUD.IS_PAUSE_MENU_ACTIVE() and not HUD.IS_MP_TEXT_CHAT_TYPING() then
    if is_playing_anim then
      if isKeyJustPressed(stopButtonCode) and not isBrowsingApps() then
        widgetSound("Cancel")
        cleanup(script)
        is_playing_anim  = false
        is_shortcut_anim = false
        if anim_music then
          play_music("stop")
          anim_music = false
        end
        if spawned_npcs[1] ~= nil then
          cleanupNPC(script)
        end
      end
    end
    if usePlayKey then
      if filteredAnims == nil then
        updatefilteredAnims()
      end
      if isKeyJustPressed(keybinds.next_anim.code) and not isBrowsingApps() then
        widgetSound("Nav")
        if anim_index < #filteredAnims - 1 then
          anim_index = anim_index + 1
        else
          anim_index = 0
        end
        info = filteredAnims[anim_index + 1]
        gui.show_message("Current Animation:", info.name)
        script:sleep(200)
      end
      if isKeyJustPressed(keybinds.previous_anim.code) and not isBrowsingApps() then
        widgetSound("Nav")
        if anim_index <= 0 then
          anim_index = #filteredAnims - 1
        else
          anim_index = anim_index - 1
        end
        info = filteredAnims[anim_index + 1]
        gui.show_message("Current Animation:", info.name)
        script:sleep(200)
      end
      if isKeyJustPressed(keybinds.play_anim.code) and not isBrowsingApps() then
        if not is_playing_anim then
          if info ~= nil then
            if info.cat == "In-Vehicle" and PED.IS_PED_ON_FOOT(self.get_ped())
              or not VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(self.get_veh())) then
              widgetSound("Error")
              gui.show_error("Samurai's Scripts", "This animation can only be played while sitting inside a vehicle (cars and trucks only).")
            else
              widgetSound("Select")
              local mycoords     = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
              local myheading    = ENTITY.GET_ENTITY_HEADING(self.get_ped())
              local myforwardX   = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
              local myforwardY   = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
              local myboneIndex  = PED.GET_PED_BONE_INDEX(self.get_ped(), info.boneID)
              local mybonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), info.boneID, 0.0, 0.0, 0.0)
              if manualFlags then
                setmanualflag()
              else
                flag = info.flag
              end
              playAnim(info, self.get_ped(), flag, selfprop1, selfprop2, selfloopedFX, selfSexPed, myboneIndex, mycoords,
                myheading, myforwardX, myforwardY, mybonecoords, "self", plyrProps, selfPTFX, script
              )
              curr_playing_anim = info
              is_playing_anim   = true
              if str_contains(curr_playing_anim.name, "DJ") then
                if not is_playing_radio then
                  play_music("start", "RADIO_22_DLC_BATTLE_MIX1_RADIO")
                  anim_music = true
                end
              end
            end
            script:sleep(200)
          end
        else
          widgetSound("Error")
          if not PAD.IS_USING_KEYBOARD_AND_MOUSE(0) then
            PAD.SET_CONTROL_SHAKE(0, 500, 250)
          end
          gui.show_warning("YimActions",
            string.format("Press %s to stop the current animation before playing the next one.", stopButton))
          script:sleep(800)
        end
      end
    end
  end
  if npc_blips[1] ~= nil then
    for _, b in ipairs(npc_blips) do
      if HUD.DOES_BLIP_EXIST(b) then
        for _, npc in ipairs(spawned_npcs) do
          if PED.IS_PED_SITTING_IN_ANY_VEHICLE(npc) then
            if HUD.GET_BLIP_ALPHA(b) > 1.0 then
              HUD.SET_BLIP_ALPHA(b, 0.0)
            end
          else
            if HUD.GET_BLIP_ALPHA(b) < 1000.0 then
              HUD.SET_BLIP_ALPHA(b, 1000.0)
            end
          end
        end
      end
    end
  end
  if spawned_npcs[1] ~= nil then
    for _, npc in ipairs(spawned_npcs) do
      local myPos    = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
      local fwdX     = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
      local fwdY     = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
      local npcPos   = ENTITY.GET_ENTITY_COORDS(npc, false)
      local distCalc = SYSTEM.VDIST(myPos.x, myPos.y, myPos.z, npcPos.x, npcPos.y, npcPos.z)
      if distCalc > 100 then
        script:sleep(1000)
        TASK.CLEAR_PED_TASKS(npc)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, myPos.x - (fwdX * 2), myPos.y - (fwdY * 2), myPos.z, true, false, false)
      end
    end
  end
  if is_playing_scenario then
    if isKeyJustPressed(stopButtonCode) then
      widgetSound("Cancel")
      busySpinnerOn(SCN_STOP_SPINNER_, 3)
      TASK.CLEAR_PED_TASKS(self.get_ped())
      is_playing_scenario = false
      script:sleep(1000)
      busySpinnerOff()
      if ENTITY.DOES_ENTITY_EXIST(bbq) then
        ENTITY.DELETE_ENTITY(bbq)
      end
    end
  end
end)

script.register_looped("MISC", function(misc)
  if is_playing_anim then
    if not curr_playing_anim.autoOff then
      PED.SET_PED_CAN_SWITCH_WEAPON(self.get_ped(), false)
    end
    if WEAPON.IS_PED_ARMED(self.get_ped(), 7) then
      WEAPON.SET_CURRENT_PED_WEAPON(self.get_ped(), 0xA2719263, false)
    end
    if is_playing_anim and str_contains(curr_playing_anim.name, ") (pistol)")  then
      log.info('true')
      for _, w in ipairs(handguns_T) do
        if WEAPON.HAS_PED_GOT_WEAPON(self.get_ped(), w, false) then
          WEAPON.SET_CURRENT_PED_WEAPON(self.get_ped(), w, true)
          break
        end
      end
      misc:sleep(555)
      AUDIO.PLAY_SOUND_FRONTEND(-1, "SNIPER_FIRE", "DLC_BIKER_RESUPPLY_MEET_CONTACT_SOUNDS", true)
      repeat
        misc:sleep(100)
      until ENTITY.IS_ENTITY_PLAYING_ANIM(self.get_ped(), "mp_suicide", "pistol", 3) == false
      PED.SET_PED_CAN_SWITCH_WEAPON(self.get_ped(), true)
    end
    repeat
      misc:sleep(10)
    until is_playing_anim == false
    PED.SET_PED_CAN_SWITCH_WEAPON(self.get_ped(), true)
    if curr_playing_anim.cat == "In-Vehicle" then
      if PAD.IS_CONTROL_PRESSED(0, 75) or PAD.IS_DISABLED_CONTROL_PRESSED(0, 75) or PED.IS_PED_ON_FOOT(self.get_ped()) then
        cleanup(misc)
        is_playing_anim = false
      end
    end
  end
end)

-- Animation Shotrcut
script.register_looped("ANIMSC", function(animsc)
  if shortcut_anim.anim ~= nil and not gui.is_open() then
    if isKeyJustPressed(shortcut_anim.btn) and not is_typing and not is_setting_hotkeys and not is_playing_anim and not is_playing_scenario then
      info               = shortcut_anim
      local mycoords     = ENTITY.GET_ENTITY_COORDS(self.get_ped(), true)
      local myheading    = ENTITY.GET_ENTITY_HEADING(self.get_ped())
      local myforwardX   = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
      local myforwardY   = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
      local myboneIndex  = PED.GET_PED_BONE_INDEX(self.get_ped(), info.boneID)
      local mybonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), info.boneID, 0.0, 0.0, 0.0)
      if is_playing_anim or is_playing_scenario then
        cleanup(animsc)
        if ENTITY.DOES_ENTITY_EXIST(bbq) then
          ENTITY.DELETE_ENTITY(bbq)
        end
        is_playing_anim     = false
        is_playing_scenario = false
        animsc:sleep(500)
      end
      if requestAnimDict(shortcut_anim.dict) then
        playAnim(shortcut_anim, self.get_ped(), shortcut_anim.flag, selfprop1, selfprop2, selfloopedFX, selfSexPed,
          myboneIndex, mycoords, myheading, myforwardX, myforwardY, mybonecoords, "self", plyrProps, selfPTFX, animsc
        )
        if str_contains(shortcut_anim.name, "DJ") then
          if not anim_music then
            play_music("start", "RADIO_22_DLC_BATTLE_MIX1_RADIO")
            anim_music = true
          end
        end
        animsc:sleep(100)
        curr_playing_anim = shortcut_anim
        is_playing_anim  = true
        is_shortcut_anim = true
      end
    end
  end
  if is_shortcut_anim and isKeyJustPressed(shortcut_anim.btn) then
    animsc:sleep(100)
    cleanup(animsc)
    is_playing_anim  = false
    is_shortcut_anim = false
  end
end)

script.register_looped("AIEV", function(aiev) -- Anim Interrupt Event
  if is_playing_anim then
    if PED.IS_PED_SWIMMING(self.get_ped()) or PED.IS_PED_SWIMMING_UNDER_WATER(self.get_ped()) then
      cleanup(aiev)
      is_playing_anim = false
    end
    local isLooped = curr_playing_anim.flag & 1 > 0
    local isFrozen = curr_playing_anim.flag & 2 > 0
    if not isLooped and not isFrozen then
      repeat
        aiev:sleep(200)
      until not ENTITY.IS_ENTITY_PLAYING_ANIM(self.get_ped(), curr_playing_anim.dict, curr_playing_anim.anim, 3)
      is_playing_anim = false
    end
    if not ENTITY.IS_ENTITY_DEAD(self.get_ped(), true) then
      if is_playing_anim and not ENTITY.IS_ENTITY_PLAYING_ANIM(self.get_ped(), curr_playing_anim.dict, curr_playing_anim.anim, 3)
        and not isKeyJustPressed(keybinds.stop_anim.code) then
        aiev:sleep(1000)
        if PED.IS_PED_FALLING(self.get_ped()) then
          repeat
            aiev:sleep(1000)
          until not PED.IS_PED_FALLING(self.get_ped())
          aiev:sleep(1000)
          onAnimInterrupt()
        end
        if PED.IS_PED_RAGDOLL(self.get_ped()) then
          repeat
            aiev:sleep(1000)
          until not PED.IS_PED_RAGDOLL(self.get_ped())
          aiev:sleep(1000)
          onAnimInterrupt()
        end
        onAnimInterrupt()
      end
    else
      cleanup(aiev)
      is_playing_anim = false
    end
  end

  if is_playing_scenario then
    if ENTITY.IS_ENTITY_DEAD(self.get_ped(), true) then
      if bbq ~= nil and ENTITY.DOES_ENTITY_EXIST(bbq) then
        ENTITY.DELETE_ENTITY(bbq)
      end
      is_playing_scenario = false
    end
  end
end)

-- PANIK Button
script.register_looped("PANIK", function(panik)
  if isKeyJustPressed(keybinds.panik.code) and not HUD.IS_MP_TEXT_CHAT_TYPING() and not HUD.IS_PAUSE_MENU_ACTIVE()
      and not is_typing and not is_setting_hotkeys and not gui.is_open() and not script.is_active("CELLPHONE_FLASHHAND") then
    panik:sleep(200)
    reset_(panik)
    gui.show_message("YimActions", "All script changes have been reset.")
  end
end)

---IsKeyJustPressed
script.register_looped("IKJP", function(ikjp)
  for _, k in ipairs(VK_T) do
    if k.just_pressed then
      ikjp:sleep(0.2)
      k.just_pressed = false
    end
  end
end)


-- Even Handlers
event.register_handler(menu_event.ScriptsReloaded, function(reload)
  reset_(reload)
end)
event.register_handler(menu_event.MenuUnloaded, function(unload)
  reset_(unload)
end)
event.register_handler(menu_event.Wndproc, function(_, msg, wParam, _)
  if msg == WM._KEYDOWN or msg == WM._SYSKEYDOWN or msg == WM._XBUTTONDOWN then
    for _, key in ipairs(VK_T) do
      if wParam == key.code then
        key.pressed      = true
        key.just_pressed = true
        break
      end
    end
  elseif msg == WM._KEYUP or msg == WM._SYSKEYUP then
    for _, key in ipairs(VK_T) do
      if wParam == key.code then
        if key.pressed then
          key.pressed      = false
          key.just_pressed = false
          break
        end
      end
    end
  elseif msg == WM._XBUTTONUP then
    for _, key in ipairs(VK_T) do
      if key.code == 0x10020 then
        if key.pressed then
          key.pressed      = false
          key.just_pressed = false
          break
        end
      elseif key.code == 0x20040 then
        if key.pressed then
          key.pressed      = false
          key.just_pressed = false
          break
        end
      end
    end
  end
end)
