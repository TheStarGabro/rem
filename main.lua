--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initialized")

local import = rem.import
local print = import("modules/Output").print

local RemoteSpy = import("modules/RemoteSpy")
local Signal = import("constructors/Signal")
local Collect = import("modules/Collect")

local OnEventMulti = Signal.newChanged()

local Zone

janitor:Add(
    RemoteSpy.Signal:Connect(function(instance,info)
        OnEventMulti:TryFire(instance,info)
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded):Connect(function(info)
        Zone = info.args[1]
        --Collect:Start()
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
                print(i,v)
            end
        end
    end)
)

-- Set default zone
for i,v in game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry:InvokeServer() do
    Zone = v.ZoneName
end

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