local HasIsolated = false
local function SetTSNClear()
    local chatman = sdk.get_managed_singleton("snow.progress.quest.ProgressQuestManager")

    if not chatman then
        print("chatman fail")
        return nil
    end

    chatman:setClear(10702,true)
    print(chatman:isClear(10702))
end

local function SaveIsolation()
    local saveService = sdk.get_native_singleton("via.storage.saveService.SaveService")
    if not saveService then
        print("saveservice fail")
        return nil
    end
    local app_type = sdk.find_type_definition("via.storage.saveService.SaveService")
    local currentSavePath = sdk.call_native_func(saveService, app_type, "get_SaveMountPath")
    sdk.call_native_func(saveService, app_type, "set_SaveMountPath",currentSavePath .. "_ap")
    HasIsolated = true
end

SaveIsolation()

re.on_pre_application_entry("UpdateBehavior", function() 
    --main loop access, update timers in here
    if not HasIsolated then
        SaveIsolation()
    end
end)

re.on_draw_ui(function()
    -- Obtain the FigureManager singleton.

    if imgui.tree_node("Save Tests") then
        -- Get the current figure/model being displayed.
        imgui.push_id(0)
        if imgui.button("Clear Narwa") then
            SetTSNClear()
        end
    end
end)