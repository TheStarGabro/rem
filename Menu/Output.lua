if game:GetService("RunService"):IsStudio() then rem = setmetatable({},{__index = function(t) return t end,__call = function(t) return t end}) end

local FONT = Enum.Font.Arimo
local LINES = 25

local janitor = rem.janitor
local import = rem.import
local TextService = game:GetService("TextService")
local Menu if game:GetService("RunService"):IsStudio() then Menu = require(script.Parent.Menu) else Menu = import("Modules/Menu") end

local output = Menu:Add("Output")

local OutputMeta = {}
OutputMeta.__index = OutputMeta

-------------------------------------------------------------------

local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.Size = UDim2.fromScale(1,1)
scroll.CanvasSize = UDim2.fromScale(1,1)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
scroll.Parent = output.Frame

local mainFrame = Instance.new("Frame")
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.fromScale(1,1)
mainFrame.Parent = scroll

local list = Instance.new("UIListLayout")
list.Parent = mainFrame

local popup = Instance.new("Frame")
popup.BackgroundTransparency = 1
popup.BorderSizePixel = 0
popup.BackgroundColor3 = Color3.new(.227451, .227451, .227451)
popup.AnchorPoint = Vector2.new(.5,0)
popup.Position = UDim2.fromScale(.5,1)
popup.Size = UDim2.fromScale(1,1)

local popuptext = Instance.new("TextLabel")
popuptext.TextScaled = true
popuptext.TextColor3 = Color3.new(1,1,1)
popuptext.BackgroundTransparency = 1
popuptext.Size = UDim2.fromScale(1,1)
popuptext.Parent = popup

-------------------------------------------------------------------

local lines = {}

local function format(text)
	local date = DateTime.now():ToLocalTime()

	return `{date.Hour}:{date.Minute}:{date.Second}.{date.Millisecond}  {text}`
end

local UpdateY = {}

local function AddUpdateY(instance,property,func)
	local f = func

	if not f then
		local p = instance[property]

		if typeof(p) == "number" then
			f = function()
				instance[property] = mainFrame.AbsoluteSize.Y/LINES
			end
		elseif typeof(p) == "UDim2" then
			f = function()
				local v = instance[property]
				instance[property] = UDim2.new(v.X.Scale,v.X.Offset,0,mainFrame.AbsoluteSize.Y/LINES)
			end
		end
	end

	f()

	local uy = UpdateY[instance]
	if not uy then
		uy = {}
		UpdateY[instance] = uy
	end
	table.insert(uy,f)
end

janitor:Add(
	mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		for instance,info in UpdateY do
			for _,f in info do
				f()
			end
		end
	end)
)

local function Output(frame)
	local line = Instance.new("Frame")
	line.BackgroundTransparency = 1
	line.Size = UDim2.fromScale(1,1/LINES)
	line.AutomaticSize = Enum.AutomaticSize.Y
	line.Parent = mainFrame

	table.insert(lines,line)

	local linelist = Instance.new("UIListLayout")
	linelist.Parent = line

	local output = setmetatable({
		Frame = line
	},OutputMeta)

	output:Separate()

	return output
end

function OutputMeta:Text(text,info)
	info = info or {}

	local label:TextLabel = Instance.new(info.IsButton and "TextButton" or "TextLabel")
	label.Text = text
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextColor3 = Color3.new(1,1,1)
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = #self.Row:GetChildren()+1
	label.TextColor3 = info.Color or Color3.new(1,1,1)
	label.Size = UDim2.new(0,1,1,0)

	if info.Popup then
		janitor:Add(
			label.MouseEnter:Connect(function()
				popuptext.Text = info.Popup
				popup.Parent = label
			end)
		)

		janitor:Add(
			label.MouseLeave:Connect(function()
				popup.Parent = nil
			end)
		)
	end

	AddUpdateY(label,"Size")
	AddUpdateY(label,"TextSize")
	AddUpdateY(label,nil,function()
		local size = TextService:GetTextSize(text,label.TextSize,FONT,Vector2.new(math.huge,math.huge))

		local ls = label.Size
		label.Size = UDim2.new(0,size.X,ls.Y.Scale,ls.Y.Offset)
	end)

	label.Parent = self.Row

	return {
		Instance = label
	}
