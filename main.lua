--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")
local Signal = import("constructors/Signal")
local CollectCurrencies = import("modules/CollectCurrencies")

local OnEventMulti = Signal.newChanged()

janitor:Add(
    RemoteSpy.Signal:Connect(function(instance,info)
        OnEventMulti:TryFire(instance,info)
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded):Connect(function(info)
        CollectCurrencies:Start()
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency):Connect(function(info)
        print("World")
        for i,v in info do
            print(i,v)
        end
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupUniqueWorldCurrency):Connect(function(info)
        print("Unique")
        for i,v in info do
            print(i,v)
        end
    end)
)

CollectCurrencies:Start()