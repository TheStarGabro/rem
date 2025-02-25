--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

print("Main: "..tostring(os.clock()))

local hydroxideImport = import
local import = rem.import
local janitor = rem.janitor

local RemoteSpy = import("modules/RemoteSpy")
local Signal = import("constructors/Signal")
local Collect = import("modules/Collect")
local Buttons = import("modules/Buttons")

import("Menu/Output")
import("Menu/Remotes")

----------------------------------------------------------------

local Zone
local OnEventMulti = Signal.newChanged()

-- Create buttons
local currency_button = Buttons:Create():Text("Currency"):Image("rbxthumb://type=BadgeIcon&id=1701184002070847&w=150&h=150"):Popup("Automatically collect currency/destructible/entity")
currency_button.Frame.MouseButton1Click:Connect(function()
    currency_button:Toggle()
    
    if currency_button.state then
        Collect:Start()
    else
        Collect:Stop() 
    end
end)

local grind_button = Buttons:Create():Text("Grind"):Image("rbxthumb://type=BadgeIcon&id=151504819763412&w=150&h=150"):Popup("Always grind")
grind_button.Frame.MouseButton1Click:Connect(function()
    grind_button:Toggle()

    if grind_button.task then
        task.cancel(grind_button.task)
    end

    if grind_button.state then
        local task = task.spawn(function()
            while task.wait(0.1) do
                game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress:FireServer(
                    "RailGrindPoints",
                    4,
                    {ZoneName = Zone}
                )
            end
        end)
        grind_button.task = task
        janitor:Add(task)
    end
end)

local wisp_button = Buttons:Create():Text("Wisp"):Image("rbxthumb://type=BadgeIcon&id=168551842&w=150&h=150"):Popup("+5 Wisp"):Toggle(true)
wisp_button.Frame.MouseButton1Click:Connect(function()
    game.ReplicatedStorage.Knit.Services.MapStateService.RE.OnStateAction:FireServer("AddEventCurrency","Whisper",5,true)
end)

local hydroxide_button = Buttons:Create():Text("Hydroxide"):Image(""):Popup("Toggle Hydroxide")
hydroxide_button.Frame.MouseButton1Click:Connect(function()
    hydroxide_button:Toggle()

    if hydroxide_button.state then
        if not hydroxide_button.active then
            hydroxide_button.active = true
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/Hydroxide/init.lua"))()
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/Hydroxide/ui/main.lua"))()
        end
    end

    local ui = hydroxideImport("ui/main")
    ui.Enabled = hydroxide_button.state
end)

-- Set default zone
for i,v in game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry:InvokeServer() do
    Zone = v.ZoneName
end

----------------------------------------------------------------

janitor:Add(
    RemoteSpy.Signal:Connect(function(instance,info)
        OnEventMulti:TryFire(instance,info)
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded):Connect(function(info)
        Zone = info.args[1]
        if currency_button.state then
            Collect:Start()
        end
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency):Connect(function(info)
        --print("World")
        for i,v in info do
            --print(i,v)
        end
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupUniqueWorldCurrency):Connect(function(info)
        --print("Unique")
        for i,v in info do
            --print(i,v)
        end
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress):Connect(function(info)
        local args = info.args

        if args[1] == "RailGrindPoints" then
            for i,v in args[3] do
                --print(i,v)
            end
        end
    end)
)

--[[
janitor:Add(task.spawn(function()
    while task.wait(0.1) do
        game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress:FireServer(
            "RailGrindPoints",
            4,
            {ZoneName = Zone}
        )
    end
end))]]

--Collect:Start()