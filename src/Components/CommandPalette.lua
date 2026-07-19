local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New

return function(Library)
	local Palette = { Opened = false, Results = {} }

	local Tint = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false, ZIndex = 100, Parent = Library.Layers.Overlay })
	local Dismiss = New("TextButton", { Text = "", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 100, Parent = Tint })
	local Panel = New("Frame", { Size = UDim2.new(0.9, 0, 0, 330), Position = UDim2.new(0.5, 0, 0.18, 0), AnchorPoint = Vector2.new(0.5, 0), ThemeTag = { BackgroundColor3 = "Dialog" }, Parent = Tint }, {
		New("UISizeConstraint", { MinSize = Vector2.new(300, 260), MaxSize = Vector2.new(560, 330) }),
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.45, ThemeTag = { Color = "DialogBorder" } }),
	})
	local Search = New("TextBox", { Size = UDim2.new(1, -32, 0, 42), Position = UDim2.fromOffset(16, 14), PlaceholderText = "Type a command...", Text = "", TextSize = 16, BackgroundTransparency = 0.1, ThemeTag = { BackgroundColor3 = "DialogInput", TextColor3 = "Text", PlaceholderColor3 = "SubText" }, Parent = Panel }, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.55, ThemeTag = { Color = "DialogInputLine" } }),
	})
	local Results = New("ScrollingFrame", { Size = UDim2.new(1, -32, 1, -78), Position = UDim2.fromOffset(16, 66), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), Parent = Panel }, {
		New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local function ClearResults()
		for _, Child in ipairs(Results:GetChildren()) do if Child:IsA("TextButton") then Child:Destroy() end end
		table.clear(Palette.Results)
	end

	local function Matches(Command, Query)
		local Text = (tostring(Command.Title) .. " " .. tostring(Command.Id)):lower()
		for _, Keyword in ipairs(Command.Keywords or {}) do Text = Text .. " " .. tostring(Keyword):lower() end
		return Query == "" or Text:find(Query, 1, true) ~= nil
	end

	function Palette:Refresh()
		ClearResults()
		local Query = Search.Text:lower()
		for _, Command in ipairs(Library:GetCommands()) do
			if #Palette.Results >= 7 then break end
			if Matches(Command, Query) then
				table.insert(Palette.Results, Command)
				local Button = New("TextButton", { Size = UDim2.new(1, -2, 0, 34), Text = "  " .. Command.Title, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 0.2, ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" }, Parent = Results }, {
					New("UICorner", { CornerRadius = UDim.new(0, 5) }),
					New("UIStroke", { Transparency = 0.7, ThemeTag = { Color = "DialogButtonBorder" } }),
				})
				Creator.AddSignal(Button.Activated, function() Palette:Close(); Library:ExecuteCommand(Command) end, Button)
			end
		end
		Results.CanvasSize = UDim2.fromOffset(0, #Palette.Results * 40)
	end

	function Palette:Open()
		Palette.Opened = true
		Tint.Visible = true
		Search.Text = ""
		Palette:Refresh()
		task.defer(function() Search:CaptureFocus() end)
	end

	function Palette:Close()
		Palette.Opened = false
		Tint.Visible = false
		Search:ReleaseFocus()
	end

	Creator.AddSignal(Search:GetPropertyChangedSignal("Text"), function() Palette:Refresh() end, Tint)
	Creator.AddSignal(Search.FocusLost, function(EnterPressed)
		if EnterPressed and Palette.Results[1] then local Command = Palette.Results[1]; Palette:Close(); Library:ExecuteCommand(Command) end
	end, Tint)
	Creator.AddSignal(Dismiss.Activated, function() Palette:Close() end, Tint)
	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if Palette.Opened and Input.KeyCode == Enum.KeyCode.Escape then Palette:Close() end
	end, Tint)

	if UserInputService.TouchEnabled then
		local MobileButton = New("TextButton", { Size = UDim2.fromOffset(46, 38), Position = UDim2.new(0, 12, 1, -54), Text = "Find", TextSize = 12, BackgroundTransparency = 0.08, ThemeTag = { BackgroundColor3 = "Dialog", TextColor3 = "Text" }, Parent = Library.Layers.Overlay }, { New("UICorner", { CornerRadius = UDim.new(0, 7) }) })
		Creator.AddSignal(MobileButton.Activated, function() Palette:Open() end, MobileButton)
	end

	return Palette
end
