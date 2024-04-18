---@diagnostic disable: undefined-global, lowercase-global
YimActions = gui.get_tab("Samurai's YimActions")
require ("animdata")
json = json()
-- local debug = false
local anim_index = 0
local scenario_index = 0
local npc_index = 0
local switch = 0
local filteredAnims = {}
local filteredScenarios = {}
-- local favorites = {}
local searchQuery = ""
local is_typing = false
local searchBar = true
local x = 0
local counter = 0
local clumsy = false
local rod = false
plyrProps = {}
npcProps = {}
selfPTFX = {}
npcPTFX = {}
spawned_npcs = {}
is_playing_anim = false
is_playing_scenario = false
default_config = {disableTooltips = false, phoneAnim = false, disableProps = false, sprintInside = false, lockpick = false, manualFlags = false, controllable = false, looped = false, upperbody = false, freeze = false, usePlayKey = false}
disableProps = readFromConfig("disableProps")
npc_godMode = readFromConfig("npc_godMode")
local disableTooltips = readFromConfig("disableTooltips")
local phoneAnim = readFromConfig("phoneAnim")
local sprintInside = readFromConfig("sprintInside")
local lockPick = readFromConfig("lockPick")
local manualFlags = readFromConfig("manualFlags")
local controllable = readFromConfig("controllable")
local looped = readFromConfig("looped")
local upperbody = readFromConfig("upperbody")
local freeze = readFromConfig("freeze")
local usePlayKey = readFromConfig("usePlayKey")
script.register_looped("game input", function()
        if is_typing then
            PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
        end
        if PAD.IS_USING_KEYBOARD_AND_MOUSE() then
            stopButton = "[G]"
        else
            stopButton = "[DPAD LEFT]"
        end
end)
local function updatefilteredAnims()
    filteredAnims = {}
    for _, anim in ipairs(animlist) do
        if string.find(string.lower(anim.name), string.lower(searchQuery)) then
            table.insert(filteredAnims, anim)
        end
    end
    table.sort(animlist, function(a, b)
        return a.name < b.name
    end)
end
local function displayFilteredAnims()
    updatefilteredAnims()
    local animNames = {}
    for _, anim in ipairs(filteredAnims) do
        table.insert(animNames, anim.name)
    end
    anim_index, used = ImGui.ListBox("##animlistbox", anim_index, animNames, #filteredAnims)
end
local function updateNpcs()
    filteredNpcs = {}
    for _, npc in ipairs(npcList) do
            table.insert(filteredNpcs, npc)
    end
    table.sort(filteredNpcs, function(a, b)
        return a.name < b.name
    end)
end
local function displayNpcs()
    updateNpcs()
    local npcNames = {}
    for _, npc in ipairs(filteredNpcs) do
        table.insert(npcNames, npc.name)
    end
    npc_index, used = ImGui.Combo("##npcList", npc_index, npcNames, #filteredNpcs)
end
local function setmanualflag()
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
local function setdrunk()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("MOVE_M@DRUNK@VERYDRUNK") do
            STREAMING.REQUEST_CLIP_SET("MOVE_M@DRUNK@VERYDRUNK")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "MOVE_M@DRUNK@VERYDRUNK", 1.0)
    end)
end
local function sethoe()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_f@maneater") do
            STREAMING.REQUEST_CLIP_SET("move_f@maneater")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_f@maneater", 1.0)
    end)
end
local function setcrouched()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_ped_crouched") do
            STREAMING.REQUEST_CLIP_SET("move_ped_crouched")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_ped_crouched", 0.3)
    end)
end
local function setlester()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_heist_lester") do
            STREAMING.REQUEST_CLIP_SET("move_heist_lester")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_heist_lester", 0.4)
    end)
end
local function setballistic()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("anim_group_move_ballistic") do
            STREAMING.REQUEST_CLIP_SET("anim_group_move_ballistic")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "anim_group_move_ballistic", 1)           
    end)
end
function resetCheckBoxes()
    disableTooltips = false
    phoneAnim = false
    lockPick = false
    sprintInside = false
    clumsy = false
    rod = false
    disableProps = false
    manualFlags = false
    controllable = false
    looped = false
    upperbody = false
    freeze = false
    usePlayKey = false
