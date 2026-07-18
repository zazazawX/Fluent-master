local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Slider - Missing Title.")
	assert(type(Config.Default) == "number", "Slider - Default value must be a number.")
	assert(type(Config.Min) == "number", "Slider - Minimum value must be a number.")
	assert(type(Config.Max) == "number", "Slider - Maximum value must be a number.")
	assert(Config.Min < Config.Max, "Slider - Minimum value must be less than maximum value.")
	assert(
		type(Config.Rounding) == "number"
			and Config.Rounding >= 0
			and Config.Rounding % 1 == 0,
		"Slider - Rounding must be a non-negative integer."
	)
	if Config.Step ~= nil then
		assert(type(Config.Step) == "number" and Config.Step > 0, "Slider - Step must be a positive number.")
	end

	local Slider = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Step = Config.Step or (1 / (10 ^ Config.Rounding)),
		Callback = Config.Callback or function(Value) end,
		Type = "Slider",
	}

	local Dragging = false
	local DragInput
	local SliderInteraction = {}

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false, Config.Tooltip)
	SliderFrame.Frame.Selectable = false
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc

	local SliderDot = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ThemeTag = {
			ImageColor3 = "Accent",
		},
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0),
	}, {
		SliderDot,
	})

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	local SliderDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = "Value",
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 14),
		Position = UDim2.new(0, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	local SliderFocusStroke = New("UIStroke", {
		Transparency = 1,
		Thickness = 1,
		ThemeTag = {
			Color = "Accent",
		},
	})

	local SliderInner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = SliderFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "SliderRail",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		SliderFocusStroke,
		New("UISizeConstraint", {
			MaxSize = Vector2.new(150, math.huge),
		}),
		SliderDisplay,
		SliderFill,
		SliderRail,
	})

	local SliderInput = New("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 32),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Selectable = true,
		Parent = SliderFrame.Frame,
	}, {
		New("UISizeConstraint", {
			MaxSize = Vector2.new(150, math.huge),
		}),
	})

	local function UpdateFromPosition(Position)
		local RailWidth = math.max(SliderRail.AbsoluteSize.X, 1)
		local SizeScale = math.clamp((Position.X - SliderRail.AbsolutePosition.X) / RailWidth, 0, 1)
		Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
	end

	Creator.AddSignal(SliderInput.InputBegan, function(Input)
		if
			(
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			)
			and not Dragging
		then
			if not Library:AcquireInteraction(SliderInteraction) then
				return
			end
			Dragging = true
			DragInput = Input
			UpdateFromPosition(Input.Position)
		end
	end, SliderFrame.Frame)
	Creator.AddSignal(SliderInput.SelectionGained, function()
		SliderFocusStroke.Transparency = 0
	end, SliderFrame.Frame)
	Creator.AddSignal(SliderInput.SelectionLost, function()
		SliderFocusStroke.Transparency = 1
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if GuiService.SelectedObject ~= SliderInput then
			return
		end
		if Input.KeyCode == Enum.KeyCode.Left or Input.KeyCode == Enum.KeyCode.DPadLeft then
			Slider:SetValue(Slider.Value - Slider.Step)
		elseif Input.KeyCode == Enum.KeyCode.Right or Input.KeyCode == Enum.KeyCode.DPadRight then
			Slider:SetValue(Slider.Value + Slider.Step)
		end
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Dragging
			and Input == DragInput
		then
			Dragging = false
			DragInput = nil
			Library:ReleaseInteraction(SliderInteraction)
		end
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		local IsDragInput = DragInput
			and (
				Input == DragInput
				or (
					DragInput.UserInputType == Enum.UserInputType.MouseButton1
					and Input.UserInputType == Enum.UserInputType.MouseMovement
				)
			)
		if
			Dragging
			and IsDragInput
		then
			UpdateFromPosition(Input.Position)
		end
	end, SliderFrame.Frame)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		assert(type(Value) == "number", "Slider - Value must be a number.")
		self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
		SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
		SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
		SliderDisplay.Text = tostring(self.Value)

		Library:SafeCallback(Slider.Callback, self.Value)
		Library:SafeCallback(Slider.Changed, self.Value)
	end

	function Slider:Destroy()
		Library:ReleaseInteraction(SliderInteraction)
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)

	Library.Options[Idx] = Slider
	return Slider
end

return Element
