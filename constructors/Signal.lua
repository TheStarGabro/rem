local Signal = {}
local Constructor = {}

local spawn = task.spawn
local running,defer,yield = coroutine.running,task.defer,coroutine.yield
local emptyFunc = function() end
local safetab = setmetatable({},{__index = function(t) return t end,__call = function(t) return t end})

local function callbackSignal(self,index)
	if rawget(self,index) then
		self[index]:Fire(self)
	end
end

local Receipt = {}
function Receipt:Disconnect()
	local signal = self._signal
	
	callbackSignal(signal,"PreDisconnect")
	
	signal._connections[self] = nil
	setmetatable(self,nil)
	
	callbackSignal(signal,"PostDisconnect")
end

local receiptMeta = {__index = Receipt}
local _Receipt = function(self,func:(any)->(),pre,post)
	local receipt = setmetatable({_signal = self}::nil,receiptMeta)

	callbackSignal(self,"PreConnect")
	
	local func =
		pre and post and function(...) pre(receipt) func(...) post(receipt) end or
		pre and function(...) pre(receipt) func(...) end or
		post and function(...) func(...) post(receipt) end or
		func

	self._connections[receipt] = func
	
	callbackSignal(self,"PostConnect")
	
	self.Count += 1

	return receipt
end

Signal.Count = 0

function Signal:Connect(func)
	func = func::typeof(self._funcType)
	return _Receipt(self,func::nil)::typeof(Receipt)
end

function Signal:Once(func:(any)->())
	func = func::typeof(self._funcType)
	return _Receipt(self,func,function(self) self:Disconnect() end)::typeof(Receipt)
end

function Signal:Wait()
	local cor = running()
	
	callbackSignal(self,"PreConnect")
	
	local connections = self._connections
	connections[cor] = function(...) connections[cor] = nil spawn(cor,...) end
	
	callbackSignal(self,"PostConnect")
	
	self.Count += 1

	return yield()
end

function Signal:Fire(...)
	local run = self.run or spawn
	for _,f in self._connections do
		run(f,...)
	end
end

function Signal:Yieldable(state:bool)
	if state == nil then
		state = not self.yieldeable
	end

	self.yieldable = state
	self.run = state and function(f,...) f(...) end or nil

	return self
end

function Signal:DisconnectAll()
	local connections = self._connections
	
	local preDisconnect = rawget(self,"PreDisconnect")
	local postDisconnect = rawget(self,"PostDisconnect")
	
	for r,f in connections do
		if preDisconnect then preDisconnect:Fire(self) end
		
		connections[r] = nil
		
		if typeof(r) == 'thread' then
			spawn(f)
		end
		
		if postDisconnect then postDisconnect:Fire(self) end
	end
end

local _Transfer = function(self,from,to)
	from = self[from]
	to = self[to]

	for receipt,func in from do
		to[receipt] = func
	end

	table.clear(from)
end

function Signal:Pause()
	_Transfer(self,"_connections","_pausedConnections")
end

function Signal:Resume()
	_Transfer(self,"_pausedConnections","_connections")
end

local function IndexesEvent(index)
	return function(self)
		local connect = rawget(self,index)

		if not connect then
			connect = Constructor.new()
			rawset(self,index,connect)
		end

		return connect
	end::typeof(Signal)
end

local function IndexesTab(index)
	return function(self)
		local tab = {}
		
		rawset(self,index,tab)
		
		return tab
	end
end

local SignalIndexes = {
	PreConnect = IndexesEvent("PreConnect"),
	PostConnect = IndexesEvent("PostConnect"),
	PreDisconnect = IndexesEvent("PreDisconnect"),
	PostDisconnect = IndexesEvent("PostDisconnect"),
}
(SignalIndexes::nil)._connections = IndexesTab("_connections");
(SignalIndexes::nil)._pausedConnections = IndexesTab("_pausedConnections");

type SignalType = typeof(setmetatable({}::typeof(SignalIndexes),{__index = Signal}))

local function IsHash(t)
	if typeof(t) == "table" then
		local isHash
		local count = 0
		for _,_ in t do
			count+=1
			break
		end
		isHash = count ~= #count
		
		if count ~= 0 then
			return isHash,count
		end
		
		return nil,0
	end