end
script.register_looped("Ragdoll Loop", function(script)
    script:yield()
    if clumsy then
        if PED.IS_PED_RAGDOLL(self.get_ped()) then
            script:sleep(2500)
            return
        end
        PED.SET_PED_RAGDOLL_ON_COLLISION(self.get_ped(), true)
    elseif rod then
        if PAD.IS_CONTROL_PRESSED(0, 252) then
            PED.SET_PED_TO_RAGDOLL(self.get_ped(), 1500, 0, 0, false)
        end
    end
    script:yield()
end)
script.register_looped("npc stuff", function(follow)
    for k, v in ipairs(spawned_npcs) do
        if ENTITY.DOES_ENTITY_EXIST(v) then
            if ENTITY.IS_ENTITY_DEAD(v) then
                PED.REMOVE_PED_FROM_GROUP(v)
                follow:sleep(3000)
                PED.DELETE_PED(v)
                table.remove(spawned_npcs, k)
            end
        end
    end
end)
YimActions:add_imgui(function()
    if searchBar then
        ImGui.PushItemWidth(270)
        searchQuery, used = ImGui.InputTextWithHint("##searchBar", "Search", searchQuery, 32)
        if ImGui.IsItemActive() then
            is_typing = true
        else
            is_typing = false
        end
    end
    ImGui.BeginTabBar("Samurai's YimActions", ImGuiTabBarFlags.None)
    if ImGui.BeginTabItem("Animations") then
        ImGui.PushItemWidth(345)
        displayFilteredAnims()
        info = filteredAnims[anim_index + 1]
        ImGui.Separator()
        manualFlags, used = ImGui.Checkbox("Edit Flags", manualFlags, true)
        if used then
            saveToConfig("manualFlags", manualFlags)
        end
        helpmarker(false, "Allows you to customize how the animation plays.\nExample: if an animation is set to loop but you want it to freeze, activate this then choose your desired settings.")
        ImGui.SameLine()
        disableProps, used = ImGui.Checkbox("Disable Props", disableProps, true)
        if used then
            saveToConfig("disableProps", disableProps)
        end
        helpmarker(false, "Choose whether to play animations with props or not. Check or Un-check this before playing the animation.")
        if manualFlags then
            ImGui.Separator()
            controllable, used = ImGui.Checkbox("Allow Control", controllable, true)
            if used then
                saveToConfig("controllable", controllable)
            end
            helpmarker(false, "Allows you to keep control of your character and/or vehicle. If paired with 'Upper Body Only', you can play animations and walk/run/drive around.")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            looped, used = ImGui.Checkbox("Loop", looped, true)
            if used then
                saveToConfig("looped", looped)
            end
            helpmarker(false, "Plays the animation forever until you manually stop it.")
            upperbody, used = ImGui.Checkbox("Upper Body Only", upperbody, true)
            if used then
                saveToConfig("upperbody", upperbody)
            end
            helpmarker(false, "Only plays the animation on you character's upperbody (from the waist up).")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            freeze, used = ImGui.Checkbox("Freeze", freeze, true)
            if used then
                saveToConfig("freeze", freeze)
            end
            helpmarker(false, "Freezes the animation at the very last frame. Useful for ragdoll/sleeping/dead animations.")
        end
        function cleanup()
            script.run_in_fiber(function()
                TASK.CLEAR_PED_TASKS(self.get_ped())
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                if plyrProps[1] ~= nil then
                    for k, v in ipairs(plyrProps) do
                        script.run_in_fiber(function(script)
                            if ENTITY.DOES_ENTITY_EXIST(v) then
                                PED.DELETE_PED(v)
                            end
                            if ENTITY.DOES_ENTITY_EXIST(v) then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v)
                                script:sleep(100)
                                ENTITY.DELETE_ENTITY(v)
                            end
                        end)
                        table.remove(plyrProps, k)
                    end
                end
                if selfPTFX[1] ~= nil then
                    for k, v in ipairs(selfPTFX) do
                        script.run_in_fiber(function()
                            GRAPHICS.STOP_PARTICLE_FX_LOOPED(v)
                        end)
                        table.remove(selfPTFX, k)
                    end
                end
            end)
        end
        if ImGui.Button("   Play   ") then
            local coords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
            local heading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
            local forwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
            local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
            local boneIndex = PED.GET_PED_BONE_INDEX(self.get_ped(), info.boneID)
            local bonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), info.boneID)
            if manualFlags then
                setmanualflag()
            else
                flag = info.flag
            end
            playSelected(self.get_ped(), selfprop1, selfprop2, selfloopedFX, selfSexPed, boneIndex, coords, heading, forwardX, forwardY, bonecoords, "self", plyrProps, selfPTFX)
            is_playing_anim = true
        end
        ImGui.SameLine()
        if ImGui.Button("   Stop   ") then
            if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), false) then
                cleanup()
                local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                PED.SET_PED_INTO_VEHICLE(self.get_ped(), veh, -1)
            else
                cleanup()
                local current_coords = ENTITY.GET_ENTITY_COORDS(self.get_ped())
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true, false, false)
            end
            is_playing_anim = false
        end
        widgetToolTip(false, "TIP: You can also stop animations by pressing [G] on keyboard or [DPAD LEFT] on controller.")
        ImGui.SameLine()
        local errCol = {}
        if plyrProps[1] ~= nil then
            errCol = {104, 247, 114, 0.2}
        else
            errCol = {225, 0, 0, 0.5}
        end
        if Button("Remove Attachments", {104, 247, 114, 0.6}, {104, 247, 114, 0.5}, errCol) then
            all_objects = entities.get_all_objects_as_handles()
            for _, v in ipairs(all_objects) do
                script.run_in_fiber(function()
                    modelHash = ENTITY.GET_ENTITY_MODEL(v)
                    attachedObject = ENTITY.GET_ENTITY_OF_TYPE_ATTACHED_TO_ENTITY(self.get_ped(), modelHash)
                    if ENTITY.DOES_ENTITY_EXIST(attachedObject) then
                        ENTITY.DETACH_ENTITY(attachedObject)
                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(attachedObject)
                        TASK.CLEAR_PED_TASKS(self.get_ped())
                    end
                end)
            end
            all_peds = entities.get_all_peds_as_handles()
            for _, p in ipairs(all_peds) do
                script.run_in_fiber(function()
                    pedHash = ENTITY.GET_ENTITY_MODEL(p)
                    attachedPed = ENTITY.GET_ENTITY_OF_TYPE_ATTACHED_TO_ENTITY(self.get_ped(), pedHash)
                    if ENTITY.DOES_ENTITY_EXIST(attachedPed) then
                        ENTITY.DETACH_ENTITY(attachedPed)
                        TASK.CLEAR_PED_TASKS(self.get_ped())
                        TASK.CLEAR_PED_TASKS(attachedPed)
                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(attachedPed)
                    end
                end)
            end
            is_playing_anim = false
            if plyrProps[1] ~= nil then
                for k, _ in ipairs(plyrProps) do
                    plyrProps[k] = nil
                end
            else
                gui.show_error("YimActions", "There are no objects or peds attached.")
            end
        end
        widgetToolTip(false, "Detaches all props.")
        -- if ImGui.Button("Add To Favorites") then
        --     table.insert(favorites, info)
        --     save_favorites()
        -- end
        ImGui.Separator()
        ImGui.Text("Ragdoll Options:")
        ImGui.Spacing()
        clumsy, used = ImGui.Checkbox("Clumsy", clumsy, true)
        if clumsy then
            rod = false
        end
        widgetToolTip(false, "Makes You Ragdoll When You Collide With Any Object.\n(Doesn't work with Ragdoll On Demand)")
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        rod, used = ImGui.Checkbox("Ragdoll On Demand", rod, true)
        if rod then
            clumsy = false
        end
        widgetToolTip(false, "Press [X] On Keyboard or [LT] On Controller To Instantly Ragdoll. The Longer You Hold The Button, The Longer You Stay On The Ground.\n(Doesn't work with Clumsy)")
        ImGui.Spacing()
        ImGui.Text("Movement Options:")
        ImGui.Spacing()
        local isChanged = false
        switch, isChanged = ImGui.RadioButton("Normal", switch, 0)
        if isChanged then
            PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.0)
            isChanged = false
        end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Drunk", switch, 1)
        widgetToolTip(false, "Works Great With Ragdoll Options.")
        if isChanged then setdrunk() end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Hoe", switch, 2)
        if isChanged then sethoe() end
        switch, isChanged = ImGui.RadioButton("Crouch", switch, 3)
        widgetToolTip(false, "You can pair this with the default stealth action [LEFT CTRL].")
        if isChanged then setcrouched() end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Lester", switch, 4)
        if isChanged then setlester() end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Heavy", switch, 5)
        if isChanged then setballistic() end
        ImGui.Separator()
        ImGui.Text("Play Animations On NPCs:")
        ImGui.SameLine()
        coloredText("[Work In Progress]", {247, 185, 104, 0.78})
        ImGui.PushItemWidth(200)
        displayNpcs()
        ImGui.PopItemWidth()
        local npcData = filteredNpcs[npc_index + 1]
        function cleanupNPC()
            script.run_in_fiber(function()
                for _, v in ipairs(spawned_npcs) do
                    TASK.CLEAR_PED_TASKS(v)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(v, true)
                end
                if npcProps[1] ~= nil then
                    for k, v in ipairs(npcProps) do
                        script.run_in_fiber(function(script)
                            if ENTITY.DOES_ENTITY_EXIST(v) then
                                PED.DELETE_PED(v)
                            end
                            if ENTITY.DOES_ENTITY_EXIST(v) then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v)
                                script:sleep(100)
                                ENTITY.DELETE_ENTITY(v)
                            end
                        end)
                    end
                end
                if ENTITY.DOES_ENTITY_EXIST(npcSexPed) then
                    PED.DELETE_PED(npcSexPed)
                end
                if npcPTFX[1] ~= nil then
                    for key, value in ipairs(npcPTFX) do
                        script.run_in_fiber(function()
                            GRAPHICS.STOP_PARTICLE_FX_LOOPED(value)
                        end)
                        table.remove(npcPTFX, key)
                    end
                end
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
            end)
        end
        ImGui.SameLine()
        npc_godMode, used = ImGui.Checkbox("Invincibe", npc_godMode, true)
        if used then
            saveToConfig("npc_godMode", npc_godMode)
        end
        widgetToolTip(false, "Spawn NPCs in God Mode.")
        if ImGui.Button("Spawn") then
            script.run_in_fiber(function()
                local pedCoords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
                local pedHeading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
                local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
                local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
                local myGroup = PLAYER.GET_PLAYER_GROUP(self.get_ped())
                while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
                    STREAMING.REQUEST_MODEL(npcData.hash)
                    coroutine.yield()
                end
                npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4, pedCoords.z, true, false, false)
                ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
                PED.SET_PED_AS_GROUP_MEMBER(npc, myGroup)
                PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
                npcBlip = HUD.ADD_BLIP_FOR_ENTITY(npc)
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
                -- PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true)
                if npc_godMode then
                    ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
                end
                table.insert(spawned_npcs, npc)
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Delete") then
            cleanupNPC()
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
        ImGui.SameLine()
        if ImGui.Button("Play On NPC") then
            -- script.run_in_fiber(function(cunt)
            --     if is_playing_anim then
            --         cleanupNPC()
            --     end
            --     cunt:sleep(200)
            -- end)
            if spawned_npcs[1] ~= nil then
                for _, v in ipairs(spawned_npcs) do
                    if ENTITY.DOES_ENTITY_EXIST(v) then
                        local npcCoords = ENTITY.GET_ENTITY_COORDS(v, false)
                        local npcHeading = ENTITY.GET_ENTITY_HEADING(v)
                        local npcForwardX = ENTITY.GET_ENTITY_FORWARD_X(v)
                        local npcForwardY = ENTITY.GET_ENTITY_FORWARD_Y(v)
                        local npcBoneIndex = PED.GET_PED_BONE_INDEX(v, info.boneID)
                        local npcBboneCoords = PED.GET_PED_BONE_COORDS(v, info.boneID)
                        if manualFlags then
                            setmanualflag()
                        else
                            flag = info.flag
                        end
                        playSelected(v, npcprop1, npcprop2, npcloopedFX, npcSexPed, npcBoneIndex, npcCoords, npcHeading, npcForwardX, npcForwardY, npcBboneCoords, "cunt", npcProps, npcPTFX)
                    end
                end
            else
                gui.show_error("YimActions", "Spawn an NPC first!")
            end
        end
        ImGui.SameLine()
        if ImGui.Button("Stop NPC") then
            cleanupNPC()
            for _, v in ipairs(spawned_npcs) do
                script.run_in_fiber(function()
                    if PED.IS_PED_IN_ANY_VEHICLE(v, false) then
                        local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                        for i = 0, 4 do
                            if VEHICLE.IS_VEHICLE_SEAT_FREE(i) == false then
                                sittingPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, i, false)
                                if sittingPed == v then
                                    seat = i
                                end
                            end
                            PED.SET_PED_INTO_VEHICLE(v, veh, seat)
                        end
                    end
                end)
            end
        end
        event.register_handler(menu_event.ScriptsReloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(self.get_ped(), false)
            if is_playing_anim then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                if selfPTFX ~= nil then
                    for k, v in ipairs(selfPTFX) do
                        GRAPHICS.STOP_PARTICLE_FX_LOOPED(v)
                        table.remove(selfPTFX, k)
                    end
                end
            -- //fix player clipping through the ground after ending low-positioned anims//
                local current_coords = ENTITY.GET_ENTITY_COORDS(self.get_ped())
                if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                    PED.SET_PED_INTO_VEHICLE(self.get_ped(), veh, -1)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
                if plyrProps[1] ~= nil then
                    for k, v in ipairs(plyrProps) do
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v)
                            script:sleep(100)
                            ENTITY.DELETE_ENTITY(v)
                        end
                        table.remove(plyrProps, k)
                    end
                end
            end
            if spawned_npcs[1] ~= nil then
                cleanupNPC()
                for k, v in ipairs(spawned_npcs) do
                    if ENTITY.DOES_ENTITY_EXIST(v) then
                        ENTITY.DELETE_ENTITY(v)
                    end
                    table.remove(spawned_npcs, k)
                end
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(self.get_ped(), false)
            if is_playing_anim then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                if selfPTFX ~= nil then
                    for k, v in ipairs(selfPTFX) do
                        GRAPHICS.STOP_PARTICLE_FX_LOOPED(v)
                        table.remove(selfPTFX, k)
                    end
                end
            -- //fix player clipping through the ground after ending low-positioned anims//
                local current_coords = ENTITY.GET_ENTITY_COORDS(self.get_ped())
                if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                    PED.SET_PED_INTO_VEHICLE(self.get_ped(), veh, -1)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
                if plyrProps[1] ~= nil then
                    for k, v in ipairs(plyrProps) do
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v)
                            script:sleep(100)
                            ENTITY.DELETE_ENTITY(v)
                        end
                        table.remove(plyrProps, k)
                    end
                end
            end
            if spawned_npcs[1] ~= nil then
                for k, v in ipairs(spawned_npcs) do
                    if ENTITY.DOES_ENTITY_EXIST(v) then
                        ENTITY.DELETE_ENTITY(v)
                    end
                    table.remove(spawned_npcs, k)
                end
            end
        end)
        ImGui.EndTabItem()
    end
    if ImGui.BeginTabItem("Scenarios") then
        ImGui.PushItemWidth(335)
        local function updatefilteredScenarios()
            filteredScenarios = {}
            for _, scene in ipairs(ped_scenarios) do
                if string.find(string.lower(scene.name), string.lower(searchQuery)) then
                    table.insert(filteredScenarios, scene)
                end
            end
        end
        local function displayFilteredScenarios()
            updatefilteredScenarios()
            local scenarioNames = {}
            for _, scene in ipairs(filteredScenarios) do
                table.insert(scenarioNames, scene.name)
            end
            scenario_index, used = ImGui.ListBox("##scenarioList", scenario_index, scenarioNames, #filteredScenarios)
        end
        displayFilteredScenarios()
        ImGui.Separator()
        if ImGui.Button("   Play    ") then
            if is_playing_anim then
                cleanup()
            end
            local data = filteredScenarios[scenario_index + 1]
            local coords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
            local heading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
            local forwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
            local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
            if data.name == "Cook On BBQ" then
                script.run_in_fiber(function()
                    while not STREAMING.HAS_MODEL_LOADED(286252949) do
                        STREAMING.REQUEST_MODEL(286252949)
                        coroutine.yield()
                    end
                    bbq = OBJECT.CREATE_OBJECT(286252949, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true, false)
                    ENTITY.SET_ENTITY_HEADING(bbq, heading)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(bbq)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                    TASK.TASK_START_SCENARIO_IN_PLACE(self.get_ped(), data.scenario, -1, true)
                    is_playing_scenario = true
                end)
            else
                script.run_in_fiber(function()
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                    TASK.TASK_START_SCENARIO_IN_PLACE(self.get_ped(), data.scenario, -1, true)
                    is_playing_scenario = true
                    if ENTITY.DOES_ENTITY_EXIST(bbq) then
                        ENTITY.DELETE_ENTITY(bbq)
                    end
                end)
            end
        end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() 
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        if ImGui.Button("   Stop   ") then
            if is_playing_scenario then
                script.run_in_fiber(function(script)
                    busyspinner("Stopping scenario...", 3)
                    TASK.CLEAR_PED_TASKS(self.get_ped())
                    is_playing_scenario = false
                    script:sleep(1000)
                    HUD.BUSYSPINNER_OFF()
                    if ENTITY.DOES_ENTITY_EXIST(bbq) then
                        ENTITY.DELETE_ENTITY(bbq)
                    end
                end)
            end
        end
        widgetToolTip(false, "TIP: You can also stop scenarios by pressing [G] on keyboard or [DPAD LEFT] on controller.")
        ImGui.Separator()
        ImGui.Text("Play Scenarios On NPCs:")
        ImGui.SameLine()
        coloredText("[Work In Progress]", {247, 185, 104, 0.78})
        ImGui.PushItemWidth(200)
        displayNpcs()
        ImGui.PopItemWidth()
        ImGui.SameLine()
        npc_godMode, used = ImGui.Checkbox("Invincibe", npc_godMode, true)
        widgetToolTip(false, "Spawn NPCs in God Mode.")
        local npcData = filteredNpcs[npc_index + 1]
        if ImGui.Button("Spawn") then
            local pedCoords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
            local pedHeading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
            local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
            local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
            local myGroup = PLAYER.GET_PLAYER_GROUP(self.get_ped())
            script.run_in_fiber(function()
                while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
                    STREAMING.REQUEST_MODEL(npcData.hash)
                    coroutine.yield()
                end
                npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4, pedCoords.z, true, false, false)
                ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
                PED.SET_PED_AS_GROUP_MEMBER(npc, myGroup)
                PED.SET_PED_NEVER_LEAVES_GROUP(npc, true)
                npcBlip = HUD.ADD_BLIP_FOR_ENTITY(npc)
                HUD.SET_BLIP_AS_FRIENDLY(npcBlip, true)
                HUD.SET_BLIP_SCALE(npcBlip, 0.8)
                HUD.SHOW_HEADING_INDICATOR_ON_BLIP(npcBlip, true)
                HUD.SET_BLIP_SPRITE(npcBlip, 280)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4, pedCoords.z, true, false, false)
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
        if ImGui.Button("Delete") then
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
        ImGui.SameLine()
        if ImGui.Button("Play On NPC") then
            if spawned_npcs[1] ~= nil then
                if is_playing_anim then
                    cleanupNPC()
                end
                local data = filteredScenarios[scenario_index+1]
                for _, v in ipairs(spawned_npcs) do
                    local npcCoords = ENTITY.GET_ENTITY_COORDS(v, false)
                    local npcHeading = ENTITY.GET_ENTITY_HEADING(v)
                    local npcForwardX = ENTITY.GET_ENTITY_FORWARD_X(v)
                    local npcForwardY = ENTITY.GET_ENTITY_FORWARD_Y(v)
                    if data.name == "Cook On BBQ" then
                        script.run_in_fiber(function()
                            while not STREAMING.HAS_MODEL_LOADED(286252949) do
                                STREAMING.REQUEST_MODEL(286252949)
                                coroutine.yield()
                            end
                            bbq = OBJECT.CREATE_OBJECT(286252949, npcCoords.x + (npcForwardX), npcCoords.y + (npcForwardY), npcCoords.z, true, true, false)
                            ENTITY.SET_ENTITY_HEADING(bbq, npcHeading)
                            OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(bbq)
                            TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
                            TASK.TASK_START_SCENARIO_IN_PLACE(v, data.scenario, -1, true)
                            is_playing_scenario = true
                        end)
                    else
                        script.run_in_fiber(function()
                            TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
                            TASK.TASK_START_SCENARIO_IN_PLACE(v, data.scenario, -1, true)
                            is_playing_scenario = true
                            if ENTITY.DOES_ENTITY_EXIST(bbq) then
                                ENTITY.DELETE_ENTITY(bbq)
                            end
                        end)
                    end
                end
            else
                gui.show_error("YimActions", "Spawn an NPC first!")
            end
        end
        ImGui.SameLine()
        if ImGui.Button("Stop NPC") then
            if is_playing_scenario then
                script.run_in_fiber(function(script)
                    busyspinner("Stopping scenario...", 3)
                    for _, v in ipairs(spawned_npcs) do
                        TASK.CLEAR_PED_TASKS(v)
                    end
                    is_playing_scenario = false
                    if ENTITY.DOES_ENTITY_EXIST(bbq) then
                        ENTITY.DELETE_ENTITY(bbq)
                    end
                    script:sleep(800)
                    HUD.BUSYSPINNER_OFF()
                end)
            end
        end
        event.register_handler(menu_event.ScriptsReloaded, function()
            if is_playing_scenario then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                is_playing_scenario = false
                if ENTITY.DOES_ENTITY_EXIST(bbq) then
                    ENTITY.DELETE_ENTITY(bbq)
                end
                if spawned_npcs[1] ~= nil then
                    for k, v in ipairs(spawned_npcs) do
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.DELETE_ENTITY(v)
                        end
                        table.remove(spawned_npcs, k)
                    end
                end
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            if is_playing_scenario then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
                is_playing_scenario = false
                if ENTITY.DOES_ENTITY_EXIST(bbq) then
                    ENTITY.DELETE_ENTITY(bbq)
                end
                if spawned_npcs[1] ~= nil then
                    for k, v in ipairs(spawned_npcs) do
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.DELETE_ENTITY(v)
                        end
                        table.remove(spawned_npcs, k)
                    end
                end
            end
        end)
        ImGui.EndTabItem()
    end
    local function progressBar()
        x = x + 0.01
        if x > 1 then
            x = 1
            progessMessage = "Settings Successfully Reset."
        else
            progessMessage = "Please Wait..."
        end
    end
    local function displayProgressBar()
        ImGui.Text(progessMessage)
        progressBar()
        ImGui.ProgressBar(x, 250, 25)
    end
    if ImGui.BeginTabItem("Settings") then
        searchBar = false
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        ImGui.Text("     ")
        disableTooltips, used = ImGui.Checkbox("Disable Tooltips", disableTooltips, true)
        if used then
        saveToConfig("disableTooltips", disableTooltips)
        end
        widgetToolTip(false, "Well, it disables this thing.")
        phoneAnim, used = ImGui.Checkbox("Enable Phone Animations", phoneAnim, true)
        if used then
            saveToConfig("phoneAnim", phoneAnim)
        end
        helpmarker(false, "Restores the disabled phone animations from Single Player.")
        sprintInside, used = ImGui.Checkbox("Sprint Inside Interiors", sprintInside, true)
        if used then
            saveToConfig("sprintInside", sprintInside)
        end
        helpmarker(false, "Allows you to sprint at full speed inside interiors that do not allow it like the Casino.")
        lockPick, used = ImGui.Checkbox("Use Lockpick Animation", lockPick, true)
        if used then
            saveToConfig("lockPick", lockPick)
        end
        helpmarker(false, "When stealing vehicles, your character will use the lockpick animation instead of breaking the window.")
        usePlayKey, used = ImGui.Checkbox("Use Hotkeys For Animations", usePlayKey, true)
        if used then
            saveToConfig("usePlayKey", usePlayKey)
        end
        if not disableTooltips then
            ImGui.SameLine(); ImGui.TextDisabled("(?)")
            if ImGui.IsItemHovered() then
                ImGui.SetNextWindowBgAlpha(0.75)
                ImGui.BeginTooltip()
                ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
                ImGui.TextWrapped("Select an animation from the list then use [DELETE] on Keyboard or [X] on Controller to play it while the menu is closed. You can also select the previous/next animation by pressing [PAGE DOWN] to go down the list and [PAGE UP] to go up.\nNOTE: For these hotkeys to work, you have to open YimActions GUI at least once. Browsing the list while the menu is closed is currently not supported for controller.")
                ImGui.PopTextWrapPos()
                coloredText("EXPERIMENTAL: This is the only way to use hotkeys with YimMenu at the moment. This was annoying to implement and it will likely be buggy. If it causes issues for you, disable it from Settings.\n(The 'stop animation' hotkey won't be affected)", {240, 3, 50, 0.8})
                ImGui.EndTooltip()
            end
        end
        ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing()
        ImGui.Separator()
        if Button("Reset Settings", {142, 0, 0, 1}, {142, 0, 0, 0.7}, {142, 0, 0, 0.5}) then
            ImGui.OpenPopup("##Progress Bar")
        end
        widgetToolTip(false, "Revert saved settings and disable all checkboxes.")
        ImGui.SetNextWindowBgAlpha(0)
        if ImGui.BeginPopupModal("##Progress Bar", ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoScrollWithMouse | ImGuiWindowFlags.AlwaysAutoResize) then
                displayProgressBar()
                resetConfig(default_config)
                if x == 1 then
                    counter = counter + 1
                    if counter > 100 then
                        ImGui.CloseCurrentPopup()
                        counter = 0
                        x = 0
                        resetCheckBoxes()
                    else return
                    end
                end
            ImGui.EndPopup()
        end
        ImGui.EndTabItem()
    else
        searchBar = true
    end
