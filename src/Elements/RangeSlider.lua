local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "RangeSlider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "RangeSlider - Missing Title.")
	assert(type(Config.Min) == "number", "RangeSlider - Minimum value must be a number.")
	assert(type(Config.Max) == "number", "RangeSlider - Maximum value must be a number.")
	assert(Config.Min < Config.Max, "RangeSlider - Minimum value must be less than maximum value.")
	
	local DefaultMin = Config.Default and Config.Default[1] or Config.Min
	local DefaultMax = Config.Default and Config.Default[2] or Config.Max
	
	assert(
		type(Config.Rounding) == "number"
			and Config.Rounding >= 0
			and Config.Rounding % 1 == 0,
		"RangeSlider - Rounding must be a non-negative integer."
	)

	local RangeSlider = {
		Value = { Min = DefaultMin, Max = DefaultMax },
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Step = Config.Step or (1 / (10 ^ Config.Rounding)),
		Callback = Config.Callback or function(Value) end,
		Type = "RangeSlider",
	}

	local Dragging = false
	local DraggingDot = nil -- "Min" or "Max"
	local DragInput
	local SliderInteraction = {}

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	SliderFrame.Frame.Selectable = false
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	RangeSlider.SetTitle = SliderFrame.SetTitle
	RangeSlider.SetDesc = SliderFrame.SetDesc

	local SliderDotMin = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ZIndex = 3,
		ThemeTag = {
			ImageColor3 = "Accent",
		},
	})

	local SliderDotMax = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ZIndex = 3,
		ThemeTag = {
			ImageColor3 = "Accent",
		},
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0),
	}, {
		SliderDotMin,
		SliderDotMax,
	})

	local SliderFill = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
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
		local ClickScale = math.clamp((Position.X - SliderRail.AbsolutePosition.X) / RailWidth, 0, 1)
		local ClickValue = RangeSlider.Min + ((RangeSlider.Max - RangeSlider.Min) * ClickScale)

		if not DraggingDot then
			-- Determine closest dot
			local ScaleMin = (RangeSlider.Value.Min - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)
			local ScaleMax = (RangeSlider.Value.Max - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)
			local DistMin = math.abs(ClickScale - ScaleMin)
			local DistMax = math.abs(ClickScale - ScaleMax)

			if DistMin < DistMax then
				DraggingDot = "Min"
			else
				DraggingDot = "Max"
			end
		end

		if DraggingDot == "Min" then
			local NewVal = math.min(ClickValue, RangeSlider.Value.Max)
			RangeSlider:SetValue(NewVal, RangeSlider.Value.Max)
		else
			local NewVal = math.max(ClickValue, RangeSlider.Value.Min)
			RangeSlider:SetValue(RangeSlider.Value.Min, NewVal)
		end
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
			DraggingDot = nil
			UpdateFromPosition(Input.Position)
		end
	end, SliderFrame.Frame)

	Creator.AddSignal(SliderInput.SelectionGained, function()
		SliderFocusStroke.Transparency = 0
	end, SliderFrame.Frame)

	Creator.AddSignal(SliderInput.SelectionLost, function()
		SliderFocusStroke.Transparency = 1
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Dragging
			and Input == DragInput
		then
			Dragging = false
			DragInput = nil
			DraggingDot = nil
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

	function RangeSlider:OnChanged(Func)
		RangeSlider.Changed = Func
		Func(RangeSlider.Value)
	end

	function RangeSlider:SetValue(MinVal, MaxVal)
		local RoundedMin = Library:Round(math.clamp(MinVal, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding)
		local RoundedMax = Library:Round(math.clamp(MaxVal, RangeSlider.Min, RangeSlider.Max), RangeSlider.Rounding)
		
		if RoundedMin > RoundedMax then
			RoundedMin = RoundedMax
		end
		
		RangeSlider.Value = { Min = RoundedMin, Max = RoundedMax }
		
		local ScaleMin = (RoundedMin - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)
		local ScaleMax = (RoundedMax - RangeSlider.Min) / (RangeSlider.Max - RangeSlider.Min)
		
		SliderDotMin.Position = UDim2.new(ScaleMin, -7, 0.5, 0)
		SliderDotMax.Position = UDim2.new(ScaleMax, -7, 0.5, 0)
		SliderFill.Position = UDim2.fromScale(ScaleMin, 0)
		SliderFill.Size = UDim2.fromScale(ScaleMax - ScaleMin, 1)
		SliderDisplay.Text = tostring(RoundedMin) .. " - " .. tostring(RoundedMax)

		Library:SafeCallback(RangeSlider.Callback, RangeSlider.Value)
		Library:SafeCallback(RangeSlider.Changed, RangeSlider.Value)
	end

	function RangeSlider:Destroy()
		Library:ReleaseInteraction(SliderInteraction)
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	RangeSlider:SetValue(DefaultMin, DefaultMax)

	Library.Options[Idx] = RangeSlider
	return RangeSlider
end

return Element
