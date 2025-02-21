--loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/main.lua"))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/TheStarGabro/rem/main/init.lua"))()

print("Initiated")

local RemoteSpy = import("modules/RemoteSpy")

local blacklist = {
    "UpdateCharacterState" = true
}

janitor:Add(
    RemoteSpy.Remote.Event:Connect(function(remote,call)
        if not blacklist[remote.Name] then
            print(remote:GetFullName())
        end
    end)
)