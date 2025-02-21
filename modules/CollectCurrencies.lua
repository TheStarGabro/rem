local CollectCurrencies = {}

local DELAY = 1

local RunService = game:GetService("RunService")

local GetRegistry = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry
local PickupWorldCurrency = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency

local collectThread
local registry

-- PickupWorldCurrency
-- PickupUniqueWorldCurrency

function CollectCurrencies:CollectAll()
    registry = registry or GetRegistry:InvokeServer()
    for _,currency in registry do
        PickupWorldCurrency:FireServer(currency.GUID)
    end
end

function CollectCurrencies:Start()
    CollectCurrencies:Stop()
    
    collectThread = task.spawn(function()
        while task.wait(DELAY) do
            print("Collect")
            CollectCurrencies.CollectAll()
        end
    end)
    janitor:Add(collectThread)
end

function CollectCurrencies:Stop()
    if collectThread then
        task.cancel(collectThread)
    end
end

return CollectCurrencies