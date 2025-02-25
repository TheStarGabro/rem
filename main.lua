--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

print("Main: "..tostring(os.clock()))

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

local function effectButton(button,onfunc,offfunc)
    return function()
        button:Toggle()

        if button.task then
            task.cancel(button.task)
            button.task = nil
        end
    
        local func
        if button.state then
            if onfunc then func = onfunc end
        else
            if offfunc then func = offfunc end
        end
    
        if func then
            local task = task.spawn(func)
    
            button.task = task
            janitor:Add(task)
        end
    end
end

local grind_button = Buttons:Create():Text("Grind"):Image("rbxthumb://type=BadgeIcon&id=151504819763412&w=150&h=150"):Popup("Always grind")
grind_button.Frame.MouseButton1Click:Connect(effectButton(grind_button,function()
    while task.wait(0.1) do
        game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress:FireServer(
            "RailGrindPoints",
            4,
            {ZoneName = Zone}
        )
    end
end))

local hoverboard_button = Buttons:Create():Text("Hoverboard"):Image("rbxthumb://type=BadgeIcon&id=2126304284&w=150&h=150"):Popup("Trick & Boost"):Toggle(true)
hoverboard_button.Frame.MouseButton1Click:Connect(effectButton(hoverboard_button,function()
    while task.wait(0.1) do
        game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress:FireServer(
            "HoverboardBoostAmount",
            1,
            {ZoneName = Zone}
        )

        game.ReplicatedStorage.Knit.Services.ProgressService.RE.ClientLogProgress:FireServer(
            "HoverboardTrickAmount",
            1,
            {ZoneName = Zone}
        )
    end
end))

local run_button = Buttons:Create():Text("Run"):Image("rbxthumb://type=BadgeIcon&id=2126202654&w=150&h=150"):Popup("Run"):Toggle(true)
run_button.Frame.MouseButton1Click:Connect(effectButton(run_button,function()
    while task.wait(0.1) do
        game.ReplicatedStorage.Knit.Services.CharacterService.RE.UpdateCharacterState:FireServer(
            {
                IsRunning = true,
                CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,10)
            }
        )
    end
end))

local wisp_button = Buttons:Create():Text("Wisp"):Image("rbxassetid://168551841"):Popup("+5 Wisp"):Toggle(true)
wisp_button.Frame.MouseButton1Click:Connect(function()
    game.ReplicatedStorage.Knit.Services.MapStateService.RE.OnStateAction:FireServer("AddEventCurrency","Whisper",5,true)
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

local flashscreen = Instance.new("ScreenGui")
flashscreen.Parent = game.Players.LocalPlayer.PlayerGui

local flash = Instance.new("TextLabel")
flash.Text = "MAIN LOADED"
flash.TextScaled = true
flash.TextColor3 = Color3.new(1,1,1)
flash.Size = UDim2.fromScale(1,1)
flash.Parent = flashscreen
task.wait(0.2)
flashscreen:Destroy()

print("Main Loaded")
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