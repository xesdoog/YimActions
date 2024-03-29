---@diagnostic disable: undefined-global, lowercase-global
YimActions = gui.get_tab("Samurai's YimActions")
require ("animdata")
json = require("json")
local anim_index = 0
local scenario_index = 0
local npc_index = 0
local switch = 0
local filteredAnims = {}
local filteredScenarios = {}
local spawned_entities = {}
local spawned_npcs = {}
local searchQuery = ""
local is_typing = false
local controllable = false
local looped = false
local upperbody = false
local freeze = false
local searchBar = true
local x = 0
local counter = 0
is_playing_anim = false
is_playing_scenario = false
default_config = {disableTooltips = false, phoneAnim = false, clumsy = false, rod = false, disableProps = false}
local disableTooltips = readFromConfig("disableTooltips")
local phoneAnim = readFromConfig("phoneAnim")
local clumsy = readFromConfig("clumsy")
local rod = readFromConfig("rod")
local manualFlags = false
local disableProps = readFromConfig("disableProps")
script.register_looped("playerID", function(playerID)
    if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
        is_online = true
        onlinePed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
    else
        is_online = false
        spPed = self.get_ped()
    end
    if is_online then
        ped = onlinePed
    else
        ped = spPed
    end
    playerID:yield()
end)
script.register_looped("Ragdoll Loop", function(script)
    script:yield()
    if clumsy then
        if PED.IS_PED_RAGDOLL(ped) then
            script:sleep(2500)
            return
        end
        PED.SET_PED_RAGDOLL_ON_COLLISION(ped, true)
    elseif rod then
        if PAD.IS_CONTROL_PRESSED(0, 252) then
            PED.SET_PED_TO_RAGDOLL(ped, 1500, 0, 0, false)
        end
    end
    script:yield()
end)
script.register_looped("animation hotkey", function(script)
    script:yield()
    if is_playing_anim then
        if PAD.IS_CONTROL_PRESSED(0, 256) then
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) or PED.IS_PED_IN_ANY_VEHICLE(npc, false)  then
                cleanup()
                cleanupNPC()
                local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                PED.SET_PED_INTO_VEHICLE(ped, veh, 0)
                PED.SET_PED_INTO_VEHICLE(npc, veh, 0)
            else
                cleanup()
                cleanupNPC()
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
                local npc_coords = ENTITY.GET_ENTITY_COORDS(npc)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, npc_coords.x, npc_coords.y, npc_coords.z, true, false, false)
            end
            is_playing_anim = false
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
        end
    end
end)
script.register_looped("follow ped", function(follow)
    follow:yield()
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_SITTING_IN_ANY_VEHICLE(npc) then
        local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
        PED.SET_PED_INTO_VEHICLE(npc, veh, 0)
        follow:yield()
    end
    if PED.IS_PED_SITTING_IN_ANY_VEHICLE(npc) and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
        follow:yield()
    end
end)
script.register_looped("disable game input", function()
        if is_typing then
            PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
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
        PED.SET_PED_MOVEMENT_CLIPSET(ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
    end)
end
local function sethoe()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_f@maneater") do
            STREAMING.REQUEST_CLIP_SET("move_f@maneater")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(ped, "move_f@maneater", 1.0)
    end)
end
local function setcrouched()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_ped_crouched") do
            STREAMING.REQUEST_CLIP_SET("move_ped_crouched")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(ped, "move_ped_crouched", 0.3)
    end)
end
local function setlester()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("move_heist_lester") do
            STREAMING.REQUEST_CLIP_SET("move_heist_lester")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(ped, "move_heist_lester", 0.4)
    end)
end
local function setballistic()
    script.run_in_fiber(function()
        while not STREAMING.HAS_CLIP_SET_LOADED("anim_group_move_ballistic") do
            STREAMING.REQUEST_CLIP_SET("anim_group_move_ballistic")
            coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(ped, "anim_group_move_ballistic", 1)
    end)
end
function resetCheckBoxes()
    disableTooltips = false 
    phoneAnim = false
    clumsy = false
    rod = false
    disableProps = false
