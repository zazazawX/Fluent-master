-- i will rewrite this someday
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)
local Assets = require(script.Parent.Assets)
local Components = script.Parent

local Spring = Creator.MotionGoal
local Instant = Flipper.Instant.new
local New = Creator.New

return function(Config)
	local Library = require(Root)
	local ViewportMargin = 12
	local MinimumWindowSize = Vector2.new(320, 300)
	local DefaultWindowSize = UDim2.fromOffset(580, 460)

	local function GetViewportSize()
		if Config.Parent and Config.Parent:IsA("GuiObject") then
			local ParentSize = Config.Parent.AbsoluteSize
			if ParentSize.X > 0 and ParentSize.Y > 0 then
				return ParentSize
			end
		end

		local ViewportSize = Camera.ViewportSize
		if ViewportSize.X <= 0 or ViewportSize.Y <= 0 then
			return Vector2.new(800, 600)
		end
		return ViewportSize
	end

	local function ConstrainSize(Size)
		local ViewportSize = GetViewportSize()
		local MaximumSize = Vector2.new(
			math.max(1, ViewportSize.X - ViewportMargin * 2),
			math.max(1, ViewportSize.Y - ViewportMargin * 2)
		)
		local MinimumSize = Vector2.new(
			math.min(MinimumWindowSize.X, MaximumSize.X),
			math.min(MinimumWindowSize.Y, MaximumSize.Y)
		)

		return Vector2.new(
			math.clamp(Size.X, MinimumSize.X, MaximumSize.X),
			math.clamp(Size.Y, MinimumSize.Y, MaximumSize.Y)
		)
	end

	local function ClampPosition(Position, Size)
		local ViewportSize = GetViewportSize()
		local MaxX = math.max(ViewportMargin, ViewportSize.X - Size.X - ViewportMargin)
		local MaxY = math.max(ViewportMargin, ViewportSize.Y - Size.Y - ViewportMargin)
		return Vector2.new(
			math.clamp(Position.X, ViewportMargin, MaxX),
			math.clamp(Position.Y, ViewportMargin, MaxY)
		)
	end

	local ConfigSize = Config.Size or DefaultWindowSize
	local InitialSize = ConstrainSize(Vector2.new(ConfigSize.X.Offset, ConfigSize.Y.Offset))
	local ViewportSize = GetViewportSize()
	local InitialPosition = ClampPosition(
		Vector2.new(
			ViewportSize.X / 2 - InitialSize.X / 2,
			ViewportSize.Y / 2 - InitialSize.Y / 2
		),
		InitialSize
	)

	local Window = {
		Minimized = false,
		Maximized = false,
		Size = UDim2.fromOffset(InitialSize.X, InitialSize.Y),
		CurrentPos = 0,
		ExpandedTabWidth = Config.TabWidth or 160,
		TabWidth = Config.TabWidth or 160,
		Compact = false,
		DrawerOpen = false,
		SidebarCollapsed = false,
		Position = UDim2.fromOffset(InitialPosition.X, InitialPosition.Y),
	}

	local Dragging, DragInput, MousePos, StartPos = false
	local Resizing, ResizeInput, ResizePos, ResizeStartSize = false
	local DragInteraction = {}
	local ResizeInteraction = {}
	local MinimizeNotif = false

	Window.AcrylicPaint = Acrylic.AcrylicPaint()

	local Selector = New("Frame", {
		Size = UDim2.fromOffset(4, 0),
		BackgroundColor3 = Color3.fromRGB(76, 194, 255),
		Position = UDim2.fromOffset(0, 17),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
	})

	local ResizeStartFrame = New("Frame", {
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 1, -20),
	})

	Window.TabHolder = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -36),
		Position = UDim2.fromOffset(0, 36),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
		}),
	})

	local TabFrameStroke = New("UIStroke", {
		Transparency = 1,
		ThemeTag = {
			Color = "DialogBorder",
		},
	})

	local TabFrame = New("Frame", {
		Size = UDim2.new(0, Window.TabWidth, 1, -66),
		Position = UDim2.new(0, 12, 0, 54),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ThemeTag = {
			BackgroundColor3 = "Dialog",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		TabFrameStroke,
		Window.TabHolder,
		Selector,
	})

	local CollapseButton = New("TextButton", {
		Size = UDim2.new(1, -8, 0, 28),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		Text = "☰",
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		TextSize = 16,
		Parent = TabFrame,
		ThemeTag = {
			TextColor3 = "Text",
		}
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
	})

	Creator.AddSignal(CollapseButton.MouseEnter, function()
		CollapseButton.BackgroundTransparency = 0.9
	end, CollapseButton)
	Creator.AddSignal(CollapseButton.MouseLeave, function()
		CollapseButton.BackgroundTransparency = 1
	end, CollapseButton)
	Creator.AddSignal(CollapseButton.Activated, function()
		Window.SidebarCollapsed = not Window.SidebarCollapsed
		ApplyResponsiveLayout()
	end, CollapseButton)

	Window.TabDisplay = New("TextLabel", {
		RichText = true,
		Text = "Tab",
		TextTransparency = 0,
		FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		TextSize = 28,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -Window.TabWidth - 42, 0, 28),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 56),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Window.ContainerHolder = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerAnim = New("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerCanvas = New("Frame", {
		Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
		BackgroundTransparency = 1,
	}, {
		Window.ContainerAnim,
		Window.ContainerHolder
	})

	Window.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = Window.Size,
		Position = Window.Position,
		Parent = Config.Parent,
	}, {
		Window.AcrylicPaint.Frame,
		Window.TabDisplay,
		Window.ContainerCanvas,
		TabFrame,
		ResizeStartFrame,
	})

	Window.TitleBar = require(script.Parent.TitleBar)({
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		Parent = Window.Root,
		Window = Window,
	})

	local DrawerScrim = New("TextButton", {
		Name = "DrawerScrim",
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Visible = false,
		Selectable = false,
		ZIndex = 30,
		Parent = Window.Root,
	})

	local NavigationButton = New("TextButton", {
		Name = "NavigationButton",
		Text = "☰",
		TextSize = 20,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.fromOffset(12, 53),
		BackgroundTransparency = 0.89,
		Visible = false,
		ZIndex = 45,
		Parent = Window.Root,
		ThemeTag = {
			BackgroundColor3 = "Element",
			TextColor3 = "Text",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}),
	})

	local function IsPointInside(GuiObject, Point)
		if not GuiObject or not GuiObject.Parent then
			return false
		end
		local Position = GuiObject.AbsolutePosition
		local Size = GuiObject.AbsoluteSize
		return Point.X >= Position.X
			and Point.X <= Position.X + Size.X
			and Point.Y >= Position.Y
			and Point.Y <= Position.Y + Size.Y
	end

	local function IsOverTitleBarControl(Point)
		for _, Button in ipairs({
			Window.TitleBar.CloseButton,
			Window.TitleBar.MaxButton,
			Window.TitleBar.MinButton,
		}) do
			if Button and IsPointInside(Button.Frame, Point) then
				return true
			end
		end
		return false
	end

	if require(Root).UseAcrylic then
		Window.AcrylicPaint.AddParent(Window.Root)
	end

	local ApplyResponsiveLayout = function() end

	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})

	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})

	Window.SelectorPosMotor = Flipper.SingleMotor.new(17)
	Window.SelectorSizeMotor = Flipper.SingleMotor.new(0)
	Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
	Window.ContainerPosMotor = Flipper.SingleMotor.new(94)

	local WindowMotors = {
		SizeMotor,
		PosMotor,
		Window.SelectorPosMotor,
		Window.SelectorSizeMotor,
		Window.ContainerBackMotor,
		Window.ContainerPosMotor,
	}

	SizeMotor:onStep(function(values)
		Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
		ApplyResponsiveLayout()
	end)

	PosMotor:onStep(function(values)
		Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
	end)

	local LastValue = 0
	local LastTime = 0
	Window.SelectorPosMotor:onStep(function(Value)
		Selector.Position = UDim2.new(0, 0, 0, Value + 17)
		local Now = tick()
		local DeltaTime = Now - LastTime

		if LastValue ~= nil then
			Window.SelectorSizeMotor:setGoal(Spring((math.abs(Value - LastValue) / (DeltaTime * 60)) + 16))
			LastValue = Value
		end
		LastTime = Now
	end)

	Window.SelectorSizeMotor:onStep(function(Value)
		Selector.Size = UDim2.new(0, 4, 0, Value)
	end)

	Window.ContainerBackMotor:onStep(function(Value)
		Window.ContainerAnim.GroupTransparency = Value
	end)

	Window.ContainerPosMotor:onStep(function(Value)
		Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
	end)

	local OldSizeX
	local OldSizeY
	Window.Maximize = function(Value, NoPos, IsInstant)
		local WasMaximized = Window.Maximized
		if Value and not WasMaximized then
			OldSizeX = Window.Size.X.Offset
			OldSizeY = Window.Size.Y.Offset
		end

		Window.Maximized = Value
		Window.TitleBar.MaxButton.Frame.Icon.Image = Value and Assets.Restore or Assets.Max

		local ViewportSize = GetViewportSize()
		local RestoredSize = ConstrainSize(Vector2.new(
			OldSizeX or Window.Size.X.Offset,
			OldSizeY or Window.Size.Y.Offset
		))
		local SizeX = Value and ViewportSize.X or RestoredSize.X
		local SizeY = Value and ViewportSize.Y or RestoredSize.Y
		local Goal = IsInstant and Flipper.Instant.new or Spring
		SizeMotor:setGoal({
			X = Goal(SizeX, { frequency = 6 }),
			Y = Goal(SizeY, { frequency = 6 }),
		})
		Window.Size = UDim2.fromOffset(SizeX, SizeY)

		if not Value then
			local RestoredPosition = ClampPosition(
				Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset),
				Vector2.new(SizeX, SizeY)
			)
			Window.Position = UDim2.fromOffset(RestoredPosition.X, RestoredPosition.Y)
		end

		if not NoPos then
			PosMotor:setGoal({
				X = Goal(Value and 0 or Window.Position.X.Offset, { frequency = 6 }),
				Y = Goal(Value and 0 or Window.Position.Y.Offset, { frequency = 6 }),
			})
		end
		ApplyResponsiveLayout()
	end

	Creator.AddSignal(Window.TitleBar.Frame.InputBegan, function(Input)
		if
			(
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			)
			and not Dragging
			and not Library.DialogOpen
			and not IsOverTitleBarControl(Input.Position)
		then
			if not Library:AcquireInteraction(DragInteraction) then
				return
			end
			Dragging = true
			MousePos = Input.Position
			StartPos = Window.Root.Position
			if Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end

			if Window.Maximized then
				local PointerPosition = Input.Position
				local RestoreWidth = OldSizeX or InitialSize.X
				local RestoreHeight = OldSizeY or InitialSize.Y
				local HorizontalRatio = math.clamp(
					PointerPosition.X / math.max(Window.Root.AbsoluteSize.X, 1),
					0,
					1
				)
				StartPos = UDim2.fromOffset(
					PointerPosition.X - RestoreWidth * HorizontalRatio,
					PointerPosition.Y - math.min(24, RestoreHeight / 2)
				)
			end

			local DragEndConnection
			DragEndConnection = Creator.AddSignal(Input.Changed, function()
				if
					Input.UserInputState == Enum.UserInputState.End
					or Input.UserInputState == Enum.UserInputState.Cancel
				then
					Dragging = false
					DragInput = nil
					Library:ReleaseInteraction(DragInteraction)
					Creator.RemoveSignal(DragEndConnection)
				end
			end, Window.Root)
		end
	end, Window.Root)

	Creator.AddSignal(Window.TitleBar.Frame.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		elseif Input.UserInputType == Enum.UserInputType.Touch and (not Dragging or Input == DragInput) then
			DragInput = Input
		end
	end, Window.Root)

	Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
		if
			(
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			)
			and not Resizing
			and not Library.DialogOpen
		then
			if not Library:AcquireInteraction(ResizeInteraction) then
				return
			end
			Resizing = true
			ResizeInput = Input
			ResizePos = Input.Position
			ResizeStartSize = Window.Size
		end
	end, Window.Root)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			if Window.Maximized then
				Window.Maximize(false, true, true)
			end

			local WindowSize = Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset)
			local TargetPosition = ClampPosition(
				Vector2.new(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y),
				WindowSize
			)
			Window.Position = UDim2.fromOffset(TargetPosition.X, TargetPosition.Y)
			PosMotor:setGoal({
				X = Instant(Window.Position.X.Offset),
				Y = Instant(Window.Position.Y.Offset),
			})
		end

		local IsResizeInput = ResizeInput
			and (
				Input == ResizeInput
				or (
					ResizeInput.UserInputType == Enum.UserInputType.MouseButton1
					and Input.UserInputType == Enum.UserInputType.MouseMovement
				)
			)
		if IsResizeInput and Resizing then
			local Delta = Input.Position - ResizePos
			local StartSize = ResizeStartSize or Window.Size
			local TargetSizeClamped = ConstrainSize(Vector2.new(
				StartSize.X.Offset + Delta.X,
				StartSize.Y.Offset + Delta.Y
			))

			SizeMotor:setGoal({
				X = Flipper.Instant.new(TargetSizeClamped.X),
				Y = Flipper.Instant.new(TargetSizeClamped.Y),
			})
			Window.Size = UDim2.fromOffset(TargetSizeClamped.X, TargetSizeClamped.Y)

			local ClampedPosition = ClampPosition(
				Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset),
				TargetSizeClamped
			)
			Window.Position = UDim2.fromOffset(ClampedPosition.X, ClampedPosition.Y)
			PosMotor:setGoal({
				X = Instant(ClampedPosition.X),
				Y = Instant(ClampedPosition.Y),
			})
		end
	end, Window.Root)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Resizing
			and (
				Input == ResizeInput
				or (
					ResizeInput
					and ResizeInput.UserInputType == Enum.UserInputType.MouseButton1
					and Input.UserInputType == Enum.UserInputType.MouseButton1
				)
			)
		then
			Resizing = false
			ResizeInput = nil
			ResizeStartSize = nil
			Library:ReleaseInteraction(ResizeInteraction)
			Window.Size = UDim2.fromOffset(SizeMotor:getValue().X, SizeMotor:getValue().Y)
		end
	end, Window.Root)

	Creator.AddSignal(Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, Window.TabHolder.UIListLayout.AbsoluteContentSize.Y)
	end, Window.Root)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			type(Library.MinimizeKeybind) == "table"
			and Library.MinimizeKeybind.Type == "Keybind"
			and not UserInputService:GetFocusedTextBox()
		then
			if Input.KeyCode.Name == Library.MinimizeKeybind.Value then
				Window:Minimize()
			end
		elseif Input.KeyCode == Library.MinimizeKey and not UserInputService:GetFocusedTextBox() then
			Window:Minimize()
		end
	end, Window.Root)

	function Window:Minimize()
		if Library.DialogOpen then
			return
		end
		Window.Minimized = not Window.Minimized
		if Window.Minimized and Library.ActiveDropdown then
			Library.ActiveDropdown:Close()
		end
		if Window.Minimized and Window.DrawerOpen then
			Window:SetNavigationDrawer(false)
		end
		Window.Root.Visible = not Window.Minimized
		if not MinimizeNotif then
			MinimizeNotif = true
			local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
			Library:Notify({
				Title = "Interface",
				Content = "Press " .. Key .. " to toggle the interface.",
				Duration = 6
			})
		end
	end

	function Window:Destroy()
		for _, Motor in ipairs(WindowMotors) do
			pcall(function()
				Motor:destroy()
			end)
		end
		Library:ReleaseInteraction(DragInteraction)
		Library:ReleaseInteraction(ResizeInteraction)
		Library.InteractionOwner = nil
		if Library.ActiveDropdown then
			Library.ActiveDropdown:Close()
		end
		Library.ActiveDialog = nil
		Library.DialogOpen = false
		if require(Root).UseAcrylic then
			Window.AcrylicPaint.Model:Destroy()
		end
		Window.Root:Destroy()
		local index = table.find(Library.Windows, Window)
		if index then
			table.remove(Library.Windows, index)
		end
		if Library.Window == Window then
			Library.Window = Library.Windows[1]
		end
	end

	local DialogModule = require(Components.Dialog):Init(Window)
	function Window:Dialog(Config)
		local Dialog = DialogModule:Create()
		Dialog.Title.Text = Config.Title

		local Content = New("TextLabel", {
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Text = Config.Content,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(20, 60),
			BackgroundTransparency = 1,
			Parent = Dialog.Root,
			ClipsDescendants = false,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 165),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.Root,
		})

		Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
		if Content.TextBounds.X + 40 > Window.Size.X.Offset - 120 then
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, 165)
			Content.TextWrapped = true
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, Content.TextBounds.Y + 150)
		end

		Dialog:FitToWindow()

		for _, Button in next, Config.Buttons do
			Dialog:Button(Button.Title, Button.Callback)
		end

		Dialog:Open()
	end

	local TabModule = require(Components.Tab):Init(Window)

	function Window:SetNavigationDrawer(Open)
		Open = Open == true and Window.Compact
		if Window.DrawerOpen == Open then
			return
		end
		if Open and Library.ActiveDropdown then
			Library.ActiveDropdown:Close()
		end

		Window.DrawerOpen = Open
		local DrawerWidth = Window.DrawerWidth or 200
		local TargetPosition = UDim2.fromOffset(Open and 12 or -DrawerWidth - 12, 54)
		if Open then
			Window.PreviousSelection = GuiService.SelectedObject
			DrawerScrim.Visible = true
			NavigationButton.Visible = false
		end
		Creator.PlayTween(
			TabFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = TargetPosition }
		)

		if Open then
			task.defer(function()
				local SelectedFrame = TabModule:GetSelectedFrame()
				if Window.DrawerOpen and SelectedFrame and SelectedFrame.Parent then
					GuiService.SelectedObject = SelectedFrame
				end
			end)
		else
			local PreviousSelection = Window.PreviousSelection
			Window.PreviousSelection = nil
			if PreviousSelection and PreviousSelection.Parent then
				GuiService.SelectedObject = PreviousSelection
			elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(TabFrame) then
				GuiService.SelectedObject = nil
			end
			task.delay(Creator.MotionDuration(0.2), function()
				if not Window.DrawerOpen and Window.Root.Parent then
					DrawerScrim.Visible = false
					NavigationButton.Visible = Window.Compact
				end
			end)
		end
	end

	Creator.AddSignal(NavigationButton.Activated, function()
		Window:SetNavigationDrawer(true)
	end, Window.Root)
	Creator.AddSignal(DrawerScrim.Activated, function()
		Window:SetNavigationDrawer(false)
	end, Window.Root)

	ApplyResponsiveLayout = function()
		local WindowWidth = Window.Root.AbsoluteSize.X
		if WindowWidth <= 0 then
			WindowWidth = Window.Size.X.Offset
		end

		local Compact = WindowWidth < 520 or GetViewportSize().X < 640
		local EffectiveTabWidth = Compact and 0 or (Window.SidebarCollapsed and 48 or math.min(
			Window.ExpandedTabWidth,
			math.max(80, WindowWidth - 280)
		))
		local DrawerWidth = math.min(240, math.max(180, WindowWidth * 0.72))
		Window.Compact = Compact
		Window.TabWidth = EffectiveTabWidth
		Window.DrawerWidth = DrawerWidth

		if Compact then
			CollapseButton.Visible = false
			TabFrame.Size = UDim2.new(0, DrawerWidth, 1, -66)
			TabFrame.Position = UDim2.fromOffset(Window.DrawerOpen and 12 or -DrawerWidth - 12, 54)
			TabFrame.BackgroundTransparency = 0.05
			TabFrameStroke.Transparency = 0.5
			TabFrame.ZIndex = 40
			Window.TabDisplay.Position = UDim2.fromOffset(56, 56)
			Window.TabDisplay.Size = UDim2.new(1, -72, 0, 28)
			Window.ContainerCanvas.Size = UDim2.new(1, -24, 1, -102)
			Window.ContainerCanvas.Position = UDim2.fromOffset(12, 90)
			NavigationButton.Visible = not Window.DrawerOpen
			DrawerScrim.Visible = Window.DrawerOpen
		else
			CollapseButton.Visible = true
			Window.DrawerOpen = false
			TabFrame.Size = UDim2.new(0, EffectiveTabWidth, 1, -66)
			TabFrame.Position = UDim2.fromOffset(12, 54)
			TabFrame.BackgroundTransparency = 1
			TabFrameStroke.Transparency = 1
			TabFrame.ZIndex = 1
			Window.TabDisplay.Position = UDim2.fromOffset(EffectiveTabWidth + 26, 56)
			Window.TabDisplay.Size = UDim2.new(1, -EffectiveTabWidth - 42, 0, 28)
			Window.ContainerCanvas.Size = UDim2.new(1, -EffectiveTabWidth - 32, 1, -102)
			Window.ContainerCanvas.Position = UDim2.fromOffset(EffectiveTabWidth + 26, 90)
			NavigationButton.Visible = false
			DrawerScrim.Visible = false
		end
		Window.TabDisplay.TextSize = Compact and 22 or 28

		local ResizeHandleSize = UserInputService.TouchEnabled and 32 or 20
		ResizeStartFrame.Size = UDim2.fromOffset(ResizeHandleSize, ResizeHandleSize)
		ResizeStartFrame.Position = UDim2.new(1, -ResizeHandleSize, 1, -ResizeHandleSize)
		ResizeStartFrame.Visible = not Window.Maximized
		TabModule:SetCompact(Compact or Window.SidebarCollapsed == true)
	end

	local function UpdateViewport()
		local ViewportSize = GetViewportSize()
		if Window.Maximized then
			Window.Size = UDim2.fromOffset(ViewportSize.X, ViewportSize.Y)
			SizeMotor:setGoal({
				X = Instant(ViewportSize.X),
				Y = Instant(ViewportSize.Y),
			})
			PosMotor:setGoal({
				X = Instant(0),
				Y = Instant(0),
			})
		else
			local NewSize = ConstrainSize(Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset))
			local NewPosition = ClampPosition(
				Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset),
				NewSize
			)
			Window.Size = UDim2.fromOffset(NewSize.X, NewSize.Y)
			Window.Position = UDim2.fromOffset(NewPosition.X, NewPosition.Y)
			SizeMotor:setGoal({
				X = Instant(NewSize.X),
				Y = Instant(NewSize.Y),
			})
			PosMotor:setGoal({
				X = Instant(NewPosition.X),
				Y = Instant(NewPosition.Y),
			})
		end
		ApplyResponsiveLayout()
	end

	function Window:AddTab(TabConfig)
		return TabModule:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
	end

	function Window:SelectTab(Tab)
		TabModule:SelectTab(Tab)
	end

	function Window:SetSize(Size, IsInstant)
		assert(typeof(Size) == "UDim2", "SetSize - Size must be a UDim2")
		if Window.Maximized then
			Window.Maximize(false, false, true)
		end
		local NewSize = ConstrainSize(Vector2.new(Size.X.Offset, Size.Y.Offset))
		local Goal = IsInstant and Instant or Spring
		Window.Size = UDim2.fromOffset(NewSize.X, NewSize.Y)
		SizeMotor:setGoal({
			X = Goal(NewSize.X, { frequency = 6 }),
			Y = Goal(NewSize.Y, { frequency = 6 }),
		})
		local NewPosition = ClampPosition(
			Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset),
			NewSize
		)
		Window.Position = UDim2.fromOffset(NewPosition.X, NewPosition.Y)
		PosMotor:setGoal({
			X = Goal(NewPosition.X, { frequency = 6 }),
			Y = Goal(NewPosition.Y, { frequency = 6 }),
		})
	end

	Creator.AddSignal(UserInputService.InputBegan, function(Input, Processed)
		if Processed or UserInputService:GetFocusedTextBox() then
			return
		end

		local KeyCode = Input.KeyCode
		if KeyCode == Enum.KeyCode.Escape or KeyCode == Enum.KeyCode.ButtonB then
			if Library.ActiveDialog then
				task.spawn(function()
					Library.ActiveDialog:Close()
				end)
			elseif Library.ActiveDropdown then
				Library.ActiveDropdown:Close()
			elseif Window.DrawerOpen then
				Window:SetNavigationDrawer(false)
			end
			return
		end
		if Library.DialogOpen then
			return
		end

		if Window.Compact and (KeyCode == Enum.KeyCode.M or KeyCode == Enum.KeyCode.ButtonX) then
			Window:SetNavigationDrawer(not Window.DrawerOpen)
			return
		end

		local Direction
		if KeyCode == Enum.KeyCode.PageUp or KeyCode == Enum.KeyCode.ButtonL1 then
			Direction = -1
		elseif KeyCode == Enum.KeyCode.PageDown or KeyCode == Enum.KeyCode.ButtonR1 then
			Direction = 1
		end
		if Direction then
			local SelectedTab = TabModule:SelectRelative(Direction)
			if Input.UserInputType == Enum.UserInputType.Gamepad1 and SelectedTab and not Window.Compact then
				GuiService.SelectedObject = SelectedTab.Frame
			end
		end
	end, Window.Root)

	Creator.AddSignal(Window.TabHolder:GetPropertyChangedSignal("CanvasPosition"), function()
		LastValue = TabModule:GetCurrentTabPos() + 16
		LastTime = 0
		Window.SelectorPosMotor:setGoal(Instant(TabModule:GetCurrentTabPos()))
	end, Window.Root)

	Creator.AddSignal(Camera:GetPropertyChangedSignal("ViewportSize"), UpdateViewport, Window.Root)
	if Config.Parent and Config.Parent:IsA("GuiObject") then
		Creator.AddSignal(Config.Parent:GetPropertyChangedSignal("AbsoluteSize"), UpdateViewport, Window.Root)
	end
	Creator.AddSignal(Window.Root:GetPropertyChangedSignal("AbsoluteSize"), ApplyResponsiveLayout, Window.Root)
	function Window:AddThemeCustomizer()
		local Themes = require(Root.Themes)
		if not Themes.Custom then
			local CustomTheme = {}
			for k, v in pairs(Themes.Dark) do
				CustomTheme[k] = v
			end
			CustomTheme.Name = "Custom"
			Themes.Custom = CustomTheme
			table.insert(Library.Themes, "Custom")
		end

		local CustomTab = Window:AddTab({ Title = "Theme Editor", Icon = "palette" })

		CustomTab:AddDropdown("CustomizerActiveTheme", {
			Title = "Active Theme",
			Description = "Select the interface theme",
			Values = Library.Themes,
			Default = Library.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
			end
		})

		CustomTab:AddSection("Custom Theme Colors")

		local TargetProperties = {
			{ Name = "Accent", Type = "Color3" },
			{ Name = "AcrylicMain", Type = "Color3" },
			{ Name = "Element", Type = "Color3" },
			{ Name = "Text", Type = "Color3" },
			{ Name = "SubText", Type = "Color3" },
			{ Name = "SliderRail", Type = "Color3" },
			{ Name = "DropdownHolder", Type = "Color3" },
			{ Name = "Dialog", Type = "Color3" },
		}

		for _, Prop in ipairs(TargetProperties) do
			CustomTab:AddColorpicker("Customizer_" .. Prop.Name, {
				Title = Prop.Name,
				Default = Themes.Custom[Prop.Name],
				Callback = function(Value)
					Themes.Custom[Prop.Name] = Value
					if Library.Theme == "Custom" then
						Creator.UpdateTheme()
					end
				end
			})
		end

		CustomTab:AddSection("Export Theme")
		CustomTab:AddButton({
			Title = "Export Theme Code",
			Description = "Copies the custom theme Lua code to clipboard",
			Callback = function()
				local luaCode = "return {\n\tName = \"Custom\",\n"
				for k, v in pairs(Themes.Custom) do
					if k ~= "Name" then
						if typeof(v) == "Color3" then
							luaCode = luaCode .. string.format("\t%s = Color3.fromRGB(%d, %d, %d),\n", k, v.R * 255, v.G * 255, v.B * 255)
						elseif typeof(v) == "number" then
							luaCode = luaCode .. string.format("\t%s = %s,\n", k, tostring(v))
						end
					end
				end
				luaCode = luaCode .. "}"

				local SetClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
				if SetClipboard then
					pcall(SetClipboard, luaCode)
					Library:Notify({
						Title = "Exported",
						Content = "Custom theme code copied to clipboard!",
						Duration = 5
					})
				else
					Library:Notify({
						Title = "Exported",
						Content = "Your executor does not support setclipboard.",
						Duration = 5
					})
				end
			end
		})
	end

	UpdateViewport()

	return Window
end