end)
script.register_looped("side features", function(script)
    script:yield()
    if phoneAnim and NETWORK.NETWORK_IS_SESSION_ACTIVE() then
        if not ENTITY.IS_ENTITY_DEAD(self.get_ped()) then
            PED.SET_PED_CONFIG_FLAG(self.get_ped(), 242, false)
            PED.SET_PED_CONFIG_FLAG(self.get_ped(), 243, false)
            PED.SET_PED_CONFIG_FLAG(self.get_ped(), 244, false)
            MOBILE.CELL_SET_INPUT(5)
        end
    end
    if sprintInside then
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, true)
    else
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, false)
    end
    if lockPick then
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, true)
    else
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, false)
    end
end)
script.register_looped("scenario hotkey", function(hotkey)
    hotkey:yield()
    if is_playing_scenario then
        if PAD.IS_CONTROL_PRESSED(0, 47) then
            script.run_in_fiber(function(script)
                busyspinner("Stopping scenario...", 3)
                TASK.CLEAR_PED_TASKS(self.get_ped())
                for _, v in ipairs(spawned_npcs) do
                    TASK.CLEAR_PED_TASKS(v)
                end
                script:sleep(800)
                HUD.BUSYSPINNER_OFF()
                if ENTITY.DOES_ENTITY_EXIST(bbq) then
                    ENTITY.DELETE_ENTITY(bbq)
                end
                is_playing_scenario = false
            end)
        end
    end
end)

