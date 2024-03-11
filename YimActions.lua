---@diagnostic disable: undefined-global, lowercase-global

YimActions = gui.get_tab("YimActions")

anim_player = YimActions:add_tab("SAMURAI's Animations")

scenario_player = YimActions:add_tab("SAMURAI's Scenarios")

local animlist = require ("animdata")

local anim_index = 0

local flag_loop = 0
local flag_freeze = 0
local flag_upperbody = 0
local flag_control = 0

ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())

is_playing_anim = false

anim_player:add_text("Search:")

local searchQuery = ""

local is_typing = false
script.register_looped("", function()
	if is_typing then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
end)

anim_player:add_imgui(function()
    searchQuery, used = ImGui.InputText("", searchQuery, 32)
    if ImGui.IsItemActive() then
		is_typing = true
	else
		is_typing = false
	end
    ImGui.PushItemWidth(350)
end)

local filteredAnims = {}
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

local function displayFilteredList()
    updatefilteredAnims()
    local animNames = {}
    for _, anim in ipairs(filteredAnims) do
        table.insert(animNames, anim.name)
    end
    anim_index, used = ImGui.ListBox(" ", anim_index, animNames, #filteredAnims)
end

anim_player:add_imgui(displayFilteredList)

anim_player:add_separator()

anim_player:add_imgui(function()
    manualFlags, used = ImGui.Checkbox("Edit Animation Flags", manualFlags, true)
    ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Allows you to customize how the animation plays.\n\nExample: if an animation is set to loop but you want it\nto freeze, activate this then choose your desired settings.")
            ImGui.EndTooltip()
        end
    if manualFlags then
        ImGui.Separator()
        controllable, used = ImGui.Checkbox("Allow Control", controllable, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Allows you to keep control of your character and/or vehicle.\nIf paired with 'Upper Body Only', you can play animations\nand walk/run around.")
            ImGui.EndTooltip()
        end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        looped, used = ImGui.Checkbox("Loop", looped, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Plays the animation forever unless\nyou manually stop it.")
            ImGui.EndTooltip()
        end
        upperbody, used = ImGui.Checkbox("Upper Body Only", upperbody, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Only plays the animation on you character's upperbody (from the waist up).")
            ImGui.EndTooltip()
        end
        ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()
        freeze, used = ImGui.Checkbox("Freeze", freeze, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Freezes the animation at the very last frame.\nUsefull for ragdoll or sleeping animations for example.")
            ImGui.EndTooltip()
        end
    end
end)

anim_player:add_separator()

anim_player:add_imgui(function()
    info = filteredAnims[anim_index+1]
    local coords = ENTITY.GET_ENTITY_COORDS(ped, false)
    local heading = ENTITY.GET_ENTITY_HEADING(ped)
    local forwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
    local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
    local boneIndex = PED.GET_PED_BONE_INDEX(ped, info.boneID)
    local bonecoords = PED.GET_PED_BONE_COORDS(ped, info.boneID)

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

        if manualFlags then
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
                prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0, true, true, false)
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
                type2:sleep(info.ptfxdelay)
                GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(info.ptfxname, ped, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, 0.0, 0.0, 0.0, boneIndex, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                is_playing_anim = true
            end)

        elseif info.type == 3 then
            cleanup()
            script.run_in_fiber(function()
                while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                    STREAMING.REQUEST_MODEL(info.prop1)
                    coroutine.yield()
                end
                prop1 = OBJECT.CREATE_OBJECT(info.prop1, coords.x + forwardX /1.7, coords.y + forwardY /1.7, coords.z, true, true, false)
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
                prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0, true, true, false)
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
                prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0, true, true, false)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                type5:sleep(50)
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                    STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                    coroutine.yield()
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(info.ptfxname, prop1, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, 0.0, 0.0, 0.0, info.ptfxscale, false, false, false, 0, 0, 0, 0)
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
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0, true, true, false)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop2) do
                        STREAMING.REQUEST_MODEL(info.prop2)
                        coroutine.yield()
                    end
                    prop2 = OBJECT.CREATE_OBJECT(info.prop2, 0.0, 0.0, 0, true, true, false)
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
            script.run_in_fiber(function(script)
                while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) do
                    STREAMING.REQUEST_ANIM_DICT(info.dict)
                    coroutine.yield()
                end
                TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, flag, 0.0, false, false, false)
                is_playing_anim = true
            end)
        end
    end

    if info.name == "Movement: Crawl Forward" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Use 'A/D' To Turn Right/Left.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Movement: Goofy Walk" or info.name == "Movement: Boss Walk" or info.name == "Movement: Goofy Run" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Walk Or Run After Playing The Animation.")
            ImGui.EndTooltip()
        end
    elseif info.name == "MISC: Sleep" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Stop previous animation before playing this one\nor you will fall through the ground.\n\nUse 'W A S D' To Adjust Your Position.")
            ImGui.EndTooltip()
        end
    elseif info.name == "MISC: Sunbathe" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Use 'W A S D' To Adjust Your Position.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Movement: Crawl Forward (injured)" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Use 'A/D' To Turn Right/Left.\nEquip Your Pistol For Better Results.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Car: Mechanic 02" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Face Away From The Vehicle\nBefore Playing The Animation.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Action: Commit Seppuku (×_×) (pistol)" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Equip Your Pistol For Better Results.")
            ImGui.EndTooltip()
        end
    end

    ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine() ImGui.Spacing() ImGui.SameLine()

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
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.Text("TIP: You can also stop animations by pressing\n'X' on keyboard or 'LT' on controller.")
        ImGui.EndTooltip()
    end

    event.register_handler(menu_event.ScriptsReloaded, function()
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
end)

