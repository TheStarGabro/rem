loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")

print(RemoteSpy.CurrentRemotes)

janitor:Add(
    RemoteSpy.Remote.Event:Connect(function(...)
        print(...)
    end)
)