loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")

print(RemoteSpy.CurrentRemotes)
for i,v in RemoteSpy.CurrentRemotes do
    print(i,v,v.Name)
end

janitor:Add(
    RemoteSpy.Remote.Event:Connect(function(...)
        print(...)
    end)
)