if game:GetService("RunService"):IsStudio() then rem = setmetatable({},{__index = function(t) return t end,__call = function(t) return t end}) end

local FONT = Enum.Font.Arimo
local MOTE_HEIGHT = 0.05
local CALLS_LINES = 30
local CALLS_DISPLAYED = 20

local janitor = rem.janitor
local import = rem.import
local TextService = game:GetService("TextService")
local Menu if game:GetService("RunService"):IsStudio() then Menu = require(script.Parent.Menu) else Menu = import("Modules/Menu") end

local remote = Menu:Add("Remote")
local menu = remote.Menu

local Mote = {}
Mote.__index = Mote

local Log = {}
Log.__index = Log

-------------------------------------------------------------------

local motespage = Instance.new("Frame")
motespage.BackgroundTransparency = 1
motespage.Size = UDim2.fromScale(1,1)

local motespagescroll = Instance.new("ScrollingFrame")
motespagescroll.BackgroundTransparency = 1
motespagescroll.Size = UDim2.fromScale(1,1)
motespagescroll.CanvasSize = UDim2.fromScale(1,1)
motespagescroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
motespagescroll.Parent = motespage

local motespagelist = Instance.new("UIListLayout")
motespagelist.Parent = motespagescroll

local callspage = Instance.new("Frame")
callspage.BackgroundTransparency = 1
callspage.Size = UDim2.fromScale(1,1)

local callspagescroll = Instance.new("ScrollingFrame")
callspagescroll.BackgroundTransparency = 1
callspagescroll.Size = UDim2.fromScale(1,1)
callspagescroll.CanvasSize = UDim2.fromScale(1,1)
callspagescroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
callspagescroll.Parent = callspage

local callsnav = Instance.new("Frame")
callsnav.Position = UDim2.fromScale(1,1)
callsnav.Size = UDim2.fromScale(0.35,0.08)
callsnav.AnchorPoint = Vector2.new(1,1)
callsnav.BorderSizePixel = 0
callsnav.BackgroundColor3 = Color3.new(0.223529, 0.223529, 0.223529)
callsnav.Parent = callspage

local callsnavlist = Instance.new("UIListLayout")
callsnavlist.FillDirection = Enum.FillDirection.Horizontal
callsnavlist.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
callsnavlist.SortOrder = Enum.SortOrder.LayoutOrder
callsnavlist.Parent = callsnav

local callsnavprev = Instance.new("TextButton")
callsnavprev.Text = "<"
callsnavprev.TextColor3 = Color3.new(1,1,1)
callsnavprev.TextScaled = true
callsnavprev.Size = UDim2.fromScale(0.33,1)
callsnavprev.BackgroundTransparency = 1
callsnavprev.Parent = callsnav

local callsnavnumber = Instance.new("TextLabel")
callsnavnumber.TextColor3 = Color3.new(1,1,1)
callsnavnumber.TextScaled = true
callsnavnumber.Size = UDim2.fromScale(0.33,1)
callsnavnumber.BackgroundTransparency = 1
callsnavnumber.Parent = callsnav

local callsnavnext = Instance.new("TextButton")
callsnavnext.Text = ">"
callsnavnext.TextColor3 = Color3.new(1,1,1)
callsnavnext.TextScaled = true
callsnavnext.Size = UDim2.fromScale(0.33,1)
callsnavnext.BackgroundTransparency = 1
callsnavnext.Parent = callsnav

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

local viewing_mote
local calls_page_index = -1

local viewing
local function ViewPage(instance)
	if viewing then
		viewing.Parent = nil
	end

	viewing = instance
	instance.Parent = remote.Frame
end

local function CallsPage(index)
	local potential = viewing_mote and math.ceil(#viewing_mote.CallList / CALLS_DISPLAYED) or 1

	local new = math.clamp(index,1,potential)
	if new == calls_page_index then return end

	calls_page_index = new

	if viewing_mote then
		viewing_mote:View()
	end
end

ViewPage(motespage)
CallsPage(1)

-------------------------------------------------------------------

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

function Log:Text(text,info)
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

	menu:AddSized(label,function()
		local y = self.Frame.AbsoluteSize.Y/self.LineCount
		label.TextSize = y

		local size = TextService:GetTextSize(text,y,FONT,Vector2.new(math.huge,math.huge))

		local ls = label.Size
		label.Size = UDim2.new(0,size.X,0,y)
	end)

	if not self.Row then
		self:Separate()
	end
	label.Parent = self.Row

	return {
		Instance = label
	}
end

function Log:Add(add,depth)
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

function Log:Separate()
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	menu:AddSized(row,function()
		row.Size = UDim2.new(1,0,0,self.Frame.AbsoluteSize.Y/self.LineCount)
	end)
	row.Parent = self.Frame

	self.Row = row

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = row

	return {Instance = row}
end

function Log:Push(depth)
	local t = ""

	for i = 1,depth do
		t..="    "
	end

	self:Text(t)
end

function Log.new(linecount:number)
	local log = setmetatable({},Log)

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1,1)
	frame.Parent = callspagescroll

	local linelist = Instance.new("UIListLayout")
	linelist.Parent = frame

	log.Frame = frame
	log.LineCount = linecount or 1

	return log
