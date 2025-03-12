local import = rem.import
local hookMetaMethod = rem.hookMetaMethod
local getNamecallMethod = rem.getNamecallMethod
local newCClosure = rem.newCClosure
local hookFunction = rem.hookFunction
local getCallingScript = rem.getCallingScript
local getInfo = rem.getInfo
local oh = rem.oh

local RemoteSpy = {}
local Remote = import("constructors/Remote")
local Signal = import("constructors/Signal")

local requiredMethods = {
    ["checkCaller"] = true,
    ["newCClosure"] = true,
    ["hookFunction"] = true,
    ["isReadOnly"] = true,
    ["setReadOnly"] = true,
    ["getInfo"] = true,
    ["getMetatable"] = true,
    ["setClipboard"] = true,
    ["getNamecallMethod"] = true,
    ["getCallingScript"] = true,
}

local remoteMethods = {
    FireServer = true,
    InvokeServer = true,
    Fire = true,
    Invoke = true
}

local remotesViewing = {
    RemoteEvent = true,
    RemoteFunction = true,
    BindableEvent = true,
    BindableFunction = true
}

local methodHooks = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

local functionsIndexed = {
    RemoteFunction = true,
    BindableFunction = true
}

local currentRemotes = {}

local remoteSignal = Signal.new():Yieldable()
local functionSignal = Signal.new()
local eventSet = true

local function connectEvent(callback)
    return remoteSignal:Connect(callback)
end

local originalMethod
originalMethod = hookMetaMethod(game, "__namecall", function(...)
    local instance = ...
    
    if typeof(instance) ~= "Instance" then
        return originalMethod(...)
    end

    local method = getNamecallMethod()

    if method == "fireServer" then
        method = "FireServer"
    elseif method == "invokeServer" then
        method = "InvokeServer"
    end
        
    if remotesViewing[instance.ClassName] and remoteMethods[method] then
        local remote = currentRemotes[instance]
        local vargs = {select(2, ...)}
            
        if not remote then
            remote = Remote.new(instance)
            currentRemotes[instance] = remote
        end

        local remoteIgnored = remote.Ignored
        local remoteBlocked = remote.Blocked
        local argsIgnored = remote.AreArgsIgnored(remote, vargs)
        local argsBlocked = remote.AreArgsBlocked(remote, vargs)

        if eventSet and (not remoteIgnored and not argsIgnored) then
            local call = {
                script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                args = vargs,
                func = getInfo(3).func
            }

            remote.IncrementCalls(remote, call)
            print(remoteSignal,remoteSignal.Fire)
            remoteSignal:Fire(instance, call)

            local first_arg = ...
            local new_args = {first_arg}
            for _,v in ipairs(call.args) do
                table.insert(new_args,v)
            end

            if functionsIndexed[instance.ClassName] then
                local received = {originalMethod(unpack(new_args))}
    
                functionSignal:Fire(instance,{
                    args = received
                })
    
                return unpack(received)
            end
    
            return originalMethod(unpack(new_args))
        end

        if remoteBlocked or argsBlocked then
            return
        end
    end

    return originalMethod(...)
end)

-- vuln fix

local pcall = pcall

local function checkPermission(instance)
    if (instance.ClassName) then end
end

for _name, hook in pairs(methodHooks) do
    local originalMethod
    originalMethod = hookFunction(hook, newCClosure(function(...)
        local instance = ...

        if typeof(instance) ~= "Instance" then
            return originalMethod(...)
        end
                
        do
            local success = pcall(checkPermission, instance)
            if (not success) then return originalMethod(...) end
        end

        if instance.ClassName == _name and remotesViewing[instance.ClassName] then
            local remote = currentRemotes[instance]
            local vargs = {select(2, ...)}

            if not remote then
                remote = Remote.new(instance)
                currentRemotes[instance] = remote
            end

            local remoteIgnored = remote.Ignored 
            local argsIgnored = remote:AreArgsIgnored(vargs)

            if remote.Blocked or remote:AreArgsBlocked(vargs) then
                return
            end
            
            if eventSet and (not remoteIgnored and not argsIgnored) then
                local call = {
                    script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                    args = vargs,
                    func = getInfo(3).func
                }
    
                remote:IncrementCalls(call)
                remoteSignal:Fire(instance, call)

                local first_arg = ...
                local new_args = {first_arg}
                for _,v in ipairs(call.args) do
                    table.insert(new_args,v)
                end

                if functionsIndexed[instance.ClassName] then
                    local received = {originalMethod(unpack(new_args))}
        
                    functionSignal:Fire(instance,{
                        args = received
                    })
        
                    return unpack(received)
                end
        
                return originalMethod(unpack(new_args))
            end
        end

        return originalMethod(...)
    end))

    oh.Hooks[originalMethod] = hook
end

RemoteSpy.RemotesViewing = remotesViewing
RemoteSpy.CurrentRemotes = currentRemotes
RemoteSpy.ConnectEvent = connectEvent
RemoteSpy.RequiredMethods = requiredMethods

RemoteSpy.Signal = remoteSignal
RemoteSpy.FunctionSignal = functionSignal

return RemoteSpy
