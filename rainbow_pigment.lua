local defaultColors = {
    {1.0,0.0,0.0},
    {1.0,1.0,0.0},
    {0.0,1.0,0.0},
    {0.0,1.0,1.0},
    {0.0,0.0,1.0},
    {1.0,0.0,1.0}
}

local colors = defaultColors

local helm1 = false
local helm2 = false
local body1 = false
local body2 = false
local arms1 = false
local arms2 = false
local waist1 = false
local waist2 = false
local legs1 = false
local legs2 = false

local speed = 1

local speedMod = 1.0

local function SetSpeed()
    print(speed)
    if speed == 2 then
        speedMod = 2.0
    elseif speed == 3 then
        speedMod = 0.5
    elseif speed == 4 then
        speedMod = 4.0
    else
        speedMod = 1.0
    end
end

local function SaveConfig()
    config = {}
    config["colors"] = colors
    config["armorSave"] = {}
    config["armorSave"]["helm1"] = helm1
    config["armorSave"]["helm2"] = helm2
    config["armorSave"]["body1"] = body1
    config["armorSave"]["body2"] = body2
    config["armorSave"]["arms1"] = arms1
    config["armorSave"]["arms2"] = arms2
    config["armorSave"]["waist1"] = waist1
    config["armorSave"]["waist2"] = waist2
    config["armorSave"]["legs1"] = legs1
    config["armorSave"]["legs2"] = legs2
    config["speed"] = speed
    if not json.dump_file("rainbow_pigment.json", config, 4) then
        print("Config cannot be saved!")
    end
end

local function ReadConfig()
    config = json.load_file("rainbow_pigment.json")
    if config ~= nil then
        colors = config["colors"]
        if colors == nil then
            colors = defaultColors
        end
        helm1 = config["armorSave"]["helm1"]
        helm2 = config["armorSave"]["helm2"]
        body1 = config["armorSave"]["body1"]
        body2 = config["armorSave"]["body2"]
        arms1 = config["armorSave"]["arms1"]
        arms2 = config["armorSave"]["arms2"]
        waist1 = config["armorSave"]["waist1"]
        waist2 = config["armorSave"]["waist2"]
        legs1 = config["armorSave"]["legs1"]
        legs2 = config["armorSave"]["legs2"]
        speed = config["speed"]
        SetSpeed()
    else
        SaveConfig()
    end

end

local timeLength = 600.0
    
local currentTime = 0.0

local float4 = sdk.find_type_definition("via.Float4")

local function Lerp(start_value, end_value, pct)

    return (start_value + (end_value - start_value) * pct);
end

local function round100(num)
	return math.floor(num / 100) * 100
end

local function get_localplayer()

end

local function setColor(color, index, isColor1)
    local playman = sdk.get_managed_singleton("snow.player.PlayerManager")

    if not playman then
        print("playman fail")
        return nil
    end

    local player = playman:call("findMasterPlayer")
    --player = snow.player.PlayerBase
    if not player then
        print("Player fail")
        return nil
    end
    if not player then
        print("Player fail")
        return nil
    end

    local matctrl = player:get_field("_RefPlayerMaterialCtrl")

    if not matctrl then
        print("matctrl fail")
        return nil
    end

    local part = matctrl:call("getPartsMaterial",index)

    if part == nil then 
        part = matctrl:call("getPartsMaterial",index)
    end

    if part == nil then
        return nil
    end
    part:call("setSymbolColor", isColor1, Vector4f.new(color[1],color[2],color[3],1.0))
end

local function get_currentColor()
    local application = sdk.get_native_singleton("via.Application")

    if not application then
        return nil
    end
    local app_type = sdk.find_type_definition("via.Application")
    local deltaTime = sdk.call_native_func(application, app_type, "get_DeltaTime")
    --print("DeltaTime")
    --print(deltaTime)
    --print("WithMod")
    --print(deltaTime * speedMod)
    currentTime = currentTime + (deltaTime * speedMod)
    if currentTime > timeLength then
        currentTime = currentTime - timeLength
    end
    local index = (round100(currentTime) / 100) + 1
    local nextIndex = index + 1
    if nextIndex > 6.0 then
        nextIndex = 1.0
    end
    local factor = ((currentTime / 100) % 1)
    return {
        Lerp(colors[index][1],colors[nextIndex][1],factor),
        Lerp(colors[index][2],colors[nextIndex][2],factor),
        Lerp(colors[index][3],colors[nextIndex][3],factor)
    }

end

ReadConfig()

re.on_pre_application_entry("UpdateBehavior", function() 
    local color = get_currentColor()
    if helm1 then
        setColor(color,4,true)
    end
    if helm2 then
        setColor(color,4,false)
    end
    if body1 then
        setColor(color,0,true)
    end
    if body2 then
        setColor(color,0,false)
    end
    if arms1 then
        setColor(color,1,true)
    end
    if arms2 then
        setColor(color,1,false)
    end
    if waist1 then
        setColor(color,2,true)
    end
    if waist2 then
        setColor(color,2,false)
    end
    if legs1 then
        setColor(color,3,true)
    end
    if legs2 then
        setColor(color,3,false)
    end
end)



re.on_draw_ui(function()
    -- Obtain the FigureManager singleton.

    if imgui.tree_node("Rainbow Pigment") then
        -- Get the current figure/model being displayed.
        imgui.push_id(0)
        if imgui.button("Refresh Config") then
            ReadConfig()
        end
        
        local changed, newSpeed = imgui.combo("Speed", speed, {"Default", "Double", "Half", "4x"})
        if changed then
            speed = newSpeed
            SetSpeed()
        end
        if imgui.checkbox("Helm Color 1", helm1) then
            helm1 = not helm1
        end
        if imgui.checkbox("Helm Color 2", helm2) then
            helm2 = not helm2
        end
        if imgui.checkbox("Body Color 1", body1) then
            body1 = not body1
        end
        if imgui.checkbox("Body Color 2", body2) then
            body2 = not body2
        end
        if imgui.checkbox("Arms Color 1", arms1) then
            arms1 = not arms1
        end
        if imgui.checkbox("Arms Color 2", arms2) then
            arms2 = not arms2
        end
        if imgui.checkbox("Waist Color 1", waist1) then
            waist1 = not waist1
        end
        if imgui.checkbox("Waist Color 2", waist2) then
            waist2 = not waist2
        end
        if imgui.checkbox("Legs Color 1", legs1) then
            legs1 = not legs1
        end
        if imgui.checkbox("Legs Color 2", legs2) then
            legs2 = not legs2
        end
        imgui.tree_pop()
    end
end)

re.on_config_save(function()
    SaveConfig()
end)