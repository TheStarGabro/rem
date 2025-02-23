if game:GetService("RunService"):IsStudio() then rem = setmetatable({},{__index = function(t) return t end,__call = function(t) return t end}) end
local FONT = Enum.Font.Arimo
local POPUP_INCREASE = 3

local TextService = game:GetService("TextService")
local janitor = rem.janitor

local Buttons = {}

local screenUI = Instance.new("ScreenGui")
screenUI.IgnoreGuiInset = true
screenUI.DisplayOrder = 1
screenUI.Parent = game.Players.LocalPlayer.PlayerGui

local ui = Instance.new("Frame")
ui.BackgroundColor3 = Color3.new(.262745, .262745, .262745)
ui.BorderSizePixel = 0
ui.BackgroundTransparency = .1
ui.AnchorPoint = Vector2.new(1,.5)
ui.Position = UDim2.fromScale(0.9,.5)
ui.Size = UDim2.fromScale(.03,.9)
ui.Parent = screenUI

local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.Size = UDim2.fromScale(1,1)
scroll.CanvasSize = UDim2.fromScale(1,1)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
scroll.ScrollBarThickness = 0
scroll.Parent = ui

local mainFrame = Instance.new("Frame")
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.fromScale(1,1)
mainFrame.Parent = scroll

local list = Instance.new("UIListLayout")
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.Parent = mainFrame

local popup = Instance.new("TextLabel")
popup.BorderSizePixel = 0
popup.BackgroundColor3 = Color3.new(.227451, .227451, .227451)
popup.AnchorPoint = Vector2.new(.5,0)
popup.TextXAlignment = Enum.TextXAlignment.Center
popup.TextYAlignment = Enum.TextYAlignment.Top
popup.TextScaled = true
popup.TextColor3 = Color3.new(1,1,1)

----------------------------------------------------------------

local ButtonMeta = {}
ButtonMeta.__index = ButtonMeta

function ButtonMeta:Image(image)
	self.imagelabel.Image = image
	
	return self
end

function ButtonMeta:Text(text)
	self.textlabel.Text = text
	
	return self
end

function ButtonMeta:Toggle(state)
	if state == nil then
		state = not self.state
	end
	
	self.state = not not state
	
	if state then
		self.textlabel.TextColor3 = Color3.new(1,1,1)
		self.imagelabel.ImageColor3 = Color3.new(1,1,1)
	else
		self.textlabel.TextColor3 = Color3.new(0.580392, 0.580392, 0.580392)
		self.imagelabel.ImageColor3 = Color3.new(0.427451, 0.427451, 0.427451)
	end
	
end

function ButtonMeta:Popup(text)
	self.popuptext = text

	return self
end

function Buttons:Create()
	local frame = Instance.new("ImageButton")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1,1)
	frame.Parent = mainFrame
	
	local aspectratio = Instance.new("UIAspectRatioConstraint")
	aspectratio.Parent = frame
	
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Size = UDim2.fromScale(1,0.75)
	image.Active = false
	image.Parent = frame
	
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.fromScale(1,0.25)
	text.Position = UDim2.fromScale(0,0.75)
	text.Font = FONT
	text.TextScaled = true
	text.Text = ""
	text.Active = false
	text.Parent = frame
	
	local button = setmetatable({},ButtonMeta)
	
	button.Frame = frame;
	(button::nil).imagelabel = image;
	(button::nil).textlabel = text;
	
	janitor:Add(
		frame.MouseEnter:Connect(function()
			local str = button.popuptext or ""
			popup.Text = str
			
			local abspos,abssize = frame.AbsolutePosition,frame.AbsoluteSize
			local pos = abspos + abssize - Vector2.new(abssize.X*0.5,0) - screenUI.AbsolutePosition
			popup.Position = UDim2.fromOffset(pos.X,pos.Y)
			
			local textsize = text.AbsoluteSize.Y * POPUP_INCREASE
			local size = TextService:GetTextSize(str,textsize,FONT,Vector2.new(10000,10000))
			popup.Size = UDim2.fromOffset(size.X,size.Y)
			
			popup.Parent = screenUI
		end)
	)
	
	
	janitor:Add(
		frame.MouseLeave:Connect(function()
			popup.Parent = nil
		end)
	)

	button:Toggle(true)
	
	return button
end

return Buttons