function helpmarker(colorFlag, text, color)
    if not disableTooltips then
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.SetNextWindowBgAlpha(0.75)
            ImGui.BeginTooltip()
            if colorFlag == true then
                coloredText(text, color)
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
        if ImGui.IsItemHovered() then
            ImGui.SetNextWindowBgAlpha(0.75)
            ImGui.BeginTooltip()
            if colorFlag == true then
                coloredText(text, color)
            else
                ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
                ImGui.TextWrapped(text)
                ImGui.PopTextWrapPos()
            end
            ImGui.EndTooltip()
        end
    end
end

script.register_looped("animation hotkey", function(script)
    script:yield()
    if is_playing_anim then
        if spawned_npcs[1] ~= nil then
            if PAD.IS_CONTROL_PRESSED(0, 47) then
                cleanup()
                cleanupNPC()
                for _, v in ipairs(spawned_npcs) do
                    if PED.IS_PED_IN_ANY_VEHICLE(v, false) then
                        local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                        for i = 0, 4 do
                            if VEHICLE.IS_VEHICLE_SEAT_FREE(i) == false then
                                sittingPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, i, false)
                                if sittingPed == v then
                                    seat = i
                                end
                            end
                            PED.SET_PED_INTO_VEHICLE(v, veh, seat)
                        end
                    end
                end
                if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
                    cleanup()
                    PED.SET_PED_INTO_VEHICLE(self.get_ped(), veh, -1)
                else
                    cleanup()
                    local current_coords = ENTITY.GET_ENTITY_COORDS(self.get_ped())
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
            end
        else
            if PAD.IS_CONTROL_PRESSED(0, 47) then
                cleanup()
                local current_coords = ENTITY.GET_ENTITY_COORDS(self.get_ped())
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.get_ped(), current_coords.x, current_coords.y, current_coords.z, true, false, false)
                is_playing_anim = false
            end
        end
    end
    if usePlayKey and info ~= nil then
        if PAD.IS_CONTROL_PRESSED(0, 317) then
            anim_index = anim_index + 1
            info = filteredAnims[anim_index + 1]
            if info == nil then
                anim_index = 0
                info = filteredAnims[anim_index + 1]
                gui.show_message("Current Animation:", info.name)
            end
            if info ~= nil then
                gui.show_message("Current Animation:", info.name)
            end
            script:sleep(200) -- average inter-key interval is about what, 250ms? this should be enough.
        elseif PAD.IS_CONTROL_PRESSED(0, 316) and anim_index > 0 then -- prevent going to index 0 which breaks the script.
            anim_index = anim_index - 1
            info = filteredAnims[anim_index + 1]
            gui.show_message("Current Animation:", info.name)
            script:sleep(200)
        elseif PAD.IS_CONTROL_PRESSED(0, 316) and anim_index == 0 then
                info = filteredAnims[anim_index + 1]
                gui.show_warning("Current Animation:", info.name.."\n\nYou have reached the top of the list.")
                script:sleep(400)
        end
        if PAD.IS_CONTROL_PRESSED(0, 256) then
            if not is_playing_anim then
                if info ~= nil then
                    local coords = ENTITY.GET_ENTITY_COORDS(self.get_ped(), false)
                    local heading = ENTITY.GET_ENTITY_HEADING(self.get_ped())
                    local forwardX = ENTITY.GET_ENTITY_FORWARD_X(self.get_ped())
                    local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(self.get_ped())
                    local boneIndex = PED.GET_PED_BONE_INDEX(self.get_ped(), info.boneID)
                    local bonecoords = PED.GET_PED_BONE_COORDS(self.get_ped(), info.boneID)
                    if manualFlags then
                        setmanualflag()
                    else
                        flag = info.flag
                    end
                    playSelected(self.get_ped(), selfprop1, selfprop2, selfloopedFX, selfSexPed, boneIndex, coords, heading, forwardX, forwardY, bonecoords, "self", plyrProps, selfPTFX)
                    script:sleep(200)
                end
            else
                PAD.SET_CONTROL_SHAKE(0, 500, 250)
                gui.show_message("YimActions", "Press "..stopButton.." to stop the current animation before playing the next one.")
                script:sleep(800)
            end
        end
    end
end)