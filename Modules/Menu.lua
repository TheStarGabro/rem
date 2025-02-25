if game:GetService("RunService"):IsStudio() then rem = setmetatable({},{__index = function(t) return t end,__call = function(t) return t end}) end
local FONT = Enum.Font.Arimo
local HOTBAR_HEIGHT = 0.05
local NAV_HEIGHT = 0.05
local TOGGLE_KEY = Enum.KeyCode.Backquote

local TextService = game:GetService("TextService")
local janitor = rem.janitor

local Menu = {}
Menu.__index = Menu

local Submenu = {}
Submenu.__index = Submenu

-------------------------------------------------------------------


function Submenu:HotbarButton()
	local button = Instance.new("ImageButton")
	button.BackgroundTransparency = 1
	button.Size = UDim2.fromScale(1,1)

	local aspectratio = Instance.new("UIAspectRatioConstraint")
	aspectratio.Parent = button
	aspectratio.DominantAxis = Enum.DominantAxis.Height
	
	table.insert(self.HotbarButtons,button)
	
	if self.Menu.CurrentSubmenu == self then
		self:Select()
	end

	return button
end

function Submenu:Select()
	local oldsubmenu = self.Menu.CurrentSubmenu
	
	if oldsubmenu and oldsubmenu ~= self then
		oldsubmenu:Deselect()
	end
	
	self.Menu.CurrentSubmenu = self
	
	local ui = self.Menu.UI
	local content = ui.Content
	local hotbar = ui.Hotbar
	
	self.Frame.Parent = content
	for _,button in self.HotbarButtons do
		button.Parent = hotbar
	end
end

function Submenu:Deselect()
	self.Frame.Parent = nil
	for _,button in self.HotbarButtons do
		button.Parent = nil
	end
end

-------------------------------------------------------------------

function Menu.new()
	local menu = setmetatable({},Menu)
	
	local screenUI = Instance.new("ScreenGui")
	screenUI.IgnoreGuiInset = true
	screenUI.DisplayOrder = 1
	screenUI.Parent = game.Players.LocalPlayer.PlayerGui

	local ui = Instance.new("Frame")
	ui.BackgroundColor3 = Color3.new(.262745, .262745, .262745)
	ui.BorderSizePixel = 0
	ui.BackgroundTransparency = .1
	ui.AnchorPoint = Vector2.new(0,.5)
	ui.Position = UDim2.fromScale(0.1,.5)
	ui.Size = UDim2.fromScale(.35,.9)
	ui.Parent = screenUI

	local uilist = Instance.new("UIListLayout")
	uilist.Parent = ui

	local hotbar = Instance.new("Frame")
	hotbar.BorderSizePixel = 0
	hotbar.BackgroundColor3 = Color3.new(.211765, .211765, .211765)
	hotbar.Size = UDim2.fromScale(1,HOTBAR_HEIGHT)
	hotbar.Parent = ui

	local hotbarlist = Instance.new("UIListLayout")
	hotbarlist.HorizontalAlignment = Enum.HorizontalAlignment.Right
	hotbarlist.VerticalAlignment = Enum.VerticalAlignment.Center
	hotbarlist.Padding = UDim.new(0,5)
	hotbarlist.Parent = hotbar

	local nav = Instance.new("Frame")
	nav.BorderSizePixel = 0
	nav.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	nav.Size = UDim2.fromScale(1,NAV_HEIGHT)
	nav.Parent = ui

	local navscroll = Instance.new("ScrollingFrame")
	navscroll.BackgroundTransparency = 1
	navscroll.ScrollBarThickness = 0
	navscroll.CanvasSize = UDim2.fromScale(1,1)
	navscroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
	navscroll.Size = UDim2.fromScale(1,1)
	navscroll.Parent = nav

	local navlist = Instance.new("UIListLayout")
	navlist.FillDirection = Enum.FillDirection.Horizontal
	navlist.VerticalAlignment = Enum.VerticalAlignment.Center
	navlist.Parent = navscroll

	local content = Instance.new("Frame")
	content.BorderSizePixel = 0
	content.BackgroundTransparency = 1
	content.BackgroundColor3 = Color3.new(.211765, .211765, .211765)
	content.Size = UDim2.fromScale(1,1-HOTBAR_HEIGHT-NAV_HEIGHT)
	content.Parent = ui
	
	janitor:Add(function()
		screenUI:Destroy()
	end)
	
	janitor:Add(
		game:GetService("UserInputService").InputBegan:Connect(function(input)
			if input.KeyCode ~= TOGGLE_KEY then return end
			
			menu:Toggle()
		end)
	)
	
	menu.UI = {
		ScreenGui = screenUI,
		Hotbar = hotbar,
		Nav = navscroll,
		Content = content
	}
	menu.Submenus = {}
	menu.sizedupdates = {}
	
	menu:Toggle(false)
	
	janitor:Add(
		screenUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			for instance,info in menu.sizedupdates do
				for _,f in info do
					f()
				end
			end
		end)
	)
	
	return menu
end

function Menu:AddSized(instance:GuiObject,func:()->())
	local f = func
	
	local sizedupdates = self.sizedupdates
	local su = sizedupdates[instance]
	if not su then
		su = {}
		sizedupdates[instance] = su
	end
	
	f()
	table.insert(su,f)
end

function Menu:Add(name)
	local submenu = setmetatable({},Submenu)
	
	local ui = self.UI
	
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1,1)
	
	submenu.Menu = self
	submenu.Frame = frame
	submenu.HotbarButtons = {}
	
	local nav = ui.Nav
	local navbutton = Instance.new("TextButton")
	assert(name,"Submenu needs a name")
	navbutton.Text = name
	navbutton.TextColor3 = Color3.new(1,1,1)
	navbutton.Font = FONT
	navbutton.BorderSizePixel = 0
	navbutton.BackgroundColor3 = Color3.new(0.384314, 0.384314, 0.384314)
	navbutton.Parent = nav
	
	self:AddSized(navbutton,function(size)
		navbutton.TextSize = nav.AbsoluteSize.Y
		navbutton.Size = UDim2.new(0,TextService:GetTextSize(name,navbutton.TextSize,FONT,Vector2.new(math.huge,math.huge)).X,1,0)
	end)
	
	janitor:Add(
		navbutton.MouseButton1Down:Connect(function()
			submenu:Select()
		end)
	)

	
	table.insert(self.Submenus,submenu)
	if #self.Submenus == 1 then
		submenu:Select()
	end

	return submenu
end

function Menu:Toggle(state:boolean?)
	if state == nil then
		state = not self.state
	end
	
	self.state = state
	self.UI.ScreenGui.Enabled = state
end

-------------------------------------------------------------------

return Menu.new()