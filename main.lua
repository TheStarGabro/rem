--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")
local Signal = import("constructors/Signal")
local CollectCurrencies = import("modules/CollectCurrencies")

local OnEventMulti = Signal.newChanged()

janitor:Add(
    RemoteSpy.Signal:Connect(function(instance,info)
        OnEventMulti:TryFire(instance)
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded):Connect(function()
        CollectCurrencies:Start()
    end)
)

CollectCurrencies:Start()