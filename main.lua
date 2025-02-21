print("a")
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()
print("b")
local RemoteSpy = import("RemoteSpy")

RemoteSpy.Remote:Connect(function(...)
    print(...)
end)