--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")
local Signal = import("constructors/Signal")

local OnEventMulti = Signal.newChanged()

janitor:Add(
    RemoteSpy.Signal:Connect(function(instance,info)
        if instance == game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded then
            print("zoneloaded from signal")
        end
        
        OnEventMulti:TryFire(instance)
    end),

    OnEventMulti(game.ReplicatedStorage.Knit.Services.ZoneService.RE.ZoneLoaded):Connect(function()
        print("zoneloaded")
    end)
)

