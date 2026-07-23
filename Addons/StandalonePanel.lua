local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local StandalonePanel = { Library = nil }

function StandalonePanel:SetLibrary(Library)
	self.Library = Library
end

function StandalonePanel:CreatePanel(Config)
	assert(self.Library, "StandalonePanel - Must call SetLibrary(Fluent) first")
	assert(type(Config) == "table", "StandalonePanel - Config must be a table")
	assert(type(Config.OnSubmit) == "function", "StandalonePanel - Missing OnSubmit callback")

	local Library = self.Library
	if Config.Theme then Library:SetTheme(Config.Theme) end
	if Config.AccentColor then Library:SetAccentColor(Config.AccentColor) end
	local Creator = Library.Creator
	local New = Creator.New
	local Acrylic = Library.Acrylic
	local PreviousUseAcrylic = Library.UseAcrylic == true
	local UseAcrylic = Config.Acrylic == true
	if UseAcrylic then
		Library.UseAcrylic = true
		if not PreviousUseAcrylic then Acrylic.init() end
	end
	Library.UseAcrylic = UseAcrylic
	local Controller = {
		Values = {},
		Inputs = {},
		Choices = {},
		ChoiceStrokes = {},
		ChoiceSelectors = {},
		Toggles = {},
		Dropdowns = {},
		DropdownSelectors = {},
		ErrorLabels = {},
		Fields = {},
		Logs = {},
		Opened = true,
		Submitting = false,
		HistoryVisible = Config.ShowHistory == true,
	}

	local GuiParent = Config.Parent
	if not GuiParent then
		GuiParent = Config.UseCoreGui == false and LocalPlayer.PlayerGui
			or (RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"))
	end
	local Gui = New("ScreenGui", {
		Name = Config.Name or "CoreXStandalonePanel",
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ClipToDeviceSafeArea = false,
		ResetOnSpawn = false,
		Parent = GuiParent,
	})
	ProtectGui(Gui)

	local Overlay = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = Config.Overlay == false and 1 or (Config.OverlayTransparency or 0.78),
		BorderSizePixel = 0,
		Parent = Gui,
	})

	local Panel = New("Frame", {
		Size = Config.Size or UDim2.new(0.9, 0, 0.72, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = Overlay,
	}, {
		New("UISizeConstraint", {
			MinSize = Vector2.new(320, 340),
			MaxSize = Config.MaxSize or Vector2.new(680, 450),
		}),
	})
	local function MakeDraggable(Handle, Target)
		local Dragging, DragInput, StartPointer, StartPosition
		Creator.AddSignal(Handle.InputBegan, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
			Dragging, DragInput = true, Input
			StartPointer, StartPosition = Input.Position, Target.Position
		end, Gui)
		Creator.AddSignal(UserInputService.InputChanged, function(Input)
			if not Dragging then return end
			if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end
			local Delta = Input.Position - StartPointer
			Target.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		end, Gui)
		Creator.AddSignal(UserInputService.InputEnded, function(Input)
			if Input == DragInput or Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging, DragInput = false, nil
			end
		end, Gui)
	end
	New("ImageLabel", {
		Size = UDim2.new(1, 70, 1, 70),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://8992230677",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Parent = Panel,
	})
	local Paint = Acrylic.AcrylicPaint()
	Library.UseAcrylic = PreviousUseAcrylic
	Paint.Frame.Parent = Panel
	if Paint.AddParent then Paint.AddParent(Panel) end
	local PaintBackground = Paint.Frame:FindFirstChild("Background")
	if PaintBackground and not UseAcrylic then
		PaintBackground.BackgroundTransparency = Config.PanelTransparency or 0.02
	end
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Paint.Frame })
	New("UIStroke", { Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, ThemeTag = { Color = "AcrylicBorder" }, Parent = Paint.Frame })
	local Surface = Paint.Frame

	local Header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = Surface,
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			ThemeTag = { BackgroundColor3 = "DialogHolderLine" },
		}),
	})

	local TitleIcon = Config.Icon and New("ImageLabel", {
		Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(16, 17), BackgroundTransparency = 1,
		Image = Library:GetIcon(Config.Icon) or Config.Icon, ThemeTag = { ImageColor3 = "Text" }, Parent = Header,
	}) or nil
	New("TextLabel", {
		Size = UDim2.new(0.6, -20, 1, 0),
		Position = UDim2.fromOffset(TitleIcon and 40 or 16, 0),
		BackgroundTransparency = 1,
		Text = Config.Title or "Standalone Panel",
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" },
		Parent = Header,
	})

	local MetricLabel = New("TextLabel", {
		Size = UDim2.new(0.4, -128, 1, 0),
		Position = UDim2.new(0.6, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = (Config.MetricTitle or "Total") .. ": " .. tostring(Config.Metric or 0),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "Accent" },
		Parent = Header,
	})

	local CloseButton = New("TextButton", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.new(1, -42, 0, 8),
		BackgroundTransparency = 1,
		Text = "X",
		TextSize = 13,
		ThemeTag = { TextColor3 = "SubText" },
		Parent = Header,
	})
	local HistoryButton = New("TextButton", {
		Size = UDim2.fromOffset(74, 30),
		Position = UDim2.new(1, -120, 0, 10),
		BackgroundTransparency = Config.ShowHistory == true and 0.15 or 0.5,
		Text = Config.HistoryButtonText or "History",
		TextSize = 11,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" },
		Parent = Header,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("UIStroke", { Transparency = 0.65, ThemeTag = { Color = "DialogButtonBorder" } }),
	})

	local Body = New("Frame", {
		Size = UDim2.new(1, -28, 1, -72),
		Position = UDim2.fromOffset(14, 58),
		BackgroundTransparency = 1,
		Parent = Surface,
	})

	local Form = New("ScrollingFrame", {
		Size = UDim2.new(Config.FormWidthScale or 0.42, -6, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		Parent = Body,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }),
	})

	local Preview = New("Frame", {
		Size = UDim2.new(1 - (Config.FormWidthScale or 0.42), -6, 1, -66),
		Position = UDim2.new(Config.FormWidthScale or 0.42, 6, 0, 0),
		BackgroundTransparency = Config.PreviewTransparency or 0.04,
		ThemeTag = { BackgroundColor3 = "DialogInput" },
		Parent = Body,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.4, ThemeTag = { Color = "DialogButtonBorder" } }),
	})

	local PreviewTitle = New("TextLabel", {
		Size = UDim2.new(1, -142, 0, 34),
		Position = UDim2.fromOffset(12, 4),
		BackgroundTransparency = 1,
		Text = Config.PreviewTitle or "Preview",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "Text" },
		Parent = Preview,
	})
	local HistoryBaseText = Config.HistoryButtonText or "History"
	HistoryButton.Text = HistoryBaseText .. " (0)"
	local HistoryScroll = New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -46),
		Position = UDim2.fromOffset(8, 38),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		Parent = Preview,
	})
	local ItemSetters = {}
	local ItemDataStates = {}
	local AllItemsSelected = false
	local SelectAllButton = New("TextButton", {
		Size = UDim2.fromOffset(78, 24), Position = UDim2.new(1, -88, 0, 9),
		BackgroundTransparency = 0.35, Text = "Select All", TextSize = 10, Visible = false,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Accent" }, Parent = Preview,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 4) }), New("UIStroke", { Transparency = 0.65, ThemeTag = { Color = "DialogButtonBorder" } }) })
	Header.Active = true
	MakeDraggable(Header, Panel)

	local PreviewText = New("TextLabel", {
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(4, 0),
		BackgroundTransparency = 1,
		Text = Config.Preview or "",
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		ThemeTag = { TextColor3 = "SubText" },
		Parent = HistoryScroll,
	})
	local function RefreshHistoryCanvas(ScrollToBottom)
		task.defer(function()
			if not HistoryScroll.Parent or not PreviewText.Parent then return end
			local Height = math.max(PreviewText.AbsoluteSize.Y + 8, HistoryScroll.AbsoluteSize.Y)
			HistoryScroll.CanvasSize = UDim2.fromOffset(0, Height)
			if ScrollToBottom then
				HistoryScroll.CanvasPosition = Vector2.new(0, math.max(0, Height - HistoryScroll.AbsoluteSize.Y))
			end
		end)
	end
	Creator.AddSignal(PreviewText:GetPropertyChangedSignal("AbsoluteSize"), function()
		RefreshHistoryCanvas(false)
	end, Gui)
	local ItemScroll = New("ScrollingFrame", {
		Size = HistoryScroll.Size, Position = HistoryScroll.Position, BackgroundTransparency = 1, Visible = false,
		BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), Parent = Preview,
	}, { New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local ItemLayout = ItemScroll:FindFirstChildOfClass("UIListLayout")

	-- History is a separate floating window. Preview remains available for item lists.
	local HistoryPanel = New("Frame", {
		Size = Config.HistorySize or UDim2.new(0.46, 0, 0.62, 0),
		Position = Config.HistoryPosition or UDim2.fromScale(0.72, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Visible = Controller.HistoryVisible,
		ZIndex = 30,
		ThemeTag = { BackgroundColor3 = "Dialog" },
		Parent = Overlay,
	}, {
		New("UISizeConstraint", { MinSize = Vector2.new(260, 240), MaxSize = Vector2.new(430, 390) }),
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.4, ThemeTag = { Color = "DialogBorder" } }),
	})
	local HistoryDragArea = New("Frame", {
		Size = UDim2.new(1, -110, 0, 46), BackgroundTransparency = 1, Active = true, ZIndex = 30, Parent = HistoryPanel,
	})
	MakeDraggable(HistoryDragArea, HistoryPanel)
	New("TextLabel", {
		Size = UDim2.new(1, -54, 0, 46), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
		Text = Config.HistoryTitle or "History", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" }, Parent = HistoryPanel,
	})
	local HistoryCloseIcon = New("TextButton", {
		Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, -42, 0, 6), BackgroundTransparency = 1,
		Text = "X", TextSize = 12, ZIndex = 31, ThemeTag = { TextColor3 = "SubText" }, Parent = HistoryPanel,
	})
	New("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 45), ZIndex = 31, ThemeTag = { BackgroundColor3 = "DialogHolderLine" }, Parent = HistoryPanel })
	local HistoryList = New("ScrollingFrame", {
		Size = UDim2.new(1, -24, 1, -116), Position = UDim2.fromOffset(12, 55), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), ZIndex = 31, Parent = HistoryPanel,
	})
	local HistoryLayout = New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = HistoryList })
	local HistoryText = New("TextLabel", {
		Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(4, 0),
		BackgroundTransparency = 1, Text = "", TextSize = 12, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 32,
		LayoutOrder = 100000, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), ThemeTag = { TextColor3 = "SubText" }, Parent = HistoryList,
	})
	local ClearHistoryButton = New("TextButton", {
		Size = UDim2.new(0.5, -18, 0, 34), Position = UDim2.new(0, 12, 1, -46), BackgroundTransparency = 0,
		Text = "Clear History", TextSize = 11, ZIndex = 31,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		BackgroundColor3 = Color3.fromRGB(190, 35, 40), TextColor3 = Color3.new(1, 1, 1), Parent = HistoryPanel,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }) })
	local CopyHistoryButton = New("TextButton", {
		Size = UDim2.fromOffset(48, 24), Position = UDim2.new(1, -98, 0, 11), BackgroundTransparency = 0.35,
		Text = "Copy", TextSize = 10, ZIndex = 31, ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "SubText" }, Parent = HistoryPanel,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 4) }) })
	local CloseHistoryButton = New("TextButton", {
		Size = UDim2.new(0.5, -18, 0, 34), Position = UDim2.new(0.5, 6, 1, -46), BackgroundTransparency = 0,
		Text = "Close", TextSize = 11, ZIndex = 31,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" }, Parent = HistoryPanel,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }) })
	local function RefreshLogCanvas(ScrollToBottom)
		task.defer(function()
			if not HistoryList.Parent or not HistoryText.Parent then return end
			local Height = math.max(HistoryText.AbsoluteSize.Y + 8, HistoryList.AbsoluteSize.Y)
			HistoryList.CanvasSize = UDim2.fromOffset(0, Height)
			if ScrollToBottom then HistoryList.CanvasPosition = Vector2.new(0, math.max(0, Height - HistoryList.AbsoluteSize.Y)) end
		end)
	end

	local FormLayout = Form:FindFirstChildOfClass("UIListLayout")
	local function RefreshCanvas()
		task.defer(function()
			if FormLayout then Form.CanvasSize = UDim2.fromOffset(0, FormLayout.AbsoluteContentSize.Y + 6) end
		end)
	end
	Creator.AddSignal(FormLayout:GetPropertyChangedSignal("AbsoluteContentSize"), RefreshCanvas, Gui)

	local function AddLabel(Field)
		local HasIcon = Field.Icon ~= nil
		local Heading = New("Frame", { Size = UDim2.new(1, -4, 0, 18), BackgroundTransparency = 1, Parent = Form })
		if HasIcon then
			New("ImageLabel", {
				Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 2), BackgroundTransparency = 1,
				Image = Library:GetIcon(Field.Icon) or Field.Icon, ThemeTag = { ImageColor3 = "SubText" }, Parent = Heading,
			})
		end
		New("TextLabel", {
			Size = UDim2.new(1, HasIcon and -20 or 0, 1, 0), Position = UDim2.fromOffset(HasIcon and 20 or 0, 0), BackgroundTransparency = 1,
			Text = Field.Title or Field.Id, TextSize = 12, TextTransparency = 0.12,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			ThemeTag = { TextColor3 = "Text" }, Parent = Heading,
		})
		if Field.Description then
			New("TextLabel", {
				Size = UDim2.new(1, -4, 0, 16), BackgroundTransparency = 1, Text = Field.Description,
				TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), ThemeTag = { TextColor3 = "SubText" }, Parent = Form,
			})
		end
	end

	local function AddError(Field)
		local ErrorLabel = New("TextLabel", {
			Size = UDim2.new(1, -4, 0, 0), BackgroundTransparency = 1, Visible = false,
			Text = "", TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.fromRGB(245, 115, 115), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), Parent = Form,
		})
		Controller.ErrorLabels[Field.Id] = ErrorLabel
	end

	function Controller:SetFieldError(Id, Message)
		local Label = self.ErrorLabels[Id]
		if not Label then return end
		Label.Text = Message or ""
		Label.Visible = Message ~= nil and Message ~= ""
		Label.Size = UDim2.new(1, -4, 0, Label.Visible and 16 or 0)
		RefreshCanvas()
	end

	function Controller:ValidateField(Field)
		local Value = self.Values[Field.Id]
		local Empty = Value == nil or Value == ""
		local Message
		if Field.Type == "Number" and self.Inputs[Field.Id] and self.Inputs[Field.Id].Text ~= "" and Value == nil then
			Message = Field.NumberMessage or ((Field.Title or Field.Id) .. " must be a number")
		elseif Field.Required and Empty then
			Message = Field.RequiredMessage or ((Field.Title or Field.Id) .. " is required")
		elseif not Empty and Field.Min ~= nil and ((type(Value) == "number" and Value < Field.Min) or (type(Value) == "string" and #Value < Field.Min)) then
			Message = Field.MinMessage or ((Field.Title or Field.Id) .. " must be at least " .. tostring(Field.Min))
		elseif not Empty and Field.Max ~= nil and ((type(Value) == "number" and Value > Field.Max) or (type(Value) == "string" and #Value > Field.Max)) then
			Message = Field.MaxMessage or ((Field.Title or Field.Id) .. " must be at most " .. tostring(Field.Max))
		elseif not Empty and Field.Pattern and type(Value) == "string" and not Value:match(Field.Pattern) then
			Message = Field.PatternMessage or ((Field.Title or Field.Id) .. " has an invalid format")
		elseif Field.Validator then
			local Success, Valid, CustomMessage = pcall(Field.Validator, Value, self.Values, self)
			if not Success or Valid == false then Message = CustomMessage or Field.ValidationMessage or "Invalid value" end
		end
		self:SetFieldError(Field.Id, Message)
		return Message == nil, Message
	end

	function Controller:Validate()
		local Valid, FirstError = true, nil
		for _, Field in ipairs(self.Fields) do
			local FieldValid, Message = self:ValidateField(Field)
			if not FieldValid then Valid = false; FirstError = FirstError or Message end
		end
		return Valid, FirstError
	end

	local function AddInput(Field)
		AddLabel(Field)
		local Multiline = Field.Type == "Multiline" or Field.Multiline == true
		local InputWidthScale = Field.WidthScale or Config.InputWidthScale or 0.82
		local InputWidthOffset = Field.WidthOffset or Config.InputWidthOffset or 0
		local Holder = New("Frame", {
			Size = UDim2.new(InputWidthScale, InputWidthOffset, 0, Multiline and (Field.Height or 82) or (Config.InputHeight or 32)),
			BackgroundTransparency = Config.InputTransparency or 0.02,
			ThemeTag = { BackgroundColor3 = "DialogInput" },
			Parent = Form,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 4) }),
			New("UIStroke", { Transparency = Config.InputBorderTransparency or 0.35, ThemeTag = { Color = "DialogInputLine" } }),
		})
		local Input = New("TextBox", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			BackgroundTransparency = 1,
			Text = tostring(Field.Default or ""),
			PlaceholderText = Field.Placeholder or "",
			ClearTextOnFocus = false,
			MultiLine = Multiline,
			TextWrapped = Multiline,
			TextYAlignment = Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
			Parent = Holder,
		})
		local Indicator = New("Frame", {
			Size = UDim2.new(1, -4, 0, 1),
			Position = UDim2.new(0, 2, 1, -1),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			ThemeTag = { BackgroundColor3 = "DialogInputLine" },
			Parent = Holder,
		})
		Controller.Values[Field.Id] = Field.Default or ""
		Controller.Inputs[Field.Id] = Input
		Creator.AddSignal(Input:GetPropertyChangedSignal("Text"), function()
			local Value = Input.Text
			if Field.Type == "Number" then Value = tonumber(Value) end
			Controller.Values[Field.Id] = Value
			if Controller.ErrorLabels[Field.Id] and Controller.ErrorLabels[Field.Id].Visible then Controller:ValidateField(Field) end
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end, Gui)
		Creator.AddSignal(Input.Focused, function()
			Indicator.Size = UDim2.new(1, -2, 0, 2)
			Indicator.Position = UDim2.new(0, 1, 1, -2)
			Indicator.BackgroundTransparency = 0
			Creator.OverrideTag(Indicator, { BackgroundColor3 = "Accent" })
		end, Gui)
		Creator.AddSignal(Input.FocusLost, function()
			Indicator.Size = UDim2.new(1, -4, 0, 1)
			Indicator.Position = UDim2.new(0, 2, 1, -1)
			Indicator.BackgroundTransparency = 0.5
			Creator.OverrideTag(Indicator, { BackgroundColor3 = "DialogInputLine" })
		end, Gui)
		AddError(Field)
	end

	local function AddChoice(Field)
		AddLabel(Field)
		local Holder = New("Frame", {
			Size = UDim2.new(1, -4, 0, math.ceil(#(Field.Values or {}) / 2) * 32),
			BackgroundTransparency = 1,
			Parent = Form,
		}, {
			New("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 26), CellPadding = UDim2.fromOffset(6, 6) }),
		})
		Controller.Values[Field.Id] = Field.Default or Field.Values and Field.Values[1]
		Controller.Choices[Field.Id] = {}
		Controller.ChoiceStrokes[Field.Id] = {}
		local function Select(Value)
			Controller.Values[Field.Id] = Value
			for ChoiceValue, Button in pairs(Controller.Choices[Field.Id]) do
				local Selected = ChoiceValue == Value
				Button.BackgroundTransparency = Selected and 0.02 or 0.18
				Creator.OverrideTag(Button, { BackgroundColor3 = "DialogButton", TextColor3 = Selected and "Accent" or "Text" })
				local Stroke = Controller.ChoiceStrokes[Field.Id][ChoiceValue]
				if Stroke then
					Stroke.Transparency = Selected and 0.1 or 0.55
					Creator.OverrideTag(Stroke, { Color = Selected and "Accent" or "DialogButtonBorder" })
				end
			end
			if Controller.ErrorLabels[Field.Id] and Controller.ErrorLabels[Field.Id].Visible then Controller:ValidateField(Field) end
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end
		Controller.ChoiceSelectors[Field.Id] = Select
		for _, Value in ipairs(Field.Values or {}) do
			local Stroke = New("UIStroke", { Transparency = 0.55, ThemeTag = { Color = "DialogButtonBorder" } })
			local Button = New("TextButton", {
				Text = tostring(Value),
				TextSize = 12,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
				BackgroundTransparency = 0.18,
				ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" },
				Parent = Holder,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 4) }),
				Stroke,
			})
			Controller.Choices[Field.Id][Value] = Button
			Controller.ChoiceStrokes[Field.Id][Value] = Stroke
			Creator.AddSignal(Button.Activated, function() Select(Value) end, Gui)
		end
		Select(Controller.Values[Field.Id])
		AddError(Field)
	end

	local function AddToggle(Field)
		AddLabel(Field)
		local Button = New("TextButton", {
			Size = UDim2.new(1, -4, 0, 34), BackgroundTransparency = 0.18, Text = "", ThemeTag = { BackgroundColor3 = "DialogButton" }, Parent = Form,
		}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }), New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "DialogButtonBorder" } }) })
		local State = New("TextLabel", {
			Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold), Parent = Button,
		})
		local function Set(Value)
			Value = Value == true
			Controller.Values[Field.Id] = Value
			State.Text = Value and (Field.OnText or "On") or (Field.OffText or "Off")
			State.TextColor3 = Creator.GetThemeProperty(Value and "Accent" or "SubText")
			if Controller.ErrorLabels[Field.Id] and Controller.ErrorLabels[Field.Id].Visible then Controller:ValidateField(Field) end
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end
		Controller.Toggles[Field.Id] = Set
		Creator.AddSignal(Button.Activated, function() Set(not Controller.Values[Field.Id]) end, Gui)
		Set(Field.Default == true)
		AddError(Field)
	end

	local function AddDropdown(Field)
		AddLabel(Field)
		local Display = New("TextButton", {
			Size = UDim2.new(1, -4, 0, 36), BackgroundTransparency = 0.02, Text = "", TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { BackgroundColor3 = "DialogInput", TextColor3 = "Text" }, Parent = Form,
		}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }), New("UIPadding", { PaddingLeft = UDim.new(0, 9) }), New("UIStroke", { Transparency = 0.35, ThemeTag = { Color = "DialogInputLine" } }) })
		local List = New("Frame", { Size = UDim2.new(1, -4, 0, 0), BackgroundTransparency = 0.04, Visible = false, ThemeTag = { BackgroundColor3 = "DialogHolder" }, Parent = Form }, {
			New("UICorner", { CornerRadius = UDim.new(0, 5) }), New("UIListLayout", { Padding = UDim.new(0, 3) }), New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
		})
		local function Select(Value)
			Controller.Values[Field.Id] = Value
			Display.Text = tostring(Value or Field.Placeholder or "Select...") .. "  v"
			List.Visible = false; List.Size = UDim2.new(1, -4, 0, 0); RefreshCanvas()
			if Controller.ErrorLabels[Field.Id] and Controller.ErrorLabels[Field.Id].Visible then Controller:ValidateField(Field) end
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end
		Controller.Dropdowns[Field.Id] = { Display = Display, List = List }
		Controller.DropdownSelectors[Field.Id] = Select
		for _, Value in ipairs(Field.Values or {}) do
			local Option = New("TextButton", { Size = UDim2.new(1, 0, 0, 27), BackgroundTransparency = 0.25, Text = tostring(Value), TextSize = 11, ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" }, Parent = List }, { New("UICorner", { CornerRadius = UDim.new(0, 4) }) })
			Creator.AddSignal(Option.Activated, function() Select(Value) end, Gui)
		end
		Creator.AddSignal(Display.Activated, function()
			List.Visible = not List.Visible
			List.Size = UDim2.new(1, -4, 0, List.Visible and (#(Field.Values or {}) * 30 + 8) or 0)
			RefreshCanvas()
		end, Gui)
		Select(Field.Default or Field.Values and Field.Values[1])
		AddError(Field)
	end

	for _, Field in ipairs(Config.Fields or {}) do
		assert(Field.Id, "StandalonePanel - Every field requires Id")
		table.insert(Controller.Fields, Field)
		if Field.Type == "Choice" then AddChoice(Field)
		elseif Field.Type == "Toggle" then AddToggle(Field)
		elseif Field.Type == "Dropdown" then AddDropdown(Field)
		else AddInput(Field) end
	end

	RefreshCanvas()

	local Footer = New("Frame", {
		Size = UDim2.new(1 - (Config.FormWidthScale or 0.42), -6, 0, 60),
		Position = UDim2.new(Config.FormWidthScale or 0.42, 6, 1, -60),
		ThemeTag = { BackgroundColor3 = "DialogHolder" },
		Parent = Body,
	}, {
		New("Frame", { Size = UDim2.new(1, 0, 0, 1), ThemeTag = { BackgroundColor3 = "DialogHolderLine" } }),
	})
	local Action = New("TextButton", {
		Size = UDim2.new(1, -28, 0, 34),
		Position = UDim2.fromOffset(14, 13),
		Text = Config.ActionText or "Submit",
		TextSize = 13,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" },
		Parent = Footer,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("UIStroke", { Transparency = 0.65, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, ThemeTag = { Color = "DialogButtonBorder" } }),
	})
	if Config.ActionIcon then
		New("ImageLabel", {
			Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(10, 9), BackgroundTransparency = 1,
			Image = Library:GetIcon(Config.ActionIcon) or Config.ActionIcon, ThemeTag = { ImageColor3 = "Text" }, Parent = Action,
		})
	end

	local ConfirmConfig = type(Config.Confirm) == "table" and Config.Confirm or {}
	local ConfirmOverlay = New("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35,
		Visible = false, ZIndex = 50, Parent = Surface,
	})
	local ConfirmHeight = ConfirmConfig.Height or 220
	local ConfirmCard = New("Frame", {
		Size = UDim2.new(0.86, 0, 0, ConfirmHeight), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 51, ThemeTag = { BackgroundColor3 = "Dialog" }, Parent = ConfirmOverlay,
	}, { New("UISizeConstraint", { MinSize = Vector2.new(280, math.min(190, ConfirmHeight)), MaxSize = Vector2.new(460, math.max(220, ConfirmHeight)) }), New("UICorner", { CornerRadius = UDim.new(0, 8) }), New("UIStroke", { Transparency = 0.35, ThemeTag = { Color = "DialogBorder" } }) })
	New("TextLabel", {
		Size = UDim2.new(1, -32, 0, 26), Position = UDim2.fromOffset(16, 14), BackgroundTransparency = 1, ZIndex = 53,
		Text = ConfirmConfig.Title or "Confirm action", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold), ThemeTag = { TextColor3 = "Text" }, Parent = ConfirmCard,
	})
	local ConfirmBody = New("Frame", {
		Size = UDim2.new(1, -32, 1, -116), Position = UDim2.fromOffset(16, 48),
		ZIndex = 52, ThemeTag = { BackgroundColor3 = "DialogButton" }, Parent = ConfirmCard,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.7, ThemeTag = { Color = "DialogButtonBorder" } }),
	})
	local ConfirmStatus = New("TextLabel", {
		Size = UDim2.new(1, -32, 0, 24), Position = UDim2.fromOffset(16, 46),
		BackgroundColor3 = Color3.fromRGB(55, 43, 16), BackgroundTransparency = 0.08,
		Visible = false, ZIndex = 53, Text = "", TextSize = 11,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(250, 204, 72), Parent = ConfirmCard,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		New("UIStroke", { Color = Color3.fromRGB(180, 132, 24), Transparency = 0.2 }),
	})
	local ConfirmImage = New("ImageLabel", {
		Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 0.1, Visible = false, ZIndex = 53,
		ThemeTag = { BackgroundColor3 = "Dialog" }, Parent = ConfirmBody,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 7) }), New("UIStroke", { Transparency = 0.55, ThemeTag = { Color = "DialogButtonBorder" } }) })
	local ConfirmContent = New("TextLabel", {
		Size = UDim2.new(1, -24, 1, -20), Position = UDim2.fromOffset(12, 10), BackgroundTransparency = 1, ZIndex = 53,
		Text = type(ConfirmConfig.Content) == "string" and ConfirmConfig.Content or "Are you sure you want to continue?", TextSize = 12, TextWrapped = true,
		LineHeight = 1.12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), ThemeTag = { TextColor3 = "SubText" }, Parent = ConfirmBody,
	})
	local ConfirmProfileName = New("TextLabel", {
		Size = UDim2.new(1, -98, 0, 20), Position = UDim2.fromOffset(82, 10),
		BackgroundTransparency = 1, Visible = false, ZIndex = 54, Text = "", TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" }, Parent = ConfirmBody,
	})
	local ConfirmProfileMeta = New("TextLabel", {
		Size = UDim2.new(1, -98, 0, 48), Position = UDim2.fromOffset(82, 29),
		BackgroundTransparency = 1, Visible = false, ZIndex = 54, Text = "", TextSize = 10,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		ThemeTag = { TextColor3 = "SubText" }, Parent = ConfirmBody,
	})
	local ConfirmSummary = New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 78),
		BackgroundTransparency = 1, Visible = false, ZIndex = 54, Text = "", TextSize = 10,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "Text" }, Parent = ConfirmBody,
	})
	local ConfirmItems = New("TextLabel", {
		Size = UDim2.new(1, -24, 1, -120), Position = UDim2.fromOffset(12, 110),
		BackgroundColor3 = Color3.fromRGB(24, 25, 30), BackgroundTransparency = 0.04,
		Visible = false, ZIndex = 54, Text = "", TextSize = 11,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), TextColor3 = Color3.fromRGB(205, 208, 218),
		Parent = ConfirmBody,
	}, {
		New("UIPadding", { PaddingTop = UDim.new(0, 28), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }),
		New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "DialogButtonBorder" } }),
	})
	local ConfirmItemsTitle = New("TextLabel", {
		Size = UDim2.fromOffset(150, 20), Position = UDim2.fromOffset(23, 114),
		BackgroundTransparency = 1, Visible = false, ZIndex = 55, Text = "SELECTED ITEMS", TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(165, 169, 180), Parent = ConfirmBody,
	})
	local ConfirmTotal = New("TextLabel", {
		Size = UDim2.fromOffset(150, 20), Position = UDim2.new(1, -174, 0, 114),
		BackgroundTransparency = 1, Visible = false, ZIndex = 55, Text = "", TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" }, Parent = ConfirmBody,
	})
	New("Frame", {
		Size = UDim2.new(1, -32, 0, 1), Position = UDim2.new(0, 16, 1, -59), BorderSizePixel = 0,
		ZIndex = 52, ThemeTag = { BackgroundColor3 = "DialogButtonBorder" }, Parent = ConfirmCard,
	})
	local ConfirmYes = New("TextButton", {
		Size = UDim2.new(0.5, -20, 0, 36), Position = UDim2.new(0.5, 4, 1, -48), ZIndex = 53,
		Text = ConfirmConfig.ConfirmText or "Confirm", TextSize = 12, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = ConfirmConfig.ConfirmColor or Color3.fromRGB(34, 197, 94), Parent = ConfirmCard,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 6) }), New("UIStroke", { Transparency = 0.25, ThemeTag = { Color = "Accent" } }) })
	local ConfirmNo = New("TextButton", {
		Size = UDim2.new(0.5, -20, 0, 36), Position = UDim2.new(0, 16, 1, -48), ZIndex = 53,
		Text = ConfirmConfig.CancelText or "Cancel", TextSize = 12, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		BackgroundColor3 = ConfirmConfig.CancelColor or Color3.fromRGB(220, 55, 47),
		TextColor3 = Color3.fromRGB(255, 255, 255), Parent = ConfirmCard,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 6) }), New("UIStroke", { Transparency = 0.45, ThemeTag = { Color = "DialogButtonBorder" } }) })

	function Controller:SetMetric(Value, Title)
		if Title then Config.MetricTitle = Title end
		MetricLabel.Text = (Config.MetricTitle or "Total") .. ": " .. tostring(Value)
	end

	function Controller:SetPreview(Text, Title)
		ItemScroll.Visible = false
		HistoryScroll.Visible = true
		SelectAllButton.Visible = false
		PreviewText.Text = tostring(Text or "")
		if Title then PreviewTitle.Text = Title end
		RefreshHistoryCanvas(true)
	end

	function Controller:AppendLog(Text)
		local Entry = Config.HistoryTimestamp == false and tostring(Text) or ("[" .. os.date(Config.TimestampFormat or "%H:%M:%S") .. "] " .. tostring(Text))
		table.insert(self.Logs, Entry)
		local Limit = Config.LogLimit or 30
		while #self.Logs > Limit do table.remove(self.Logs, 1) end
		HistoryText.Text = table.concat(self.Logs, "\n\n")
		RefreshLogCanvas(true)
		HistoryButton.Text = HistoryBaseText .. " (" .. tostring(#self.Logs) .. ")"
	end

	function Controller:AppendHistory(Data)
		Data = type(Data) == "table" and Data or { Summary = tostring(Data) }
		local Success = Data.Success ~= false
		local Time = tostring(Data.Time or os.date(Config.TimestampFormat or "%H:%M:%S"))
		local User = tostring(Data.User or Data.Target or "Unknown")
		local Summary = tostring(Data.Summary or Data.Message or "No details")
		local Status = Data.Status or (Success and "Sent successfully" or "Send failed")
		local Color = Success and Color3.fromRGB(55, 220, 135) or Color3.fromRGB(245, 80, 88)

		local Entry = string.format("%s | %s | %s | %s", Time, Status, User, Summary)
		table.insert(self.Logs, Entry)
		local Limit = Config.LogLimit or 30
		while #self.Logs > Limit do table.remove(self.Logs, 1) end
		HistoryText.Visible = false

		if Config.CompactHistory then
			local CompactText = tostring(Data.Text or Data.CompactText or string.format("%s → %s | %s", Status, User, Summary))
			local Row = New("Frame", {
				Size = UDim2.new(1, -6, 0, 42), BackgroundTransparency = 0.06,
				ThemeTag = { BackgroundColor3 = "DialogButton" }, Parent = HistoryList,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 4) }),
				New("UIStroke", { Transparency = 0.78, ThemeTag = { Color = "DialogButtonBorder" } }),
			})
			New("Frame", {
				Size = UDim2.new(0, 4, 1, -8), Position = UDim2.fromOffset(0, 4),
				BackgroundColor3 = Color, BorderSizePixel = 0, Parent = Row,
			}, { New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
			New("TextLabel", {
				Size = UDim2.fromOffset(62, 42), Position = UDim2.fromOffset(12, 0),
				BackgroundTransparency = 1, Text = Time, TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				TextColor3 = Color3.fromRGB(190, 194, 204), Parent = Row,
			})
			New("TextLabel", {
				Size = UDim2.new(1, -88, 1, 0), Position = UDim2.fromOffset(78, 0),
				BackgroundTransparency = 1, Text = CompactText, TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
				TextColor3 = Color, Parent = Row,
			})
			task.defer(function()
				local Height = HistoryLayout.AbsoluteContentSize.Y + 8
				HistoryList.CanvasSize = UDim2.fromOffset(0, Height)
				HistoryList.CanvasPosition = Vector2.new(0, math.max(0, Height - HistoryList.AbsoluteSize.Y))
			end)
			HistoryButton.Text = HistoryBaseText .. " (" .. tostring(#self.Logs) .. ")"
			return
		end

		local Card = New("Frame", {
			Size = UDim2.new(1, -6, 0, 62), BackgroundTransparency = 0.22,
			ThemeTag = { BackgroundColor3 = "DialogButton" }, Parent = HistoryList,
		}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }) })
		New("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Color, BorderSizePixel = 0, Parent = Card }, {
			New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		})
		New("TextLabel", {
			Size = UDim2.new(1, -18, 0, 25), Position = UDim2.fromOffset(11, 5), BackgroundTransparency = 1,
			Text = string.format("%s  •  %s  •  %s", Time, Status, User), TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold), Parent = Card,
		})
		New("TextLabel", {
			Size = UDim2.new(1, -18, 0, 25), Position = UDim2.fromOffset(11, 30), BackgroundTransparency = 1,
			Text = Summary, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { TextColor3 = "SubText" }, Parent = Card,
		})
		task.defer(function()
			local Height = HistoryLayout.AbsoluteContentSize.Y + 8
			HistoryList.CanvasSize = UDim2.fromOffset(0, Height)
			HistoryList.CanvasPosition = Vector2.new(0, math.max(0, Height - HistoryList.AbsoluteSize.Y))
		end)
		HistoryButton.Text = HistoryBaseText .. " (" .. tostring(#self.Logs) .. ")"
	end

	function Controller:SetItems(Items, Title, OnChanged)
		HistoryScroll.Visible = false
		ItemScroll.Visible = true
		SelectAllButton.Visible = Config.ShowSelectAll ~= false
		if Title then PreviewTitle.Text = Title end
		table.clear(ItemSetters)
		table.clear(ItemDataStates)
		AllItemsSelected = #(Items or {}) > 0
		for _, Child in ipairs(ItemScroll:GetChildren()) do
			if Child:IsA("TextButton") then Child:Destroy() end
		end
		for Index, Item in ipairs(Items or {}) do
			local Data = type(Item) == "table" and Item or { Id = Item, Text = tostring(Item) }
			table.insert(ItemDataStates, Data)
			local Selected = Data.Selected == true
			if not Selected then AllItemsSelected = false end
			local Stroke = New("UIStroke", { Transparency = Selected and 0.25 or 0.75, ThemeTag = { Color = Selected and "Accent" or "DialogButtonBorder" } })
			local Button = New("TextButton", {
				Size = UDim2.new(1, -4, 0, 32), BackgroundTransparency = Selected and 0.05 or 0.35,
				Text = "  " .. tostring(Data.Text or Data.Name or Data.Id or Index), TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = Index,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = Selected and "Accent" or "Text" }, Parent = ItemScroll,
			}, { New("UICorner", { CornerRadius = UDim.new(0, 5) }), Stroke })
			local function SetSelected(Value, FireCallback)
				Selected = Value == true
				Data.Selected = Selected
				Button.BackgroundTransparency = Selected and 0.05 or 0.35
				Creator.OverrideTag(Button, { BackgroundColor3 = "DialogButton", TextColor3 = Selected and "Accent" or "Text" })
				Stroke.Transparency = Selected and 0.25 or 0.75
				Creator.OverrideTag(Stroke, { Color = Selected and "Accent" or "DialogButtonBorder" })
				if FireCallback and OnChanged then Library:SafeCallback(OnChanged, Data, Selected, self) end
			end
			table.insert(ItemSetters, SetSelected)
			Creator.AddSignal(Button.Activated, function()
				SetSelected(not Selected, true)
				AllItemsSelected = true
				for _, State in ipairs(ItemDataStates) do
					if State.Selected ~= true then AllItemsSelected = false break end
				end
				SelectAllButton.Text = AllItemsSelected and "Clear All" or "Select All"
			end, Gui)
		end
		SelectAllButton.Text = AllItemsSelected and "Clear All" or "Select All"
		task.defer(function() ItemScroll.CanvasSize = UDim2.fromOffset(0, ItemLayout.AbsoluteContentSize.Y + 6) end)
	end

	Creator.AddSignal(SelectAllButton.Activated, function()
		local NewState = not AllItemsSelected
		AllItemsSelected = NewState
		for _, SetSelected in ipairs(ItemSetters) do SetSelected(NewState, true) end
		SelectAllButton.Text = NewState and "Clear All" or "Select All"
	end, Gui)

	function Controller:ClearHistory(Silent)
		table.clear(self.Logs)
		for _, Child in ipairs(HistoryList:GetChildren()) do
			if Child:IsA("Frame") then Child:Destroy() end
		end
		HistoryText.Visible = true
		HistoryText.Text = ""
		RefreshLogCanvas(false)
		HistoryButton.Text = HistoryBaseText .. " (0)"
		if not Silent and Config.OnClearHistory then Library:SafeCallback(Config.OnClearHistory, self) end
	end

	function Controller:CopyHistory()
		local Text = table.concat(self.Logs, "\n")
		local SetClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
		if not SetClipboard then return false, "clipboard is not supported" end
		local Success, Error = pcall(SetClipboard, Text)
		return Success, Error
	end

	function Controller:SetValue(Id, Value)
		self.Values[Id] = Value
		if self.Inputs[Id] then self.Inputs[Id].Text = tostring(Value or "") end
		if self.ChoiceSelectors[Id] then self.ChoiceSelectors[Id](Value) end
		if self.Toggles[Id] then self.Toggles[Id](Value) end
		if self.DropdownSelectors[Id] then self.DropdownSelectors[Id](Value) end
	end

	function Controller:SetSubmitting(Value, Text)
		self.Submitting = Value == true
		Action.Active = not self.Submitting
		Action.Text = Text or (self.Submitting and (Config.SubmittingText or "Working...") or (Config.ActionText or "Submit"))
		Action.BackgroundTransparency = self.Submitting and 0.45 or 0
	end

	function Controller:SetSuccess(Text)
		self.Submitting = true
		Action.Active = false
		Action.Text = Text or Config.SuccessText or "Success"
		Action.BackgroundColor3 = Config.SuccessColor or Color3.fromRGB(70, 180, 115)
		Action.TextColor3 = Color3.new(1, 1, 1)
		task.delay(Config.SuccessDuration or 1.5, function()
			if not Action.Parent then return end
			Creator.OverrideTag(Action, { BackgroundColor3 = "DialogButton", TextColor3 = "Text" })
			self:SetSubmitting(false)
		end)
	end

	function Controller:PerformSubmit()
		if self.Submitting then return end
		self:SetSubmitting(true)
		task.spawn(function()
			local Success, Result = xpcall(function()
				return Config.OnSubmit(self.Values, self)
			end, debug.traceback)
			if not Success then
				self:SetSubmitting(false)
				self:AppendLog("Error: " .. tostring(Result):match("^[^\n]+"))
				Library:Notify({ Title = Config.Title or "Standalone Panel", Content = "Action failed", SubContent = tostring(Result):match("^[^\n]+"), Type = "Error", Duration = 6 })
				warn(Result)
			else
				if type(Result) == "string" then self:AppendLog(Result) end
				self:SetSuccess()
			end
		end)
	end

	function Controller:Submit(SkipConfirm)
		if self.Submitting then return end
		local Valid = self:Validate()
		if not Valid then
			Action.Text = Config.ValidationFailedText or "Check required fields"
			task.delay(1.2, function() if Action.Parent and not self.Submitting then Action.Text = Config.ActionText or "Submit" end end)
			return false
		end
		if Config.Confirm and not SkipConfirm then
			if type(ConfirmConfig.Content) == "function" then
				local Success, Content = pcall(ConfirmConfig.Content, self.Values, self)
				if Success and type(Content) == "table" then
					local Profile = Content.Profile
					local IsTransaction = type(Profile) == "table" or Content.Items ~= nil or Content.Status ~= nil
					local ShowStatus = IsTransaction and Content.Status ~= false
					ConfirmStatus.Visible = ShowStatus
					ConfirmStatus.Text = tostring(Content.Status or "⚠ PENDING CONFIRM")
					ConfirmBody.Position = IsTransaction and (ShowStatus and UDim2.fromOffset(16, 76) or UDim2.fromOffset(16, 46)) or UDim2.fromOffset(16, 48)
					ConfirmBody.Size = IsTransaction and (ShowStatus and UDim2.new(1, -32, 1, -144) or UDim2.new(1, -32, 1, -114)) or UDim2.new(1, -32, 1, -116)
					ConfirmContent.Visible = not IsTransaction
					ConfirmProfileName.Visible = IsTransaction
					ConfirmProfileMeta.Visible = IsTransaction
					ConfirmSummary.Visible = IsTransaction
					ConfirmItems.Visible = IsTransaction
					ConfirmItemsTitle.Visible = IsTransaction
					ConfirmTotal.Visible = IsTransaction
					if IsTransaction then
						Profile = Profile or {}
						ConfirmImage.Image = tostring(Profile.Image or Content.Image or "")
						ConfirmImage.Visible = ConfirmImage.Image ~= ""
						ConfirmProfileName.Text = tostring(Profile.Name or Profile.DisplayName or Profile.Username or "Unknown")
						local Username = tostring(Profile.Username or "")
						local UserId = tostring(Profile.UserId or "")
						ConfirmProfileMeta.Text = Profile.Detail and tostring(Profile.Detail) or ((Username ~= "" and ("@" .. Username) or "") .. (UserId ~= "" and ("\nID: " .. UserId) or ""))
						ConfirmSummary.Text = tostring(Content.Summary or "")
						local Items = Content.Items
						ConfirmItems.Text = type(Items) == "table" and table.concat(Items, "\n") or tostring(Items or "No items selected")
						ConfirmTotal.Text = tostring(Content.Total or "")
					else
						ConfirmContent.Text = tostring(Content.Text or Content.Content or "")
						ConfirmImage.Image = tostring(Content.Image or "")
						ConfirmImage.Visible = ConfirmImage.Image ~= ""
						ConfirmContent.Position = ConfirmImage.Visible and UDim2.fromOffset(82, 10) or UDim2.fromOffset(12, 10)
						ConfirmContent.Size = ConfirmImage.Visible and UDim2.new(1, -94, 1, -20) or UDim2.new(1, -24, 1, -20)
					end
				else
					ConfirmContent.Text = Success and tostring(Content or "") or "Unable to prepare confirmation details."
					ConfirmContent.Visible = true
					ConfirmStatus.Visible = false
					ConfirmProfileName.Visible = false
					ConfirmProfileMeta.Visible = false
					ConfirmSummary.Visible = false
					ConfirmItems.Visible = false
					ConfirmItemsTitle.Visible = false
					ConfirmTotal.Visible = false
					ConfirmBody.Position = UDim2.fromOffset(16, 48)
					ConfirmBody.Size = UDim2.new(1, -32, 1, -116)
					ConfirmImage.Visible = false
					ConfirmContent.Position = UDim2.fromOffset(12, 10)
					ConfirmContent.Size = UDim2.new(1, -24, 1, -20)
				end
			end
			ConfirmOverlay.Visible = true
			return true
		end
		self:PerformSubmit()
		return true
	end

	function Controller:Open()
		self.Opened = true
		Gui.Enabled = true
		if Paint.SetVisibility then Paint.SetVisibility(true) end
	end

	function Controller:Close()
		self.Opened = false
		if Paint.SetVisibility then Paint.SetVisibility(false) end
		Gui.Enabled = false
	end

	function Controller:Destroy()
		self.Opened = false
		if Paint.Model then Paint.Model:Destroy() end
		if UseAcrylic and not PreviousUseAcrylic and Acrylic.Disable then Acrylic.Disable() end
		Gui:Destroy()
	end

	Creator.AddSignal(Action.Activated, function() Controller:Submit() end, Gui)
	Creator.AddSignal(ConfirmYes.Activated, function() ConfirmOverlay.Visible = false; Controller:Submit(true) end, Gui)
	Creator.AddSignal(ConfirmNo.Activated, function() ConfirmOverlay.Visible = false end, Gui)
	Creator.AddSignal(ClearHistoryButton.Activated, function() Controller:ClearHistory() end, Gui)
	Creator.AddSignal(CopyHistoryButton.Activated, function()
		local Success, Error = Controller:CopyHistory()
		Library:Notify({ Title = Config.Title or "Standalone Panel", Content = Success and "History copied" or "Unable to copy history", SubContent = Success and nil or tostring(Error), Type = Success and "Success" or "Error", Duration = 3 })
	end, Gui)
	local function CloseHistory()
		Controller.HistoryVisible = false
		HistoryPanel.Visible = false
		HistoryButton.BackgroundTransparency = 0.5
	end
	Creator.AddSignal(HistoryCloseIcon.Activated, CloseHistory, Gui)
	Creator.AddSignal(CloseHistoryButton.Activated, CloseHistory, Gui)
	Creator.AddSignal(Action.MouseEnter, function() if not Controller.Submitting then Action.BackgroundTransparency = 0.15 end end, Gui)
	Creator.AddSignal(Action.MouseLeave, function() Action.BackgroundTransparency = Controller.Submitting and 0.45 or 0 end, Gui)
	Creator.AddSignal(CloseButton.Activated, function()
		if Config.DestroyOnClose then Controller:Destroy() else Controller:Close() end
		if Config.OnClose then Library:SafeCallback(Config.OnClose, Controller) end
	end, Gui)
	Creator.AddSignal(HistoryButton.Activated, function()
		Controller.HistoryVisible = not Controller.HistoryVisible
		HistoryButton.BackgroundTransparency = Controller.HistoryVisible and 0.15 or 0.5
		HistoryPanel.Visible = Controller.HistoryVisible
	end, Gui)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if Controller.Opened and Config.CloseOnEscape ~= false and Input.KeyCode == Enum.KeyCode.Escape then
			if ConfirmOverlay.Visible then ConfirmOverlay.Visible = false else Controller:Close() end
		end
	end, Gui)

	function Controller:UpdateLayout()
		Preview.Visible = true
		HistoryPanel.Visible = self.HistoryVisible
		local ViewWidth = Overlay.AbsoluteSize.X
		if ViewWidth > 0 and ViewWidth < 700 then
			HistoryPanel.Size = UDim2.new(0.9, 0, 0.7, 0)
			HistoryPanel.Position = UDim2.fromScale(0.5, 0.5)
		else
			HistoryPanel.Size = Config.HistorySize or UDim2.new(0.46, 0, 0.62, 0)
		end
		if Panel.AbsoluteSize.X < (Config.StackBreakpoint or 430) then
			Form.Size = UDim2.new(1, 0, 0.48, -4)
			Preview.Size = UDim2.new(1, 0, 0.52, -70)
			Preview.Position = UDim2.new(0, 0, 0.48, 4)
			Footer.Size = UDim2.new(1, 0, 0, 60)
			Footer.Position = UDim2.new(0, 0, 1, -60)
		else
			local FormWidth = math.clamp(Config.FormWidthScale or 0.42, 0.32, 0.68)
			Form.Size = UDim2.new(FormWidth, -6, 1, 0)
			Preview.Size = UDim2.new(1 - FormWidth, -6, 1, -66)
			Preview.Position = UDim2.new(FormWidth, 6, 0, 0)
			Footer.Size = UDim2.new(1 - FormWidth, -6, 0, 60)
			Footer.Position = UDim2.new(FormWidth, 6, 1, -60)
		end
		RefreshHistoryCanvas(false)
	end
	Creator.AddSignal(Panel:GetPropertyChangedSignal("AbsoluteSize"), function() Controller:UpdateLayout() end, Gui)
	task.defer(function() Controller:UpdateLayout() end)

	for Id, Value in pairs(Config.InitialValues or {}) do Controller:SetValue(Id, Value) end
	return Controller
end

return StandalonePanel
