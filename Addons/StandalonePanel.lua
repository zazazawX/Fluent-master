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
	local Creator = Library.Creator
	local New = Creator.New
	local Acrylic = Library.Acrylic
	local PreviousUseAcrylic = Library.UseAcrylic == true
	local UseAcrylic = Config.Acrylic == true or (Config.Acrylic == nil and Library.UseAcrylic == true)
	if UseAcrylic then
		Library.UseAcrylic = true
		if not PreviousUseAcrylic then Acrylic.init() end
	end
	local Controller = {
		Values = {},
		Inputs = {},
		Choices = {},
		ChoiceSelectors = {},
		Logs = {},
		Opened = true,
		Submitting = false,
	}

	local Gui = New("ScreenGui", {
		Name = Config.Name or "CoreXStandalonePanel",
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ClipToDeviceSafeArea = false,
		ResetOnSpawn = false,
		Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
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
			MinSize = Vector2.new(320, 360),
			MaxSize = Vector2.new(760, 520),
		}),
	})
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

	New("TextLabel", {
		Size = UDim2.new(0.6, -20, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Text = Config.Title or "Standalone Panel",
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "Text" },
		Parent = Header,
	})

	local MetricLabel = New("TextLabel", {
		Size = UDim2.new(0.4, -46, 1, 0),
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

	local Body = New("Frame", {
		Size = UDim2.new(1, -28, 1, -126),
		Position = UDim2.fromOffset(14, 58),
		BackgroundTransparency = 1,
		Parent = Surface,
	})

	local Form = New("ScrollingFrame", {
		Size = UDim2.new(0.38, -6, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		Parent = Body,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local Preview = New("Frame", {
		Size = UDim2.new(0.62, -6, 1, 0),
		Position = UDim2.new(0.38, 6, 0, 0),
		BackgroundTransparency = 0.15,
		ThemeTag = { BackgroundColor3 = "DialogInput" },
		Parent = Body,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.65, ThemeTag = { Color = "DialogButtonBorder" } }),
	})

	local PreviewTitle = New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 34),
		Position = UDim2.fromOffset(12, 4),
		BackgroundTransparency = 1,
		Text = Config.PreviewTitle or "Preview",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "Text" },
		Parent = Preview,
	})

	local PreviewText = New("TextLabel", {
		Size = UDim2.new(1, -24, 1, -50),
		Position = UDim2.fromOffset(12, 38),
		BackgroundTransparency = 1,
		Text = Config.Preview or "",
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		ThemeTag = { TextColor3 = "SubText" },
		Parent = Preview,
	})

	local function AddLabel(Text)
		return New("TextLabel", {
			Size = UDim2.new(1, -4, 0, 18),
			BackgroundTransparency = 1,
			Text = Text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
			ThemeTag = { TextColor3 = "SubText" },
			Parent = Form,
		})
	end

	local function AddInput(Field)
		AddLabel(Field.Title or Field.Id)
		local Holder = New("Frame", {
			Size = UDim2.new(1, -4, 0, 34),
			BackgroundTransparency = 0.08,
			ThemeTag = { BackgroundColor3 = "DialogInput" },
			Parent = Form,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 5) }),
			New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "DialogInputLine" } }),
		})
		local Input = New("TextBox", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			BackgroundTransparency = 1,
			Text = tostring(Field.Default or ""),
			PlaceholderText = Field.Placeholder or "",
			ClearTextOnFocus = false,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
			Parent = Holder,
		})
		local Indicator = New("Frame", { Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 2, 1, -1), ThemeTag = { BackgroundColor3 = "DialogInputLine" }, Parent = Holder })
		Controller.Values[Field.Id] = Field.Default or ""
		Controller.Inputs[Field.Id] = Input
		Creator.AddSignal(Input:GetPropertyChangedSignal("Text"), function()
			local Value = Input.Text
			if Field.Type == "Number" then Value = tonumber(Value) end
			Controller.Values[Field.Id] = Value
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end, Gui)
		Creator.AddSignal(Input.Focused, function()
			Indicator.Size = UDim2.new(1, -2, 0, 2)
			Creator.OverrideTag(Indicator, { BackgroundColor3 = "Accent" })
		end, Gui)
		Creator.AddSignal(Input.FocusLost, function()
			Indicator.Size = UDim2.new(1, -4, 0, 1)
			Creator.OverrideTag(Indicator, { BackgroundColor3 = "DialogInputLine" })
		end, Gui)
	end

	local function AddChoice(Field)
		AddLabel(Field.Title or Field.Id)
		local Holder = New("Frame", {
			Size = UDim2.new(1, -4, 0, math.ceil(#(Field.Values or {}) / 2) * 32),
			BackgroundTransparency = 1,
			Parent = Form,
		}, {
			New("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 26), CellPadding = UDim2.fromOffset(6, 6) }),
		})
		Controller.Values[Field.Id] = Field.Default or Field.Values and Field.Values[1]
		Controller.Choices[Field.Id] = {}
		local function Select(Value)
			Controller.Values[Field.Id] = Value
			for ChoiceValue, Button in pairs(Controller.Choices[Field.Id]) do
				Button.BackgroundTransparency = ChoiceValue == Value and 0.05 or 0.65
				Creator.OverrideTag(Button, { BackgroundColor3 = "DialogButton", TextColor3 = ChoiceValue == Value and "Accent" or "SubText" })
			end
			if Field.OnChanged then Library:SafeCallback(Field.OnChanged, Value, Controller) end
		end
		Controller.ChoiceSelectors[Field.Id] = Select
		for _, Value in ipairs(Field.Values or {}) do
			local Button = New("TextButton", {
				Text = tostring(Value),
				TextSize = 11,
				BackgroundTransparency = 0.65,
				ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "SubText" },
				Parent = Holder,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 4) }),
				New("UIStroke", { Transparency = 0.7, ThemeTag = { Color = "DialogButtonBorder" } }),
			})
			Controller.Choices[Field.Id][Value] = Button
			Creator.AddSignal(Button.Activated, function() Select(Value) end, Gui)
		end
		Select(Controller.Values[Field.Id])
	end

	for _, Field in ipairs(Config.Fields or {}) do
		assert(Field.Id, "StandalonePanel - Every field requires Id")
		if Field.Type == "Choice" then AddChoice(Field) else AddInput(Field) end
	end

	task.defer(function()
		local Layout = Form:FindFirstChildOfClass("UIListLayout")
		if Layout then Form.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 4) end
	end)

	local Footer = New("Frame", { Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 1, -60), ThemeTag = { BackgroundColor3 = "DialogHolder" }, Parent = Surface }, {
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

	function Controller:SetMetric(Value, Title)
		if Title then Config.MetricTitle = Title end
		MetricLabel.Text = (Config.MetricTitle or "Total") .. ": " .. tostring(Value)
	end

	function Controller:SetPreview(Text, Title)
		PreviewText.Text = tostring(Text or "")
		if Title then PreviewTitle.Text = Title end
	end

	function Controller:AppendLog(Text)
		table.insert(self.Logs, tostring(Text))
		local Limit = Config.LogLimit or 30
		while #self.Logs > Limit do table.remove(self.Logs, 1) end
		self:SetPreview(table.concat(self.Logs, "\n"), Config.PreviewTitle or "History")
	end

	function Controller:SetValue(Id, Value)
		self.Values[Id] = Value
		if self.Inputs[Id] then self.Inputs[Id].Text = tostring(Value or "") end
		if self.ChoiceSelectors[Id] then self.ChoiceSelectors[Id](Value) end
	end

	function Controller:SetSubmitting(Value, Text)
		self.Submitting = Value == true
		Action.Active = not self.Submitting
		Action.Text = Text or (self.Submitting and (Config.SubmittingText or "Working...") or (Config.ActionText or "Submit"))
		Action.BackgroundTransparency = self.Submitting and 0.45 or 0
	end

	function Controller:Submit()
		if self.Submitting then return end
		self:SetSubmitting(true)
		task.spawn(function()
			local Success, Result = xpcall(function()
				return Config.OnSubmit(self.Values, self)
			end, debug.traceback)
			self:SetSubmitting(false)
			if not Success then
				self:AppendLog("Error: " .. tostring(Result):match("^[^\n]+"))
				Library:Notify({ Title = Config.Title or "Standalone Panel", Content = "Action failed", SubContent = tostring(Result):match("^[^\n]+"), Type = "Error", Duration = 6 })
				warn(Result)
			elseif type(Result) == "string" then
				self:AppendLog(Result)
			end
		end)
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
	Creator.AddSignal(Action.MouseEnter, function() if not Controller.Submitting then Action.BackgroundTransparency = 0.15 end end, Gui)
	Creator.AddSignal(Action.MouseLeave, function() Action.BackgroundTransparency = Controller.Submitting and 0.45 or 0 end, Gui)
	Creator.AddSignal(CloseButton.Activated, function()
		if Config.DestroyOnClose then Controller:Destroy() else Controller:Close() end
		if Config.OnClose then Library:SafeCallback(Config.OnClose, Controller) end
	end, Gui)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if Controller.Opened and Config.CloseOnEscape ~= false and Input.KeyCode == Enum.KeyCode.Escape then
			Controller:Close()
		end
	end, Gui)

	local function UpdateLayout()
		if Panel.AbsoluteSize.X < 520 then
			Form.Size = UDim2.new(1, 0, 0.48, -4)
			Preview.Size = UDim2.new(1, 0, 0.52, -4)
			Preview.Position = UDim2.new(0, 0, 0.48, 4)
		else
			Form.Size = UDim2.new(0.38, -6, 1, 0)
			Preview.Size = UDim2.new(0.62, -6, 1, 0)
			Preview.Position = UDim2.new(0.38, 6, 0, 0)
		end
	end
	Creator.AddSignal(Panel:GetPropertyChangedSignal("AbsoluteSize"), UpdateLayout, Gui)
	task.defer(UpdateLayout)

	for Id, Value in pairs(Config.InitialValues or {}) do Controller:SetValue(Id, Value) end
	return Controller
end

return StandalonePanel
