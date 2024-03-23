---@diagnostic disable: undefined-global, lowercase-global
YimActions = gui.get_tab("YimActions")
require ("animdata")
local anim_index = 0
local scenario_index = 0
local switch = 0
local filteredAnims = {}
local filteredScenarios = {}
local spawned_props = {}
local searchQuery = ""
local is_typing = false
is_playing_anim = false
is_playing_scenario = false
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
        script:sleep(20)
        rod = false
        if PED.IS_PED_RAGDOLL(ped) then
            script:sleep(5000)
            return
        end
        PED.SET_PED_RAGDOLL_ON_COLLISION(ped, true)
    elseif rod then
        script:sleep(20)
        clumsy = false
        if PAD.IS_CONTROL_PRESSED(0, 252) then
            PED.SET_PED_TO_RAGDOLL(ped, 1500, 2000, 0, false)
        end
    end
end)
script.register_looped("animation hotkey", function(script)
    script:yield()
    if is_playing_anim then
        if PAD.IS_CONTROL_PRESSED(0, 256) then
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                cleanup()
                is_playing_anim = false
            else
                cleanup()
                is_playing_anim = false
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
            end
        end
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
local function Button(text, color, hovercolor, activecolor)
    ImGui.PushStyleColor(ImGuiCol.Button, color[1], color[2], color[3], color[4])
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, hovercolor[1], hovercolor[2], hovercolor[3], hovercolor[4])
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, activecolor[1], activecolor[2], activecolor[3], activecolor[4])
    local retval = ImGui.Button(text)
    ImGui.PopStyleColor()
    return retval
