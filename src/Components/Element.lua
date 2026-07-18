local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Title, Desc, Parent, Hover, TooltipText)
	local Element = {}

	Element.TitleLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		Text = Title,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Element.DescLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Desc,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	Element.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -28, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 13),
			PaddingTop = UDim.new(0, 13),
		}),
		Element.TitleLabel,
		Element.DescLabel,
	})

	Element.Border = New("UIStroke", {
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(0, 0, 0),
		ThemeTag = {
			Color = "ElementBorder",
		},
	})

	Element.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0.89,
		BackgroundColor3 = Color3.fromRGB(130, 130, 130),
		Parent = Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = 7,
		ThemeTag = {
			BackgroundColor3 = "Element",
			BackgroundTransparency = "ElementTransparency",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Element.Border,
		Element.LabelHolder,
	})

	function Element:SetTitle(Set)
		Element.TitleLabel.Text = Set
	end

	function Element:SetDesc(Set)
		if Set == nil then
			Set = ""
		end
		if Set == "" then
			Element.DescLabel.Visible = false
		else
			Element.DescLabel.Visible = true
		end
		Element.DescLabel.Text = Set
	end

	function Element:Destroy()
		Element.Frame:Destroy()
	end

	Element:SetTitle(Title)
	Element:SetDesc(Desc)

	if Hover then
		local Themes = Root.Themes
		local Motor, SetTransparency = Creator.SpringMotor(
			Creator.GetThemeProperty("ElementTransparency"),
			Element.Frame,
			"BackgroundTransparency",
			false,
			true
		)

		Creator.AddSignal(Element.Frame.MouseEnter, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
		end, Element.Frame)
		Creator.AddSignal(Element.Frame.MouseLeave, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency"))
		end, Element.Frame)
		Creator.AddSignal(Element.Frame.MouseButton1Down, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") + Creator.GetThemeProperty("HoverChange"))
		end, Element.Frame)
		Creator.AddSignal(Element.Frame.MouseButton1Up, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
		end, Element.Frame)
		Creator.AddSignal(Element.Frame.SelectionGained, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
		end, Element.Frame)
		Creator.AddSignal(Element.Frame.SelectionLost, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency"))
		end, Element.Frame)
	end

	if TooltipText and TooltipText ~= "" then
		local TooltipFrame = nil
		local TooltipThread = nil

		local function CreateTooltip()
			if TooltipFrame then return end
			
			local TooltipLabel = New("TextLabel", {
				Text = TooltipText,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextSize = 11,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
			}, {
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				})
			})

			TooltipFrame = New("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				BackgroundTransparency = 0.05,
				ZIndex = 100,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 4) }),
				New("UIStroke", {
					Color = Color3.fromRGB(55, 55, 55),
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = 1,
				}),
				TooltipLabel
			})
			
			local OverlayLayer = require(Root):GetLayer("Overlay")
			TooltipFrame.Parent = OverlayLayer

			local function UpdatePosition()
				if not TooltipFrame or not Element.Frame then return end
				local FramePos = Element.Frame.AbsolutePosition
				local FrameSize = Element.Frame.AbsoluteSize
				local TooltipSize = TooltipFrame.AbsoluteSize
				TooltipFrame.Position = UDim2.fromOffset(
					FramePos.X + (FrameSize.X / 2) - (TooltipSize.X / 2),
					FramePos.Y - TooltipSize.Y - 6
				)
			end
			UpdatePosition()
			
			Creator.AddSignal(Element.Frame:GetPropertyChangedSignal("AbsolutePosition"), UpdatePosition, TooltipFrame)
			task.spawn(function()
				task.wait()
				UpdatePosition()
			end)
		end

		local function DestroyTooltip()
			if TooltipThread then
				task.cancel(TooltipThread)
				TooltipThread = nil
			end
			if TooltipFrame then
				TooltipFrame:Destroy()
				TooltipFrame = nil
			end
		end

		Creator.AddSignal(Element.Frame.MouseEnter, function()
			if TooltipThread then task.cancel(TooltipThread) end
			TooltipThread = task.delay(0.4, function()
				CreateTooltip()
			end)
		end, Element.Frame)

		Creator.AddSignal(Element.Frame.MouseLeave, function()
			DestroyTooltip()
		end, Element.Frame)

		Creator.AddSignal(Element.Frame.Destroying, function()
			DestroyTooltip()
		end, Element.Frame)
	end

	return Element
end
