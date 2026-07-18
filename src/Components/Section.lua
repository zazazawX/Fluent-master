local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)
local Spring = Creator.MotionGoal
local New = Creator.New

return function(Title, Parent)
	local Section = {
		Collapsed = false,
	}

	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Section.Layout,
	})

	local Chevron = New("ImageLabel", {
		Image = "rbxassetid://10709790948", -- lucide-chevron-down
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		ThemeTag = {
			ImageColor3 = "SubText",
		},
	})

	local HeaderButton = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.fromOffset(0, 2),
		Text = "",
	}, {
		New("TextLabel", {
			RichText = true,
			Text = Title,
			TextTransparency = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 18,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -24, 1, 0),
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
		Chevron,
	})

	Section.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		HeaderButton,
		Section.Container,
	})

	local HeightMotor = Flipper.SingleMotor.new(0)
	HeightMotor:onStep(function(value)
		Section.Container.Size = UDim2.new(1, 0, 0, value)
		Section.Root.Size = UDim2.new(1, 0, 0, value + 25)
	end)

	local function UpdateHeight()
		local Target = Section.Collapsed and 0 or Section.Layout.AbsoluteContentSize.Y
		HeightMotor:setGoal(Spring(Target, { frequency = 8 }))
	end

	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateHeight, Section.Root)

	Creator.AddSignal(HeaderButton.Activated, function()
		Section.Collapsed = not Section.Collapsed
		Chevron.Image = Section.Collapsed and "rbxassetid://10709791437" or "rbxassetid://10709790948" -- right or down
		UpdateHeight()
	end, Section.Root)

	Creator.AddSignal(Section.Root.Destroying, function()
		HeightMotor:destroy()
	end, Section.Root)

	return Section
end
