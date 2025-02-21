local Janitor = {}

local janitorMeta = {__index = Janitor}

function Janitor:Add(...:RBXScriptConnection|thread|(...any)->())
	for _,connection in {...} do
		table.insert(self._connections,connection)
	end
end

function Janitor:Clean()
	local connections = self._connections
	
	for i,connection in connections do
		local _type = typeof(connection)
		
		if _type == "thread" then
			task.cancel(connection)
		elseif _type == "function" then
			task.spawn(connection)
		else
			connection:Disconnect()
		end

		connections[i] = nil
	end
end


local Constructor = {}

function Constructor.new()
	local t = {_connections = {}}::typeof({})
	
	return setmetatable(t,janitorMeta)
end

return Constructor