local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Idx, Config)
	local Library = self.Library
	local Searchable = Config.Search == true or (Config.Search ~= false and #(Config.Values or {}) > 6)

	local Dropdown = {
		Values = Config.Values or {},
		Value = nil,
		Multi = Config.Multi == true,
		Buttons = {},
		OptionButtons = {},
		Opened = false,
		Destroyed = false,
		Type = "Dropdown",
		Callback = Config.Callback or function() end,
	}

	local function NormalizeValue(Value)
		if Dropdown.Multi then
			local Normalized = {}
			if type(Value) ~= "table" then
				return Normalized
			end

			for Key, Selected in next, Value do
				local Candidate = type(Key) == "number" and Selected or Key
				local IsSelected = type(Key) == "number" or Selected == true
				if IsSelected and table.find(Dropdown.Values, Candidate) then
					Normalized[Candidate] = true
				end
			end
			return Normalized
		end

		if type(Value) == "number" then
			return Dropdown.Values[Value]
		end
		if table.find(Dropdown.Values, Value) then
			return Value
		end
		return nil
	end

	Dropdown.Value = NormalizeValue(Config.Default)

	local DropdownFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false, Config.Tooltip)
	DropdownFrame.Frame.Selectable = false
	DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Dropdown.SetTitle = DropdownFrame.SetTitle
	Dropdown.SetDesc = DropdownFrame.SetDesc

	local DropdownDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "Value",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local DropdownIco = New("ImageLabel", {
		Image = "rbxassetid://10709790948",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			ImageColor3 = "SubText",
		},
	})

	local DropdownInner = New("TextButton", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Selectable = true,
		Parent = DropdownFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "DropdownFrame",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		DropdownIco,
		DropdownDisplay,
	})

	local DropdownListLayout = New("UIListLayout", {
		Padding = UDim.new(0, 3),
	})

	local DropdownScrollFrame = New("ScrollingFrame", {
		Size = Searchable and UDim2.new(1, -10, 1, -41) or UDim2.new(1, -5, 1, -10),
		Position = Searchable and UDim2.new(0, 5, 0, 36) or UDim2.fromOffset(5, 5),
		BackgroundTransparency = 1,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 4,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
	}, {
		DropdownListLayout,
	})

	local SearchBox
	local DropdownHolderFrame = New("Frame", {
		Size = UDim2.fromScale(1, 0.6),
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		DropdownScrollFrame,
		New("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "DropdownBorder",
			},
		}),
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=5554236805",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
			Position = UDim2.fromOffset(-15, -15),
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.1,
		}),
	})

	if Searchable then
		SearchBox = require(Components.Textbox)(DropdownHolderFrame, true)
		SearchBox.Frame.Position = UDim2.new(0, 5, 0, 5)
		SearchBox.Frame.Size = UDim2.new(1, -10, 0, 26)
		SearchBox.Input.PlaceholderText = "Search..."
		SearchBox.Input.Text = ""
	end

	local PopupParent = Library:GetLayer("Overlay")
	local DropdownHolderCanvas = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 300),
		Parent = PopupParent,
		Visible = false,
	}, {
		DropdownHolderFrame,
		New("UISizeConstraint", {
			MinSize = Vector2.new(0, 0),
		}),
	})
	table.insert(Library.OpenFrames, DropdownHolderCanvas)

	local ViewportMargin = 8
	local function GetViewportRect()
		if PopupParent:IsA("GuiObject") then
			local ViewportSize = PopupParent.AbsoluteSize
			if ViewportSize.X > 0 and ViewportSize.Y > 0 then
				return PopupParent.AbsolutePosition, ViewportSize
			end
		end

		local ViewportSize = Camera.ViewportSize
		if ViewportSize.X <= 0 or ViewportSize.Y <= 0 then
			ViewportSize = Vector2.new(800, 600)
		end
		return Vector2.new(0, 0), ViewportSize
	end

	local function RecalculateListPosition()
		local ViewportOrigin, ViewportSize = GetViewportRect()
		local PopupSize = Vector2.new(
			DropdownHolderCanvas.Size.X.Offset,
			DropdownHolderCanvas.Size.Y.Offset
		)
		local TriggerPosition = DropdownInner.AbsolutePosition - ViewportOrigin
		local TriggerSize = DropdownInner.AbsoluteSize
		local BelowY = TriggerPosition.Y + TriggerSize.Y + 4
		local AboveY = TriggerPosition.Y - PopupSize.Y - 4
		local TargetY = BelowY

		if BelowY + PopupSize.Y > ViewportSize.Y - ViewportMargin and AboveY >= ViewportMargin then
			TargetY = AboveY
		else
			TargetY = math.clamp(
				TargetY,
				ViewportMargin,
				math.max(ViewportMargin, ViewportSize.Y - PopupSize.Y - ViewportMargin)
			)
		end

		local TargetX = math.clamp(
			TriggerPosition.X,
			ViewportMargin,
			math.max(ViewportMargin, ViewportSize.X - PopupSize.X - ViewportMargin)
		)
		DropdownHolderCanvas.Position = UDim2.fromOffset(TargetX, TargetY)
	end

	local ListSizeX = 0
	local function RecalculateListSize()
		local _, ViewportSize = GetViewportRect()
		local MaximumWidth = math.max(1, ViewportSize.X - ViewportMargin * 2)
		local MinimumWidth = math.min(170, MaximumWidth)
		local TargetWidth = math.clamp(
			math.max(ListSizeX, DropdownInner.AbsoluteSize.X),
			MinimumWidth,
			MaximumWidth
		)
		local MaximumHeight = math.max(1, math.min(392, ViewportSize.Y - ViewportMargin * 2))
		local MinimumHeight = math.min(44 + (Searchable and 36 or 0), MaximumHeight)
		local TargetHeight = math.clamp(
			DropdownListLayout.AbsoluteContentSize.Y + 10 + (Searchable and 36 or 0),
			MinimumHeight,
			MaximumHeight
		)
		DropdownHolderCanvas.Size = UDim2.fromOffset(TargetWidth, TargetHeight)
	end

	local function RecalculateCanvasSize()
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y)
	end

	local function FilterItems(SearchText)
		local LowerSearch = string.lower(SearchText or "")
		for _, Btn in ipairs(Dropdown.OptionButtons) do
			local Label = Btn:FindFirstChild("ButtonLabel", true)
			if Label and Label:IsA("TextLabel") then
				local LowerText = string.lower(Label.Text)
				if LowerSearch == "" or string.find(LowerText, LowerSearch, 1, true) then
					Btn.Visible = true
				else
					Btn.Visible = false
				end
			end
		end
	end

	RecalculateListSize()
	RecalculateListPosition()

	Creator.AddSignal(DropdownInner:GetPropertyChangedSignal("AbsolutePosition"), RecalculateListPosition, DropdownFrame.Frame)
	Creator.AddSignal(DropdownInner:GetPropertyChangedSignal("AbsoluteSize"), function()
		RecalculateListSize()
		RecalculateListPosition()
	end, DropdownFrame.Frame)
	Creator.AddSignal(Camera:GetPropertyChangedSignal("ViewportSize"), function()
		RecalculateListSize()
		RecalculateListPosition()
	end, DropdownFrame.Frame)
	Creator.AddSignal(PopupParent:GetPropertyChangedSignal("AbsolutePosition"), RecalculateListPosition, DropdownFrame.Frame)
	Creator.AddSignal(PopupParent:GetPropertyChangedSignal("AbsoluteSize"), function()
		RecalculateListSize()
		RecalculateListPosition()
	end, DropdownFrame.Frame)
	Creator.AddSignal(DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		RecalculateCanvasSize()
		RecalculateListSize()
	end, DropdownFrame.Frame)

	if Searchable and SearchBox then
		Creator.AddSignal(SearchBox.Input:GetPropertyChangedSignal("Text"), function()
			FilterItems(SearchBox.Input.Text)
		end, DropdownFrame.Frame)
	end

	Creator.AddSignal(DropdownInner.Activated, function()
		if Dropdown.Opened then
			Dropdown:Close()
		else
			Dropdown:Open()
		end
	end, DropdownFrame.Frame)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if not Dropdown.Opened then
				return
			end

			local PointerPosition = Input.Position
			local function IsInside(GuiObject)
				local Position = GuiObject.AbsolutePosition
				local Size = GuiObject.AbsoluteSize
				return PointerPosition.X >= Position.X
					and PointerPosition.X <= Position.X + Size.X
					and PointerPosition.Y >= Position.Y
					and PointerPosition.Y <= Position.Y + Size.Y
			end

			if not IsInside(DropdownHolderFrame) and not IsInside(DropdownInner) then
				Dropdown:Close()
			end
		end
	end, DropdownFrame.Frame)

	local ScrollFrame = self.ScrollFrame
	function Dropdown:Open()
		if Library.ActiveDropdown and Library.ActiveDropdown ~= Dropdown then
			Library.ActiveDropdown:Close()
		end
		Library.ActiveDropdown = Dropdown
		Dropdown.Opened = true
		Dropdown.PreviousSelection = GuiService.SelectedObject
		ScrollFrame.ScrollingEnabled = false
		if Searchable and SearchBox then
			SearchBox.Input.Text = ""
			FilterItems("")
		end
		RecalculateListSize()
		RecalculateListPosition()
		DropdownHolderCanvas.Visible = true
		Creator.PlayTween(
			DropdownHolderFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(1, 1) }
		)
		task.defer(function()
			local FirstButton = Dropdown.OptionButtons[1]
			if Dropdown.Opened and FirstButton and FirstButton.Parent then
				GuiService.SelectedObject = FirstButton
			end
		end)
	end

	function Dropdown:Close()
		local WasOpened = Dropdown.Opened
		Dropdown.Opened = false
		ScrollFrame.ScrollingEnabled = true
		DropdownHolderFrame.Size = UDim2.fromScale(1, 0.6)
		DropdownHolderCanvas.Visible = false
		if Library.ActiveDropdown == Dropdown then
			Library.ActiveDropdown = nil
		end
		if WasOpened then
			local PreviousSelection = Dropdown.PreviousSelection
			Dropdown.PreviousSelection = nil
			if PreviousSelection and PreviousSelection.Parent then
				GuiService.SelectedObject = PreviousSelection
			elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(DropdownHolderCanvas) then
				GuiService.SelectedObject = nil
			end
		end
	end

	local function CleanupPopup()
		if Library.ActiveDropdown == Dropdown then
			Library.ActiveDropdown = nil
		end

		local OpenFrameIdx = table.find(Library.OpenFrames, DropdownHolderCanvas)
		if OpenFrameIdx then
			table.remove(Library.OpenFrames, OpenFrameIdx)
		end
		if DropdownHolderCanvas.Parent then
			DropdownHolderCanvas:Destroy()
		end
	end
	Creator.AddSignal(DropdownFrame.Frame.Destroying, CleanupPopup, DropdownHolderCanvas)

	function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Dropdown.Multi then
			for Idx, Value in next, Values do
				if Dropdown.Value[Value] then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		DropdownDisplay.Text = (Str == "" and "--" or Str)
	end

	function Dropdown:GetActiveValues()
		if Dropdown.Multi then
			local Count = 0

			for _, Selected in next, Dropdown.Value do
				if Selected then
					Count = Count + 1
				end
			end

			return Count
		else
			return Dropdown.Value and 1 or 0
		end
	end

	function Dropdown:BuildDropdownList()
		local Values = Dropdown.Values
		local Buttons = {}
		Dropdown.OptionButtons = {}

		for _, Element in next, DropdownScrollFrame:GetChildren() do
			if not Element:IsA("UIListLayout") then
				Element:Destroy()
			end
		end

		local Count = 0

		for Idx, Value in next, Values do
			local Table = {}

			Count = Count + 1

			local ButtonSelector = New("Frame", {
				Size = UDim2.fromOffset(4, 14),
				BackgroundColor3 = Color3.fromRGB(76, 194, 255),
				Position = UDim2.fromOffset(-1, 16),
				AnchorPoint = Vector2.new(0, 0.5),
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(0, 2),
				}),
			})

			local ButtonLabel = New("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Text = Value,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(10, 0),
				Name = "ButtonLabel",
				ThemeTag = {
					TextColor3 = "Text",
				},
			})

			local Button = New("TextButton", {
				Size = UDim2.new(1, -5, 0, 32),
				BackgroundTransparency = 1,
				ZIndex = 23,
				Text = "",
				Parent = DropdownScrollFrame,
				ThemeTag = {
					BackgroundColor3 = "DropdownOption",
				},
			}, {
				ButtonSelector,
				ButtonLabel,
				New("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			})
			table.insert(Dropdown.OptionButtons, Button)

			local Selected

			if Dropdown.Multi then
				Selected = Dropdown.Value[Value]
			else
				Selected = Dropdown.Value == Value
			end

			local BackMotor, SetBackTransparency = Creator.SpringMotor(1, Button, "BackgroundTransparency")
			local SelMotor, SetSelTransparency = Creator.SpringMotor(1, ButtonSelector, "BackgroundTransparency")
			local SelectorSizeMotor = Flipper.SingleMotor.new(6)

			SelectorSizeMotor:onStep(function(value)
				ButtonSelector.Size = UDim2.new(0, 4, 0, value)
			end)

			Creator.AddSignal(Button.Destroying, function()
				SelectorSizeMotor:destroy()
			end, Button)

			Creator.AddSignal(Button.MouseEnter, function()
				SetBackTransparency(Selected and 0.85 or 0.89)
			end, Button)
			Creator.AddSignal(Button.MouseLeave, function()
				SetBackTransparency(Selected and 0.89 or 1)
			end, Button)
			Creator.AddSignal(Button.MouseButton1Down, function()
				SetBackTransparency(0.92)
			end, Button)
			Creator.AddSignal(Button.MouseButton1Up, function()
				SetBackTransparency(Selected and 0.85 or 0.89)
			end, Button)
			Creator.AddSignal(Button.SelectionGained, function()
				SetBackTransparency(0.85)
			end, Button)
			Creator.AddSignal(Button.SelectionLost, function()
				SetBackTransparency(Selected and 0.89 or 1)
			end, Button)

			function Table:UpdateButton()
				if Dropdown.Multi then
					Selected = Dropdown.Value[Value]
					if Selected then
						SetBackTransparency(0.89)
					end
				else
					Selected = Dropdown.Value == Value
					SetBackTransparency(Selected and 0.89 or 1)
				end

				SelectorSizeMotor:setGoal(Creator.MotionGoal(Selected and 14 or 6, { frequency = 6 }))
				SetSelTransparency(Selected and 0 or 1)
			end

			Creator.AddSignal(Button.Activated, function()
				local Try = not Selected

				if Dropdown:GetActiveValues() == 1 and not Try and not Config.AllowNull then
				else
					if Dropdown.Multi then
						Selected = Try
						Dropdown.Value[Value] = Selected and true or nil
					else
						Selected = Try
						Dropdown.Value = Selected and Value or nil

						for _, OtherButton in next, Buttons do
							OtherButton:UpdateButton()
						end
					end

					Table:UpdateButton()
					Dropdown:Display()

					Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
					Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
					if not Dropdown.Multi then
						Dropdown:Close()
					end
				end
			end, Button)

			Table:UpdateButton()
			Dropdown:Display()

			Buttons[Button] = Table
		end

		ListSizeX = 0
		for Button, Table in next, Buttons do
			if Button.ButtonLabel then
				if Button.ButtonLabel.TextBounds.X > ListSizeX then
					ListSizeX = Button.ButtonLabel.TextBounds.X
				end
			end
		end
		ListSizeX = ListSizeX + 30

		RecalculateCanvasSize()
		RecalculateListSize()
		RecalculateListPosition()
	end

	function Dropdown:SetValues(NewValues)
		if NewValues then
			Dropdown.Values = NewValues
		end

		Dropdown.Value = NormalizeValue(Dropdown.Value)
		Dropdown:BuildDropdownList()
		Dropdown:Display()
	end

	function Dropdown:OnChanged(Func)
		Dropdown.Changed = Func
		Func(Dropdown.Value)
	end

	function Dropdown:SetValue(Val)
		Dropdown.Value = NormalizeValue(Val)

		Dropdown:BuildDropdownList()
		Dropdown:Display()

		Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
		Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:Destroy()
		if Dropdown.Destroyed then
			return
		end
		Dropdown.Destroyed = true
		Dropdown:Close()
		CleanupPopup()
		DropdownFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Dropdown:BuildDropdownList()
	Dropdown:Display()

	Library.Options[Idx] = Dropdown
	return Dropdown
end

return Element
