local Collect = {}

local DELAY = 10



local RunService = game:GetService("RunService")
local janitor = rem.janitor

local CurrencyGetRegistry = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RF.GetRegistry
local DestructibleGetRegistry = game.ReplicatedStorage.Knit.Services.DestructibleService.RF.GetRegistry
local EntityGetRegistry = game.ReplicatedStorage.Knit.Services.EntityService.RF.GetRegistry

local PickupWorldCurrency = game.ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupWorldCurrency
local ProcessDObject = game.ReplicatedStorage.Knit.Services.DestructibleService.RE.ProcessDObject
local ProcessEObject = game.ReplicatedStorage.Knit.Services.EntityService.RE.ProcessEObject

local collectThread
local currencyRegistry
local destructibleRegistry
local entityRegistry

-- PickupWorldCurrency
-- PickupUniqueWorldCurrency

function Collect:Registers()
    currencyRegistry = CurrencyGetRegistry:InvokeServer()
    destructibleRegistry = DestructibleGetRegistry:InvokeServer()
    entityRegistry = EntityGetRegistry:InvokeServer()
end

function Collect:CollectAll()
    for _,currency in currencyRegistry do
        PickupWorldCurrency:FireServer(currency.GUID)
    end

    for _,destructible in destructibleRegistry do
        ProcessDObject:FireServer(destructible.GUID)
    end

    for _,entity in entityRegistry do
        ProcessEObject:FireServer(entity.GUID)
    end
end

function Collect:Start()
    Collect:Stop()

    Collect:Registers()

    collectThread = task.spawn(function()
        Collect:CollectAll()
        while task.wait(DELAY) do
            Collect:CollectAll()
        end
    end)
    
    janitor:Add(collectThread)
end

function Collect:Stop()
    if collectThread then
        task.cancel(collectThread)
    end
end

Collect:Registers()

return Collect