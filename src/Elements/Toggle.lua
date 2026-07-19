local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Title = Config.Title,
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Toggle",
	}
	Library:RegisterCallbackContext(Toggle.Callback, { Title = Config.Title, Type = "Toggle", Id = Idx })

	local ToggleFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true, Config.Tooltip)
	ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

	Toggle.SetTitle = ToggleFrame.SetTitle
	Toggle.SetDesc = ToggleFrame.SetDesc

	local ToggleCircle = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ImageTransparency = 0.5,
		ThemeTag = {
			ImageColor3 = "ToggleSlider",
		},
	})

	local ToggleBorder = New("UIStroke", {
		Transparency = 0.5,
		ThemeTag = {
			Color = "ToggleSlider",
		},
	})

	local ToggleSlider = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = ToggleFrame.Frame,
		BackgroundTransparency = 1,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 9),
		}),
		ToggleBorder,
		ToggleCircle,
	})

	local KeybindConnection
	local Picking = false
	local PickBeganConnection
	local PickEndedConnection

	if Config.Keybind then
		local DefaultKey = typeof(Config.Keybind) == "EnumItem" and Config.Keybind.Name or tostring(Config.Keybind)
		Toggle.Keybind = DefaultKey

		local KeybindLabel = New("TextLabel", {
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Text = DefaultKey,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		local KeybindButton = New("TextButton", {
			Size = UDim2.fromOffset(0, 22),
			Position = UDim2.new(1, -56, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 0.9,
			Selectable = true,
			Parent = ToggleFrame.Frame,
			AutomaticSize = Enum.AutomaticSize.X,
			ThemeTag = {
				BackgroundColor3 = "Keybind",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			}),
			New("UIStroke", {
				Transparency = 0.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				ThemeTag = {
					Color = "InElementBorder",
				},
			}),
			KeybindLabel,
		})

		KeybindConnection = Creator.AddSignal(UserInputService.InputBegan, function(Input)
			if not Picking and not UserInputService:GetFocusedTextBox() then
				local Key = Toggle.Keybind
				if Key and Key ~= "None" then
					if Key == "MouseLeft" or Key == "MouseRight" then
						if Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
						or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2 then
							Toggle:SetValue(not Toggle.Value)
						end
					elseif Input.UserInputType == Enum.UserInputType.Keyboard then
						if Input.KeyCode.Name == Key then
							Toggle:SetValue(not Toggle.Value)
						end
					end
				end
			end
		end, ToggleFrame.Frame)

		Creator.AddSignal(KeybindButton.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
			or Input.KeyCode == Enum.KeyCode.ButtonA then
				if Picking then return end
				Picking = true
				KeybindLabel.Text = "..."

				task.wait(0.2)

				Creator.RemoveSignal(PickBeganConnection)
				Creator.RemoveSignal(PickEndedConnection)

				PickBeganConnection = Creator.AddSignal(UserInputService.InputBegan, function(Input)
					local Key
					if Input.UserInputType == Enum.UserInputType.Keyboard then
						Key = Input.KeyCode.Name
					elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Key = "MouseLeft"
					elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
						Key = "MouseRight"
					end

					if not Key then return end

					Creator.RemoveSignal(PickEndedConnection)
					PickEndedConnection = Creator.AddSignal(UserInputService.InputEnded, function(Input)
						if Input.KeyCode.Name == Key
						or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
						or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2 then
							Picking = false
							KeybindLabel.Text = Key
							Toggle.Keybind = Key

							Creator.RemoveSignal(PickBeganConnection)
							Creator.RemoveSignal(PickEndedConnection)
						end
					end, ToggleFrame.Frame)
				end, ToggleFrame.Frame)
			end
		end, ToggleFrame.Frame)
	end

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	function Toggle:SetValue(Value)
		Value = not not Value
		Toggle.Value = Value

		Creator.OverrideTag(ToggleBorder, { Color = Toggle.Value and "Accent" or "ToggleSlider" })
		Creator.OverrideTag(ToggleCircle, { ImageColor3 = Toggle.Value and "ToggleToggled" or "ToggleSlider" })
		Creator.PlayTween(
			ToggleCircle,
			TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0) }
		)
		Creator.PlayTween(
			ToggleSlider,
			TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ BackgroundTransparency = Toggle.Value and 0 or 1 }
		)
		ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5

		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		Picking = false
		Creator.RemoveSignal(PickBeganConnection)
		Creator.RemoveSignal(PickEndedConnection)
		Creator.RemoveSignal(KeybindConnection)
		ToggleFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ToggleFrame.Frame.Activated, function()
		Toggle:SetValue(not Toggle.Value)
	end, ToggleFrame.Frame)

	Toggle:SetValue(Toggle.Value)

	Library.Options[Idx] = Toggle
	return Toggle
end

return Element
