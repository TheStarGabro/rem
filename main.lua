print("a")
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()
print("b")
local RemoteSpy = import("modules/RemoteSpy")

RemoteSpy.Remote.Event:Connect(function(...)
    print(...)
end)