end

local Changed = {
	IfHas = function(self:any,index:any,func:(signal:typeof(Signal))->())
		if self._signals[index] then
			func(self._signals[index])
		end
	end,
	
	TryFire = function(self:any,index:any,...)
		if self._signals[index] then
			self._signals[index]:Fire(...)
		end
	end,

	Has = function(self:any,index:any)
		return not not self._signals[index]
	end,

	Apply = function(self:any,func:(signal:SignalType)->())
		for _,s in self._signals do
			func(s)
		end
	end,
	
	AddAccepted = function(self:any,accepted:{string}|{string:boolean}|string)
		local _type = typeof(accepted)
		
		if _type == "string" then
			accepted = {accepted}
		end
		
		if _type == "table" then
			local isHash,count = IsHash(accepted)

			if count ~= 0 then
				local _accepted = self._accepted

				if isHash == true then
					for index,_ in accepted do
						_accepted[index] = true
					end
				else
					for _,index in accepted do
						_accepted[index] = true
					end
				end
			end
		end
	end,
	
	RemoveAccepted = function(self:any,accepted:{string}|{[string]:boolean?})
		local _type = typeof(accepted)

		if _type == "string" then
			accepted = {accepted}
		end

		if _type == "table" then
			local isHash,count = IsHash(accepted)

			if count ~= 0 then
				local _accepted = rawget(self,"_accepted")
				
				if _accepted then
					if isHash == true then
						for index,_ in accepted do
							_accepted[index] = nil
						end
					else
						for _,index in accepted do
							_accepted[index] = nil
						end
					end
					
					local empty = true
					
					for _,_ in _accepted do
						empty = false
						break
					end
					
					if empty then
						rawset(self,"_accepted",nil)
					end
				end
			end
		end
	end,

	Count = 0
}

local ChangedIndexes = {
	Added = IndexesEvent("Added"),
	Removed = IndexesEvent("Removed"),
}
;(ChangedIndexes::nil)._signals = IndexesTab("_signals")
;(ChangedIndexes::nil)._accepted = IndexesTab("_accepted")

local changedMeta = {}
changedMeta.__index = function(t,i)
	if Changed[i] then
		return Changed[i]
	elseif ChangedIndexes[i] then
		return ChangedIndexes[i](t)
	end
end::typeof(setmetatable(nil::typeof(Changed),{__index = ChangedIndexes}))
	
changedMeta.__call = function(t,index:any,_index:string,...)
	local args = {...}
	index = index == t and args[1] or index -- In case of :Get() instead of .Get()
	
	if rawget(t,"_accepted") and not t._accepted[index] then
		return safetab
	end

	local signals = t._signals

	if signals[index] then
		return signals[index]
	end

	local signal = Constructor.new()::SignalType
	
	signal.PostConnect:Connect(function(signal)
		t.Count += 1
	end)
	
	signal.PostDisconnect:Connect(function(signal)
		t.Count -= 1
		
		if t.Count == 0 then -- Means there are still connections
			(signals::nil)[index] = nil
			
			if rawget(t,"Removed") then
				t.Removed:Fire(index,signal)
			end
		end
	end)

	signals[index] = signal
	
	if rawget(t,"Added") then
		t.Added:Fire(index,signal,...)
	end

	return signal
end

local function newType(func)
	local t = {}

	function t:Connect(func:typeof(func))
		return nil::typeof(Receipt)
	end	

	function t:Once(func:typeof(func))
		return nil::typeof(Receipt)
	end

	return setmetatable(t,{__index = nil::SignalType})
end

function Constructor.new<FT>(funcType:FT?)
	local signal = setmetatable({},{__index = function(t,i)
		if Signal[i] then
			return Signal[i]
		elseif SignalIndexes[i] then
			return SignalIndexes[i](t)
		end
	end})::typeof(newType(funcType))

	return signal
end

type index = typeof(changedMeta.__index)
function Constructor.newChanged<FT>(funcType:FT)
	return setmetatable({},changedMeta)::typeof(function<IT>(index:IT)
		return Constructor.new(nil::FT)
	end) & typeof(changedMeta.__index)
end

return Constructor