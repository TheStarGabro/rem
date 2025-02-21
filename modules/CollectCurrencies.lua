local CollectCurrencies = {}

local DELAY = 1

local RunService = game:GetService("RunService")

local GetRegistry = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry
local PickupWorldCurrency = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency

local collectThread

function CollectCurrencies:CollectAllNormal()
    for i,currency in pairs(GetRegistry:InvokeServer()) do
        PickupWorldCurrency:FireServer(currency.GUID)
    end
end

function CollectCurrencies:Start()
    CollectCurrencies:Stop()

    local registry = GetRegistry:InvokeServer()
    
    collectThread = task.spawn(function()
        while task.wait(DELAY) do
            for _,currency in registry do
                PickupWorldCurrency:FireServer(currency.GUID)
            end
        end
    end)
end

function CollectCurrencies:Stop()
    if collectThread then
        task.cancel(collectThread)
    end
end

return CollectCurrencies