end
local function busyspinner(text, type)
    HUD.BEGIN_TEXT_COMMAND_BUSYSPINNER_ON("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
    HUD.END_TEXT_COMMAND_BUSYSPINNER_ON(type)
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
local function helpmarker(text)
    ImGui.SameLine()
    ImGui.TextDisabled("(?)")
    if ImGui.IsItemHovered() then
        ImGui.SetNextWindowBgAlpha(0.75)
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
        ImGui.TextWrapped(text)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
	end
end
local function widgetToolTip(text)
    if ImGui.IsItemHovered() then
        ImGui.SetNextWindowBgAlpha(0.75)
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
        ImGui.TextWrapped(text)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
	end
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
YimActions:add_imgui(function()
    ImGui.Text("Search:")
    searchQuery, used = ImGui.InputText("", searchQuery, 32)
    if ImGui.IsItemActive() then
        is_typing = true
    else
        is_typing = false
    end
    ImGui.BeginTabBar("YimActions", ImGuiTabBarFlags.None)
    if ImGui.BeginTabItem("Animations") then
        ImGui.PushItemWidth(350)
        displayFilteredAnims()
        ImGui.Separator()
        manualFlags, used = ImGui.Checkbox("Edit Animation Flags", manualFlags, true)
        helpmarker("Allows you to customize how the animation plays.\nExample: if an animation is set to loop but you want it to freeze, activate this then choose your desired settings.")
        if manualFlags then
            ImGui.Separator()
            controllable, used = ImGui.Checkbox("Allow Control", controllable, true)
            helpmarker("Allows you to keep control of your character and/or vehicle. If paired with 'Upper Body Only', you can play animations and walk/run/drive around.")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            looped, used = ImGui.Checkbox("Loop", looped, true)
            helpmarker("Plays the animation forever until you manually stop it.")
            upperbody, used = ImGui.Checkbox("Upper Body Only", upperbody, true)
            helpmarker("Only plays the animation on you character's upperbody (from the waist up).")
            ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
            freeze, used = ImGui.Checkbox("Freeze", freeze, true)
            helpmarker("Freezes the animation at the very last frame. Useful for ragdoll/sleeping/dead animations.")
        end
        info = filteredAnims[anim_index + 1]
        function cleanup()
            script.run_in_fiber(function()
                TASK.CLEAR_PED_TASKS(ped)
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
            end)
        end
        if ImGui.Button("   Play    ") then
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
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, true)
                    table.insert(spawned_props, prop1)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
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
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, coords.x + forwardX /1.7, coords.y + forwardY /1.7, coords.z, true, true, false)
                    table.insert(spawned_props, prop1)
                    ENTITY.SET_ENTITY_HEADING(prop1, heading + info.rotz)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
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
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                    table.insert(spawned_props, prop1)
                    ENTITY.SET_ENTITY_COORDS(prop1, bonecoords.x + info.posx, bonecoords.y + info.posy, bonecoords.z + info.posz)
                    type4:sleep(20)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    ENTITY.SET_ENTITY_COLLISION(prop1, info.propColl, info.propColl)
                    is_playing_anim = true
                end)
            elseif info.type == 5 then
                cleanup()
                script.run_in_fiber(function(type5)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                    table.insert(spawned_props, prop1)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    type5:sleep(50)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                    GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                    loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(info.ptfxname, prop1, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, info.ptfxrotx, info.ptfxroty, info.ptfxrotz, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    type5:sleep(50)
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                    is_playing_anim = true
                end)
            elseif info.type == 6 then
                    cleanup()
                    script.run_in_fiber(function()
                        while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                            STREAMING.REQUEST_MODEL(info.prop1)
                            coroutine.yield()
                        end
                        prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                        table.insert(spawned_props, prop1)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                        while not STREAMING.HAS_MODEL_LOADED(info.prop2) do
                            STREAMING.REQUEST_MODEL(info.prop2)
                            coroutine.yield()
                        end
                        prop2 = OBJECT.CREATE_OBJECT(info.prop2, 0.0, 0.0, 0.0, true, true, false)
                        table.insert(spawned_props, prop2)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(prop2, ped, PED.GET_PED_BONE_INDEX(ped, info.bone2), info.posx2, info.posy2, info.posz2, info.rotx2, info.roty2, info.rotz2, false, false, false, false, 2, true, 1)
                        while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                            STREAMING.REQUEST_ANIM_DICT(info.dict)
                            coroutine.yield()
                        end
                        TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 1.0, false, false, false)
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
        if ImGui.Button("   Stop    ") then
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                cleanup()
                is_playing_anim = false
            else
                cleanup()
                is_playing_anim = false
                local current_coords = ENTITY.GET_ENTITY_COORDS(ped)   
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
            end
        end
        widgetToolTip("TIP: You can also stop animations by pressing [Delete] on keyboard or [X] on controller.")
        ImGui.SameLine()
        if Button("Force Detach Props", {1, 0, 0, 1}, {1, 0, 0, 0.7}, {1, 0, 0, 0.5}) then
            for k, v in ipairs(spawned_props) do
                if is_playing_anim then
                    script.run_in_fiber(function()
                        if ENTITY.DOES_ENTITY_EXIST(v) then
                            ENTITY.DETACH_ENTITY(v)
                            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(v)
                            TASK.CLEAR_PED_TASKS(ped)
                            is_playing_anim = false
                            table.remove(spawned_props, k)
                        end
                    end)
                end
            end
        end
        widgetToolTip("Some props may become stuck if the animation gets unexpectedly interrupted. Use this button to get rid of them.")
        event.register_handler(menu_event.ScriptsReloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(ped, 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(ped, false)
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
                    PED.SET_PED_COORDS_KEEP_VEHICLE(ped, current_coords.x, current_coords.y, current_coords.z)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            PED.RESET_PED_MOVEMENT_CLIPSET(ped, 0.0)
            PED.SET_PED_RAGDOLL_ON_COLLISION(ped, false)
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
                    PED.SET_PED_COORDS_KEEP_VEHICLE(ped, current_coords.x, current_coords.y, current_coords.z)
                else
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
                end
                is_playing_anim = false
            end
        end)
        ImGui.Separator()
        ImGui.Text("Ragdoll Options:")
        ImGui.Spacing()
        clumsy, used = ImGui.Checkbox("Clumsy", clumsy, true)
        helpmarker("Makes You Ragdoll When You Collide With Any Object.\n(Doesn't work with Ragdoll On Demand)")
        ImGui.SameLine()
        rod, used = ImGui.Checkbox("Ragdoll On Demand", rod, true)
        helpmarker("Press [X] On Keyboard or [LT] On Controller To Instantly Ragdoll. The Longer You Hold The Button, The Longer You Stay On The Ground.\n(Doesn't work with Clumsy)")
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
        widgetToolTip("Works Great With Ragdoll Options.")
        if isChanged then setdrunk() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Hoe", switch, 2)
        if isChanged then sethoe() end
        switch, isChanged = ImGui.RadioButton("Crouch", switch, 3)
        widgetToolTip("You can pair this with the default stealth action [LEFT CTRL].")
        if isChanged then setcrouched() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Lester", switch, 4)
        if isChanged then setlester() end
        ImGui.SameLine()
        switch, isChanged = ImGui.RadioButton("Heavy", switch, 5)
        if isChanged then setballistic() end
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
            scenario_index, used = ImGui.ListBox(" ", scenario_index, scenarioNames, #filteredScenarios)
        end
        displayFilteredScenarios()
        ImGui.Separator()
        if ImGui.Button("   Play    ") then
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
                script.run_in_fiber(function(script)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(ped, data.scenario, -1, true)
                    is_playing_scenario = true
                end)
            end
        end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() 
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        if ImGui.Button("   Stop    ") then
            if is_playing_scenario then
                script.run_in_fiber(function(script)
                    busyspinner("Stopping scenario...", 3)
                    ENTITY.DELETE_ENTITY(bbq)
                    TASK.CLEAR_PED_TASKS(ped)
                    is_playing_scenario = false
                    script:sleep(2000)
                    HUD.BUSYSPINNER_OFF()
                end)
            end
        end
        widgetToolTip("TIP: You can also stop scenarios by pressing [Delete] on keyboard or [X] on controller.")
        event.register_handler(menu_event.ScriptsReloaded, function()
            if is_playing_scenario then
                ENTITY.DELETE_ENTITY(bbq)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                is_playing_scenario = false
            end
        end)
        event.register_handler(menu_event.MenuUnloaded, function()
            if is_playing_scenario then
                ENTITY.DELETE_ENTITY(bbq)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                is_playing_scenario = false
            end
        end)
        ImGui.EndTabItem()
    end
end)
script.register_looped("scenario hotkey", function(hotkey)
    hotkey:yield()
    if is_playing_scenario then
        if PAD.IS_CONTROL_PRESSED(0, 256) then
            script.run_in_fiber(function(script)
                busyspinner("Stopping scenario...", 3)
                ENTITY.DELETE_ENTITY(bbq)
                TASK.CLEAR_PED_TASKS(ped)
                is_playing_scenario = false
                script:sleep(2000)
                HUD.BUSYSPINNER_OFF()
            end)
        end
    end
end)