local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local New = Creator.New

local Dialog = {
	Window = nil,
}

function Dialog:Init(Window)
	local self = setmetatable({}, { __index = Dialog })
	self.Window = Window
	return self
end

function Dialog:Create()
	local window = self.Window or require(Root).Window
	local NewDialog = {
		Buttons = 0,
		TargetScale = 1,
		Closing = false,
		Closed = false,
		ButtonFrames = {},
		Window = window,
	}

	NewDialog.TintFrame = New("TextButton", {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Selectable = false,
		ZIndex = 50,
		Parent = window.Root,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})

	local TintMotor, TintTransparency = Creator.SpringMotor(1, NewDialog.TintFrame, "BackgroundTransparency", true)

	NewDialog.ButtonHolder = New("Frame", {
		Size = UDim2.new(1, -40, 1, -40),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	NewDialog.ButtonHolderFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		Position = UDim2.new(0, 0, 1, -70),
		ThemeTag = {
			BackgroundColor3 = "DialogHolder",
		},
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			ThemeTag = {
				BackgroundColor3 = "DialogHolderLine",
			},
		}),
		NewDialog.ButtonHolder,
	})

	NewDialog.Title = New("TextLabel", {
		FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		),
		Text = "Dialog",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(20, 25),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewDialog.Scale = New("UIScale", {
		Scale = 1,
	})

	local ScaleMotor, Scale = Creator.SpringMotor(1.1, NewDialog.Scale, "Scale")

	NewDialog.Root = New("CanvasGroup", {
		Size = UDim2.fromOffset(300, 165),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 1,
		Parent = NewDialog.TintFrame,
		ThemeTag = {
			BackgroundColor3 = "Dialog",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = {
				Color = "DialogBorder",
			},
		}),
		NewDialog.Scale,
		NewDialog.Title,
		NewDialog.ButtonHolderFrame,
	})

	local RootMotor, RootTransparency = Creator.SpringMotor(1, NewDialog.Root, "GroupTransparency")

	function NewDialog:SetScale(Value)
		NewDialog.TargetScale = math.clamp(Value or 1, 0.35, 1)
		ScaleMotor:stop()
		NewDialog.Scale.Scale = NewDialog.TargetScale
	end

	function NewDialog:FitToWindow(Padding)
		local Window = self.Window
		if not Window or not Window.Root then
			return
		end

		Padding = Padding or 12
		local AvailableSize = Window.Root.AbsoluteSize
		if AvailableSize.X <= 0 or AvailableSize.Y <= 0 then
			AvailableSize = Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset)
		end

		local MinimumSize = Vector2.new(1, 1)
		local SizeConstraint = NewDialog.Root:FindFirstChildOfClass("UISizeConstraint")
		if SizeConstraint then
			MinimumSize = SizeConstraint.MinSize
		end
		local DialogSize = Vector2.new(
			math.max(NewDialog.Root.Size.X.Offset, MinimumSize.X, 1),
			math.max(NewDialog.Root.Size.Y.Offset, MinimumSize.Y, 1)
		)

		NewDialog:SetScale(math.min(
			1,
			math.max(1, AvailableSize.X - Padding * 2) / DialogSize.X,
			math.max(1, AvailableSize.Y - Padding * 2) / DialogSize.Y
		))
	end

	Creator.AddSignal(NewDialog.Root:GetPropertyChangedSignal("Size"), function()
		NewDialog:FitToWindow()
	end, NewDialog.TintFrame)
	Creator.AddSignal(window.Root:GetPropertyChangedSignal("AbsoluteSize"), function()
		NewDialog:FitToWindow()
	end, NewDialog.TintFrame)
	NewDialog:FitToWindow()

	function NewDialog:Open()
		local Library = require(Root)
		if NewDialog.Closing or NewDialog.Closed then
			return
		end
		if Library.ActiveDialog and Library.ActiveDialog ~= NewDialog then
			Library.ActiveDialog:Close()
		end
		if Library.ActiveDropdown then
			Library.ActiveDropdown:Close()
		end
		if self.Window.DrawerOpen and self.Window.SetNavigationDrawer then
			self.Window:SetNavigationDrawer(false)
		end
		local LastInput = UserInputService:GetLastInputType()
		local GamepadNavigation = LastInput.Name:match("Gamepad") ~= nil
		NewDialog.PreviousSelection = GamepadNavigation and GuiService.SelectedObject or nil
		if not GamepadNavigation then GuiService.SelectedObject = nil end
		Library.ActiveDialog = NewDialog
		Library.DialogOpen = true
		TintTransparency(0.75)
		RootTransparency(0)
		if NewDialog.TargetScale < 1 then
			ScaleMotor:stop()
			NewDialog.Scale.Scale = NewDialog.TargetScale
		else
			NewDialog.Scale.Scale = 1.1
			Scale(1)
		end
		if GamepadNavigation then
			task.defer(function()
				local FirstButton = NewDialog.ButtonFrames[1]
				if Library.ActiveDialog == NewDialog and FirstButton and FirstButton.Parent then
					GuiService.SelectedObject = FirstButton
				end
			end)
		end
	end

	function NewDialog:Close()
		if NewDialog.Closing or NewDialog.Closed then
			return
		end
		NewDialog.Closing = true
		local Library = require(Root)
		TintTransparency(1)
		RootTransparency(1)
		if NewDialog.TargetScale < 1 then
			ScaleMotor:stop()
			NewDialog.Scale.Scale = NewDialog.TargetScale
		else
			Scale(1.1)
		end
		local Stroke = NewDialog.Root:FindFirstChildOfClass("UIStroke")
		if Stroke then
			Stroke:Destroy()
		end
		task.wait(Creator.MotionDuration(0.15))
		if NewDialog.TintFrame.Parent then
			NewDialog.TintFrame:Destroy()
		end
		NewDialog.Closed = true
		NewDialog.Closing = false
		if Library.ActiveDialog == NewDialog then
			Library.ActiveDialog = nil
		end
		Library.DialogOpen = Library.ActiveDialog ~= nil
		local PreviousSelection = NewDialog.PreviousSelection
		if PreviousSelection and PreviousSelection.Parent then
			GuiService.SelectedObject = PreviousSelection
		end
	end

	function NewDialog:Button(Title, Callback)
		NewDialog.Buttons = NewDialog.Buttons + 1
		Title = Title or "Button"
		Callback = Callback or function() end

		local Button = require(Root.Components.Button)("", NewDialog.ButtonHolder, true)
		Button.Title.Text = Title
		table.insert(NewDialog.ButtonFrames, Button.Frame)

		for _, Btn in next, NewDialog.ButtonHolder:GetChildren() do
			if Btn:IsA("TextButton") then
				Btn.Size =
					UDim2.new(1 / NewDialog.Buttons, -(((NewDialog.Buttons - 1) * 10) / NewDialog.Buttons), 0, 32)
			end
		end

		Creator.AddSignal(Button.Frame.Activated, function()
			require(Root):SafeCallback(Callback)
			pcall(function()
				NewDialog:Close()
			end)
		end, NewDialog.TintFrame)

		return Button
	end

	return NewDialog
end

return Dialog