end

function OutputMeta:Date(text:string?)
	local date = DateTime.now():ToLocalTime()
	local text = self:Text(text or `{date.Hour}:{date.Minute}:{date.Second}.{date.Millisecond} `,
		{Color = Color3.new(.72549, .72549, .72549)}
	)

	return text
end

function OutputMeta:Separate()
	local row = Instance.new("Frame")
	AddUpdateY(row,"Size")
	row.Parent = self.Frame

	self.Row = row

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = row

	return {Instance = row}
end

function OutputMeta:Push(depth)
	local t = ""

	for i = 1,depth do
		t..="    "
	end

	self:Text(t)
end

local AddCases = {
	table = function(self,add,depth)
		local _button = self:Text("►",{IsButton = true})
		local button = _button.Instance

		local opened = true

		self:Text("{")

		local _dots = self:Text("...")
		local dots = _dots.Instance

		local _close = self:Text("}")
		local close = _close.Instance

		local _row = self:Separate()
		local row = _row.Instance

		local content_rows = {}
		table.insert(content_rows,_row)

		for i,v in add do
			self:Push(depth+1)
			self:Text("[")
			self:Add(i,depth)
			self:Text("] = ")
			self:Add(v,depth)
			table.insert(content_rows,self:Separate())
		end

		self:Push(depth)
		self:Text("}")

		local function toggle()
			opened = not opened

			button.Text = opened and "▼" or "►"
			if opened then
				for _,row in content_rows do
					row.Instance.Visible = true
				end
				dots.Visible = false
				close.Visible = false
			else
				for _,row in content_rows do
					row.Instance.Visible = false
				end
				dots.Visible = true
				close.Visible = true
			end
		end

		janitor:Add(
			button.MouseButton1Click:Connect(toggle)
		)

		toggle()
	end,

	string = function(self,add,depth)
		self:Text(`"{tostring(add)}"`)
	end,

	Instance = function(self,add)
		self:Text(tostring(add),{Popup = add:GetFullName()})
	end,

	default = function(self,add,depth)
		self:Text(tostring(add))
	end,
}

function OutputMeta:Add(add,depth)
	if depth then
		depth += 1
	else
		depth = 0
	end

	local _type = typeof(add)

	if AddCases[_type] then
		AddCases[_type](self,add,depth)
	else
		AddCases.default(self,add,depth)
	end
end

local function add(...)
	local args = {...}

	local output = Output()

	local added = {
		Texts = {}
	}

	for i,v in args do
		if i ~= 1 then
			output:Separate()
			output:Date(" - ")
		else
			output:Date()
		end

		output:Text(" ")

		if typeof(v) == "table" then
			output:Add(v)
		else
			local text = tostring(v)
			local lines = text:split("\n")
			local count = #lines

			for i,l in lines do
				table.insert(added.Texts,output:Text(l))

				if i ~= count then
					output:Separate()
				end
			end
		end
	end

	return added
end

janitor:Add(
	game:GetService("LogService").MessageOut:Connect(function(msg,msgtype)
		local color =
			msgtype == Enum.MessageType.MessageError and Color3.fromRGB(255,0,0) or
			msgtype == Enum.MessageType.MessageInfo and Color3.fromRGB(128, 215, 255) or
			msgtype == Enum.MessageType.MessageWarning and Color3.fromRGB(255, 115, 21)

		if not color then return end

		local added = add(msg)

		for _,t in added.Texts do
			t.Instance.TextColor3 = color or Color3.new(1,1,1)
		end
	end)
)

local clearbutton = output:HotbarButton()
clearbutton.Image = "rbxassetid://108710284607883"
janitor:Add(
	clearbutton.MouseButton1Down:Connect(function()
		for _,line in lines do
			line:Destroy()
		end
	end)
)