script.register_looped("animation hotkey", function(script)
    script:yield()
    if is_playing_anim then
        if PAD.IS_CONTROL_PRESSED(0, 252) then
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

local ped_scenarios = {
    {scenario = "WORLD_HUMAN_STAND_MOBILE", name = "Browse Phone"},
    {scenario = "WORLD_HUMAN_CHEERING", name = "Clap"},
    {scenario = "WORLD_HUMAN_CONST_DRILL", name = "Construction: Drill"},
    {scenario = "WORLD_HUMAN_HAMMERING", name = "Construction: Hammer"},
    {scenario = "WORLD_HUMAN_WELDING", name = "Construction: Welding Torch"},
    {scenario = "PROP_HUMAN_BBQ", name = "Cook On BBQ"},
    {scenario = "WORLD_HUMAN_INSPECT_CROUCH", name = "Crouch"},
    {scenario = "WORLD_HUMAN_DRINKING", name = "Drink Beer"},
    {scenario = "WORLD_HUMAN_DRUG_DEALER", name = "Drug Dealer Smoking"},
    {scenario = "WORLD_HUMAN_DRUG_DEALER_HARD", name = "Drug Dealer Tough"},
    {scenario = "PROP_HUMAN_BUM_BIN", name = "Dumpster Dive"},
    {scenario = "WORLD_HUMAN_GARDENER_PLANT", name = "Field Planting"},
    {scenario = "WORLD_HUMAN_DRUG_FIELD_WORKERS_RAKE", name = "Field Raking"},
    {scenario = "WORLD_HUMAN_DRUG_FIELD_WORKERS_WEEDING", name = "Field Weeding"},
    {scenario = "WORLD_HUMAN_MOBILE_FILM_SHOCKING", name = "Film Shocking Event"},
    {scenario = "WORLD_HUMAN_MUSCLE_FLEX", name = "Flex Muscles"},
    {scenario = "WORLD_HUMAN_STAND_FISHING", name = "Go Fishing"},
    {scenario = "WORLD_HUMAN_HANG_OUT_STREET", name = "Hangout (conversate)"},
    {scenario = "WORLD_HUMAN_STRIP_WATCH_STAND", name = "Hangout (dance)"},
    {scenario = "WORLD_HUMAN_BUM_FREEWAY", name = "HOBO Begging"},
    {scenario = "PROP_HUMAN_BUM_SHOPPING_CART", name = "HOBO Leaning"},
    {scenario = "WORLD_HUMAN_BUM_SLUMPED", name = "HOBO Sleeping"},
    {scenario = "WORLD_HUMAN_BUM_STANDING", name = " HOBO Standing"},
    {scenario = "WORLD_HUMAN_BUM_WASH", name = "HOBO Washing"},
    {scenario = "WORLD_HUMAN_CLIPBOARD", name = "Hold Clipboard"},
    {scenario = "WORLD_HUMAN_HUMAN_STATUE", name = "Human Statue"},
    {scenario = "WORLD_HUMAN_INSPECT_STAND", name = "Inspect"},
    {scenario = "WORLD_HUMAN_JANITOR", name = "Janitor"},
    {scenario = "WORLD_HUMAN_JOG", name = "Jog"},
    {scenario = "PROP_HUMAN_SEAT_SUNLOUNGER", name = "Lay On Sunlounger"},
    {scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER", name = "Leaf Blower"},
    {scenario = "WORLD_HUMAN_LEANING", name = "Lean 01"},
    {scenario = "WORLD_HUMAN_LEANING_CASINO_TERRACE", name = "Lean 02"},
    {scenario = "WORLD_HUMAN_TOURIST_MAP", name = "Look At Tourist Map"},
    {scenario = "WORLD_HUMAN_BINOCULARS", name = "Look Through Binoculars"},
    {scenario = "WORLD_HUMAN_MAID_CLEAN", name = "Maid"},
    {scenario = "WORLD_HUMAN_VEHICLE_MECHANIC", name = "Mechanic"},
    {scenario = "WORLD_HUMAN_PAPARAZZI", name = "Paparazzi"},
    {scenario = "WORLD_HUMAN_CAR_PARK_ATTENDANT", name = "Park Attendant"},
    {scenario = "WORLD_HUMAN_PARTYING", name = "Party"},
    {scenario = "PROP_HUMAN_PARKING_METER", name = "Pay For Parking"},
    {scenario = "WORLD_HUMAN_PICNIC", name = "Picnic"},
    {scenario = "WORLD_HUMAN_GOLF_PLAYER", name = "Player: Golf"},
    {scenario = "WORLD_HUMAN_TENNIS_PLAYER", name = "Player: Tennis"},
    {scenario = "WORLD_HUMAN_COP_IDLES", name = "Police: Idle"},
    {scenario = "WORLD_HUMAN_DRUG_PROCESSORS_COKE", name = "Process Cocaine"},
    {scenario = "WORLD_HUMAN_DRUG_PROCESSORS_WEED", name = "Process Weed"},
    {scenario = "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", name = "Prostitute: High-Class"},
    {scenario = "WORLD_HUMAN_PROSTITUTE_LOW_CLASS", name = "Prostitute: Low-Class"},
    {scenario = "WORLD_HUMAN_GUARD_PATROL", name = "Security Guard (check)"},
    {scenario = "WORLD_HUMAN_GUARD_STAND", name = "Security Guard (stand)"},
    {scenario = "WORLD_HUMAN_SECURITY_SHINE_TORCH", name = "Security Guard (torch)"},
    {scenario = "WORLD_HUMAN_SMOKING", name = "Smoke Cigarette"},
    {scenario = "WORLD_HUMAN_SMOKING_POT", name = "Smoke Weed"},
    {scenario = "PROP_HUMAN_SEAT_ARMCHAIR", name = "Sit On Armchair"},
    {scenario = "PROP_HUMAN_SEAT_BAR", name = "Sit On Barstool"},
    {scenario = "PROP_HUMAN_SEAT_BENCH", name = "Sit On Bench"},
    {scenario = "PROP_HUMAN_SEAT_BENCH_DRINK", name = "Sit On Bench/Drink"},
    {scenario = "PROP_HUMAN_SEAT_BENCH_DRINK_BEER", name = "Sit On Bench/Drink Beer"},
    {scenario = "PROP_HUMAN_SEAT_BENCH_FOOD", name = "Sit On Bench/Eat"},
    {scenario = "PROP_HUMAN_SEAT_CHAIR", name = "Sit On Chair"},
    {scenario = "PROP_HUMAN_SEAT_CHAIR_DRINK", name = "Sit On Chair/Drink"},
    {scenario = "PROP_HUMAN_SEAT_CHAIR_DRINK_BEER", name = "Sit On Chair/Drink Beer"},
    {scenario = "PROP_HUMAN_SEAT_CHAIR_FOOD", name = "Sit On Chair/Eat"},
    {scenario = "PROP_HUMAN_SEAT_CHAIR_UPRIGHT", name = "Sit On Chair Upright"},
    {scenario = "PROP_HUMAN_SEAT_DECKCHAIR", name = "Sit On Deckchair"},
    {scenario = "PROP_HUMAN_SEAT_DECKCHAIR_DRINK", name = "Sit On Deckchair/Drink"},
    {scenario = "WORLD_HUMAN_SEAT_LEDGE", name = "Sit On Ledge"},
    {scenario = "WORLD_HUMAN_SEAT_LEDGE_EATING", name = "Sit On Ledge/Eat"},
    {scenario = "WORLD_HUMAN_SEAT_STEPS", name = "Sit On Steps"},
    {scenario = "WORLD_HUMAN_SEAT_WALL", name = "Sit On Wall"},
    {scenario = "WORLD_HUMAN_SEAT_WALL_EATING", name = "Sit On Wall/Eat"},
    {scenario = "WORLD_HUMAN_STAND_IMPATIENT", name = "Stand Impatiently"},
    {scenario = "WORLD_HUMAN_STAND_FIRE", name = "Stand Near Fire"},
    {scenario = "WORLD_HUMAN_MUSICIAN", name = "Street Musician"},
    {scenario = "WORLD_HUMAN_SUNBATHE_BACK", name = "Sunbathe (lay on back)"},
    {scenario = "WORLD_HUMAN_SUNBATHE", name = "Sunbathe (lay on stomach)"},
    {scenario = "WORLD_HUMAN_TOURIST_MOBILE", name = "Take Photo"},
    {scenario = "PROP_HUMAN_ATM", name = "Use ATM"},
    {scenario = "WORLD_HUMAN_VALET", name = "Valet"},
    {scenario = "PROP_HUMAN_SEAT_BUS_STOP_WAIT", name = "Wait At Bus Stop"},
    {scenario = "PROP_HUMAN_SEAT_STRIP_WATCH", name = "Watch Stripper"},
    {scenario = "WORLD_HUMAN_WINDOW_SHOP_BROWSE", name = "Window Shop"},
    {scenario = "PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS", name = "Workout: Bench Press"},
    {scenario = "PROP_HUMAN_MUSCLE_CHIN_UPS", name = "Workout: Chin-ups"},
    {scenario = "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS", name = "Workout: Freeweights"},
    {scenario = "WORLD_HUMAN_PUSH_UPS", name = "Workout: Push-ups"},
    {scenario = "WORLD_HUMAN_SIT_UPS", name = "Workout: Sit-ups"},
    {scenario = "WORLD_HUMAN_YOGA", name = "Workout: Yoga"},
}

local scenario_index = 0

local searchQuery = ""

is_playing_scenario = false

scenario_player:add_text("Search:")

scenario_player:add_imgui(function()
    searchQuery, used = ImGui.InputText("", searchQuery, 32)
    if ImGui.IsItemActive() then
		is_typing = true
	else
		is_typing = false
	end
    ImGui.PushItemWidth(250)
end)

local filteredScenarios = {}
local function updatefilteredScenarios()
    filteredScenarios = {}
    for _, scene in ipairs(ped_scenarios) do
        if string.find(string.lower(scene.name), string.lower(searchQuery)) then
            table.insert(filteredScenarios, scene)
        end
    end
end

local function displayFilteredList()
    updatefilteredScenarios()
    local scenarioNames = {}
    for _, scene in ipairs(filteredScenarios) do
        table.insert(scenarioNames, scene.name)
    end
    scenario_index, used = ImGui.ListBox(" ", scenario_index, scenarioNames, #filteredScenarios)
end

scenario_player:add_imgui(displayFilteredList)

scenario_player:add_separator()

scenario_player:add_imgui(function()
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

    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()
    ImGui.Spacing()
    ImGui.SameLine()

    if ImGui.Button("   Stop    ") then
        script.run_in_fiber(function()
            ENTITY.DELETE_ENTITY(bbq)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(bbq)
			TASK.CLEAR_PED_TASKS(ped)
            is_playing_scenario = false
		end)
    end
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.Text("TIP: You can also stop scenarios by pressing\n'X' on keyboard or 'LT' on controller.")
        ImGui.EndTooltip()
    end

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
end)

script.register_looped("scenario hotkey", function(script)
    script:yield()
    if is_playing_scenario then
        if PAD.IS_CONTROL_PRESSED(0, 252) then
            ENTITY.DELETE_ENTITY(bbq)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            is_playing_scenario = false
        end
    end
end)