end

-------------------------------------------------------------------

local motedict = {}

function Mote:Call(info)
	if self.Blocked then return end

	local count = self.Count + 1
	self.Count = count

	self.UI.Count.Text = count > 1000 and "..." or tostring(count)

	table.insert(self.CallList,info)

	local args = info.args
end

function Mote.new(remote)
	local mote = setmetatable({},Mote)

	local button = Instance.new("ImageButton")
	button.BorderSizePixel = 0
	button.BackgroundColor3 = Color3.new(0.239216, 0.239216, 0.239216)
	button.Size = UDim2.fromScale(1,MOTE_HEIGHT)
	button.Parent = motespagescroll

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
	list.Parent = button

	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromScale(1,1)
	icon.Image = remote:IsA("RemoteEvent") and "rbxassetid://4229806545" or "rbxassetid://4229810474"
	icon.Parent = button

	local iconaspect = Instance.new("UIAspectRatioConstraint")
	iconaspect.DominantAxis = Enum.DominantAxis.Height
	iconaspect.Parent = icon

	local name = Instance.new("TextLabel")
	name.Text = remote:GetFullName()
	name.TextScaled = true
	name.TextColor3 = Color3.new(1,1,1)
	name.Font = FONT
	name.BackgroundTransparency = 1
	name.Size = UDim2.fromScale(0.5,1)
	name.Parent = button

	local count = Instance.new("TextLabel")
	count.Text = "0"
	count.TextScaled = true
	count.TextColor3 = Color3.new(1,1,1)
	count.Font = FONT
	count.BackgroundTransparency = 1
	count.Size = UDim2.fromScale(0.1,1)
	count.Parent = button

	janitor:Add(
		button.MouseButton1Click:Connect(function()
			mote:View()
		end),

		button.MouseButton2Down:Connect(function() mote:Block() end)
	)

	mote.Count = 0
	mote.Remote = remote
	mote.CallList = {}
	mote.UI = {
		Button = button,
		Icon = icon,
		Name = name,
		Count = count
	}

	mote:Block(false)

	return mote
end

function Mote:Block(state:boolean)
	if state == nil then
		state = not self.Blocked
	end

	self.Blocked = state
	local color = state and Color3.new(0.4, 0, 0) or Color3.new(1,1,1)
	self.UI.Name.TextColor3 = color
	self.UI.Count.TextColor3 = color
end

function Mote:viewClean()
	if not self.log then return end
	self.log.Frame:Destroy()
	self.log = nil
end

function Mote:View()
	self:viewClean()

	viewing_mote = self
	ViewPage(callspage)

	local log = Log.new(CALLS_LINES)
	self.log = log

	callsnavnumber.Text = tostring(calls_page_index).."/"..math.ceil(#self.CallList/CALLS_DISPLAYED)

	for c = CALLS_DISPLAYED*(calls_page_index-1)+1,CALLS_DISPLAYED*calls_page_index do
		local info = self.CallList[c]
		if not info then break end -- 4 calls - break at 5

		for i,v in info.args do
			log:Separate()
			log:Text(c..":["..i.."] = ")
			log:Add(v)
		end
	end
end

function Mote:Deview()
	if viewing_mote ~= self then return end

	CallsPage(1)

	viewing_mote = nil

	ViewPage(motespage)
	self:viewClean()
end

-------------------------------------------------------------------

janitor:Add(
	callsnavprev.MouseButton1Down:Connect(function()
		CallsPage(calls_page_index-1)
	end),

	callsnavnext.MouseButton1Down:Connect(function()
		CallsPage(calls_page_index+1)
	end)
)


-------------------------------------------------------------------

local backbutton = remote:HotbarButton()
backbutton.Image = "rbxassetid://87176271353993"
janitor:Add(
	backbutton.MouseButton1Down:Connect(function()
		if viewing_mote then
			viewing_mote:Deview()
			viewing_mote = nil
		end
	end)
)

local function fired(instance,info)
	local mote = motedict[instance]
	if not mote then
		mote = Mote.new(instance)
		motedict[instance] = mote
	end

	mote:Call(info)
end

janitor:Add(
	import("modules/RemoteSpy").Signal:Connect(fired)
)