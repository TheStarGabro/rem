local Collect = {}

local DELAY = 10

local RunService = game:GetService("RunService")

local CurrencyGetRegistry = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry
local PickupWorldCurrency = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency

local EntityGetRegistry = game.ReplicatedStorage.Knit.Services.EntityService.RF.GetRegistry
local DestroyEObject = game.ReplicatedStorage.Knit.Services.EntityService.RE.DestroyEObject

local collectThread
local currencyRegistry
local enemyRegistry

-- PickupWorldCurrency
-- PickupUniqueWorldCurrency

function Collect:CollectAll()
    currencyRegistry = currencyRegistry or CurrencyGetRegistry:InvokeServer()
    enemyRegistry = enemyRegistry or EntityGetRegistry:InvokeServer()
    
    for _,currency in currencyRegistry do
        PickupWorldCurrency:FireServer(currency.GUID)
    end

    for _,entity in enemyRegistry do
        DestroyEObject:FireServer(entity.GUID)
    end
end

function Collect:Start()
    Collect:Stop()
    
    collectThread = task.spawn(function()
        while task.wait(DELAY) do
            print("Collect")
            Collec.CollectAll()
        end
    end)
    janitor:Add(collectThread)
end

function Collect:Stop()
    if collectThread then
        task.cancel(collectThread)
    end
end

return Collect