end
YimActions:add_imgui(function()
    if searchBar then
        ImGui.Text("Search:")
        ImGui.PushItemWidth(270)
        searchQuery, used = ImGui.InputText("##searchBar", searchQuery, 32)
        if ImGui.IsItemActive() then
            is_typing = true
        else
            is_typing = false
        end
    end
    ImGui.BeginTabBar("Samurai's YimActions", ImGuiTabBarFlags.None)
    if ImGui.BeginTabItem("Animations") then
        ImGui.PushItemWidth(350)
        displayFilteredAnims()
        ImGui.Separator()
        manualFlags, used = ImGui.Checkbox("Edit Flags", manualFlags, true)
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
            helpmarker(false, "Allows you to keep control of your character and/or vehicle. If paired with 'Upper Body Only', you can play animations and walk/run/drive around.")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            looped, used = ImGui.Checkbox("Loop", looped, true)
            helpmarker(false, "Plays the animation forever until you manually stop it.")
            upperbody, used = ImGui.Checkbox("Upper Body Only", upperbody, true)
            helpmarker(false, "Only plays the animation on you character's upperbody (from the waist up).")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            freeze, used = ImGui.Checkbox("Freeze", freeze, true)
            helpmarker(false, "Freezes the animation at the very last frame. Useful for ragdoll/sleeping/dead animations.")
        end
        local info = filteredAnims[anim_index + 1]
        function cleanup()
            script.run_in_fiber(function()
                TASK.CLEAR_PED_TASKS(ped)
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                if ENTITY.DOES_ENTITY_EXIST(sexPed) then
                    PED.DELETE_PED(sexPed)
                end
            end)
        end
        if ImGui.Button("   Play   ") then
            local coords = ENTITY.GET_ENTITY_COORDS(ped, false)
            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local forwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
            local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
            local boneIndex = PED.GET_PED_BONE_INDEX(ped, info.boneID)
            local bonecoords = PED.GET_PED_BONE_COORDS(ped, info.boneID)
            if manualFlags then
                setmanualflag()
            else
                flag = info.flag
            end
            if info.type == 1 then
                cleanup()
                script.run_in_fiber(function()
                    if not disableProps then
                        while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                            STREAMING.REQUEST_MODEL(info.prop1)
                            coroutine.yield()
                        end
                        prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, true)
                        table.insert(spawned_entities, prop1)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                    is_playing_anim = true
                end)
            elseif info.type == 2 then
                cleanup()
                script.run_in_fiber(function(type2)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 0, false, false, false)
                    is_playing_anim = true
                    type2:sleep(info.ptfxdelay)
                    GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                    loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(info.ptfxname, ped, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, info.ptfxrotx, info.ptfxroty, info.ptfxrotz, boneIndex, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                end)
            elseif info.type == 3 then
                cleanup()
                script.run_in_fiber(function()
                    if not disableProps then
                        while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                            STREAMING.REQUEST_MODEL(info.prop1)
                            coroutine.yield()
                        end
                        prop1 = OBJECT.CREATE_OBJECT(info.prop1, coords.x + forwardX /1.7, coords.y + forwardY /1.7, coords.z, true, true, false)
                        table.insert(spawned_entities, prop1)
                        ENTITY.SET_ENTITY_HEADING(prop1, heading + info.rotz)
                        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                    is_playing_anim = true
                end)
            elseif info.type == 4 then
                cleanup()
                script.run_in_fiber(function(type4)
                    if not disableProps then
                        while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                            STREAMING.REQUEST_MODEL(info.prop1)
                            coroutine.yield()
                        end
                        prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                        table.insert(spawned_entities, prop1)
                        ENTITY.SET_ENTITY_COORDS(prop1, bonecoords.x + info.posx, bonecoords.y + info.posy, bonecoords.z + info.posz)
                        type4:sleep(20)
                        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                        ENTITY.SET_ENTITY_COLLISION(prop1, info.propColl, info.propColl)
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                    is_playing_anim = true
                end)
            elseif info.type == 5 then
                cleanup()
                script.run_in_fiber(function(type5)
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                    if not disableProps then
                        while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                            STREAMING.REQUEST_MODEL(info.prop1)
                            coroutine.yield()
                        end
                        prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                        table.insert(spawned_entities, prop1)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                        type5:sleep(50)
                        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                            STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                            coroutine.yield()
                        end
                        type5:sleep(info.ptfxdelay)
                        GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                        loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(info.ptfxname, prop1, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, info.ptfxrotx, info.ptfxroty, info.ptfxrotz, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    end
                    is_playing_anim = true
                end)
            elseif info.type == 6 then
                    cleanup()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, prop1)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                            while not STREAMING.HAS_MODEL_LOADED(info.prop2) do
                                STREAMING.REQUEST_MODEL(info.prop2)
                                coroutine.yield()
                            end
                            prop2 = OBJECT.CREATE_OBJECT(info.prop2, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, prop2)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(prop2, ped, PED.GET_PED_BONE_INDEX(ped, info.bone2), info.posx2, info.posy2, info.posz2, info.rotx2, info.roty2, info.rotz2, false, false, false, false, 2, true, 1)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                        is_playing_anim = true
                    end)
            elseif info.type == 7 then
                cleanup()
                script.run_in_fiber(function()
                    if not disableProps then
                        while not STREAMING.HAS_MODEL_LOADED(info.pedHash) do
                            STREAMING.REQUEST_MODEL(info.pedHash)
                            coroutine.yield()
                        end
                        sexPed = PED.CREATE_PED(info.pedType, info.pedHash, 0.0, 0.0, 0.0, 0.0, true, false)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(sexPed, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, true, false, true, 1, true, 1)
                        ENTITY.SET_ENTITY_INVINCIBLE(sexPed, true)
                        table.insert(spawned_entities, sexPed)
                        npcNetID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(sexPed)
                        RequestControl(sexPed, npcNetID, 250)
                        entToNet(sexPed, npcNetID)
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict2) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict2)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(sexPed, info.dict2, info.anim2, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                        PED.SET_PED_CONFIG_FLAG(sexPed, 179, true)
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(sexPed, true)
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                    PED.SET_PED_CONFIG_FLAG(ped, 179, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(sexPed, true)
                    is_playing_anim = true
                end)
            else
                cleanup()
                script.run_in_fiber(function()
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                    is_playing_anim = true
                end)
            end
        end
        ImGui.SameLine()
        if ImGui.Button("   Stop   ") then
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                cleanup()
                local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
                is_playing_anim = false
            else
                cleanup()
                is_playing_anim = false
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
            end
        end
        widgetToolTip(false, "TIP: You can also stop animations by pressing [Delete] on keyboard or [X] on controller.")
        ImGui.SameLine()
        local errCol = {}
        if spawned_entities[1] ~= nil then
            errCol = {104, 247, 114, 0.2}
        else
            errCol = {225, 0, 0, 0.5}
        end
        if Button("Remove Attachments", {104, 247, 114, 0.6}, {104, 247, 114, 0.5}, errCol) then
            if spawned_entities[1] ~= nil then
                for k, v in ipairs(spawned_entities) do
                    script.run_in_fiber(function()
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.DETACH_ENTITY(v)
                            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(v)
                            TASK.CLEAR_PED_TASKS(ped)
                            TASK.CLEAR_PED_TASKS(npc)
                            TASK.CLEAR_PED_TASKS(sexPed)
                            TASK.CLEAR_PED_TASKS(sexPed2)
                            is_playing_anim = false
                        end
                    end)
                    table.remove(spawned_entities, k)
                end
            else
                gui.show_error("YimActions", "There are no attachments to remove!")
            end
        end
        widgetToolTip(false, "Detaches any attached or stuck props/peds.\n(Only works on attachments from this script)")
        ImGui.Separator()
        ImGui.Text("Ragdoll Options:")
        ImGui.Spacing()
        clumsy, used = ImGui.Checkbox("Clumsy", clumsy, true)
        if clumsy then
            rod = false
            saveToConfig("clumsy", clumsy)
            saveToConfig("rod", rod)
        end
        helpmarker(false, "Makes You Ragdoll When You Collide With Any Object.\n(Doesn't work with Ragdoll On Demand)")
        ImGui.SameLine()
        rod, used = ImGui.Checkbox("Ragdoll On Demand", rod, true)
        if rod then
            clumsy = false
            saveToConfig("rod", rod)
            saveToConfig("clumsy", clumsy)
        end
        helpmarker(false, "Press [X] On Keyboard or [LT] On Controller To Instantly Ragdoll. The Longer You Hold The Button, The Longer You Stay On The Ground.\n(Doesn't work with Clumsy)")
        ImGui.Spacing()
        ImGui.Text("Movement Options:")
        ImGui.Spacing()
        local isChanged = false
        switch, isChanged = ImGui.RadioButton("Normal", switch, 0)
        if isChanged then
            PED.RESET_PED_MOVEMENT_CLIPSET(ped, 0.0)
            isChanged = false
        end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Drunk", switch, 1)
        widgetToolTip(false, "Works Great With Ragdoll Options.")
        if isChanged then setdrunk() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Hoe", switch, 2)
        if isChanged then sethoe() end
        switch, isChanged = ImGui.RadioButton("Crouch", switch, 3)
        widgetToolTip(false, "You can pair this with the default stealth action [LEFT CTRL].")
        if isChanged then setcrouched() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Lester", switch, 4)
        if isChanged then setlester() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Heavy", switch, 5)
        if isChanged then setballistic() end
        ImGui.Separator()
        ImGui.Text("Play Animations On NPCs:")
        ImGui.SameLine()
        coloredText("[Work In Progress]", {247, 185, 104, 0.78})
        ImGui.PushItemWidth(200)
        displayNpcs()
        ImGui.PopItemWidth()
        ImGui.SameLine()
        local npcData = filteredNpcs[npc_index + 1]
        function cleanupNPC()
            script.run_in_fiber(function()
                TASK.CLEAR_PED_TASKS(npc)
                ENTITY.DELETE_ENTITY(npc_prop1)
                ENTITY.DELETE_ENTITY(npc_prop2)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX2)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                if ENTITY.DOES_ENTITY_EXIST(sexPed2) then
                    PED.DELETE_PED(sexPed2)
                end
            end)
        end
        if ImGui.Button("Spawn") then
            local pedCoords = ENTITY.GET_ENTITY_COORDS(ped, false)
            local pedHeading = ENTITY.GET_ENTITY_HEADING(ped)
            local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
            local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
                script.run_in_fiber(function(script)
                while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
                    STREAMING.REQUEST_MODEL(npcData.hash)
                    coroutine.yield()
                end
                npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
                ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4, pedCoords.z, true, false, false)
                ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
                table.insert(spawned_npcs, npc)
                npcNetID2 = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(npc)
                RequestControl(npc, npcNetID2, 250)
                entToNet(npc, npcNetID2)
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true) --keeps them from acting like pussies and running away.
                -- TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true) --complements the previous native but in this case it stops them from following the player.
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Delete") then
            cleanupNPC()
            script.run_in_fiber(function()
                if ENTITY.DOES_ENTITY_EXIST(npc) then
                    PED.DELETE_PED(npc)
                end
                for k, v in ipairs(spawned_npcs) do
                    table.remove(spawned_npcs, k)
                    ENTITY.DELETE_ENTITY(v) -- useless
                end
            end)
        end
        if ImGui.Button(" Play On NPC ") then
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                local npcCoords = ENTITY.GET_ENTITY_COORDS(npc, false)
                local npcHeading = ENTITY.GET_ENTITY_HEADING(npc)
                local npcForwardX = ENTITY.GET_ENTITY_FORWARD_X(npc)
                local npcForwardY = ENTITY.GET_ENTITY_FORWARD_Y(npc)
                local npcBoneIndex = PED.GET_PED_BONE_INDEX(npc, info.boneID)
                local npcBboneCoords = PED.GET_PED_BONE_COORDS(npc, info.boneID)
                if manualFlags then
                    setmanualflag()
                else
                    flag = info.flag
                end
                if info.type == 1 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            npc_prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, true)
                            table.insert(spawned_entities, npc_prop1)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(npc_prop1, npc, npcBoneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                    end)
                elseif info.type == 2 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                            STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                            coroutine.yield()
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                        GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                        loopedFX2 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(info.ptfxname, npc, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, info.ptfxrotx, info.ptfxroty, info.ptfxrotz, npcBoneIndex, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    end)
                elseif info.type == 3 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            npc_prop1 = OBJECT.CREATE_OBJECT(info.prop1, npcCoords.x + npcForwardX /1.7, npcCoords.y + npcForwardY /1.7, npcCoords.z, true, true, false)
                            table.insert(spawned_entities, npc_prop1)
                            ENTITY.SET_ENTITY_HEADING(npc_prop1, npcHeading + info.rotz)
                            OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(npc_prop1)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                    end)
                elseif info.type == 4 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            npc_prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, npc_prop1)
                            ENTITY.SET_ENTITY_COORDS(npc_prop1, npcBboneCoords.x + info.posx, npcBboneCoords.y + info.posy, npcBboneCoords.z + info.posz)
                            OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(npc_prop1)
                            ENTITY.SET_ENTITY_COLLISION(npc_prop1, info.propColl, info.propColl)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                    end)
                elseif info.type == 5 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            npc_prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, npc_prop1)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(npc_prop1, npc, npcBoneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                                STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                                coroutine.yield()
                            end
                            GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                            loopedFX2 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(info.ptfxname, npc_prop1, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, info.ptfxrotx, info.ptfxroty, info.ptfxrotz, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                        end
                    end)
                elseif info.type == 6 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                                STREAMING.REQUEST_MODEL(info.prop1)
                                coroutine.yield()
                            end
                            npc_prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, npc_prop1)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(npc_prop1, npc, npcBoneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                            while not STREAMING.HAS_MODEL_LOADED(info.prop2) do
                                STREAMING.REQUEST_MODEL(info.prop2)
                                coroutine.yield()
                            end
                            npc_prop2 = OBJECT.CREATE_OBJECT(info.prop2, 0.0, 0.0, 0.0, true, true, false)
                            table.insert(spawned_entities, npc_prop2)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(npc_prop2, npc, PED.GET_PED_BONE_INDEX(npc, info.bone2), info.posx2, info.posy2, info.posz2, info.rotx2, info.roty2, info.rotz2, false, false, false, false, 2, true, 1)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                    end)
                elseif info.type == 7 then
                    cleanupNPC()
                    script.run_in_fiber(function()
                        if not disableProps then
                            while not STREAMING.HAS_MODEL_LOADED(info.pedHash) do
                                STREAMING.REQUEST_MODEL(info.pedHash)
                                coroutine.yield()
                            end
                            sexPed2 = PED.CREATE_PED(info.pedType, info.pedHash, 0.0, 0.0, 0.0, 0.0, true, false)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(sexPed2, npc, npcBoneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, true, false, true, 1, true, 1)
                            ENTITY.SET_ENTITY_INVINCIBLE(sexPed2, true)
                            table.insert(spawned_entities, sexPed2)
                            npcNetID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(sexPed2)
                            RequestControl(sexPed2, npcNetID, 250)
                            entToNet(sexPed2, npcNetID)
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict2) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict2)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                        PED.SET_PED_CONFIG_FLAG(npc, 179, true)
                        TASK.TASK_PLAY_ANIM(sexPed2, info.dict2, info.anim2, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        PED.SET_PED_CONFIG_FLAG(sexPed2, 179, true)
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(sexPed2, true)
                        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(sexPed2, true)
                    end)
                else
                    cleanupNPC()
                    script.run_in_fiber(function()
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(npc, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                        is_playing_anim = true
                    end)
                end
            else
                gui.show_error("YimActions", "Spawn an NPC first!")
            end
        end
        ImGui.SameLine()
        if ImGui.Button("   Stop   ") then
            cleanupNPC()
            script.run_in_fiber(function()
                if PED.IS_PED_IN_ANY_VEHICLE(npc, false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                    PED.SET_PED_INTO_VEHICLE(npc, veh, 0)
                end
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
            end)
        end
        event.register_handler(menu_event.ScriptsReloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(ped, 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(ped, false)
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                PED.DELETE_PED(npc)
            end
            if is_playing_anim then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
            -- //fix player clipping through the ground after ending low-positioned anims//
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                    PED.SET_PED_INTO_VEHICLE(ped, veh, 0)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(ped, 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(ped, false)
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                PED.DELETE_PED(npc)
            end
            if is_playing_anim then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
            -- //fix player clipping through the ground after ending low-positioned anims//
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                    PED.SET_PED_INTO_VEHICLE(ped, veh, 0)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
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
                script.run_in_fiber(function()
                    TASK.CLEAR_PED_TASKS(ped)
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    if ENTITY.DOES_ENTITY_EXIST(sexPed) then
                        PED.DELETE_PED(sexPed)
                    end
                end)
            end
            local data = filteredScenarios[scenario_index+1]
            local coords = ENTITY.GET_ENTITY_COORDS(ped, false)
            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local forwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
            local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
            if data.name == "Cook On BBQ" then
                script.run_in_fiber(function()
                    while not STREAMING.HAS_MODEL_LOADED(286252949) do
                        STREAMING.REQUEST_MODEL(286252949)
                        coroutine.yield()
                    end
                    bbq = OBJECT.CREATE_OBJECT(286252949, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true, false)
                    ENTITY.SET_ENTITY_HEADING(bbq, heading)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(bbq)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, data.scenario, -1, true)
                    is_playing_scenario = true
                end)
            else
                script.run_in_fiber(function()
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, data.scenario, -1, true)
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
                    TASK.CLEAR_PED_TASKS(ped)
                    is_playing_scenario = false
                    script:sleep(1000)
                    HUD.BUSYSPINNER_OFF()
                    if ENTITY.DOES_ENTITY_EXIST(bbq) then
                        ENTITY.DELETE_ENTITY(bbq)
                    end
                end)
            end
        end
        widgetToolTip(false, "TIP: You can also stop scenarios by pressing [Delete] on keyboard or [X] on controller.")
        ImGui.Separator()
        ImGui.Text("Play Scenarios On NPCs:")
        ImGui.SameLine()
        coloredText("[Work In Progress]", {247, 185, 104, 0.78})
        ImGui.PushItemWidth(200)
        displayNpcs()
        ImGui.PopItemWidth()
        ImGui.SameLine()
        local npcData = filteredNpcs[npc_index + 1]
        if ImGui.Button("Spawn") then
            local pedCoords = ENTITY.GET_ENTITY_COORDS(ped, false)
            local pedHeading = ENTITY.GET_ENTITY_HEADING(ped)
            local pedForwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
            local pedForwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
                script.run_in_fiber(function(script)
                while not STREAMING.HAS_MODEL_LOADED(npcData.hash) do
                    STREAMING.REQUEST_MODEL(npcData.hash)
                    coroutine.yield()
                end
                npc = PED.CREATE_PED(npcData.group, npcData.hash, 0.0, 0.0, 0.0, 0.0, true, false)
                ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(npc, pedCoords.x + pedForwardX * 1.4, pedCoords.y + pedForwardY * 1.4, pedCoords.z, true, false, false)
                ENTITY.SET_ENTITY_HEADING(npc, pedHeading - 180)
                table.insert(spawned_npcs, npc)
                npcNetID2 = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(npc)
                RequestControl(npc, npcNetID2, 250)
                entToNet(npc, npcNetID2)
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true) --keeps them from acting like pussies and running away.
                -- TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true) --complements the previous native but in this case it stops them from following the player.
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Delete") then
            script.run_in_fiber(function()
                if ENTITY.DOES_ENTITY_EXIST(npc) then
                    PED.DELETE_PED(npc)
                end
                for k, v in ipairs(spawned_npcs) do
                    table.remove(spawned_npcs, k)
                    ENTITY.DELETE_ENTITY(v) -- useless
                end
            end)
        end
        if ImGui.Button(" Play On NPC ") then
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                if is_playing_anim then
                    script.run_in_fiber(function()
                        TASK.CLEAR_PED_TASKS(npc)
                        ENTITY.DELETE_ENTITY(prop1)
                        ENTITY.DELETE_ENTITY(prop2)
                        GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                        if ENTITY.DOES_ENTITY_EXIST(sexPed) then
                            PED.DELETE_PED(sexPed)
                        end
                    end)
                end
                local data = filteredScenarios[scenario_index+1]
                local npcCoords = ENTITY.GET_ENTITY_COORDS(npc, false)
                local npcHeading = ENTITY.GET_ENTITY_HEADING(npc)
                local npcForwardX = ENTITY.GET_ENTITY_FORWARD_X(npc)
                local npcForwardY = ENTITY.GET_ENTITY_FORWARD_Y(npc)
                if data.name == "Cook On BBQ" then
                    script.run_in_fiber(function()
                        while not STREAMING.HAS_MODEL_LOADED(286252949) do
                            STREAMING.REQUEST_MODEL(286252949)
                            coroutine.yield()
                        end
                        bbq = OBJECT.CREATE_OBJECT(286252949, npcCoords.x + (npcForwardX), npcCoords.y + (npcForwardY), npcCoords.z, true, true, false)
                        ENTITY.SET_ENTITY_HEADING(bbq, npcHeading)
                        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(bbq)
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                        TASK.TASK_START_SCENARIO_IN_PLACE(npc, data.scenario, -1, true)
                        is_playing_scenario = true
                    end)
                else
                    script.run_in_fiber(function()
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                        TASK.TASK_START_SCENARIO_IN_PLACE(npc, data.scenario, -1, true)
                        is_playing_scenario = true
                        if ENTITY.DOES_ENTITY_EXIST(bbq) then
                            ENTITY.DELETE_ENTITY(bbq)
                        end
                    end)
                end
            else
                gui.show_error("YimActions", "Spawn an NPC first!")
            end
        end
        ImGui.SameLine()
        if ImGui.Button("  Stop   ") then
            if is_playing_scenario then
                script.run_in_fiber(function(script)
                    busyspinner("Stopping scenario...", 3)
                        TASK.CLEAR_PED_TASKS(npc)
                        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
                        is_playing_scenario = false
                        script:sleep(1000)
                        HUD.BUSYSPINNER_OFF()
                    if ENTITY.DOES_ENTITY_EXIST(bbq) then
                        ENTITY.DELETE_ENTITY(bbq)
                    end
                end)
            end
        end
        event.register_handler(menu_event.ScriptsReloaded, function()
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                PED.DELETE_PED(npc)
            end
            if is_playing_scenario then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                is_playing_scenario = false
                if ENTITY.DOES_ENTITY_EXIST(bbq) then
                    ENTITY.DELETE_ENTITY(bbq)
                end
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            if ENTITY.DOES_ENTITY_EXIST(npc) then
                PED.DELETE_PED(npc)
            end
            if is_playing_scenario then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(npc)
                is_playing_scenario = false
                if ENTITY.DOES_ENTITY_EXIST(bbq) then
                    ENTITY.DELETE_ENTITY(bbq)
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
        disableTooltips, used = ImGui.Checkbox("Disable Tooltips", disableTooltips, true)
        if used then
        saveToConfig("disableTooltips", disableTooltips)
        end
        widgetToolTip(false, "Well, it disables this thing.")
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        if Button("Reset Settings", {142, 0, 0, 1}, {142, 0, 0, 0.7}, {142, 0, 0, 0.5}) then
            ImGui.OpenPopup("##Progress Bar")
        end
        ImGui.SetNextWindowBgAlpha(0)
        if ImGui.BeginPopupModal("##Progress Bar", ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoScrollWithMouse | ImGuiWindowFlags.AlwaysAutoResize) then
                displayProgressBar()
                resetConfig(default_config)
                resetCheckBoxes()
                if x == 1 then
                    counter = counter + 1
                    if counter > 150 then
                        ImGui.CloseCurrentPopup()
                        counter = 0
                        x = 0
                    else return
                    end
                end
            ImGui.EndPopup()
        end
        phoneAnim, used = ImGui.Checkbox("Enable Phone Animations", phoneAnim, true)
        if used then
            saveToConfig("phoneAnim", phoneAnim)
        end
        helpmarker(false, "Restores the disabled phone animations from Single Player.")
        ImGui.SameLine()
        if ImGui.SmallButton("Dummy") then
            gui.show_message("Bruh!", "Stop pressing dummy buttons.")
        end
        if phoneAnim then
            if is_online then
                if not ENTITY.IS_ENTITY_DEAD(ped) then
                    PED.SET_PED_CONFIG_FLAG(ped, 242, false)
                    PED.SET_PED_CONFIG_FLAG(ped, 243, false)
                    PED.SET_PED_CONFIG_FLAG(ped, 244, false)
                else
                    PED.SET_PED_CONFIG_FLAG(ped, 242, true)
                    PED.SET_PED_CONFIG_FLAG(ped, 243, true)
                    PED.SET_PED_CONFIG_FLAG(ped, 244, true)
                end
            end
        end
        ImGui.EndTabItem()
    else
        searchBar = true
    end
end)
script.register_looped("scenario hotkey", function(hotkey)
    hotkey:yield()
    if is_playing_scenario then
        if PAD.IS_CONTROL_PRESSED(0, 256) then
            script.run_in_fiber(function(script)
                busyspinner("Stopping scenario...", 3)
                TASK.CLEAR_PED_TASKS(ped)
                TASK.CLEAR_PED_TASKS(npc)
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, ped, 1.5, 1.5, 0, 10, -1, 1, true)
                script:sleep(1000)
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
