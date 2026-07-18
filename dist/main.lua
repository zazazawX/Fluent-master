
-- Bundled by bundle.js
local modules = {}
local loaded = {}

local function get_parent_path(path)
    if path == "" then
        return ""
    end
    local parent = path:match("^(.-)%.[^%.]+$")
    return parent or ""
end

local function create_mock_script(path)
    local mock
    mock = setmetatable({}, {
        __index = function(self, key)
            if key == "Parent" then
                return create_mock_script(get_parent_path(path))
            end
            local newPath = path == "" and key or (path .. "." .. key)
            return create_mock_script(newPath)
        end,
        __tostring = function(self)
            return path
        end
    })
    return mock
end

local function register(name, func)
    modules[name] = func
end

local function require(name)
    name = tostring(name)
    if name == "" then
        name = "main"
    end
    if loaded[name] then
        return loaded[name]
    end
    if not modules[name] then
        error("Module not found in bundle: " .. tostring(name))
    end
    local val = modules[name]()
    loaded[name] = val
    return val
end

register("Acrylic.AcrylicBlur", function()
local script = create_mock_script("Acrylic.AcrylicBlur")
local Creator = require(script.Parent.Parent.Creator)
local createAcrylic = require(script.Parent.CreateAcrylic)
local viewportPointToWorld, getOffset = unpack(require(script.Parent.Utils))

local BlurFolder = Instance.new("Folder", game:GetService("Workspace").CurrentCamera)

local function createAcrylicBlur(distance)
	local cleanups = {}

	distance = distance or 0.001
	local positions = {
		topLeft = Vector2.new(),
		topRight = Vector2.new(),
		bottomRight = Vector2.new(),
	}
	local model = createAcrylic()
	model.Parent = BlurFolder

	local function updatePositions(size, position)
		positions.topLeft = position
		positions.topRight = position + Vector2.new(size.X, 0)
		positions.bottomRight = position + size
	end

	local function render()
		if model.Transparency >= 1 then
			return
		end
		local res = game:GetService("Workspace").CurrentCamera
		if res then
			res = res.CFrame
		end
		local cond = res
		if not cond then
			cond = CFrame.new()
		end

		local camera = cond
		local topLeft = positions.topLeft
		local topRight = positions.topRight
		local bottomRight = positions.bottomRight

		local topLeft3D = viewportPointToWorld(topLeft, distance)
		local topRight3D = viewportPointToWorld(topRight, distance)
		local bottomRight3D = viewportPointToWorld(bottomRight, distance)

		local width = (topRight3D - topLeft3D).Magnitude
		local height = (topRight3D - bottomRight3D).Magnitude

		model.CFrame =
			CFrame.fromMatrix((topLeft3D + bottomRight3D) / 2, camera.XVector, camera.YVector, camera.ZVector)
		model.Mesh.Scale = Vector3.new(width, height, 0)
	end

	local function onChange(rbx)
		local offset = getOffset()
		local size = rbx.AbsoluteSize - Vector2.new(offset, offset)
		local position = rbx.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

		updatePositions(size, position)
		task.spawn(render)
	end

	local function renderOnChange()
		local camera = game:GetService("Workspace").CurrentCamera
		if not camera then
			return
		end

		table.insert(cleanups, camera:GetPropertyChangedSignal("CFrame"):Connect(render))
		table.insert(cleanups, camera:GetPropertyChangedSignal("ViewportSize"):Connect(render))
		table.insert(cleanups, camera:GetPropertyChangedSignal("FieldOfView"):Connect(render))
		task.spawn(render)
	end

	model.Destroying:Connect(function()
		for _, item in cleanups do
			pcall(function()
				item:Disconnect()
			end)
		end
	end)

	renderOnChange()

	return onChange, model
end

return function(distance)
	local Blur = {}
	local onChange, model = createAcrylicBlur(distance)

	local comp = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})

	Creator.AddSignal(comp:GetPropertyChangedSignal("AbsolutePosition"), function()
		onChange(comp)
	end, comp)

	Creator.AddSignal(comp:GetPropertyChangedSignal("AbsoluteSize"), function()
		onChange(comp)
	end, comp)

	Blur.AddParent = function(Parent)
		Creator.AddSignal(Parent:GetPropertyChangedSignal("Visible"), function()
			Blur.SetVisibility(Parent.Visible)
		end, comp)
	end

	Blur.SetVisibility = function(Value)
		model.Transparency = Value and 0.98 or 1
	end

	Blur.Frame = comp
	Blur.Model = model

	return Blur
end

end)

register("Acrylic.AcrylicPaint", function()
local script = create_mock_script("Acrylic.AcrylicPaint")
local Creator = require(script.Parent.Parent.Creator)
local AcrylicBlur = require(script.Parent.AcrylicBlur)

local New = Creator.New

return function(props)
	local AcrylicPaint = {}

	AcrylicPaint.Frame = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, {
		New("ImageLabel", {
			Image = "rbxassetid://8992230677",
			ScaleType = "Slice",
			SliceCenter = Rect.new(Vector2.new(99, 99), Vector2.new(99, 99)),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 120, 1, 116),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.7,
		}),

		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		New("Frame", {
			BackgroundTransparency = 0.45,
			Size = UDim2.fromScale(1, 1),
			Name = "Background",
			ThemeTag = {
				BackgroundColor3 = "AcrylicMain",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),

		New("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.4,
			Size = UDim2.fromScale(1, 1),
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),

			New("UIGradient", {
				Rotation = 90,
				ThemeTag = {
					Color = "AcrylicGradient",
				},
			}),
		}),

		New("ImageLabel", {
			Image = "rbxassetid://9968344105",
			ImageTransparency = 0.98,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0, 128, 0, 128),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),

		New("ImageLabel", {
			Image = "rbxassetid://9968344227",
			ImageTransparency = 0.9,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0, 128, 0, 128),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageTransparency = "AcrylicNoise",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),

		New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			New("UIStroke", {
				Transparency = 0.5,
				Thickness = 1,
				ThemeTag = {
					Color = "AcrylicBorder",
				},
			}),
		}),
	})

	local Blur

	if require(script.Parent.Parent).UseAcrylic then
		Blur = AcrylicBlur()
		Blur.Frame.Parent = AcrylicPaint.Frame
		AcrylicPaint.Model = Blur.Model
		AcrylicPaint.AddParent = Blur.AddParent
		AcrylicPaint.SetVisibility = Blur.SetVisibility
	end

	return AcrylicPaint
end

end)

register("Acrylic.CreateAcrylic", function()
local script = create_mock_script("Acrylic.CreateAcrylic")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local function createAcrylic()
	local Part = Creator.New("Part", {
		Name = "Body",
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanCollide = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.98,
	}, {
		Creator.New("SpecialMesh", {
			MeshType = Enum.MeshType.Brick,
			Offset = Vector3.new(0, 0, -0.000001),
		}),
	})

	return Part
end

return createAcrylic

end)

register("Acrylic", function()
local script = create_mock_script("Acrylic")
local Acrylic = {
	AcrylicBlur = require(script.AcrylicBlur),
	CreateAcrylic = require(script.CreateAcrylic),
	AcrylicPaint = require(script.AcrylicPaint),
}

function Acrylic.init()
	local baseEffect = Instance.new("DepthOfFieldEffect")
	baseEffect.FarIntensity = 0
	baseEffect.InFocusRadius = 0.1
	baseEffect.NearIntensity = 1

	local depthOfFieldDefaults = {}

	function Acrylic.Enable()
		for _, effect in pairs(depthOfFieldDefaults) do
			effect.Enabled = false
		end
		baseEffect.Parent = game:GetService("Lighting")
	end

	function Acrylic.Disable()
		for _, effect in pairs(depthOfFieldDefaults) do
			effect.Enabled = effect.enabled
		end
		baseEffect.Parent = nil
	end

	local function registerDefaults()
		local function register(object)
			if object:IsA("DepthOfFieldEffect") then
				depthOfFieldDefaults[object] = { enabled = object.Enabled }
			end
		end

		for _, child in pairs(game:GetService("Lighting"):GetChildren()) do
			register(child)
		end

		if game:GetService("Workspace").CurrentCamera then
			for _, child in pairs(game:GetService("Workspace").CurrentCamera:GetChildren()) do
				register(child)
			end
		end
	end

	registerDefaults()
	Acrylic.Enable()
end

return Acrylic

end)

register("Acrylic.Utils", function()
local script = create_mock_script("Acrylic.Utils")
local function map(value, inMin, inMax, outMin, outMax)
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

local function viewportPointToWorld(location, distance)
	local unitRay = game:GetService("Workspace").CurrentCamera:ScreenPointToRay(location.X, location.Y)
	return unitRay.Origin + unitRay.Direction * distance
end

local function getOffset()
	local viewportSizeY = game:GetService("Workspace").CurrentCamera.ViewportSize.Y
	return map(viewportSizeY, 0, 2560, 8, 56)
end

return { viewportPointToWorld, getOffset }

end)

register("Components.Assets", function()
local script = create_mock_script("Components.Assets")
return {
	Close = "rbxassetid://9886659671",
	Min = "rbxassetid://9886659276",
	Max = "rbxassetid://9886659406",
	Restore = "rbxassetid://9886659001",
}

end)

register("Components.Button", function()
local script = create_mock_script("Components.Button")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Theme, Parent, DialogCheck)
	DialogCheck = DialogCheck or false
	local Button = {}

	Button.Title = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Button.HoverFrame = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ThemeTag = {
			BackgroundColor3 = "Hover",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	Button.Frame = New("TextButton", {
		Size = UDim2.new(0, 0, 0, 32),
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "DialogButton",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.65,
			ThemeTag = {
				Color = "DialogButtonBorder",
			},
		}),
		Button.HoverFrame,
		Button.Title,
	})

	local Motor, SetTransparency = Creator.SpringMotor(1, Button.HoverFrame, "BackgroundTransparency", DialogCheck)
	Creator.AddSignal(Button.Frame.MouseEnter, function()
		SetTransparency(0.97)
	end, Button.Frame)
	Creator.AddSignal(Button.Frame.MouseLeave, function()
		SetTransparency(1)
	end, Button.Frame)
	Creator.AddSignal(Button.Frame.MouseButton1Down, function()
		SetTransparency(1)
	end, Button.Frame)
	Creator.AddSignal(Button.Frame.MouseButton1Up, function()
		SetTransparency(0.97)
	end, Button.Frame)
	Creator.AddSignal(Button.Frame.SelectionGained, function()
		SetTransparency(0.94)
	end, Button.Frame)
	Creator.AddSignal(Button.Frame.SelectionLost, function()
		SetTransparency(1)
	end, Button.Frame)

	return Button
end

end)

register("Components.Dialog", function()
local script = create_mock_script("Components.Dialog")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local GuiService = game:GetService("GuiService")

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
		NewDialog.PreviousSelection = GuiService.SelectedObject
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
		task.defer(function()
			local FirstButton = NewDialog.ButtonFrames[1]
			if Library.ActiveDialog == NewDialog and FirstButton and FirstButton.Parent then
				GuiService.SelectedObject = FirstButton
			end
		end)
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

end)

register("Components.Element", function()
local script = create_mock_script("Components.Element")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Title, Desc, Parent, Hover, TooltipText)
	local Element = {}

	local Library = require(Root)
	local isTitleTranslated = Library.Translations.en[Title] ~= nil
	local isDescTranslated = Library.Translations.en[Desc] ~= nil

	Element.TitleLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		Text = isTitleTranslated and Library:Translate(Title) or Title,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
			TextSize = "ElementTitleSize",
		},
	})

	if isTitleTranslated then
		Creator.AddTranslationObject(Element.TitleLabel, "Text", Title)
	end

	Element.DescLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = isDescTranslated and Library:Translate(Desc) or (Desc or ""),
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
			TextSize = "ElementDescSize",
		},
	})

	if isDescTranslated then
		Creator.AddTranslationObject(Element.DescLabel, "Text", Desc)
	end

	Element.Padding = New("UIPadding", {
		PaddingBottom = UDim.new(0, 13),
		PaddingTop = UDim.new(0, 13),
		ThemeTag = {
			PaddingBottom = "ElementPadding",
			PaddingTop = "ElementPadding",
		}
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
		Element.Padding,
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

end)

register("Components.Notification", function()
local script = create_mock_script("Components.Notification")
local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)

local Spring = Creator.MotionGoal
local Instant = Flipper.Instant.new
local New = Creator.New

local Notification = {
	Active = {},
	Queue = {},
	Clearing = false,
}

local function RemoveValue(List, Value)
	local Index = table.find(List, Value)
	if Index then
		table.remove(List, Index)
	end
end

local function DestroyImmediately(Item)
	if Item.Destroyed then
		return
	end
	Item.Destroyed = true
	if Item.RootMotor then
		Item.RootMotor:destroy()
	end
	if require(Root).UseAcrylic and Item.AcrylicPaint and Item.AcrylicPaint.Model then
		pcall(function()
			Item.AcrylicPaint.Model:Destroy()
		end)
	end
	if Item.Holder then
		Item.Holder:Destroy()
	end
end

function Notification:ProcessQueue()
	if Notification.Clearing then
		return
	end
	local Limit = math.max(1, require(Root).NotificationLimit or 3)
	while #Notification.Active < Limit and #Notification.Queue > 0 do
		local Item = table.remove(Notification.Queue, 1)
		if not Item.Closed then
			Item:Open()
		end
	end
end

function Notification:EnforceLimit()
	local Limit = math.max(1, require(Root).NotificationLimit or 3)
	for Index = #Notification.Active, Limit + 1, -1 do
		local Item = Notification.Active[Index]
		if Item and not Item.Closed then
			Item:Close()
		end
	end
	Notification:ProcessQueue()
end

function Notification:Clear()
	Notification.Clearing = true
	local Items = {}
	for _, Item in ipairs(Notification.Active) do
		table.insert(Items, Item)
	end
	for _, Item in ipairs(Notification.Queue) do
		table.insert(Items, Item)
	end
	table.clear(Notification.Active)
	table.clear(Notification.Queue)
	for _, Item in ipairs(Items) do
		Item.Closed = true
		DestroyImmediately(Item)
	end
	Notification.Clearing = false
end

function Notification:Init(Parent)
	table.clear(Notification.Active)
	table.clear(Notification.Queue)
	Notification.Holder = New("Frame", {
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.new(1, -24, 1, -24),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = Parent,
	}, {
		New("UISizeConstraint", {
			MinSize = Vector2.new(0, 0),
			MaxSize = Vector2.new(310, math.huge),
		}),
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 12),
		}),
	})
end

function Notification:New(Config)
	Config.Title = Config.Title or "Title"
	Config.Content = Config.Content or "Content"
	Config.SubContent = Config.SubContent or ""
	Config.Duration = Config.Duration or nil
	Config.Buttons = Config.Buttons or {}

	local Type = Config.Type
	local TypeColors = {
		Success = Color3.fromRGB(110, 210, 145),
		Warning = Color3.fromRGB(245, 185, 95),
		Error = Color3.fromRGB(245, 115, 115),
		Info = Creator.GetThemeProperty("Accent"),
	}
	local TypeIcons = {
		Success = "check-circle",
		Warning = "alert-triangle",
		Error = "x-circle",
		Info = "info",
	}

	local NewNotification = {
		Closed = false,
		Destroyed = false,
		State = "created",
		SwipeOffset = 0,
	}

	NewNotification.AcrylicPaint = Acrylic.AcrylicPaint()
	NewNotification.AcrylicPaint.Frame.ClipsDescendants = true

	local HasIcon = Type ~= nil and TypeIcons[Type] ~= nil
	local TitleXOffset = HasIcon and 42 or 14
	local TextWidthOffset = HasIcon and -66 or -12
	local HolderXOffset = HasIcon and 42 or 14
	local HolderWidthOffset = HasIcon and -56 or -28

	NewNotification.Title = New("TextLabel", {
		Position = UDim2.new(0, TitleXOffset, 0, 17),
		Text = Config.Title,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextSize = 13,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, TextWidthOffset, 0, 12),
		TextWrapped = true,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewNotification.ContentLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.Content,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewNotification.SubContentLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.SubContent,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	NewNotification.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(HolderXOffset, 40),
		Size = UDim2.new(1, HolderWidthOffset, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})

	NewNotification.CloseButton = New("TextButton", {
		Text = "",
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
	}, {
		New("ImageLabel", {
			Image = require(script.Parent.Assets).Close,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
	})

	NewNotification.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
		Active = true,
	}, {
		NewNotification.AcrylicPaint.Frame,
		NewNotification.Title,
		NewNotification.CloseButton,
		NewNotification.LabelHolder,
	})

	if HasIcon then
		local Library = require(Root)
		NewNotification.Icon = New("ImageLabel", {
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromOffset(14, 13),
			BackgroundTransparency = 1,
			Image = Library:GetIcon(TypeIcons[Type]) or "",
			ImageColor3 = TypeColors[Type],
			Parent = NewNotification.Root,
		})
	end

	if Config.Content == "" then
		NewNotification.ContentLabel.Visible = false
	end

	if Config.SubContent == "" then
		NewNotification.SubContentLabel.Visible = false
	end

	NewNotification.Holder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 200),
	}, {
		NewNotification.Root,
	})

	local RootMotor = Flipper.GroupMotor.new({
		Scale = 1,
		Offset = 60,
	})
	NewNotification.RootMotor = RootMotor

	RootMotor:onStep(function(Values)
		NewNotification.Root.Position = UDim2.new(Values.Scale, Values.Offset, 0, 0)
	end)

	Creator.AddSignal(NewNotification.CloseButton.Activated, function()
		NewNotification:Close()
	end, NewNotification.Holder)

	Creator.AddSignal(NewNotification.Root.InputBegan, function(Input)
		if Input.UserInputType ~= Enum.UserInputType.Touch or NewNotification.State ~= "active" then
			return
		end

		local StartPosition = Input.Position
		local TouchConnection
		TouchConnection = Creator.AddSignal(Input.Changed, function()
			NewNotification.SwipeOffset = Input.Position.X - StartPosition.X
			if
				Input.UserInputState == Enum.UserInputState.End
				or Input.UserInputState == Enum.UserInputState.Cancel
			then
				Creator.RemoveSignal(TouchConnection)
				if math.abs(NewNotification.SwipeOffset) >= 70 then
					NewNotification:Close()
				else
					NewNotification.SwipeOffset = 0
					RootMotor:setGoal({
						Scale = Instant(0),
						Offset = Spring(0, { frequency = 7 }),
					})
				end
			else
				RootMotor:setGoal({
					Scale = Instant(0),
					Offset = Instant(NewNotification.SwipeOffset),
				})
			end
		end, NewNotification.Holder)
	end, NewNotification.Holder)

	function NewNotification:Open()
		if NewNotification.Closed or NewNotification.State == "active" then
			return
		end
		NewNotification.State = "active"
		NewNotification.Holder.Parent = Notification.Holder
		table.insert(Notification.Active, NewNotification)
		local ContentSize = NewNotification.LabelHolder.AbsoluteSize.Y
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, 58 + ContentSize)
		task.defer(function()
			if NewNotification.Holder.Parent then
				NewNotification.Holder.Size =
					UDim2.new(1, 0, 0, 58 + NewNotification.LabelHolder.AbsoluteSize.Y)
			end
		end)

		RootMotor:setGoal({
			Scale = Spring(0, { frequency = 5 }),
			Offset = Spring(0, { frequency = 5 }),
		})
		if Config.Duration and not NewNotification.DurationStarted then
			NewNotification.DurationStarted = true
			task.delay(Config.Duration, function()
				NewNotification:Close()
			end)
		end
	end

	function NewNotification:Close()
		if NewNotification.Closed then
			return
		end
		NewNotification.Closed = true

		if NewNotification.State == "queued" or NewNotification.State == "created" then
			RemoveValue(Notification.Queue, NewNotification)
			DestroyImmediately(NewNotification)
			Notification:ProcessQueue()
			return
		end

		NewNotification.State = "closing"
		task.spawn(function()
			local Direction = NewNotification.SwipeOffset < 0 and -1 or 1
			RootMotor:setGoal({
				Scale = Spring(Direction, { frequency = 5 }),
				Offset = Spring(Direction * 60, { frequency = 5 }),
			})
			task.wait(Creator.MotionDuration(0.4))
			RemoveValue(Notification.Active, NewNotification)
			DestroyImmediately(NewNotification)
			Notification:ProcessQueue()
		end)
	end

	local Limit = math.max(1, require(Root).NotificationLimit or 3)
	if #Notification.Active < Limit then
		NewNotification:Open()
	else
		NewNotification.State = "queued"
		table.insert(Notification.Queue, NewNotification)
	end
	return NewNotification
end

return Notification

end)

register("Components.Section", function()
local script = create_mock_script("Components.Section")
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

	local Library = require(Root)
	local isTitleTranslated = Library.Translations.en[Title] ~= nil
	local LabelText = isTitleTranslated and Library:Translate(Title) or Title

	local Label = New("TextLabel", {
		RichText = true,
		Text = LabelText,
		TextTransparency = 0,
		FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		TextSize = 18,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, -24, 1, 0),
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	if isTitleTranslated then
		Creator.AddTranslationObject(Label, "Text", Title)
	end

	local HeaderButton = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.fromOffset(0, 2),
		Text = "",
	}, {
		Label,
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

end)

register("Components.Tab", function()
local script = create_mock_script("Components.Tab")
local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local New = Creator.New
local Spring = Creator.MotionGoal
local Instant = Flipper.Instant.new
local Components = Root.Components

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
	Compact = false,
}

function TabModule:Init(Window)
	local self = setmetatable({}, { __index = TabModule })
	self.Window = Window
	self.Tabs = {}
	self.Containers = {}
	self.SelectedTab = 0
	self.TabCount = 0
	self.Compact = false
	return self
end

function TabModule:GetCurrentTabPos()
	local SelectedTab = self.Tabs[self.SelectedTab]
	if not SelectedTab then
		return 0
	end

	local TabHolderPos = self.Window.TabHolder.AbsolutePosition.Y
	local TabPos = SelectedTab.Frame.AbsolutePosition.Y

	return TabPos - TabHolderPos
end

function TabModule:ApplyTabLayout(Tab)
	local Compact = self.Compact
	local Library = require(Root)

	if Compact then
		Tab.Icon.Visible = true
		if not Tab.HasIcon then
			Tab.Icon.Image = Library:GetIcon("box")
		end
		Tab.Label.Visible = false
		Tab.Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Tab.Icon.Position = UDim2.fromScale(0.5, 0.5)
	else
		Tab.Icon.Visible = Tab.HasIcon
		Tab.Icon.Image = Tab.IconId or ""
		Tab.Label.Visible = true
		Tab.Label.Position = Tab.HasIcon and UDim2.new(0, 30, 0.5, 0) or UDim2.new(0, 12, 0.5, 0)
		Tab.Label.Size = UDim2.new(1, Tab.HasIcon and -36 or -24, 1, 0)
		Tab.Label.TextXAlignment = Compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
		Tab.Icon.AnchorPoint = Vector2.new(0, 0.5)
		Tab.Icon.Position = UDim2.new(0, 8, 0.5, 0)
	end
end

function TabModule:SetCompact(Compact)
	self.Compact = Compact
	for _, Tab in next, self.Tabs do
		self:ApplyTabLayout(Tab)
	end
end

function TabModule:New(Title, Icon, Parent)
	local Library = require(Root)
	local Window = self.Window
	local Elements = Library.Elements

	self.TabCount = self.TabCount + 1
	local TabIndex = self.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Type = "Tab",
	}

	if Library:GetIcon(Icon) then
		Icon = Library:GetIcon(Icon)
	end

	if Icon == "" then
		Icon = nil
	end
	Tab.IconId = Icon
	Tab.HasIcon = Icon ~= nil

	Tab.Label = New("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = Tab.HasIcon and UDim2.new(0, 30, 0.5, 0) or UDim2.new(0, 12, 0.5, 0),
		Text = Title,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0,
		FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, Tab.HasIcon and -36 or -24, 1, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Tab.Icon = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 8, 0.5, 0),
		BackgroundTransparency = 1,
		Image = Icon or "",
		Visible = Tab.HasIcon,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Tab.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		SelectionOrder = TabIndex,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Tab",
			Size = "TabFrameSize",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Tab.Label,
		Tab.Icon,
	})
	self:ApplyTabLayout(Tab)

	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		SelectionGroup = true,
	}, {
		ContainerLayout,
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1),
			PaddingBottom = UDim.new(0, 1),
		}),
	})

	Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 2)
	end, Tab.ContainerFrame)

	Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(1, Tab.Frame, "BackgroundTransparency")

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.89)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		Tab.SetTransparency(Tab.Selected and 0.89 or 1)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.MouseButton1Down, function()
		Tab.SetTransparency(0.92)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.MouseButton1Up, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.89)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.SelectionGained, function()
		Tab.SetTransparency(0.85)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.SelectionLost, function()
		Tab.SetTransparency(Tab.Selected and 0.89 or 1)
	end, Tab.Frame)
	Creator.AddSignal(Tab.Frame.Activated, function()
		self:SelectTab(TabIndex)
	end, Tab.Frame)

	self.Containers[TabIndex] = Tab.ContainerFrame
	self.Tabs[TabIndex] = Tab

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.Container

	function Tab:AddSection(SectionTitle)
		local Section = { Type = "Section" }

		local SectionFrame = require(Components.Section)(SectionTitle, Tab.Container)
		Section.Container = SectionFrame.Container
		Section.ScrollFrame = Tab.Container

		setmetatable(Section, Elements)
		return Section
	end

	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Tab)
	local Window = self.Window
	assert(self.Tabs[Tab], "SelectTab - Invalid tab index")
	local Library = require(Root)
	if Library.ActiveDropdown then
		Library.ActiveDropdown:Close()
	end

	self.SelectedTab = Tab

	for _, TabObject in next, self.Tabs do
		TabObject.SetTransparency(1)
		TabObject.Selected = false
	end
	self.Tabs[Tab].SetTransparency(0.89)
	self.Tabs[Tab].Selected = true
	if Window.Compact and Window.SetNavigationDrawer then
		Window:SetNavigationDrawer(false)
	end

	Window.TabDisplay.Text = self.Tabs[Tab].Name
	Window.SelectorPosMotor:setGoal(Spring(self:GetCurrentTabPos(), { frequency = 6 }))

	task.spawn(function()
		Window.ContainerHolder.Parent = Window.ContainerAnim
		
		Window.ContainerPosMotor:setGoal(Spring(15, { frequency = 10 }))
		Window.ContainerBackMotor:setGoal(Spring(1, { frequency = 10 }))
		task.wait(Creator.MotionDuration(0.12))
		for _, Container in next, self.Containers do
			Container.Visible = false
		end
		self.Containers[Tab].Visible = true
		Window.ContainerPosMotor:setGoal(Spring(0, { frequency = 5 }))
		Window.ContainerBackMotor:setGoal(Spring(0, { frequency = 8 }))
		task.wait(Creator.MotionDuration(0.12))
		Window.ContainerHolder.Parent = Window.ContainerCanvas
	end)
end

function TabModule:GetSelectedFrame()
	local Tab = self.Tabs[self.SelectedTab]
	return Tab and Tab.Frame or nil
end

function TabModule:SelectRelative(Direction)
	if self.TabCount == 0 then
		return nil
	end

	local Current = self.SelectedTab
	if Current < 1 then
		Current = 1
	else
		Current = ((Current - 1 + Direction) % self.TabCount) + 1
	end
	self:SelectTab(Current)
	return self.Tabs[Current]
end

return TabModule

end)

register("Components.Textbox", function()
local script = create_mock_script("Components.Textbox")
local TextService = game:GetService("TextService")
local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local New = Creator.New

return function(Parent, Acrylic)
	Acrylic = Acrylic or false
	local Textbox = {}

	Textbox.Input = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(10, 0),
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	Textbox.Container = New("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -12, 1, 0),
	}, {
		Textbox.Input,
	})

	Textbox.Indicator = New("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = Acrylic and 0.5 or 0,
		ThemeTag = {
			BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine",
		},
	})

	Textbox.Frame = New("Frame", {
		Size = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = Acrylic and 0.9 or 0,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = Acrylic and "Input" or "DialogInput",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = Acrylic and 0.5 or 0.65,
			ThemeTag = {
				Color = Acrylic and "InElementBorder" or "DialogButtonBorder",
			},
		}),
		Textbox.Indicator,
		Textbox.Container,
	})

	local function Update()
		local PADDING = 2
		local Reveal = Textbox.Container.AbsoluteSize.X

		if not Textbox.Input:IsFocused() or Textbox.Input.TextBounds.X <= Reveal - 2 * PADDING then
			Textbox.Input.Position = UDim2.new(0, PADDING, 0, 0)
		else
			local Cursor = Textbox.Input.CursorPosition
			if Cursor ~= -1 then
				local subtext = string.sub(Textbox.Input.Text, 1, Cursor - 1)
				local width = TextService:GetTextSize(
					subtext,
					Textbox.Input.TextSize,
					Textbox.Input.Font,
					Vector2.new(math.huge, math.huge)
				).X

				local CurrentCursorPos = Textbox.Input.Position.X.Offset + width
				if CurrentCursorPos < PADDING then
					Textbox.Input.Position = UDim2.fromOffset(PADDING - width, 0)
				elseif CurrentCursorPos > Reveal - PADDING - 1 then
					Textbox.Input.Position = UDim2.fromOffset(Reveal - width - PADDING - 1, 0)
				end
			end
		end
	end

	task.spawn(Update)

	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("Text"), Update, Textbox.Frame)
	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("CursorPosition"), Update, Textbox.Frame)

	Creator.AddSignal(Textbox.Input.Focused, function()
		Update()
		Textbox.Indicator.Size = UDim2.new(1, -2, 0, 2)
		Textbox.Indicator.Position = UDim2.new(0, 1, 1, 0)
		Textbox.Indicator.BackgroundTransparency = 0
		Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "InputFocused" or "DialogHolder" })
		Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = "Accent" })
	end, Textbox.Frame)

	Creator.AddSignal(Textbox.Input.FocusLost, function()
		Update()
		Textbox.Indicator.Size = UDim2.new(1, -4, 0, 1)
		Textbox.Indicator.Position = UDim2.new(0, 2, 1, 0)
		Textbox.Indicator.BackgroundTransparency = 0.5
		Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "Input" or "DialogInput" })
		Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine" })
	end, Textbox.Frame)

	return Textbox
end

end)

register("Components.TitleBar", function()
local script = create_mock_script("Components.TitleBar")
local Root = script.Parent.Parent
local Assets = require(script.Parent.Assets)
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Config)
	local TitleBar = {}

	local Library = require(Root)

	local function BarButton(Icon, Pos, Parent, Callback)
		local Button = {
			Callback = Callback or function() end,
		}

		Button.Frame = New("TextButton", {
			Size = UDim2.new(0, 34, 1, -8),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = Parent,
			Position = Pos,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "Text",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 7),
			}),
			New("ImageLabel", {
				Image = Icon,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Name = "Icon",
				ThemeTag = {
					ImageColor3 = "Text",
				},
			}),
		})

		local Motor, SetTransparency = Creator.SpringMotor(1, Button.Frame, "BackgroundTransparency")

		AddSignal(Button.Frame.MouseEnter, function()
			SetTransparency(0.94)
		end, Button.Frame)
		AddSignal(Button.Frame.MouseLeave, function()
			SetTransparency(1, true)
		end, Button.Frame)
		AddSignal(Button.Frame.MouseButton1Down, function()
			SetTransparency(0.96)
		end, Button.Frame)
		AddSignal(Button.Frame.MouseButton1Up, function()
			SetTransparency(0.94)
		end, Button.Frame)
		AddSignal(Button.Frame.Activated, function(...)
			Button.Callback(...)
		end, Button.Frame)

		Button.SetCallback = function(Func)
			Button.Callback = Func
		end

		return Button
	end

	TitleBar.Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = Config.Parent,
	}, {
		New("Frame", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("TextLabel", {
				RichText = true,
				Text = Config.Title,
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextSize = 12,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			New("TextLabel", {
				RichText = true,
				Text = Config.SubTitle,
				TextTransparency = 0.4,
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextSize = 12,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
		}),
		New("Frame", {
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			},
		}),
	})

	TitleBar.CloseButton = BarButton(Assets.Close, UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
		Config.Window:Dialog({
			Title = "Close",
			Content = "Are you sure you want to unload the interface?",
			Buttons = {
				{
					Title = "Yes",
					Callback = function()
						Library:Destroy()
					end,
				},
				{
					Title = "No",
				},
			},
		})
	end)
	TitleBar.MaxButton = BarButton(Assets.Max, UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end)
	TitleBar.MinButton = BarButton(Assets.Min, UDim2.new(1, -80, 0, 4), TitleBar.Frame, function()
		Config.Window:Minimize()
	end)

	return TitleBar
end

end)

register("Components.Window", function()
local script = create_mock_script("Components.Window")
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
	local ApplyResponsiveLayout

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
		Text = "",
		Parent = TabFrame,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("ImageLabel", {
			Image = Library:GetIcon("menu") or "",
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
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

	ApplyResponsiveLayout = function() end

	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})

	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})

	Window.SelectorPosMotor = Flipper.SingleMotor.new(53)
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
		Selector.Position = UDim2.new(0, 0, 0, Value + 53)
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
		if TabModule then
			TabModule:SetCompact(Compact or Window.SidebarCollapsed == true)
		end
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

end)

register("Creator", function()
local script = create_mock_script("Creator")
local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)
local TweenService = game:GetService("TweenService")

local Creator = {
	Registry = {},
	Signals = {},
	SignalCleanups = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.RemoveSignal(Connection)
	if not Connection then
		return
	end

	local Idx = table.find(Creator.Signals, Connection)
	if Idx then
		table.remove(Creator.Signals, Idx)
	end

	local CleanupConnection = Creator.SignalCleanups[Connection]
	Creator.SignalCleanups[Connection] = nil
	if CleanupConnection then
		local CleanupIdx = table.find(Creator.Signals, CleanupConnection)
		if CleanupIdx then
			table.remove(Creator.Signals, CleanupIdx)
		end
		if CleanupConnection.Connected then
			CleanupConnection:Disconnect()
		end
	end

	if Connection.Connected then
		Connection:Disconnect()
	end
end

function Creator.AddSignal(Signal, Function, Owner)
	local Connection = Signal:Connect(Function)
	table.insert(Creator.Signals, Connection)

	if Owner then
		local CleanupConnection
		CleanupConnection = Owner.Destroying:Connect(function()
			Creator.RemoveSignal(Connection)
		end)
		Creator.SignalCleanups[Connection] = CleanupConnection
		table.insert(Creator.Signals, CleanupConnection)
	end

	return Connection
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		if Connection.Connected then
			pcall(function() Connection:Disconnect() end)
		end
	end
	table.clear(Creator.SignalCleanups)
end

function Creator.ClearRegistry()
	for Instance, Motors in next, Creator.TransparencyMotors do
		if type(Motors) == "table" then
			for Motor in next, Motors do
				pcall(function() Motor:destroy() end)
			end
		end
	end
	
	for Object, Data in next, Creator.Registry do
		if Data.DestroyingConnection then
			pcall(function() Data.DestroyingConnection:Disconnect() end)
		end
	end
	
	Creator.Disconnect()
	
	table.clear(Creator.Registry)
	table.clear(Creator.TransparencyMotors)
	table.clear(Creator.Signals)
	table.clear(Creator.SignalCleanups)
	table.clear(Creator.TranslationRegistry)
end

Creator.TranslationRegistry = {}

function Creator.AddTranslationObject(Object, Property, Key)
	local Data = Creator.TranslationRegistry[Object] or {}
	Data[Property] = Key
	Creator.TranslationRegistry[Object] = Data
	
	Object.Destroying:Connect(function()
		Creator.TranslationRegistry[Object] = nil
	end)
end

function Creator.UpdateTranslations()
	for Object, Props in next, Creator.TranslationRegistry do
		for Property, Key in next, Props do
			pcall(function()
				Object[Property] = require(Root):Translate(Key)
			end)
		end
	end
end

function Creator.GetThemeProperty(Property)
	if Property == "ElementPadding" then
		return require(Root).CompactMode and UDim.new(0, 8) or UDim.new(0, 13)
	elseif Property == "ElementTitleSize" then
		return require(Root).CompactMode and 11 or 13
	elseif Property == "ElementDescSize" then
		return require(Root).CompactMode and 10 or 12
	elseif Property == "TabFrameSize" then
		return require(Root).CompactMode and UDim2.new(1, 0, 0, 28) or UDim2.new(1, 0, 0, 34)
	end

	if Property == "Accent" and require(Root).AccentColor then
		return require(Root).AccentColor
	end

	if Themes[require(Root).Theme][Property] then
		return Themes[require(Root).Theme][Property]
	end
	return Themes["Dark"][Property]
end

function Creator.UpdateTheme()
	for Instance, Object in next, Creator.Registry do
		for Property, ColorIdx in next, Object.Properties do
			Instance[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end

	for _, Motors in next, Creator.TransparencyMotors do
		for Motor in next, Motors do
			Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
		end
	end
end

function Creator.IsReducedMotion()
	return require(Root).ReducedMotion == true
end

function Creator.MotionGoal(Value, Options)
	if Creator.IsReducedMotion() then
		return Flipper.Instant.new(Value)
	end
	return Flipper.Spring.new(Value, Options)
end

function Creator.MotionDuration(Duration)
	return Creator.IsReducedMotion() and 0 or Duration
end

function Creator.PlayTween(Object, Info, Goals)
	if Creator.IsReducedMotion() then
		for Property, Value in next, Goals do
			Object[Property] = Value
		end
		return nil
	end

	local Tween = TweenService:Create(Object, Info, Goals)
	Tween:Play()
	return Tween
end

function Creator.AddThemeObject(Object, Properties)
	local Idx = #Creator.Registry + 1
	local Data = {
		Object = Object,
		Properties = Properties,
		Idx = Idx,
	}

	Creator.Registry[Object] = Data
	Data.DestroyingConnection = Object.Destroying:Connect(function()
		Creator.Registry[Object] = nil
		Creator.TransparencyMotors[Object] = nil
	end)
	Creator.UpdateTheme()
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	Creator.UpdateTheme()
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)
	return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		Creator.TransparencyMotors[Instance] = Creator.TransparencyMotors[Instance] or {}
		Creator.TransparencyMotors[Instance][Motor] = true
	end

	local DestroyConnection
	DestroyConnection = Instance.Destroying:Connect(function()
		DestroyConnection:Disconnect()
		Motor:destroy()
		if Creator.TransparencyMotors[Instance] then
			Creator.TransparencyMotors[Instance][Motor] = nil
		end
	end)

	local function SetValue(Value, Ignore)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Creator.MotionGoal(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator

end)

register("Elements.Button", function()
local script = create_mock_script("Elements.Button")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Callback = Config.Callback or function() end

	local ButtonFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true, Config.Tooltip)

	local ButtonIco = New("ImageLabel", {
		Image = "rbxassetid://10709791437",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = ButtonFrame.Frame,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Creator.AddSignal(ButtonFrame.Frame.Activated, function()
		self.Library:SafeCallback(Config.Callback)
	end, ButtonFrame.Frame)

	return ButtonFrame
end

return Element

end)

register("Elements.Colorpicker", function()
local script = create_mock_script("Elements.Colorpicker")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Colorpicker - Missing Title")
	assert(Config.Default, "AddColorPicker: Missing default value.")

	local Colorpicker = {
		Value = Config.Default,
		Transparency = Config.Transparency or 0,
		Type = "Colorpicker",
		Title = type(Config.Title) == "string" and Config.Title or "Colorpicker",
		Callback = Config.Callback or function(Color) end,
	}

	function Colorpicker:SetHSVFromRGB(Color)
		local H, S, V = Color3.toHSV(Color)
		Colorpicker.Hue = H
		Colorpicker.Sat = S
		Colorpicker.Vib = V
	end

	Colorpicker:SetHSVFromRGB(Colorpicker.Value)

	local ColorpickerFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true, Config.Tooltip)

	Colorpicker.SetTitle = ColorpickerFrame.SetTitle
	Colorpicker.SetDesc = ColorpickerFrame.SetDesc

	local DisplayFrameColor = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colorpicker.Value,
		Parent = ColorpickerFrame.Frame,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	local DisplayFrame = New("ImageLabel", {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Parent = ColorpickerFrame.Frame,
		Image = "http://www.roblox.com/asset/?id=14204231522",
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(40, 40),
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		DisplayFrameColor,
	})

	local function CreateColorDialog()
		local Dialog = require(Components.Dialog):Create()
		Dialog.Title.Text = Colorpicker.Title
		Dialog.Root.Size = UDim2.fromOffset(430, 330)
		Dialog:FitToWindow()

		local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib
		local Transparency = Colorpicker.Transparency

		local function CreateInput()
			local Box = require(Components.Textbox)()
			Box.Frame.Parent = Dialog.Root
			Box.Frame.Size = UDim2.new(0, 90, 0, 32)

			return Box
		end

		local function CreateInputLabel(Text, Pos)
			return New("TextLabel", {
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = Text,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 32),
				Position = Pos,
				BackgroundTransparency = 1,
				Parent = Dialog.Root,
				ThemeTag = {
					TextColor3 = "Text",
				},
			})
		end

		local function GetRGB()
			local Value = Color3.fromHSV(Hue, Sat, Vib)
			return { R = math.floor(Value.r * 255), G = math.floor(Value.g * 255), B = math.floor(Value.b * 255) }
		end

		local SatCursor = New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=4805639000",
		})

		local SatVibMap = New("ImageLabel", {
			Size = UDim2.fromOffset(180, 160),
			Position = UDim2.fromOffset(20, 55),
			Image = "rbxassetid://4155801252",
			BackgroundColor3 = Colorpicker.Value,
			BackgroundTransparency = 0,
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			SatCursor,
		})

		local OldColorFrame = New("Frame", {
			BackgroundColor3 = Colorpicker.Value,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = Colorpicker.Transparency,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local OldColorFrameChecker = New("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=14204231522",
			ImageTransparency = 0.45,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(112, 220),
			Size = UDim2.fromOffset(88, 24),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIStroke", {
				Thickness = 2,
				Transparency = 0.75,
			}),
			OldColorFrame,
		})

		local DialogDisplayFrame = New("Frame", {
			BackgroundColor3 = Colorpicker.Value,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local DialogDisplayFrameChecker = New("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=14204231522",
			ImageTransparency = 0.45,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 220),
			Size = UDim2.fromOffset(88, 24),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIStroke", {
				Thickness = 2,
				Transparency = 0.75,
			}),
			DialogDisplayFrame,
		})

		local SequenceTable = {}

		for Color = 0, 1, 0.1 do
			table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
		end

		local HueSliderGradient = New("UIGradient", {
			Color = ColorSequence.new(SequenceTable),
			Rotation = 90,
		})

		local HueDragHolder = New("Frame", {
			Size = UDim2.new(1, 0, 1, -10),
			Position = UDim2.fromOffset(0, 5),
			BackgroundTransparency = 1,
		})

		local HueDrag = New("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			Image = "http://www.roblox.com/asset/?id=12266946128",
			Parent = HueDragHolder,
			ThemeTag = {
				ImageColor3 = "DialogInput",
			},
		})

		local HueSlider = New("Frame", {
			Size = UDim2.fromOffset(12, 190),
			Position = UDim2.fromOffset(210, 55),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			HueSliderGradient,
			HueDragHolder,
		})

		local HexInput = CreateInput()
		HexInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 55)
		CreateInputLabel("Hex", UDim2.fromOffset(Config.Transparency and 360 or 340, 55))

		local RedInput = CreateInput()
		RedInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 95)
		CreateInputLabel("Red", UDim2.fromOffset(Config.Transparency and 360 or 340, 95))

		local GreenInput = CreateInput()
		GreenInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 135)
		CreateInputLabel("Green", UDim2.fromOffset(Config.Transparency and 360 or 340, 135))

		local BlueInput = CreateInput()
		BlueInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 175)
		CreateInputLabel("Blue", UDim2.fromOffset(Config.Transparency and 360 or 340, 175))

		local AlphaInput
		if Config.Transparency then
			AlphaInput = CreateInput()
			AlphaInput.Frame.Position = UDim2.fromOffset(260, 215)
			CreateInputLabel("Alpha", UDim2.fromOffset(360, 215))
		end

		local TransparencySlider, TransparencyDrag, TransparencyColor
		if Config.Transparency then
			local TransparencyDragHolder = New("Frame", {
				Size = UDim2.new(1, 0, 1, -10),
				Position = UDim2.fromOffset(0, 5),
				BackgroundTransparency = 1,
			})

			TransparencyDrag = New("ImageLabel", {
				Size = UDim2.fromOffset(14, 14),
				Image = "http://www.roblox.com/asset/?id=12266946128",
				Parent = TransparencyDragHolder,
				ThemeTag = {
					ImageColor3 = "DialogInput",
				},
			})

			TransparencyColor = New("Frame", {
				Size = UDim2.fromScale(1, 1),
			}, {
				New("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Rotation = 270,
				}),
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			})

			TransparencySlider = New("Frame", {
				Size = UDim2.fromOffset(12, 190),
				Position = UDim2.fromOffset(230, 55),
				Parent = Dialog.Root,
				BackgroundTransparency = 1,
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				New("ImageLabel", {
					Image = "http://www.roblox.com/asset/?id=14204231522",
					ImageTransparency = 0.45,
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.fromOffset(40, 40),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = Dialog.Root,
				}, {
					New("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
				}),
				TransparencyColor,
				TransparencyDragHolder,
			})
		end

		local function Display()
			SatVibMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			HueDrag.Position = UDim2.new(0, -1, Hue, -6)
			SatCursor.Position = UDim2.new(Sat, 0, 1 - Vib, 0)
			DialogDisplayFrame.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)

			HexInput.Input.Text = "#" .. Color3.fromHSV(Hue, Sat, Vib):ToHex()
			RedInput.Input.Text = GetRGB()["R"]
			GreenInput.Input.Text = GetRGB()["G"]
			BlueInput.Input.Text = GetRGB()["B"]

			if Config.Transparency then
				TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
				DialogDisplayFrame.BackgroundTransparency = Transparency
				TransparencyDrag.Position = UDim2.new(0, -1, 1 - Transparency, -6)
				AlphaInput.Input.Text = require(Root):Round((1 - Transparency) * 100, 0) .. "%"
			end
		end

		local PointerInteraction = {}
		local PointerCleanup
		PointerCleanup = Creator.AddSignal(Dialog.TintFrame.Destroying, function()
			Library:ReleaseInteraction(PointerInteraction)
			Creator.RemoveSignal(PointerCleanup)
		end)

		local function TrackPointer(Input, Update)
			if not Library:AcquireInteraction(PointerInteraction) then
				return
			end

			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				while
					UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
					and Dialog.TintFrame.Parent
				do
					Update(Vector2.new(Mouse.X, Mouse.Y))
					RenderStepped:Wait()
				end
				Library:ReleaseInteraction(PointerInteraction)
			elseif Input.UserInputType == Enum.UserInputType.Touch then
				Update(Input.Position)
				local TouchConnection
				TouchConnection = Creator.AddSignal(Input.Changed, function()
					if
						Input.UserInputState == Enum.UserInputState.End
						or Input.UserInputState == Enum.UserInputState.Cancel
					then
						Library:ReleaseInteraction(PointerInteraction)
						Creator.RemoveSignal(TouchConnection)
					else
						Update(Input.Position)
					end
				end, Dialog.TintFrame)
			else
				Library:ReleaseInteraction(PointerInteraction)
			end
		end

		Creator.AddSignal(HexInput.Input.FocusLost, function(Enter)
			if Enter then
				local Success, Result = pcall(Color3.fromHex, HexInput.Input.Text)
				if Success and typeof(Result) == "Color3" then
					Hue, Sat, Vib = Color3.toHSV(Result)
				end
			end
			Display()
		end, Dialog.TintFrame)

		Creator.AddSignal(RedInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result = pcall(Color3.fromRGB, RedInput.Input.Text, CurrentColor["G"], CurrentColor["B"])
				if Success and typeof(Result) == "Color3" then
					if tonumber(RedInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end, Dialog.TintFrame)

		Creator.AddSignal(GreenInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result =
					pcall(Color3.fromRGB, CurrentColor["R"], GreenInput.Input.Text, CurrentColor["B"])
				if Success and typeof(Result) == "Color3" then
					if tonumber(GreenInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end, Dialog.TintFrame)

		Creator.AddSignal(BlueInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result =
					pcall(Color3.fromRGB, CurrentColor["R"], CurrentColor["G"], BlueInput.Input.Text)
				if Success and typeof(Result) == "Color3" then
					if tonumber(BlueInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end, Dialog.TintFrame)

		if Config.Transparency then
			Creator.AddSignal(AlphaInput.Input.FocusLost, function(Enter)
				if Enter then
					pcall(function()
						local Value = tonumber(AlphaInput.Input.Text)
						if Value >= 0 and Value <= 100 then
							Transparency = 1 - Value * 0.01
						end
					end)
				end
				Display()
			end, Dialog.TintFrame)
		end

		Creator.AddSignal(SatVibMap.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				TrackPointer(Input, function(Position)
					local MinX = SatVibMap.AbsolutePosition.X
					local MaxX = MinX + SatVibMap.AbsoluteSize.X
					local PointerX = math.clamp(Position.X, MinX, MaxX)

					local MinY = SatVibMap.AbsolutePosition.Y
					local MaxY = MinY + SatVibMap.AbsoluteSize.Y
					local PointerY = math.clamp(Position.Y, MinY, MaxY)

					Sat = (PointerX - MinX) / (MaxX - MinX)
					Vib = 1 - ((PointerY - MinY) / (MaxY - MinY))
					Display()
				end)
			end
		end, Dialog.TintFrame)

		Creator.AddSignal(HueSlider.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				TrackPointer(Input, function(Position)
					local MinY = HueSlider.AbsolutePosition.Y
					local MaxY = MinY + HueSlider.AbsoluteSize.Y
					local PointerY = math.clamp(Position.Y, MinY, MaxY)

					Hue = ((PointerY - MinY) / (MaxY - MinY))
					Display()
				end)
			end
		end, Dialog.TintFrame)

		if Config.Transparency then
			Creator.AddSignal(TransparencySlider.InputBegan, function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					TrackPointer(Input, function(Position)
						local MinY = TransparencySlider.AbsolutePosition.Y
						local MaxY = MinY + TransparencySlider.AbsoluteSize.Y
						local PointerY = math.clamp(Position.Y, MinY, MaxY)

						Transparency = 1 - ((PointerY - MinY) / (MaxY - MinY))
						Display()
					end)
				end
			end, Dialog.TintFrame)
		end

		Display()

		Dialog:Button("Done", function()
			Colorpicker:SetValue({ Hue, Sat, Vib }, Transparency)
		end)
		Dialog:Button("Cancel")
		Dialog:Open()
	end

	function Colorpicker:Display()
		Colorpicker.Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)

		DisplayFrameColor.BackgroundColor3 = Colorpicker.Value
		DisplayFrameColor.BackgroundTransparency = Colorpicker.Transparency

		Element.Library:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
		Element.Library:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
	end

	function Colorpicker:SetValue(HSV, Transparency)
		local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

		Colorpicker.Transparency = Transparency or 0
		Colorpicker:SetHSVFromRGB(Color)
		Colorpicker:Display()
	end

	function Colorpicker:SetValueRGB(Color, Transparency)
		Colorpicker.Transparency = Transparency or 0
		Colorpicker:SetHSVFromRGB(Color)
		Colorpicker:Display()
	end

	function Colorpicker:OnChanged(Func)
		Colorpicker.Changed = Func
		Func(Colorpicker.Value)
	end

	function Colorpicker:Destroy()
		ColorpickerFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ColorpickerFrame.Frame.Activated, function()
		CreateColorDialog()
	end, ColorpickerFrame.Frame)

	Colorpicker:Display()

	Library.Options[Idx] = Colorpicker
	return Colorpicker
end

return Element

end)

register("Elements.CopyButton", function()
local script = create_mock_script("Elements.CopyButton")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "CopyButton"

function Element:New(Config)
	assert(Config.Title, "CopyButton - Missing Title")
	Config.Value = Config.Value or ""
	Config.Callback = Config.Callback or function() end

	local ButtonFrame = require(Components.Element)(Config.Title, Config.Description or "", self.Container, true)

	local ButtonIco = New("ImageLabel", {
		Image = "rbxassetid://10709798574", -- lucide-clipboard-copy
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = ButtonFrame.Frame,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Creator.AddSignal(ButtonFrame.Frame.Activated, function()
		local Text = type(Config.Value) == "function" and Config.Value() or Config.Value
		local SetClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
		if SetClipboard then
			pcall(SetClipboard, Text)
			self.Library:Notify({
				Title = "Copied",
				Content = "Successfully copied text to clipboard!",
				Duration = 3,
			})
		else
			self.Library:Notify({
				Title = "Error",
				Content = "Your executor does not support setclipboard.",
				Duration = 3,
			})
		end
		self.Library:SafeCallback(Config.Callback, Text)
	end, ButtonFrame.Frame)

	return ButtonFrame
end

return Element

end)

register("Elements.Dropdown", function()
local script = create_mock_script("Elements.Dropdown")
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

end)

register("Elements.Image", function()
local script = create_mock_script("Elements.Image")
local Root = script.Parent.Parent
local Components = Root.Components
local Creator = require(Root.Creator)
local New = Creator.New

local ImageElement = {}
ImageElement.__index = ImageElement
ImageElement.__type = "Image"

function ImageElement:New(Config)
	assert(Config.Title, "Image - Missing Title")
	assert(Config.Image, "Image - Missing Image ID")

	local ImageFrame = require(Components.Element)(Config.Title, Config.Description or "", self.Container, false)
	ImageFrame.Frame.Selectable = false

	local ImageSize = Config.Size or UDim2.fromOffset(64, 64)

	local ImageLabel = New("ImageLabel", {
		Image = Config.Image,
		Size = ImageSize,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		ScaleType = Config.ScaleType or Enum.ScaleType.Fit,
		Parent = ImageFrame.Frame,
	})

	ImageFrame.DescLabel.Size = UDim2.new(1, -(ImageSize.X.Offset + 30), 0, 14)

	function ImageFrame:SetImage(ImageId)
		ImageLabel.Image = ImageId
	end

	return ImageFrame
end

return ImageElement

end)

register("Elements", function()
local script = create_mock_script("Elements")

local Elements = {}
local btn = require("Elements.Button")
local cp = require("Elements.Colorpicker")
local dd = require("Elements.Dropdown")
local inp = require("Elements.Input")
local kb = require("Elements.Keybind")
local pg = require("Elements.Paragraph")
local sl = require("Elements.Slider")
local tg = require("Elements.Toggle")
local rs = require("Elements.RangeSlider")
local img = require("Elements.Image")
local cb = require("Elements.CopyButton")

table.insert(Elements, btn)
table.insert(Elements, cp)
table.insert(Elements, dd)
table.insert(Elements, inp)
table.insert(Elements, kb)
table.insert(Elements, pg)
table.insert(Elements, sl)
table.insert(Elements, tg)
table.insert(Elements, rs)
table.insert(Elements, img)
table.insert(Elements, cb)

return Elements

end)

register("Elements.Input", function()
local script = create_mock_script("Elements.Input")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local AddSignal = Creator.AddSignal
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Input"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Input - Missing Title")
	Config.Callback = Config.Callback or function() end

	local Input = {
		Value = Config.Default or "",
		Numeric = Config.Numeric or false,
		Finished = Config.Finished or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Input",
	}

	local InputFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false, Config.Tooltip)
	InputFrame.Frame.Selectable = false

	Input.SetTitle = InputFrame.SetTitle
	Input.SetDesc = InputFrame.SetDesc

	local Textbox = require(Components.Textbox)(InputFrame.Frame, true)
	Textbox.Frame.Position = UDim2.new(1, -10, 0.5, 0)
	Textbox.Frame.AnchorPoint = Vector2.new(1, 0.5)
	Textbox.Frame.Size = UDim2.fromOffset(160, 30)
	Textbox.Input.Text = Config.Default or ""
	Textbox.Input.PlaceholderText = Config.Placeholder or ""

	local Box = Textbox.Input

	function Input:SetValue(Text)
		if Config.MaxLength and #Text > Config.MaxLength then
			Text = Text:sub(1, Config.MaxLength)
		end

		if Input.Numeric then
			if (not tonumber(Text)) and Text:len() > 0 then
				Text = Input.Value
			end
		end

		Input.Value = Text
		Box.Text = Text

		Library:SafeCallback(Input.Callback, Input.Value)
		Library:SafeCallback(Input.Changed, Input.Value)
	end

	if Input.Finished then
		AddSignal(Box.FocusLost, function(enter)
			if not enter then
				return
			end
			Input:SetValue(Box.Text)
		end, InputFrame.Frame)
	else
		AddSignal(Box:GetPropertyChangedSignal("Text"), function()
			Input:SetValue(Box.Text)
		end, InputFrame.Frame)
	end

	function Input:OnChanged(Func)
		Input.Changed = Func
		Func(Input.Value)
	end

	function Input:Destroy()
		InputFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Library.Options[Idx] = Input
	return Input
end

return Element

end)

register("Elements.Keybind", function()
local script = create_mock_script("Elements.Keybind")
local UserInputService = game:GetService("UserInputService")

local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Keybind"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "KeyBind - Missing Title")
	assert(Config.Default, "KeyBind - Missing default value.")

	local Keybind = {
		Value = Config.Default,
		Toggled = false,
		Mode = Config.Mode or "Toggle",
		Type = "Keybind",
		Callback = Config.Callback or function(Value) end,
		ChangedCallback = Config.ChangedCallback or function(New) end,
	}

	local Picking = false
	local PickBeganConnection
	local PickEndedConnection

	local KeybindFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true, Config.Tooltip)

	Keybind.SetTitle = KeybindFrame.SetTitle
	Keybind.SetDesc = KeybindFrame.SetDesc

	local KeybindDisplayLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = Config.Default,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 0, 0, 14),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local KeybindDisplayFrame = New("TextButton", {
		Size = UDim2.fromOffset(0, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Selectable = true,
		Parent = KeybindFrame.Frame,
		AutomaticSize = Enum.AutomaticSize.X,
		ThemeTag = {
			BackgroundColor3 = "Keybind",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		KeybindDisplayLabel,
	})
	KeybindFrame.Frame.Selectable = false

	function Keybind:GetState()
		if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
			return false
		end

		if Keybind.Mode == "Always" then
			return true
		elseif Keybind.Mode == "Hold" then
			if Keybind.Value == "None" then
				return false
			end

			local Key = Keybind.Value

			if Key == "MouseLeft" or Key == "MouseRight" then
				return Key == "MouseLeft" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
					or Key == "MouseRight"
						and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			else
				return UserInputService:IsKeyDown(Enum.KeyCode[Keybind.Value])
			end
		else
			return Keybind.Toggled
		end
	end

	function Keybind:SetValue(Key, Mode)
		Key = Key or Keybind.Value
		Mode = Mode or Keybind.Mode

		KeybindDisplayLabel.Text = Key
		Keybind.Value = Key
		Keybind.Mode = Mode
	end

	function Keybind:OnClick(Callback)
		Keybind.Clicked = Callback
	end

	function Keybind:OnChanged(Callback)
		Keybind.Changed = Callback
		Callback(Keybind.Value)
	end

	function Keybind:DoClick()
		Library:SafeCallback(Keybind.Callback, Keybind.Toggled)
		Library:SafeCallback(Keybind.Clicked, Keybind.Toggled)
	end

	function Keybind:Destroy()
		Picking = false
		Creator.RemoveSignal(PickBeganConnection)
		Creator.RemoveSignal(PickEndedConnection)
		KeybindFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(KeybindDisplayFrame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
			or Input.KeyCode == Enum.KeyCode.ButtonA
		then
			if Picking then
				return
			end
			Picking = true
			KeybindDisplayLabel.Text = "..."

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

				if not Key then
					return
				end

				Creator.RemoveSignal(PickEndedConnection)
				PickEndedConnection = Creator.AddSignal(UserInputService.InputEnded, function(Input)
					if
						Input.KeyCode.Name == Key
						or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
						or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
					then
						Picking = false

						KeybindDisplayLabel.Text = Key
						Keybind.Value = Key

						local ChangedInput = Input.UserInputType == Enum.UserInputType.Keyboard
							and Input.KeyCode
							or Input.UserInputType
						Library:SafeCallback(Keybind.ChangedCallback, ChangedInput)
						Library:SafeCallback(Keybind.Changed, ChangedInput)

						Creator.RemoveSignal(PickBeganConnection)
						Creator.RemoveSignal(PickEndedConnection)
					end
				end, KeybindFrame.Frame)
			end, KeybindFrame.Frame)
		end
	end, KeybindFrame.Frame)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if not Picking and not UserInputService:GetFocusedTextBox() then
			if Keybind.Mode == "Toggle" then
				local Key = Keybind.Value

				if Key == "MouseLeft" or Key == "MouseRight" then
					if
						Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
						or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
					then
						Keybind.Toggled = not Keybind.Toggled
						Keybind:DoClick()
					end
				elseif Input.UserInputType == Enum.UserInputType.Keyboard then
					if Input.KeyCode.Name == Key then
						Keybind.Toggled = not Keybind.Toggled
						Keybind:DoClick()
					end
				end
			end
		end
	end, KeybindFrame.Frame)

	Library.Options[Idx] = Keybind
	return Keybind
end

return Element

end)

register("Elements.Paragraph", function()
local script = create_mock_script("Elements.Paragraph")
local Root = script.Parent.Parent
local Components = Root.Components
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph:New(Config)
	assert(Config.Title, "Paragraph - Missing Title")
	Config.Content = Config.Content or ""

	local Paragraph = require(Components.Element)(Config.Title, Config.Content, Paragraph.Container, false)
	Paragraph.Frame.Selectable = false
	Paragraph.Frame.BackgroundTransparency = 0.92
	Paragraph.Border.Transparency = 0.6

	return Paragraph
end

return Paragraph

end)

register("Elements.RangeSlider", function()
local script = create_mock_script("Elements.RangeSlider")
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

end)

register("Elements.Slider", function()
local script = create_mock_script("Elements.Slider")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Slider - Missing Title.")
	assert(type(Config.Default) == "number", "Slider - Default value must be a number.")
	assert(type(Config.Min) == "number", "Slider - Minimum value must be a number.")
	assert(type(Config.Max) == "number", "Slider - Maximum value must be a number.")
	assert(Config.Min < Config.Max, "Slider - Minimum value must be less than maximum value.")
	assert(
		type(Config.Rounding) == "number"
			and Config.Rounding >= 0
			and Config.Rounding % 1 == 0,
		"Slider - Rounding must be a non-negative integer."
	)
	if Config.Step ~= nil then
		assert(type(Config.Step) == "number" and Config.Step > 0, "Slider - Step must be a positive number.")
	end

	local Slider = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Step = Config.Step or (1 / (10 ^ Config.Rounding)),
		Callback = Config.Callback or function(Value) end,
		Type = "Slider",
	}

	local Dragging = false
	local DragInput
	local SliderInteraction = {}

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false, Config.Tooltip)
	SliderFrame.Frame.Selectable = false
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc

	local SliderDot = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ThemeTag = {
			ImageColor3 = "Accent",
		},
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0),
	}, {
		SliderDot,
	})

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
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
		local SizeScale = math.clamp((Position.X - SliderRail.AbsolutePosition.X) / RailWidth, 0, 1)
		Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
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
			UpdateFromPosition(Input.Position)
		end
	end, SliderFrame.Frame)
	Creator.AddSignal(SliderInput.SelectionGained, function()
		SliderFocusStroke.Transparency = 0
	end, SliderFrame.Frame)
	Creator.AddSignal(SliderInput.SelectionLost, function()
		SliderFocusStroke.Transparency = 1
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if GuiService.SelectedObject ~= SliderInput then
			return
		end
		if Input.KeyCode == Enum.KeyCode.Left or Input.KeyCode == Enum.KeyCode.DPadLeft then
			Slider:SetValue(Slider.Value - Slider.Step)
		elseif Input.KeyCode == Enum.KeyCode.Right or Input.KeyCode == Enum.KeyCode.DPadRight then
			Slider:SetValue(Slider.Value + Slider.Step)
		end
	end, SliderFrame.Frame)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Dragging
			and Input == DragInput
		then
			Dragging = false
			DragInput = nil
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

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		assert(type(Value) == "number", "Slider - Value must be a number.")
		self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
		SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
		SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
		SliderDisplay.Text = tostring(self.Value)

		Library:SafeCallback(Slider.Callback, self.Value)
		Library:SafeCallback(Slider.Changed, self.Value)
	end

	function Slider:Destroy()
		Library:ReleaseInteraction(SliderInteraction)
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)

	Library.Options[Idx] = Slider
	return Slider
end

return Element

end)

register("Elements.Toggle", function()
local script = create_mock_script("Elements.Toggle")
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
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Toggle",
	}

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

end)

register("Icons", function()
local script = create_mock_script("Icons")
-- This file was @generated by Tarmac. It is not intended for manual editing.
return {
	assets = {
		["lucide-accessibility"] = "rbxassetid://10709751939",
		["lucide-activity"] = "rbxassetid://10709752035",
		["lucide-air-vent"] = "rbxassetid://10709752131",
		["lucide-airplay"] = "rbxassetid://10709752254",
		["lucide-alarm-check"] = "rbxassetid://10709752405",
		["lucide-alarm-clock"] = "rbxassetid://10709752630",
		["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
		["lucide-alarm-minus"] = "rbxassetid://10709752732",
		["lucide-alarm-plus"] = "rbxassetid://10709752825",
		["lucide-album"] = "rbxassetid://10709752906",
		["lucide-alert-circle"] = "rbxassetid://10709752996",
		["lucide-alert-octagon"] = "rbxassetid://10709753064",
		["lucide-alert-triangle"] = "rbxassetid://10709753149",
		["lucide-align-center"] = "rbxassetid://10709753570",
		["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
		["lucide-align-center-vertical"] = "rbxassetid://10709753421",
		["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
		["lucide-align-end-vertical"] = "rbxassetid://10709753808",
		["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
		["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",
		["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
		["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
		["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",
		["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
		["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",
		["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
		["lucide-align-justify"] = "rbxassetid://10709759610",
		["lucide-align-left"] = "rbxassetid://10709759764",
		["lucide-align-right"] = "rbxassetid://10709759895",
		["lucide-align-start-horizontal"] = "rbxassetid://10709760051",
		["lucide-align-start-vertical"] = "rbxassetid://10709760244",
		["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",
		["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
		["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
		["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",
		["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
		["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",
		["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",
		["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
		["lucide-anchor"] = "rbxassetid://10709761530",
		["lucide-angry"] = "rbxassetid://10709761629",
		["lucide-annoyed"] = "rbxassetid://10709761722",
		["lucide-aperture"] = "rbxassetid://10709761813",
		["lucide-apple"] = "rbxassetid://10709761889",
		["lucide-archive"] = "rbxassetid://10709762233",
		["lucide-archive-restore"] = "rbxassetid://10709762058",
		["lucide-armchair"] = "rbxassetid://10709762327",
		["lucide-arrow-big-down"] = "rbxassetid://10747796644",
		["lucide-arrow-big-left"] = "rbxassetid://10709762574",
		["lucide-arrow-big-right"] = "rbxassetid://10709762727",
		["lucide-arrow-big-up"] = "rbxassetid://10709762879",
		["lucide-arrow-down"] = "rbxassetid://10709767827",
		["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
		["lucide-arrow-down-left"] = "rbxassetid://10709767656",
		["lucide-arrow-down-right"] = "rbxassetid://10709767750",
		["lucide-arrow-left"] = "rbxassetid://10709768114",
		["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
		["lucide-arrow-left-right"] = "rbxassetid://10709768019",
		["lucide-arrow-right"] = "rbxassetid://10709768347",
		["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
		["lucide-arrow-up"] = "rbxassetid://10709768939",
		["lucide-arrow-up-circle"] = "rbxassetid://10709768432",
		["lucide-arrow-up-down"] = "rbxassetid://10709768538",
		["lucide-arrow-up-left"] = "rbxassetid://10709768661",
		["lucide-arrow-up-right"] = "rbxassetid://10709768787",
		["lucide-asterisk"] = "rbxassetid://10709769095",
		["lucide-at-sign"] = "rbxassetid://10709769286",
		["lucide-award"] = "rbxassetid://10709769406",
		["lucide-axe"] = "rbxassetid://10709769508",
		["lucide-axis-3d"] = "rbxassetid://10709769598",
		["lucide-baby"] = "rbxassetid://10709769732",
		["lucide-backpack"] = "rbxassetid://10709769841",
		["lucide-baggage-claim"] = "rbxassetid://10709769935",
		["lucide-banana"] = "rbxassetid://10709770005",
		["lucide-banknote"] = "rbxassetid://10709770178",
		["lucide-bar-chart"] = "rbxassetid://10709773755",
		["lucide-bar-chart-2"] = "rbxassetid://10709770317",
		["lucide-bar-chart-3"] = "rbxassetid://10709770431",
		["lucide-bar-chart-4"] = "rbxassetid://10709770560",
		["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
		["lucide-barcode"] = "rbxassetid://10747360675",
		["lucide-baseline"] = "rbxassetid://10709773863",
		["lucide-bath"] = "rbxassetid://10709773963",
		["lucide-battery"] = "rbxassetid://10709774640",
		["lucide-battery-charging"] = "rbxassetid://10709774068",
		["lucide-battery-full"] = "rbxassetid://10709774206",
		["lucide-battery-low"] = "rbxassetid://10709774370",
		["lucide-battery-medium"] = "rbxassetid://10709774513",
		["lucide-beaker"] = "rbxassetid://10709774756",
		["lucide-bed"] = "rbxassetid://10709775036",
		["lucide-bed-double"] = "rbxassetid://10709774864",
		["lucide-bed-single"] = "rbxassetid://10709774968",
		["lucide-beer"] = "rbxassetid://10709775167",
		["lucide-bell"] = "rbxassetid://10709775704",
		["lucide-bell-minus"] = "rbxassetid://10709775241",
		["lucide-bell-off"] = "rbxassetid://10709775320",
		["lucide-bell-plus"] = "rbxassetid://10709775448",
		["lucide-bell-ring"] = "rbxassetid://10709775560",
		["lucide-bike"] = "rbxassetid://10709775894",
		["lucide-binary"] = "rbxassetid://10709776050",
		["lucide-bitcoin"] = "rbxassetid://10709776126",
		["lucide-bluetooth"] = "rbxassetid://10709776655",
		["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
		["lucide-bluetooth-off"] = "rbxassetid://10709776344",
		["lucide-bluetooth-searching"] = "rbxassetid://10709776501",
		["lucide-bold"] = "rbxassetid://10747813908",
		["lucide-bomb"] = "rbxassetid://10709781460",
		["lucide-bone"] = "rbxassetid://10709781605",
		["lucide-book"] = "rbxassetid://10709781824",
		["lucide-book-open"] = "rbxassetid://10709781717",
		["lucide-bookmark"] = "rbxassetid://10709782154",
		["lucide-bookmark-minus"] = "rbxassetid://10709781919",
		["lucide-bookmark-plus"] = "rbxassetid://10709782044",
		["lucide-bot"] = "rbxassetid://10709782230",
		["lucide-box"] = "rbxassetid://10709782497",
		["lucide-box-select"] = "rbxassetid://10709782342",
		["lucide-boxes"] = "rbxassetid://10709782582",
		["lucide-briefcase"] = "rbxassetid://10709782662",
		["lucide-brush"] = "rbxassetid://10709782758",
		["lucide-bug"] = "rbxassetid://10709782845",
		["lucide-building"] = "rbxassetid://10709783051",
		["lucide-building-2"] = "rbxassetid://10709782939",
		["lucide-bus"] = "rbxassetid://10709783137",
		["lucide-cake"] = "rbxassetid://10709783217",
		["lucide-calculator"] = "rbxassetid://10709783311",
		["lucide-calendar"] = "rbxassetid://10709789505",
		["lucide-calendar-check"] = "rbxassetid://10709783474",
		["lucide-calendar-check-2"] = "rbxassetid://10709783392",
		["lucide-calendar-clock"] = "rbxassetid://10709783577",
		["lucide-calendar-days"] = "rbxassetid://10709783673",
		["lucide-calendar-heart"] = "rbxassetid://10709783835",
		["lucide-calendar-minus"] = "rbxassetid://10709783959",
		["lucide-calendar-off"] = "rbxassetid://10709788784",
		["lucide-calendar-plus"] = "rbxassetid://10709788937",
		["lucide-calendar-range"] = "rbxassetid://10709789053",
		["lucide-calendar-search"] = "rbxassetid://10709789200",
		["lucide-calendar-x"] = "rbxassetid://10709789407",
		["lucide-calendar-x-2"] = "rbxassetid://10709789329",
		["lucide-camera"] = "rbxassetid://10709789686",
		["lucide-camera-off"] = "rbxassetid://10747822677",
		["lucide-car"] = "rbxassetid://10709789810",
		["lucide-carrot"] = "rbxassetid://10709789960",
		["lucide-cast"] = "rbxassetid://10709790097",
		["lucide-charge"] = "rbxassetid://10709790202",
		["lucide-check"] = "rbxassetid://10709790644",
		["lucide-check-circle"] = "rbxassetid://10709790387",
		["lucide-check-circle-2"] = "rbxassetid://10709790298",
		["lucide-check-square"] = "rbxassetid://10709790537",
		["lucide-chef-hat"] = "rbxassetid://10709790757",
		["lucide-cherry"] = "rbxassetid://10709790875",
		["lucide-chevron-down"] = "rbxassetid://10709790948",
		["lucide-chevron-first"] = "rbxassetid://10709791015",
		["lucide-chevron-last"] = "rbxassetid://10709791130",
		["lucide-chevron-left"] = "rbxassetid://10709791281",
		["lucide-chevron-right"] = "rbxassetid://10709791437",
		["lucide-chevron-up"] = "rbxassetid://10709791523",
		["lucide-chevrons-down"] = "rbxassetid://10709796864",
		["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
		["lucide-chevrons-left"] = "rbxassetid://10709797151",
		["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
		["lucide-chevrons-right"] = "rbxassetid://10709797382",
		["lucide-chevrons-right-left"] = "rbxassetid://10709797274",
		["lucide-chevrons-up"] = "rbxassetid://10709797622",
		["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
		["lucide-chrome"] = "rbxassetid://10709797725",
		["lucide-circle"] = "rbxassetid://10709798174",
		["lucide-circle-dot"] = "rbxassetid://10709797837",
		["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
		["lucide-circle-slashed"] = "rbxassetid://10709798100",
		["lucide-citrus"] = "rbxassetid://10709798276",
		["lucide-clapperboard"] = "rbxassetid://10709798350",
		["lucide-clipboard"] = "rbxassetid://10709799288",
		["lucide-clipboard-check"] = "rbxassetid://10709798443",
		["lucide-clipboard-copy"] = "rbxassetid://10709798574",
		["lucide-clipboard-edit"] = "rbxassetid://10709798682",
		["lucide-clipboard-list"] = "rbxassetid://10709798792",
		["lucide-clipboard-signature"] = "rbxassetid://10709798890",
		["lucide-clipboard-type"] = "rbxassetid://10709798999",
		["lucide-clipboard-x"] = "rbxassetid://10709799124",
		["lucide-clock"] = "rbxassetid://10709805144",
		["lucide-clock-1"] = "rbxassetid://10709799535",
		["lucide-clock-10"] = "rbxassetid://10709799718",
		["lucide-clock-11"] = "rbxassetid://10709799818",
		["lucide-clock-12"] = "rbxassetid://10709799962",
		["lucide-clock-2"] = "rbxassetid://10709803876",
		["lucide-clock-3"] = "rbxassetid://10709803989",
		["lucide-clock-4"] = "rbxassetid://10709804164",
		["lucide-clock-5"] = "rbxassetid://10709804291",
		["lucide-clock-6"] = "rbxassetid://10709804435",
		["lucide-clock-7"] = "rbxassetid://10709804599",
		["lucide-clock-8"] = "rbxassetid://10709804784",
		["lucide-clock-9"] = "rbxassetid://10709804996",
		["lucide-cloud"] = "rbxassetid://10709806740",
		["lucide-cloud-cog"] = "rbxassetid://10709805262",
		["lucide-cloud-drizzle"] = "rbxassetid://10709805371",
		["lucide-cloud-fog"] = "rbxassetid://10709805477",
		["lucide-cloud-hail"] = "rbxassetid://10709805596",
		["lucide-cloud-lightning"] = "rbxassetid://10709805727",
		["lucide-cloud-moon"] = "rbxassetid://10709805942",
		["lucide-cloud-moon-rain"] = "rbxassetid://10709805838",
		["lucide-cloud-off"] = "rbxassetid://10709806060",
		["lucide-cloud-rain"] = "rbxassetid://10709806277",
		["lucide-cloud-rain-wind"] = "rbxassetid://10709806166",
		["lucide-cloud-snow"] = "rbxassetid://10709806374",
		["lucide-cloud-sun"] = "rbxassetid://10709806631",
		["lucide-cloud-sun-rain"] = "rbxassetid://10709806475",
		["lucide-cloudy"] = "rbxassetid://10709806859",
		["lucide-clover"] = "rbxassetid://10709806995",
		["lucide-code"] = "rbxassetid://10709810463",
		["lucide-code-2"] = "rbxassetid://10709807111",
		["lucide-codepen"] = "rbxassetid://10709810534",
		["lucide-codesandbox"] = "rbxassetid://10709810676",
		["lucide-coffee"] = "rbxassetid://10709810814",
		["lucide-cog"] = "rbxassetid://10709810948",
		["lucide-coins"] = "rbxassetid://10709811110",
		["lucide-columns"] = "rbxassetid://10709811261",
		["lucide-command"] = "rbxassetid://10709811365",
		["lucide-compass"] = "rbxassetid://10709811445",
		["lucide-component"] = "rbxassetid://10709811595",
		["lucide-concierge-bell"] = "rbxassetid://10709811706",
		["lucide-connection"] = "rbxassetid://10747361219",
		["lucide-contact"] = "rbxassetid://10709811834",
		["lucide-contrast"] = "rbxassetid://10709811939",
		["lucide-cookie"] = "rbxassetid://10709812067",
		["lucide-copy"] = "rbxassetid://10709812159",
		["lucide-copyleft"] = "rbxassetid://10709812251",
		["lucide-copyright"] = "rbxassetid://10709812311",
		["lucide-corner-down-left"] = "rbxassetid://10709812396",
		["lucide-corner-down-right"] = "rbxassetid://10709812485",
		["lucide-corner-left-down"] = "rbxassetid://10709812632",
		["lucide-corner-left-up"] = "rbxassetid://10709812784",
		["lucide-corner-right-down"] = "rbxassetid://10709812939",
		["lucide-corner-right-up"] = "rbxassetid://10709813094",
		["lucide-corner-up-left"] = "rbxassetid://10709813185",
		["lucide-corner-up-right"] = "rbxassetid://10709813281",
		["lucide-cpu"] = "rbxassetid://10709813383",
		["lucide-croissant"] = "rbxassetid://10709818125",
		["lucide-crop"] = "rbxassetid://10709818245",
		["lucide-cross"] = "rbxassetid://10709818399",
		["lucide-crosshair"] = "rbxassetid://10709818534",
		["lucide-crown"] = "rbxassetid://10709818626",
		["lucide-cup-soda"] = "rbxassetid://10709818763",
		["lucide-curly-braces"] = "rbxassetid://10709818847",
		["lucide-currency"] = "rbxassetid://10709818931",
		["lucide-database"] = "rbxassetid://10709818996",
		["lucide-delete"] = "rbxassetid://10709819059",
		["lucide-diamond"] = "rbxassetid://10709819149",
		["lucide-dice-1"] = "rbxassetid://10709819266",
		["lucide-dice-2"] = "rbxassetid://10709819361",
		["lucide-dice-3"] = "rbxassetid://10709819508",
		["lucide-dice-4"] = "rbxassetid://10709819670",
		["lucide-dice-5"] = "rbxassetid://10709819801",
		["lucide-dice-6"] = "rbxassetid://10709819896",
		["lucide-dices"] = "rbxassetid://10723343321",
		["lucide-diff"] = "rbxassetid://10723343416",
		["lucide-disc"] = "rbxassetid://10723343537",
		["lucide-divide"] = "rbxassetid://10723343805",
		["lucide-divide-circle"] = "rbxassetid://10723343636",
		["lucide-divide-square"] = "rbxassetid://10723343737",
		["lucide-dollar-sign"] = "rbxassetid://10723343958",
		["lucide-download"] = "rbxassetid://10723344270",
		["lucide-download-cloud"] = "rbxassetid://10723344088",
		["lucide-droplet"] = "rbxassetid://10723344432",
		["lucide-droplets"] = "rbxassetid://10734883356",
		["lucide-drumstick"] = "rbxassetid://10723344737",
		["lucide-edit"] = "rbxassetid://10734883598",
		["lucide-edit-2"] = "rbxassetid://10723344885",
		["lucide-edit-3"] = "rbxassetid://10723345088",
		["lucide-egg"] = "rbxassetid://10723345518",
		["lucide-egg-fried"] = "rbxassetid://10723345347",
		["lucide-electricity"] = "rbxassetid://10723345749",
		["lucide-electricity-off"] = "rbxassetid://10723345643",
		["lucide-equal"] = "rbxassetid://10723345990",
		["lucide-equal-not"] = "rbxassetid://10723345866",
		["lucide-eraser"] = "rbxassetid://10723346158",
		["lucide-euro"] = "rbxassetid://10723346372",
		["lucide-expand"] = "rbxassetid://10723346553",
		["lucide-external-link"] = "rbxassetid://10723346684",
		["lucide-eye"] = "rbxassetid://10723346959",
		["lucide-eye-off"] = "rbxassetid://10723346871",
		["lucide-factory"] = "rbxassetid://10723347051",
		["lucide-fan"] = "rbxassetid://10723354359",
		["lucide-fast-forward"] = "rbxassetid://10723354521",
		["lucide-feather"] = "rbxassetid://10723354671",
		["lucide-figma"] = "rbxassetid://10723354801",
		["lucide-file"] = "rbxassetid://10723374641",
		["lucide-file-archive"] = "rbxassetid://10723354921",
		["lucide-file-audio"] = "rbxassetid://10723355148",
		["lucide-file-audio-2"] = "rbxassetid://10723355026",
		["lucide-file-axis-3d"] = "rbxassetid://10723355272",
		["lucide-file-badge"] = "rbxassetid://10723355622",
		["lucide-file-badge-2"] = "rbxassetid://10723355451",
		["lucide-file-bar-chart"] = "rbxassetid://10723355887",
		["lucide-file-bar-chart-2"] = "rbxassetid://10723355746",
		["lucide-file-box"] = "rbxassetid://10723355989",
		["lucide-file-check"] = "rbxassetid://10723356210",
		["lucide-file-check-2"] = "rbxassetid://10723356100",
		["lucide-file-clock"] = "rbxassetid://10723356329",
		["lucide-file-code"] = "rbxassetid://10723356507",
		["lucide-file-cog"] = "rbxassetid://10723356830",
		["lucide-file-cog-2"] = "rbxassetid://10723356676",
		["lucide-file-diff"] = "rbxassetid://10723357039",
		["lucide-file-digit"] = "rbxassetid://10723357151",
		["lucide-file-down"] = "rbxassetid://10723357322",
		["lucide-file-edit"] = "rbxassetid://10723357495",
		["lucide-file-heart"] = "rbxassetid://10723357637",
		["lucide-file-image"] = "rbxassetid://10723357790",
		["lucide-file-input"] = "rbxassetid://10723357933",
		["lucide-file-json"] = "rbxassetid://10723364435",
		["lucide-file-json-2"] = "rbxassetid://10723364361",
		["lucide-file-key"] = "rbxassetid://10723364605",
		["lucide-file-key-2"] = "rbxassetid://10723364515",
		["lucide-file-line-chart"] = "rbxassetid://10723364725",
		["lucide-file-lock"] = "rbxassetid://10723364957",
		["lucide-file-lock-2"] = "rbxassetid://10723364861",
		["lucide-file-minus"] = "rbxassetid://10723365254",
		["lucide-file-minus-2"] = "rbxassetid://10723365086",
		["lucide-file-output"] = "rbxassetid://10723365457",
		["lucide-file-pie-chart"] = "rbxassetid://10723365598",
		["lucide-file-plus"] = "rbxassetid://10723365877",
		["lucide-file-plus-2"] = "rbxassetid://10723365766",
		["lucide-file-question"] = "rbxassetid://10723365987",
		["lucide-file-scan"] = "rbxassetid://10723366167",
		["lucide-file-search"] = "rbxassetid://10723366550",
		["lucide-file-search-2"] = "rbxassetid://10723366340",
		["lucide-file-signature"] = "rbxassetid://10723366741",
		["lucide-file-spreadsheet"] = "rbxassetid://10723366962",
		["lucide-file-symlink"] = "rbxassetid://10723367098",
		["lucide-file-terminal"] = "rbxassetid://10723367244",
		["lucide-file-text"] = "rbxassetid://10723367380",
		["lucide-file-type"] = "rbxassetid://10723367606",
		["lucide-file-type-2"] = "rbxassetid://10723367509",
		["lucide-file-up"] = "rbxassetid://10723367734",
		["lucide-file-video"] = "rbxassetid://10723373884",
		["lucide-file-video-2"] = "rbxassetid://10723367834",
		["lucide-file-volume"] = "rbxassetid://10723374172",
		["lucide-file-volume-2"] = "rbxassetid://10723374030",
		["lucide-file-warning"] = "rbxassetid://10723374276",
		["lucide-file-x"] = "rbxassetid://10723374544",
		["lucide-file-x-2"] = "rbxassetid://10723374378",
		["lucide-files"] = "rbxassetid://10723374759",
		["lucide-film"] = "rbxassetid://10723374981",
		["lucide-filter"] = "rbxassetid://10723375128",
		["lucide-fingerprint"] = "rbxassetid://10723375250",
		["lucide-flag"] = "rbxassetid://10723375890",
		["lucide-flag-off"] = "rbxassetid://10723375443",
		["lucide-flag-triangle-left"] = "rbxassetid://10723375608",
		["lucide-flag-triangle-right"] = "rbxassetid://10723375727",
		["lucide-flame"] = "rbxassetid://10723376114",
		["lucide-flashlight"] = "rbxassetid://10723376471",
		["lucide-flashlight-off"] = "rbxassetid://10723376365",
		["lucide-flask-conical"] = "rbxassetid://10734883986",
		["lucide-flask-round"] = "rbxassetid://10723376614",
		["lucide-flip-horizontal"] = "rbxassetid://10723376884",
		["lucide-flip-horizontal-2"] = "rbxassetid://10723376745",
		["lucide-flip-vertical"] = "rbxassetid://10723377138",
		["lucide-flip-vertical-2"] = "rbxassetid://10723377026",
		["lucide-flower"] = "rbxassetid://10747830374",
		["lucide-flower-2"] = "rbxassetid://10723377305",
		["lucide-focus"] = "rbxassetid://10723377537",
		["lucide-folder"] = "rbxassetid://10723387563",
		["lucide-folder-archive"] = "rbxassetid://10723384478",
		["lucide-folder-check"] = "rbxassetid://10723384605",
		["lucide-folder-clock"] = "rbxassetid://10723384731",
		["lucide-folder-closed"] = "rbxassetid://10723384893",
		["lucide-folder-cog"] = "rbxassetid://10723385213",
		["lucide-folder-cog-2"] = "rbxassetid://10723385036",
		["lucide-folder-down"] = "rbxassetid://10723385338",
		["lucide-folder-edit"] = "rbxassetid://10723385445",
		["lucide-folder-heart"] = "rbxassetid://10723385545",
		["lucide-folder-input"] = "rbxassetid://10723385721",
		["lucide-folder-key"] = "rbxassetid://10723385848",
		["lucide-folder-lock"] = "rbxassetid://10723386005",
		["lucide-folder-minus"] = "rbxassetid://10723386127",
		["lucide-folder-open"] = "rbxassetid://10723386277",
		["lucide-folder-output"] = "rbxassetid://10723386386",
		["lucide-folder-plus"] = "rbxassetid://10723386531",
		["lucide-folder-search"] = "rbxassetid://10723386787",
		["lucide-folder-search-2"] = "rbxassetid://10723386674",
		["lucide-folder-symlink"] = "rbxassetid://10723386930",
		["lucide-folder-tree"] = "rbxassetid://10723387085",
		["lucide-folder-up"] = "rbxassetid://10723387265",
		["lucide-folder-x"] = "rbxassetid://10723387448",
		["lucide-folders"] = "rbxassetid://10723387721",
		["lucide-form-input"] = "rbxassetid://10723387841",
		["lucide-forward"] = "rbxassetid://10723388016",
		["lucide-frame"] = "rbxassetid://10723394389",
		["lucide-framer"] = "rbxassetid://10723394565",
		["lucide-frown"] = "rbxassetid://10723394681",
		["lucide-fuel"] = "rbxassetid://10723394846",
		["lucide-function-square"] = "rbxassetid://10723395041",
		["lucide-gamepad"] = "rbxassetid://10723395457",
		["lucide-gamepad-2"] = "rbxassetid://10723395215",
		["lucide-gauge"] = "rbxassetid://10723395708",
		["lucide-gavel"] = "rbxassetid://10723395896",
		["lucide-gem"] = "rbxassetid://10723396000",
		["lucide-ghost"] = "rbxassetid://10723396107",
		["lucide-gift"] = "rbxassetid://10723396402",
		["lucide-gift-card"] = "rbxassetid://10723396225",
		["lucide-git-branch"] = "rbxassetid://10723396676",
		["lucide-git-branch-plus"] = "rbxassetid://10723396542",
		["lucide-git-commit"] = "rbxassetid://10723396812",
		["lucide-git-compare"] = "rbxassetid://10723396954",
		["lucide-git-fork"] = "rbxassetid://10723397049",
		["lucide-git-merge"] = "rbxassetid://10723397165",
		["lucide-git-pull-request"] = "rbxassetid://10723397431",
		["lucide-git-pull-request-closed"] = "rbxassetid://10723397268",
		["lucide-git-pull-request-draft"] = "rbxassetid://10734884302",
		["lucide-glass"] = "rbxassetid://10723397788",
		["lucide-glass-2"] = "rbxassetid://10723397529",
		["lucide-glass-water"] = "rbxassetid://10723397678",
		["lucide-glasses"] = "rbxassetid://10723397895",
		["lucide-globe"] = "rbxassetid://10723404337",
		["lucide-globe-2"] = "rbxassetid://10723398002",
		["lucide-grab"] = "rbxassetid://10723404472",
		["lucide-graduation-cap"] = "rbxassetid://10723404691",
		["lucide-grape"] = "rbxassetid://10723404822",
		["lucide-grid"] = "rbxassetid://10723404936",
		["lucide-grip-horizontal"] = "rbxassetid://10723405089",
		["lucide-grip-vertical"] = "rbxassetid://10723405236",
		["lucide-hammer"] = "rbxassetid://10723405360",
		["lucide-hand"] = "rbxassetid://10723405649",
		["lucide-hand-metal"] = "rbxassetid://10723405508",
		["lucide-hard-drive"] = "rbxassetid://10723405749",
		["lucide-hard-hat"] = "rbxassetid://10723405859",
		["lucide-hash"] = "rbxassetid://10723405975",
		["lucide-haze"] = "rbxassetid://10723406078",
		["lucide-headphones"] = "rbxassetid://10723406165",
		["lucide-heart"] = "rbxassetid://10723406885",
		["lucide-heart-crack"] = "rbxassetid://10723406299",
		["lucide-heart-handshake"] = "rbxassetid://10723406480",
		["lucide-heart-off"] = "rbxassetid://10723406662",
		["lucide-heart-pulse"] = "rbxassetid://10723406795",
		["lucide-help-circle"] = "rbxassetid://10723406988",
		["lucide-hexagon"] = "rbxassetid://10723407092",
		["lucide-highlighter"] = "rbxassetid://10723407192",
		["lucide-history"] = "rbxassetid://10723407335",
		["lucide-home"] = "rbxassetid://10723407389",
		["lucide-hourglass"] = "rbxassetid://10723407498",
		["lucide-ice-cream"] = "rbxassetid://10723414308",
		["lucide-image"] = "rbxassetid://10723415040",
		["lucide-image-minus"] = "rbxassetid://10723414487",
		["lucide-image-off"] = "rbxassetid://10723414677",
		["lucide-image-plus"] = "rbxassetid://10723414827",
		["lucide-import"] = "rbxassetid://10723415205",
		["lucide-inbox"] = "rbxassetid://10723415335",
		["lucide-indent"] = "rbxassetid://10723415494",
		["lucide-indian-rupee"] = "rbxassetid://10723415642",
		["lucide-infinity"] = "rbxassetid://10723415766",
		["lucide-info"] = "rbxassetid://10723415903",
		["lucide-inspect"] = "rbxassetid://10723416057",
		["lucide-italic"] = "rbxassetid://10723416195",
		["lucide-japanese-yen"] = "rbxassetid://10723416363",
		["lucide-joystick"] = "rbxassetid://10723416527",
		["lucide-key"] = "rbxassetid://10723416652",
		["lucide-keyboard"] = "rbxassetid://10723416765",
		["lucide-lamp"] = "rbxassetid://10723417513",
		["lucide-lamp-ceiling"] = "rbxassetid://10723416922",
		["lucide-lamp-desk"] = "rbxassetid://10723417016",
		["lucide-lamp-floor"] = "rbxassetid://10723417131",
		["lucide-lamp-wall-down"] = "rbxassetid://10723417240",
		["lucide-lamp-wall-up"] = "rbxassetid://10723417356",
		["lucide-landmark"] = "rbxassetid://10723417608",
		["lucide-languages"] = "rbxassetid://10723417703",
		["lucide-laptop"] = "rbxassetid://10723423881",
		["lucide-laptop-2"] = "rbxassetid://10723417797",
		["lucide-lasso"] = "rbxassetid://10723424235",
		["lucide-lasso-select"] = "rbxassetid://10723424058",
		["lucide-laugh"] = "rbxassetid://10723424372",
		["lucide-layers"] = "rbxassetid://10723424505",
		["lucide-layout"] = "rbxassetid://10723425376",
		["lucide-layout-dashboard"] = "rbxassetid://10723424646",
		["lucide-layout-grid"] = "rbxassetid://10723424838",
		["lucide-layout-list"] = "rbxassetid://10723424963",
		["lucide-layout-template"] = "rbxassetid://10723425187",
		["lucide-leaf"] = "rbxassetid://10723425539",
		["lucide-library"] = "rbxassetid://10723425615",
		["lucide-life-buoy"] = "rbxassetid://10723425685",
		["lucide-lightbulb"] = "rbxassetid://10723425852",
		["lucide-lightbulb-off"] = "rbxassetid://10723425762",
		["lucide-line-chart"] = "rbxassetid://10723426393",
		["lucide-link"] = "rbxassetid://10723426722",
		["lucide-link-2"] = "rbxassetid://10723426595",
		["lucide-link-2-off"] = "rbxassetid://10723426513",
		["lucide-list"] = "rbxassetid://10723433811",
		["lucide-list-checks"] = "rbxassetid://10734884548",
		["lucide-list-end"] = "rbxassetid://10723426886",
		["lucide-list-minus"] = "rbxassetid://10723426986",
		["lucide-list-music"] = "rbxassetid://10723427081",
		["lucide-list-ordered"] = "rbxassetid://10723427199",
		["lucide-list-plus"] = "rbxassetid://10723427334",
		["lucide-list-start"] = "rbxassetid://10723427494",
		["lucide-list-video"] = "rbxassetid://10723427619",
		["lucide-list-x"] = "rbxassetid://10723433655",
		["lucide-loader"] = "rbxassetid://10723434070",
		["lucide-loader-2"] = "rbxassetid://10723433935",
		["lucide-locate"] = "rbxassetid://10723434557",
		["lucide-locate-fixed"] = "rbxassetid://10723434236",
		["lucide-locate-off"] = "rbxassetid://10723434379",
		["lucide-lock"] = "rbxassetid://10723434711",
		["lucide-log-in"] = "rbxassetid://10723434830",
		["lucide-log-out"] = "rbxassetid://10723434906",
		["lucide-luggage"] = "rbxassetid://10723434993",
		["lucide-magnet"] = "rbxassetid://10723435069",
		["lucide-mail"] = "rbxassetid://10734885430",
		["lucide-mail-check"] = "rbxassetid://10723435182",
		["lucide-mail-minus"] = "rbxassetid://10723435261",
		["lucide-mail-open"] = "rbxassetid://10723435342",
		["lucide-mail-plus"] = "rbxassetid://10723435443",
		["lucide-mail-question"] = "rbxassetid://10723435515",
		["lucide-mail-search"] = "rbxassetid://10734884739",
		["lucide-mail-warning"] = "rbxassetid://10734885015",
		["lucide-mail-x"] = "rbxassetid://10734885247",
		["lucide-mails"] = "rbxassetid://10734885614",
		["lucide-map"] = "rbxassetid://10734886202",
		["lucide-map-pin"] = "rbxassetid://10734886004",
		["lucide-map-pin-off"] = "rbxassetid://10734885803",
		["lucide-maximize"] = "rbxassetid://10734886735",
		["lucide-maximize-2"] = "rbxassetid://10734886496",
		["lucide-medal"] = "rbxassetid://10734887072",
		["lucide-megaphone"] = "rbxassetid://10734887454",
		["lucide-megaphone-off"] = "rbxassetid://10734887311",
		["lucide-meh"] = "rbxassetid://10734887603",
		["lucide-menu"] = "rbxassetid://10734887784",
		["lucide-message-circle"] = "rbxassetid://10734888000",
		["lucide-message-square"] = "rbxassetid://10734888228",
		["lucide-mic"] = "rbxassetid://10734888864",
		["lucide-mic-2"] = "rbxassetid://10734888430",
		["lucide-mic-off"] = "rbxassetid://10734888646",
		["lucide-microscope"] = "rbxassetid://10734889106",
		["lucide-microwave"] = "rbxassetid://10734895076",
		["lucide-milestone"] = "rbxassetid://10734895310",
		["lucide-minimize"] = "rbxassetid://10734895698",
		["lucide-minimize-2"] = "rbxassetid://10734895530",
		["lucide-minus"] = "rbxassetid://10734896206",
		["lucide-minus-circle"] = "rbxassetid://10734895856",
		["lucide-minus-square"] = "rbxassetid://10734896029",
		["lucide-monitor"] = "rbxassetid://10734896881",
		["lucide-monitor-off"] = "rbxassetid://10734896360",
		["lucide-monitor-speaker"] = "rbxassetid://10734896512",
		["lucide-moon"] = "rbxassetid://10734897102",
		["lucide-more-horizontal"] = "rbxassetid://10734897250",
		["lucide-more-vertical"] = "rbxassetid://10734897387",
		["lucide-mountain"] = "rbxassetid://10734897956",
		["lucide-mountain-snow"] = "rbxassetid://10734897665",
		["lucide-mouse"] = "rbxassetid://10734898592",
		["lucide-mouse-pointer"] = "rbxassetid://10734898476",
		["lucide-mouse-pointer-2"] = "rbxassetid://10734898194",
		["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
		["lucide-move"] = "rbxassetid://10734900011",
		["lucide-move-3d"] = "rbxassetid://10734898756",
		["lucide-move-diagonal"] = "rbxassetid://10734899164",
		["lucide-move-diagonal-2"] = "rbxassetid://10734898934",
		["lucide-move-horizontal"] = "rbxassetid://10734899414",
		["lucide-move-vertical"] = "rbxassetid://10734899821",
		["lucide-music"] = "rbxassetid://10734905958",
		["lucide-music-2"] = "rbxassetid://10734900215",
		["lucide-music-3"] = "rbxassetid://10734905665",
		["lucide-music-4"] = "rbxassetid://10734905823",
		["lucide-navigation"] = "rbxassetid://10734906744",
		["lucide-navigation-2"] = "rbxassetid://10734906332",
		["lucide-navigation-2-off"] = "rbxassetid://10734906144",
		["lucide-navigation-off"] = "rbxassetid://10734906580",
		["lucide-network"] = "rbxassetid://10734906975",
		["lucide-newspaper"] = "rbxassetid://10734907168",
		["lucide-octagon"] = "rbxassetid://10734907361",
		["lucide-option"] = "rbxassetid://10734907649",
		["lucide-outdent"] = "rbxassetid://10734907933",
		["lucide-package"] = "rbxassetid://10734909540",
		["lucide-package-2"] = "rbxassetid://10734908151",
		["lucide-package-check"] = "rbxassetid://10734908384",
		["lucide-package-minus"] = "rbxassetid://10734908626",
		["lucide-package-open"] = "rbxassetid://10734908793",
		["lucide-package-plus"] = "rbxassetid://10734909016",
		["lucide-package-search"] = "rbxassetid://10734909196",
		["lucide-package-x"] = "rbxassetid://10734909375",
		["lucide-paint-bucket"] = "rbxassetid://10734909847",
		["lucide-paintbrush"] = "rbxassetid://10734910187",
		["lucide-paintbrush-2"] = "rbxassetid://10734910030",
		["lucide-palette"] = "rbxassetid://10734910430",
		["lucide-palmtree"] = "rbxassetid://10734910680",
		["lucide-paperclip"] = "rbxassetid://10734910927",
		["lucide-party-popper"] = "rbxassetid://10734918735",
		["lucide-pause"] = "rbxassetid://10734919336",
		["lucide-pause-circle"] = "rbxassetid://10735024209",
		["lucide-pause-octagon"] = "rbxassetid://10734919143",
		["lucide-pen-tool"] = "rbxassetid://10734919503",
		["lucide-pencil"] = "rbxassetid://10734919691",
		["lucide-percent"] = "rbxassetid://10734919919",
		["lucide-person-standing"] = "rbxassetid://10734920149",
		["lucide-phone"] = "rbxassetid://10734921524",
		["lucide-phone-call"] = "rbxassetid://10734920305",
		["lucide-phone-forwarded"] = "rbxassetid://10734920508",
		["lucide-phone-incoming"] = "rbxassetid://10734920694",
		["lucide-phone-missed"] = "rbxassetid://10734920845",
		["lucide-phone-off"] = "rbxassetid://10734921077",
		["lucide-phone-outgoing"] = "rbxassetid://10734921288",
		["lucide-pie-chart"] = "rbxassetid://10734921727",
		["lucide-piggy-bank"] = "rbxassetid://10734921935",
		["lucide-pin"] = "rbxassetid://10734922324",
		["lucide-pin-off"] = "rbxassetid://10734922180",
		["lucide-pipette"] = "rbxassetid://10734922497",
		["lucide-pizza"] = "rbxassetid://10734922774",
		["lucide-plane"] = "rbxassetid://10734922971",
		["lucide-play"] = "rbxassetid://10734923549",
		["lucide-play-circle"] = "rbxassetid://10734923214",
		["lucide-plus"] = "rbxassetid://10734924532",
		["lucide-plus-circle"] = "rbxassetid://10734923868",
		["lucide-plus-square"] = "rbxassetid://10734924219",
		["lucide-podcast"] = "rbxassetid://10734929553",
		["lucide-pointer"] = "rbxassetid://10734929723",
		["lucide-pound-sterling"] = "rbxassetid://10734929981",
		["lucide-power"] = "rbxassetid://10734930466",
		["lucide-power-off"] = "rbxassetid://10734930257",
		["lucide-printer"] = "rbxassetid://10734930632",
		["lucide-puzzle"] = "rbxassetid://10734930886",
		["lucide-quote"] = "rbxassetid://10734931234",
		["lucide-radio"] = "rbxassetid://10734931596",
		["lucide-radio-receiver"] = "rbxassetid://10734931402",
		["lucide-rectangle-horizontal"] = "rbxassetid://10734931777",
		["lucide-rectangle-vertical"] = "rbxassetid://10734932081",
		["lucide-recycle"] = "rbxassetid://10734932295",
		["lucide-redo"] = "rbxassetid://10734932822",
		["lucide-redo-2"] = "rbxassetid://10734932586",
		["lucide-refresh-ccw"] = "rbxassetid://10734933056",
		["lucide-refresh-cw"] = "rbxassetid://10734933222",
		["lucide-refrigerator"] = "rbxassetid://10734933465",
		["lucide-regex"] = "rbxassetid://10734933655",
		["lucide-repeat"] = "rbxassetid://10734933966",
		["lucide-repeat-1"] = "rbxassetid://10734933826",
		["lucide-reply"] = "rbxassetid://10734934252",
		["lucide-reply-all"] = "rbxassetid://10734934132",
		["lucide-rewind"] = "rbxassetid://10734934347",
		["lucide-rocket"] = "rbxassetid://10734934585",
		["lucide-rocking-chair"] = "rbxassetid://10734939942",
		["lucide-rotate-3d"] = "rbxassetid://10734940107",
		["lucide-rotate-ccw"] = "rbxassetid://10734940376",
		["lucide-rotate-cw"] = "rbxassetid://10734940654",
		["lucide-rss"] = "rbxassetid://10734940825",
		["lucide-ruler"] = "rbxassetid://10734941018",
		["lucide-russian-ruble"] = "rbxassetid://10734941199",
		["lucide-sailboat"] = "rbxassetid://10734941354",
		["lucide-save"] = "rbxassetid://10734941499",
		["lucide-scale"] = "rbxassetid://10734941912",
		["lucide-scale-3d"] = "rbxassetid://10734941739",
		["lucide-scaling"] = "rbxassetid://10734942072",
		["lucide-scan"] = "rbxassetid://10734942565",
		["lucide-scan-face"] = "rbxassetid://10734942198",
		["lucide-scan-line"] = "rbxassetid://10734942351",
		["lucide-scissors"] = "rbxassetid://10734942778",
		["lucide-screen-share"] = "rbxassetid://10734943193",
		["lucide-screen-share-off"] = "rbxassetid://10734942967",
		["lucide-scroll"] = "rbxassetid://10734943448",
		["lucide-search"] = "rbxassetid://10734943674",
		["lucide-send"] = "rbxassetid://10734943902",
		["lucide-separator-horizontal"] = "rbxassetid://10734944115",
		["lucide-separator-vertical"] = "rbxassetid://10734944326",
		["lucide-server"] = "rbxassetid://10734949856",
		["lucide-server-cog"] = "rbxassetid://10734944444",
		["lucide-server-crash"] = "rbxassetid://10734944554",
		["lucide-server-off"] = "rbxassetid://10734944668",
		["lucide-settings"] = "rbxassetid://10734950309",
		["lucide-settings-2"] = "rbxassetid://10734950020",
		["lucide-share"] = "rbxassetid://10734950813",
		["lucide-share-2"] = "rbxassetid://10734950553",
		["lucide-sheet"] = "rbxassetid://10734951038",
		["lucide-shield"] = "rbxassetid://10734951847",
		["lucide-shield-alert"] = "rbxassetid://10734951173",
		["lucide-shield-check"] = "rbxassetid://10734951367",
		["lucide-shield-close"] = "rbxassetid://10734951535",
		["lucide-shield-off"] = "rbxassetid://10734951684",
		["lucide-shirt"] = "rbxassetid://10734952036",
		["lucide-shopping-bag"] = "rbxassetid://10734952273",
		["lucide-shopping-cart"] = "rbxassetid://10734952479",
		["lucide-shovel"] = "rbxassetid://10734952773",
		["lucide-shower-head"] = "rbxassetid://10734952942",
		["lucide-shrink"] = "rbxassetid://10734953073",
		["lucide-shrub"] = "rbxassetid://10734953241",
		["lucide-shuffle"] = "rbxassetid://10734953451",
		["lucide-sidebar"] = "rbxassetid://10734954301",
		["lucide-sidebar-close"] = "rbxassetid://10734953715",
		["lucide-sidebar-open"] = "rbxassetid://10734954000",
		["lucide-sigma"] = "rbxassetid://10734954538",
		["lucide-signal"] = "rbxassetid://10734961133",
		["lucide-signal-high"] = "rbxassetid://10734954807",
		["lucide-signal-low"] = "rbxassetid://10734955080",
		["lucide-signal-medium"] = "rbxassetid://10734955336",
		["lucide-signal-zero"] = "rbxassetid://10734960878",
		["lucide-siren"] = "rbxassetid://10734961284",
		["lucide-skip-back"] = "rbxassetid://10734961526",
		["lucide-skip-forward"] = "rbxassetid://10734961809",
		["lucide-skull"] = "rbxassetid://10734962068",
		["lucide-slack"] = "rbxassetid://10734962339",
		["lucide-slash"] = "rbxassetid://10734962600",
		["lucide-slice"] = "rbxassetid://10734963024",
		["lucide-sliders"] = "rbxassetid://10734963400",
		["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
		["lucide-smartphone"] = "rbxassetid://10734963940",
		["lucide-smartphone-charging"] = "rbxassetid://10734963671",
		["lucide-smile"] = "rbxassetid://10734964441",
		["lucide-smile-plus"] = "rbxassetid://10734964188",
		["lucide-snowflake"] = "rbxassetid://10734964600",
		["lucide-sofa"] = "rbxassetid://10734964852",
		["lucide-sort-asc"] = "rbxassetid://10734965115",
		["lucide-sort-desc"] = "rbxassetid://10734965287",
		["lucide-speaker"] = "rbxassetid://10734965419",
		["lucide-sprout"] = "rbxassetid://10734965572",
		["lucide-square"] = "rbxassetid://10734965702",
		["lucide-star"] = "rbxassetid://10734966248",
		["lucide-star-half"] = "rbxassetid://10734965897",
		["lucide-star-off"] = "rbxassetid://10734966097",
		["lucide-stethoscope"] = "rbxassetid://10734966384",
		["lucide-sticker"] = "rbxassetid://10734972234",
		["lucide-sticky-note"] = "rbxassetid://10734972463",
		["lucide-stop-circle"] = "rbxassetid://10734972621",
		["lucide-stretch-horizontal"] = "rbxassetid://10734972862",
		["lucide-stretch-vertical"] = "rbxassetid://10734973130",
		["lucide-strikethrough"] = "rbxassetid://10734973290",
		["lucide-subscript"] = "rbxassetid://10734973457",
		["lucide-sun"] = "rbxassetid://10734974297",
		["lucide-sun-dim"] = "rbxassetid://10734973645",
		["lucide-sun-medium"] = "rbxassetid://10734973778",
		["lucide-sun-moon"] = "rbxassetid://10734973999",
		["lucide-sun-snow"] = "rbxassetid://10734974130",
		["lucide-sunrise"] = "rbxassetid://10734974522",
		["lucide-sunset"] = "rbxassetid://10734974689",
		["lucide-superscript"] = "rbxassetid://10734974850",
		["lucide-swiss-franc"] = "rbxassetid://10734975024",
		["lucide-switch-camera"] = "rbxassetid://10734975214",
		["lucide-sword"] = "rbxassetid://10734975486",
		["lucide-swords"] = "rbxassetid://10734975692",
		["lucide-syringe"] = "rbxassetid://10734975932",
		["lucide-table"] = "rbxassetid://10734976230",
		["lucide-table-2"] = "rbxassetid://10734976097",
		["lucide-tablet"] = "rbxassetid://10734976394",
		["lucide-tag"] = "rbxassetid://10734976528",
		["lucide-tags"] = "rbxassetid://10734976739",
		["lucide-target"] = "rbxassetid://10734977012",
		["lucide-tent"] = "rbxassetid://10734981750",
		["lucide-terminal"] = "rbxassetid://10734982144",
		["lucide-terminal-square"] = "rbxassetid://10734981995",
		["lucide-text-cursor"] = "rbxassetid://10734982395",
		["lucide-text-cursor-input"] = "rbxassetid://10734982297",
		["lucide-thermometer"] = "rbxassetid://10734983134",
		["lucide-thermometer-snowflake"] = "rbxassetid://10734982571",
		["lucide-thermometer-sun"] = "rbxassetid://10734982771",
		["lucide-thumbs-down"] = "rbxassetid://10734983359",
		["lucide-thumbs-up"] = "rbxassetid://10734983629",
		["lucide-ticket"] = "rbxassetid://10734983868",
		["lucide-timer"] = "rbxassetid://10734984606",
		["lucide-timer-off"] = "rbxassetid://10734984138",
		["lucide-timer-reset"] = "rbxassetid://10734984355",
		["lucide-toggle-left"] = "rbxassetid://10734984834",
		["lucide-toggle-right"] = "rbxassetid://10734985040",
		["lucide-tornado"] = "rbxassetid://10734985247",
		["lucide-toy-brick"] = "rbxassetid://10747361919",
		["lucide-train"] = "rbxassetid://10747362105",
		["lucide-trash"] = "rbxassetid://10747362393",
		["lucide-trash-2"] = "rbxassetid://10747362241",
		["lucide-tree-deciduous"] = "rbxassetid://10747362534",
		["lucide-tree-pine"] = "rbxassetid://10747362748",
		["lucide-trees"] = "rbxassetid://10747363016",
		["lucide-trending-down"] = "rbxassetid://10747363205",
		["lucide-trending-up"] = "rbxassetid://10747363465",
		["lucide-triangle"] = "rbxassetid://10747363621",
		["lucide-trophy"] = "rbxassetid://10747363809",
		["lucide-truck"] = "rbxassetid://10747364031",
		["lucide-tv"] = "rbxassetid://10747364593",
		["lucide-tv-2"] = "rbxassetid://10747364302",
		["lucide-type"] = "rbxassetid://10747364761",
		["lucide-umbrella"] = "rbxassetid://10747364971",
		["lucide-underline"] = "rbxassetid://10747365191",
		["lucide-undo"] = "rbxassetid://10747365484",
		["lucide-undo-2"] = "rbxassetid://10747365359",
		["lucide-unlink"] = "rbxassetid://10747365771",
		["lucide-unlink-2"] = "rbxassetid://10747397871",
		["lucide-unlock"] = "rbxassetid://10747366027",
		["lucide-upload"] = "rbxassetid://10747366434",
		["lucide-upload-cloud"] = "rbxassetid://10747366266",
		["lucide-usb"] = "rbxassetid://10747366606",
		["lucide-user"] = "rbxassetid://10747373176",
		["lucide-user-check"] = "rbxassetid://10747371901",
		["lucide-user-cog"] = "rbxassetid://10747372167",
		["lucide-user-minus"] = "rbxassetid://10747372346",
		["lucide-user-plus"] = "rbxassetid://10747372702",
		["lucide-user-x"] = "rbxassetid://10747372992",
		["lucide-users"] = "rbxassetid://10747373426",
		["lucide-utensils"] = "rbxassetid://10747373821",
		["lucide-utensils-crossed"] = "rbxassetid://10747373629",
		["lucide-venetian-mask"] = "rbxassetid://10747374003",
		["lucide-verified"] = "rbxassetid://10747374131",
		["lucide-vibrate"] = "rbxassetid://10747374489",
		["lucide-vibrate-off"] = "rbxassetid://10747374269",
		["lucide-video"] = "rbxassetid://10747374938",
		["lucide-video-off"] = "rbxassetid://10747374721",
		["lucide-view"] = "rbxassetid://10747375132",
		["lucide-voicemail"] = "rbxassetid://10747375281",
		["lucide-volume"] = "rbxassetid://10747376008",
		["lucide-volume-1"] = "rbxassetid://10747375450",
		["lucide-volume-2"] = "rbxassetid://10747375679",
		["lucide-volume-x"] = "rbxassetid://10747375880",
		["lucide-wallet"] = "rbxassetid://10747376205",
		["lucide-wand"] = "rbxassetid://10747376565",
		["lucide-wand-2"] = "rbxassetid://10747376349",
		["lucide-watch"] = "rbxassetid://10747376722",
		["lucide-waves"] = "rbxassetid://10747376931",
		["lucide-webcam"] = "rbxassetid://10747381992",
		["lucide-wifi"] = "rbxassetid://10747382504",
		["lucide-wifi-off"] = "rbxassetid://10747382268",
		["lucide-wind"] = "rbxassetid://10747382750",
		["lucide-wrap-text"] = "rbxassetid://10747383065",
		["lucide-wrench"] = "rbxassetid://10747383470",
		["lucide-x"] = "rbxassetid://10747384394",
		["lucide-x-circle"] = "rbxassetid://10747383819",
		["lucide-x-octagon"] = "rbxassetid://10747384037",
		["lucide-x-square"] = "rbxassetid://10747384217",
		["lucide-zoom-in"] = "rbxassetid://10747384552",
		["lucide-zoom-out"] = "rbxassetid://10747384679",
	},
}

end)

register("main", function()
local script = create_mock_script("")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Root = script
local Creator = require(Root.Creator)
local ElementsTable = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Components = Root.Components
local NotificationModule = require(Components.Notification)
local Themes = require(Root.Themes)
local ThemeValidator = require(Root.ThemeValidator)

local New = Creator.New

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUI = New("ScreenGui", {
	Name = "Core X",
	IgnoreGuiInset = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
	ClipToDeviceSafeArea = true,
	Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
})
ProtectGui(GUI)

local SafeArea = New("Frame", {
	Name = "SafeArea",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = GUI,
})

local function CreateLayer(Name, ZIndex)
	return New("Frame", {
		Name = Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = ZIndex,
		Parent = SafeArea,
	})
end

local Layers = {
	Window = CreateLayer("WindowLayer", 1),
	Overlay = CreateLayer("OverlayLayer", 10),
	Notifications = CreateLayer("NotificationLayer", 20),
}
NotificationModule:Init(Layers.Notifications)

local Library = {
	Version = "1.2.0",

	OpenFrames = {},
	ActiveDropdown = nil,
	ActiveDialog = nil,
	Options = {},
	Themes = Themes.Names,
	Types = require(Root.Types),
	ThemeContrastReports = ThemeValidator.ValidateAll(Themes, 4.5),

	Window = nil,
	WindowFrame = nil,
	Windows = {},
	Unloaded = false,

	Theme = "Dark",
	DialogOpen = false,
	InteractionOwner = nil,
	ReducedMotion = false,
	NotificationLimit = 3,
	UseAcrylic = false,
	Acrylic = false,
	Transparency = true,
	MinimizeKeybind = nil,
	MinimizeKey = Enum.KeyCode.LeftControl,

	GUI = GUI,
	SafeArea = SafeArea,
	Layers = Layers,
}

function Library:GetLayer(Name)
	return Library.Layers[Name] or Library.SafeArea
end

function Library:AcquireInteraction(Owner)
	if not Owner then
		return false
	end
	if Library.InteractionOwner and Library.InteractionOwner ~= Owner then
		return false
	end
	Library.InteractionOwner = Owner
	return true
end

function Library:ReleaseInteraction(Owner)
	if Library.InteractionOwner == Owner then
		Library.InteractionOwner = nil
	end
end

function Library:SetReducedMotion(Value)
	Library.ReducedMotion = Value == true
end

function Library:SetNotificationLimit(Value)
	Value = math.max(1, math.floor(tonumber(Value) or 3))
	Library.NotificationLimit = Value
	if NotificationModule.EnforceLimit then
		NotificationModule:EnforceLimit()
	end
end

function Library:SafeCallback(Function, ...)
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		local _, i = Event:find(":%d+: ")

		if not i then
			return Library:Notify({
				Title = "Interface",
				Content = "Callback error",
				SubContent = Event,
				Duration = 5,
			})
		end

		return Library:Notify({
			Title = "Interface",
			Content = "Callback error",
			SubContent = Event:sub(i + 1),
			Duration = 5,
		})
	end
end

function Library:Round(Number, Factor)
	Factor = Factor or 0
	local Multiplier = 10 ^ Factor
	return math.round(Number * Multiplier) / Multiplier
end

local Icons = require(Root.Icons).assets
function Library:GetIcon(Name)
	if Name ~= nil and Icons["lucide-" .. Name] then
		return Icons["lucide-" .. Name]
	end
	return nil
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

for _, ElementComponent in ipairs(ElementsTable) do
	Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
		ElementComponent.Container = self.Container
		ElementComponent.Type = self.Type
		ElementComponent.ScrollFrame = self.ScrollFrame
		ElementComponent.Library = Library

		return ElementComponent:New(Idx, Config)
	end
end

Library.Elements = Elements

function Library:CreateWindow(Config)
	assert(Config.Title, "Window - Missing Title")

	Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
	Library:SetReducedMotion(Config.ReducedMotion)
	Library:SetNotificationLimit(Config.NotificationLimit or 3)
	Library.UseAcrylic = Config.Acrylic or false
	Library.Acrylic = Config.Acrylic or false
	local RequestedTheme = Config.Theme or "Dark"
	Library.Theme = table.find(Library.Themes, RequestedTheme) and RequestedTheme or "Dark"
	if Config.Acrylic then
		Acrylic.init()
	end

	local Window = require(Components.Window)({
		Parent = Layers.Window,
		Size = Config.Size,
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		TabWidth = Config.TabWidth,
	})

	if not Library.Window then
		Library.Window = Window
	end
	table.insert(Library.Windows, Window)
	Library:SetTheme(Library.Theme)

	local ShowSplash = Config.ShowSplashScreen ~= false
	if ShowSplash then
		Window.Root.Visible = false

		local SplashFrame = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = Library.Layers.Overlay,
		})

		local Container = New("Frame", {
			Size = UDim2.fromOffset(360, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Parent = SplashFrame,
		})

		local TitleLabel = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.new(0, 0, 0, 0),
			Text = Config.SplashScreenTitle or ("Loading " .. Config.Title .. "..."),
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextSize = 18,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Parent = Container,
		})

		local SubLabel = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 30),
			Text = "Building UI Library...",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Light, Enum.FontStyle.Normal),
			TextSize = 13,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Parent = Container,
		})

		local ProgressTrack = New("Frame", {
			Size = UDim2.fromOffset(300, 4),
			Position = UDim2.new(0.5, 0, 0, 65),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Parent = Container,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		})

		local ProgressFill = New("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255),
			BorderSizePixel = 0,
			Parent = ProgressTrack,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		})

		local SplashScale = New("UIScale", {
			Scale = 1,
			Parent = Container,
		})

		task.spawn(function()
			local Steps = {
				{ val = 0.15, text = "Loading files..." },
				{ val = 0.35, text = "Building UI elements..." },
				{ val = 0.60, text = "Applying themes..." },
				{ val = 0.85, text = "Loading configurations..." },
				{ val = 1.00, text = "Ready!" },
			}

			local TweenService = game:GetService("TweenService")
			for _, step in ipairs(Steps) do
				SubLabel.Text = step.text
				local Tween = TweenService:Create(ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(step.val, 1) })
				Tween:Play()
				task.wait(0.35)
			end

			task.wait(0.1)

			local FadeTime = 0.3
			local FadeTweenInfo = TweenInfo.new(FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			TweenService:Create(TitleLabel, FadeTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(SubLabel, FadeTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(ProgressTrack, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(ProgressFill, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(SplashScale, FadeTweenInfo, { Scale = 1.05 }):Play()

			task.wait(FadeTime)
			SplashFrame:Destroy()

			Window.Root.Visible = true
			local WindowScale = New("UIScale", {
				Scale = 0.95,
				Parent = Window.Root,
			})

			local OriginalPos = Window.Root.Position
			Window.Root.Position = OriginalPos + UDim2.fromOffset(0, 15)

			local WindowTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(WindowScale, WindowTweenInfo, { Scale = 1 }):Play()
			TweenService:Create(Window.Root, WindowTweenInfo, { Position = OriginalPos }):Play()

			task.wait(0.4)
			WindowScale:Destroy()
		end)
	end

	return Window
end

Library.Language = "en"
Library.CompactMode = false
Library.AccentColor = nil

Library.Translations = {
	th = {
		["ConfigName"] = "ชื่อไฟล์การตั้งค่า",
		["ConfigList"] = "รายการไฟล์ทั้งหมด",
		["CreateConfig"] = "สร้างการตั้งค่าใหม่",
		["LoadConfig"] = "โหลดการตั้งค่านี้",
		["OverwriteConfig"] = "บันทึกทับตัวเดิม",
		["RefreshList"] = "รีเฟรชรายการ",
		["SetAutoload"] = "ตั้งเป็นโหลดอัตโนมัติ",
		["Theme"] = "ธีมสีหน้าต่าง",
		["Acrylic"] = "เอฟเฟกต์เบลอหลัง (Acrylic)",
		["Transparency"] = "เปิดเอฟเฟกต์โปร่งแสง",
		["MinimizeBind"] = "ปุ่มซ่อนหน้าต่าง",
		["AccentColor"] = "สีไฮไลต์หลัก",
		["AccentColorDesc"] = "ปรับแต่งสีปุ่ม สวิตช์ และขีดเส้นเน้นของธีม",
		["AutoloadDesc"] = "โหลดอัตโนมัติในปัจจุบัน: %s",
		["ThemeDesc"] = "เปลี่ยนสไตล์สีสันของหน้าต่างหลัก",
		["AcrylicDesc"] = "การเบลอพื้นหลังต้องการระดับกราฟิก 8 ขึ้นไป",
		["TransparencyDesc"] = "ทำให้พื้นหลังแผงหน้าต่างมีความโปร่งแสงขึ้น",
		["MinimizeDesc"] = "ปุ่มลัดสำหรับซ่อนหรือแสดงหน้าต่าง UI",
		["AutoloadNone"] = "ไม่มี",
		["InterfaceSection"] = "การปรับแต่งหน้าต่าง (Interface)",
		["ConfigSection"] = "การจัดการตั้งค่า (Configuration)",
		["CompactMode"] = "โหมดกะทัดรัด (Compact Mode)",
		["CompactModeDesc"] = "ย่อระยะห่าง ขนาดตัวอักษร และขนาดปุ่มให้เล็กลง",
		["AutoloadFail"] = "ตั้งเซฟโหลดอัตโนมัติล้มเหลว: %s",
		["AutoloadLoaded"] = "โหลดเซฟอัตโนมัติ %q เรียบร้อย",
		["AutoloadSet"] = "ตั้งเซฟ %q ให้โหลดอัตโนมัติเรียบร้อย",
		["SaveFail"] = "บันทึกข้อมูลล้มเหลว: %s",
		["SaveSuccess"] = "สร้างเซฟ %q เรียบร้อย",
		["LoadFail"] = "โหลดข้อมูลล้มเหลว: %s",
		["LoadSuccess"] = "โหลดเซฟ %q เรียบร้อย",
		["OverwriteFail"] = "บันทึกทับล้มเหลว: %s",
		["OverwriteSuccess"] = "บันทึกทับเซฟ %q เรียบร้อย",
		["ReducedMotion"] = "ลดการเคลื่อนไหว (Reduced Motion)",
		["ReducedMotionDesc"] = "ปิดแอนิเมชันของระบบเพื่อลดการใช้ทรัพยากร",
		["Language"] = "ภาษา (Language)",
		["LanguageDesc"] = "เปลี่ยนภาษาของเมนูหลัก",
	},
	en = {
		["ConfigName"] = "Config name",
		["ConfigList"] = "Config list",
		["CreateConfig"] = "Create config",
		["LoadConfig"] = "Load config",
		["OverwriteConfig"] = "Overwrite config",
		["RefreshList"] = "Refresh list",
		["SetAutoload"] = "Set as autoload",
		["Theme"] = "Theme",
		["Acrylic"] = "Acrylic",
		["Transparency"] = "Transparency",
		["MinimizeBind"] = "Minimize Bind",
		["AccentColor"] = "Accent Color",
		["AccentColorDesc"] = "Customize the highlight color of controls.",
		["AutoloadDesc"] = "Current autoload config: %s",
		["ThemeDesc"] = "Changes the interface theme.",
		["AcrylicDesc"] = "The blurred background requires graphic quality 8+",
		["TransparencyDesc"] = "Makes the interface transparent.",
		["MinimizeDesc"] = "Hotkey for minimizing the main window.",
		["AutoloadNone"] = "none",
		["InterfaceSection"] = "Interface",
		["ConfigSection"] = "Configuration",
		["CompactMode"] = "Compact Mode",
		["CompactModeDesc"] = "Reduces UI spacing, padding, and text sizes.",
		["AutoloadFail"] = "Failed to set autoload config: %s",
		["AutoloadLoaded"] = "Auto loaded config %q",
		["AutoloadSet"] = "Set %q to auto load",
		["SaveFail"] = "Failed to save config: %s",
		["SaveSuccess"] = "Created config %q",
		["LoadFail"] = "Failed to load config: %s",
		["LoadSuccess"] = "Loaded config %q",
		["OverwriteFail"] = "Failed to overwrite config: %s",
		["OverwriteSuccess"] = "Overwrote config %q",
		["ReducedMotion"] = "Reduced motion",
		["ReducedMotionDesc"] = "Disables non-essential interface animations.",
		["Language"] = "Language",
		["LanguageDesc"] = "Changes the interface language.",
	}
}

Library.LanguageChangedSignals = {}

function Library:OnLanguageChanged(Callback)
	table.insert(Library.LanguageChangedSignals, Callback)
end

function Library:SetLanguage(Lang)
	if Library.Translations[Lang] then
		Library.Language = Lang
		Creator.UpdateTheme()
		Creator.UpdateTranslations()
		for _, cb in ipairs(Library.LanguageChangedSignals) do
			pcall(cb)
		end
	end
end

function Library:Translate(Key, ...)
	local Lang = Library.Language or "en"
	local Dict = Library.Translations[Lang] or Library.Translations["en"]
	local Format = Dict[Key] or Library.Translations["en"][Key] or Key
	return string.format(Format, ...)
end

function Library:SetCompactMode(Value)
	Library.CompactMode = Value
	Creator.UpdateTheme()
end

function Library:SetAccentColor(Value)
	Library.AccentColor = Value
	Creator.UpdateTheme()
end

function Library:SetTheme(Value)
	if table.find(Library.Themes, Value) then
		Library.Theme = Value
		Library.LastThemeContrastReport = Library:CheckThemeContrast(Value)
		Creator.UpdateTheme()
	end
end

function Library:CheckThemeContrast(Value, Minimum)
	local ThemeName = Value or Library.Theme
	local Theme = Themes[ThemeName]
	if not Theme then
		return nil
	end
	local Report = ThemeValidator.ValidateTheme(Theme, Minimum, Themes.Dark)
	Library.ThemeContrastReports[ThemeName] = Report
	return Report
end

function Library:CheckAllThemeContrast(Minimum)
	Library.ThemeContrastReports = ThemeValidator.ValidateAll(Themes, Minimum)
	return Library.ThemeContrastReports
end

function Library:Destroy()
	Library.Unloaded = true
	NotificationModule:Clear()
	Creator.ClearRegistry()
	for _, Window in ipairs(Library.Windows) do
		pcall(function()
			Window:Destroy()
		end)
	end
	table.clear(Library.Windows)
	Library.Window = nil
	Library.GUI:Destroy()
	Library.ActiveDropdown = nil
	Library.ActiveDialog = nil
	Library.DialogOpen = false
	Library.InteractionOwner = nil
end

function Library:ToggleAcrylic(Value)
	if Library.UseAcrylic then
		Library.Acrylic = Value
		for _, Window in ipairs(Library.Windows) do
			if Window.AcrylicPaint and Window.AcrylicPaint.Model then
				Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
			end
		end
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function Library:ToggleTransparency(Value)
	for _, Window in ipairs(Library.Windows) do
		if Window.AcrylicPaint and Window.AcrylicPaint.Frame and Window.AcrylicPaint.Frame.Background then
			Window.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
		end
	end
end

function Library:Notify(Config)
	return NotificationModule:New(Config)
end

local Presets = {
	PandaAuth = function(Key, Config)
		local Service = Config.Service or ""
		local Url = "https://api-gateway.pandadevelopment.net/v1/sdk/verify?key=" .. tostring(Key) .. "&service=" .. tostring(Service)
		local success, result = pcall(function()
			return game:HttpGet(Url)
		end)
		if success and result then
			local successJson, decoded = pcall(function()
				return game:GetService("HttpService"):JSONDecode(result)
			end)
			if successJson and decoded then
				return decoded.success == true or decoded.valid == true
			end
		end
		return false
	end,
	
	Luaguard = function(Key, Config)
		local Project = Config.Project or ""
		local Url = "https://api.luaguard.org/v1/check?key=" .. tostring(Key) .. "&project=" .. tostring(Project)
		local success, result = pcall(function()
			return game:HttpGet(Url)
		end)
		if success and result then
			local successJson, decoded = pcall(function()
				return game:GetService("HttpService"):JSONDecode(result)
			end)
			if successJson and decoded then
				return decoded.success == true or decoded.valid == true or decoded.status == "success"
			end
		end
		return false
	end,
	
	Keyguard = function(Key, Config)
		local Project = Config.Project or ""
		local Url = "https://api.keyguard.xyz/v1/assets/verify?key=" .. tostring(Key) .. "&project=" .. tostring(Project)
		local success, result = pcall(function()
			return game:HttpGet(Url)
		end)
		if success and result then
			local successJson, decoded = pcall(function()
				return game:GetService("HttpService"):JSONDecode(result)
			end)
			if successJson and decoded then
				return decoded.success == true or decoded.valid == true
			end
		end
		return false
	end,
	
	Custom = function(Key, Config)
		local Url = Config.Url or ""
		if Url == "" then return false end
		local FinalUrl = Url:gsub("{key}", tostring(Key))
		if FinalUrl == Url then
			if FinalUrl:find("%?") then
				FinalUrl = FinalUrl .. "&key=" .. tostring(Key)
			else
				FinalUrl = FinalUrl .. "?key=" .. tostring(Key)
			end
		end
		local success, result = pcall(function()
			return game:HttpGet(FinalUrl)
		end)
		if success and result then
			if Config.CheckFunction then
				local successCheck, res = pcall(Config.CheckFunction, result)
				return successCheck and res == true
			else
				local successJson, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(result)
				end)
				if successJson and decoded then
					return decoded.success == true or decoded.valid == true or decoded.status == "success"
				end
				return result:lower():find("true") ~= nil or result:lower():find("success") ~= nil
			end
		end
		return false
	end
}

function Library:CreateKeySystem(Config)
	assert(Config.OnVerified, "KeySystem - Missing OnVerified callback")

	local UseAcrylic = Config.Acrylic ~= false
	if UseAcrylic then
		Library.UseAcrylic = true
		Acrylic.init()
	end

	local SaveKey = Config.SaveKey
	local SavePath = Config.SavePath or "fluent-key.txt"
	local SavedKey = ""

	if SaveKey then
		local readfile = readfile or (io and io.read)
		local isfile = isfile or function(path)
			local success, _ = pcall(readfile, path)
			return success
		end
		if isfile(SavePath) then
			local successRead, content = pcall(readfile, SavePath)
			if successRead and content then
				SavedKey = content:gsub("%s+", "")
			end
		end
	end

	local KeySystemGui = New("ScreenGui", {
		Name = "CoreXKeySystem",
		IgnoreGuiInset = false,
		ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ClipToDeviceSafeArea = true,
		Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
	})
	ProtectGui(KeySystemGui)

	local KeySystemFrame = New("Frame", {
		Size = UDim2.fromOffset(340, 200),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = KeySystemGui,
	})

	local KeySystemPaint = Acrylic.AcrylicPaint()
	if KeySystemPaint.AddParent then
		KeySystemPaint.AddParent(KeySystemFrame)
	end

	New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = KeySystemPaint.Frame,
	})

	local UIStroke = New("UIStroke", {
		Color = Color3.fromRGB(80, 80, 80),
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = KeySystemPaint.Frame,
	})

	local Title = New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 24),
		Position = UDim2.fromOffset(12, 16),
		Text = Config.Title or "Key System",
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = KeySystemPaint.Frame,
	})

	local SubTitle = New("TextLabel", {
		Size = UDim2.new(1, -24, 0, 18),
		Position = UDim2.fromOffset(12, 38),
		Text = Config.SubTitle or "Verification Required",
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextSize = 12,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = KeySystemPaint.Frame,
	})

	local TextboxFrame = New("Frame", {
		Size = UDim2.new(1, -24, 0, 36),
		Position = UDim2.fromOffset(12, 75),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = 0.3,
		Parent = KeySystemPaint.Frame,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", {
			Color = Color3.fromRGB(60, 60, 60),
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
	})

	local Input = New("TextBox", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Enter key here...",
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Parent = TextboxFrame,
	})

	local GetKeyButton, DiscordButton, VerifyButton
	
	if Config.Discord then
		GetKeyButton = New("TextButton", {
			Size = UDim2.new(0, 100, 0, 36),
			Position = UDim2.new(0, 12, 1, -48),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BackgroundTransparency = 0.3,
			Text = "Get Key",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(230, 230, 230),
			TextSize = 13,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Color = Color3.fromRGB(70, 70, 70),
				Transparency = 0.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
		})

		DiscordButton = New("TextButton", {
			Size = UDim2.new(0, 100, 0, 36),
			Position = UDim2.new(0, 120, 1, -48),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BackgroundTransparency = 0.3,
			Text = "Discord",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(230, 230, 230),
			TextSize = 13,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Color = Color3.fromRGB(70, 70, 70),
				Transparency = 0.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
		})

		VerifyButton = New("TextButton", {
			Size = UDim2.new(0, 100, 0, 36),
			Position = UDim2.new(0, 228, 1, -48),
			BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255),
			BackgroundTransparency = 0,
			Text = "Verify Key",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
	else
		GetKeyButton = New("TextButton", {
			Size = UDim2.new(0.5, -16, 0, 36),
			Position = UDim2.new(0, 12, 1, -48),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BackgroundTransparency = 0.3,
			Text = "Get Key",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(230, 230, 230),
			TextSize = 13,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Color = Color3.fromRGB(70, 70, 70),
				Transparency = 0.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
		})

		VerifyButton = New("TextButton", {
			Size = UDim2.new(0.5, -16, 0, 36),
			Position = UDim2.new(0.5, 4, 1, -48),
			BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255),
			BackgroundTransparency = 0,
			Text = "Verify Key",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
	end

	local TweenService = game:GetService("TweenService")
	
	GetKeyButton.MouseEnter:Connect(function()
		TweenService:Create(GetKeyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55, 55, 55) }):Play()
	end)
	GetKeyButton.MouseLeave:Connect(function()
		TweenService:Create(GetKeyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
	end)

	if DiscordButton then
		DiscordButton.MouseEnter:Connect(function()
			TweenService:Create(DiscordButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55, 55, 55) }):Play()
		end)
		DiscordButton.MouseLeave:Connect(function()
			TweenService:Create(DiscordButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
		end)
		DiscordButton.Activated:Connect(function()
			if setclipboard then
				setclipboard(Config.Discord)
				Library:Notify({
					Title = "Discord Link",
					Content = "Discord invite link copied to clipboard!",
					Type = "Success",
					Duration = 3
				})
			else
				Library:Notify({
					Title = "Discord Link",
					Content = "Your executor does not support setclipboard.",
					Type = "Error",
					Duration = 3
				})
			end
		end)
	end

	VerifyButton.MouseEnter:Connect(function()
		TweenService:Create(VerifyButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
	end)
	VerifyButton.MouseLeave:Connect(function()
		TweenService:Create(VerifyButton, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
	end)

	local Attempts = 0
	local MaxAttempts = Config.MaxAttempts or 5
	local LockoutDuration = Config.LockoutDuration or 60
	local IsLocked = false
	local IsVerifying = false

	local function SetInputEnabled(Enabled)
		Input.TextEditable = Enabled
	end

	local function StartLockout()
		IsLocked = true
		SetInputEnabled(false)
		local TimeLeft = LockoutDuration
		task.spawn(function()
			while TimeLeft > 0 do
				VerifyButton.Text = "Locked (" .. tostring(TimeLeft) .. "s)"
				VerifyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				VerifyButton.TextColor3 = Color3.fromRGB(150, 150, 150)
				task.wait(1)
				TimeLeft = TimeLeft - 1
			end
			IsLocked = false
			Attempts = 0
			SetInputEnabled(true)
			VerifyButton.Text = "Verify Key"
			VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255)
			VerifyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		end)
	end

	local function VerifyKey(Key)
		if Key == "" or Key == nil then return false end
		
		if Config.Preset and Presets[Config.Preset] then
			return Presets[Config.Preset](Key, Config.PresetConfig or {})
		elseif Config.Callback then
			local success, res = pcall(Config.Callback, Key)
			return success and res == true
		elseif Config.Key and Key == Config.Key then
			return true
		elseif Config.Keys then
			for _, k in ipairs(Config.Keys) do
				if Key == tostring(k) then
					return true
				end
			end
		end
		return false
	end

	local function Verify(KeyOverride)
		if IsLocked or IsVerifying then return end
		
		local Entered = KeyOverride or Input.Text
		if Entered == "" then
			Library:Notify({
				Title = "Key System",
				Content = "Please enter a key first.",
				Type = "Warning",
				Duration = 3
			})
			return
		end

		IsVerifying = true
		SetInputEnabled(false)
		VerifyButton.Text = "Verifying..."
		VerifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		VerifyButton.TextColor3 = Color3.fromRGB(150, 150, 150)

		task.spawn(function()
			local Correct = VerifyKey(Entered)
			
			if Correct then
				if SaveKey then
					local writefile = writefile or (io and io.write)
					if writefile then
						pcall(writefile, SavePath, Entered)
					end
				end

				Library:Notify({
					Title = "Key System",
					Content = "Access granted! Loading UI...",
					Type = "Success",
					Duration = 3
				})

				local FadeTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(Title, FadeTweenInfo, { TextTransparency = 1 }):Play()
				TweenService:Create(SubTitle, FadeTweenInfo, { TextTransparency = 1 }):Play()
				TweenService:Create(TextboxFrame, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
				TweenService:Create(Input, FadeTweenInfo, { TextTransparency = 1 }):Play()
				TweenService:Create(GetKeyButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
				if DiscordButton then
					TweenService:Create(DiscordButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
				end
				TweenService:Create(VerifyButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
				TweenService:Create(UIStroke, FadeTweenInfo, { Transparency = 1 }):Play()

				local FrameScale = New("UIScale", { Scale = 1, Parent = KeySystemPaint.Frame })
				TweenService:Create(FrameScale, FadeTweenInfo, { Scale = 1.05 }):Play()

				task.wait(0.3)
				KeySystemGui:Destroy()
				
				task.spawn(Config.OnVerified)
			else
				IsVerifying = false
				SetInputEnabled(true)
				VerifyButton.Text = "Verify Key"
				VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255)
				VerifyButton.TextColor3 = Color3.fromRGB(0, 0, 0)

				local Stroke = TextboxFrame:FindFirstChildOfClass("UIStroke")
				if Stroke then
					Stroke.Color = Color3.fromRGB(245, 115, 115)
					task.spawn(function()
						task.wait(1.5)
						if Stroke.Parent then
							Stroke.Color = Color3.fromRGB(60, 60, 60)
						end
					end)
				end

				local OriginalPos = KeySystemFrame.Position
				task.spawn(function()
					for i = 1, 6 do
						local OffsetX = (i % 2 == 0) and 8 or -8
						KeySystemFrame.Position = OriginalPos + UDim2.fromOffset(OffsetX, 0)
						task.wait(0.04)
					end
					KeySystemFrame.Position = OriginalPos
				end)

				Attempts = Attempts + 1
				if Config.BruteForceProtection ~= false and Attempts >= MaxAttempts then
					StartLockout()
					Library:Notify({
						Title = "Key System",
						Content = "Too many wrong attempts! Locked for " .. tostring(LockoutDuration) .. "s.",
						Type = "Error",
						Duration = 5
					})
				else
					Library:Notify({
						Title = "Key System",
						Content = "Invalid key. Attempts: " .. tostring(Attempts) .. "/" .. tostring(MaxAttempts),
						Type = "Error",
						Duration = 3
					})
				end
			end
		end)
	end

	VerifyButton.Activated:Connect(function()
		Verify()
	end)
	
	GetKeyButton.Activated:Connect(function()
		if Config.GetKeyLink then
			if setclipboard then
				setclipboard(Config.GetKeyLink)
				Library:Notify({
					Title = "Key System",
					Content = "Key link copied to clipboard!",
					Type = "Success",
					Duration = 3
				})
			else
				Library:Notify({
					Title = "Key System",
					Content = "Your executor does not support setclipboard.",
					Type = "Error",
					Duration = 3
				})
			end
		else
			Library:Notify({
				Title = "Key System",
				Content = "No key link provided.",
				Type = "Warning",
				Duration = 3
			})
		end
	end)

	Input.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			Verify()
		end
	end)

	if SavedKey ~= "" then
		Input.Text = SavedKey
		Verify(SavedKey)
	end
end

if getgenv then
	getgenv().Fluent = Library
	getgenv().CoreX = Library
end

return Library

end)

register("Packages.Flipper.BaseMotor", function()
local script = create_mock_script("Packages.Flipper.BaseMotor")
local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)

local noop = function() end

local BaseMotor = {}
BaseMotor.__index = BaseMotor

function BaseMotor.new()
	return setmetatable({
		_onStep = Signal.new(),
		_onStart = Signal.new(),
		_onComplete = Signal.new(),
	}, BaseMotor)
end

function BaseMotor:onStep(handler)
	return self._onStep:connect(handler)
end

function BaseMotor:onStart(handler)
	return self._onStart:connect(handler)
end

function BaseMotor:onComplete(handler)
	return self._onComplete:connect(handler)
end

function BaseMotor:start()
	if not self._connection then
		self._connection = RunService.RenderStepped:Connect(function(deltaTime)
			self:step(deltaTime)
		end)
	end
end

function BaseMotor:stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

BaseMotor.destroy = BaseMotor.stop

BaseMotor.step = noop
BaseMotor.getValue = noop
BaseMotor.setGoal = noop

function BaseMotor:__tostring()
	return "Motor"
end

return BaseMotor

end)

register("Packages.Flipper.BaseMotor.spec", function()
local script = create_mock_script("Packages.Flipper.BaseMotor.spec")
return function()
	local RunService = game:GetService("RunService")

	local BaseMotor = require(script.Parent.BaseMotor)

	describe("connection management", function()
		local motor = BaseMotor.new()

		it("should hook up connections on :start()", function()
			motor:start()
			expect(typeof(motor._connection)).to.equal("RBXScriptConnection")
		end)

		it("should remove connections on :stop() or :destroy()", function()
			motor:stop()
			expect(motor._connection).to.equal(nil)
		end)
	end)

	it("should call :step() with deltaTime", function()
		local motor = BaseMotor.new()

		local argumentsProvided
		function motor:step(...)
			argumentsProvided = { ... }
			motor:stop()
		end

		motor:start()

		local expectedDeltaTime = RunService.RenderStepped:Wait()

		-- Give it another frame, because connections tend to be invoked later than :Wait() calls
		RunService.RenderStepped:Wait()

		expect(argumentsProvided).to.be.ok()
		expect(argumentsProvided[1]).to.equal(expectedDeltaTime)
	end)
end

end)

register("Packages.Flipper.GroupMotor", function()
local script = create_mock_script("Packages.Flipper.GroupMotor")
local BaseMotor = require(script.Parent.BaseMotor)
local SingleMotor = require(script.Parent.SingleMotor)

local isMotor = require(script.Parent.isMotor)

local GroupMotor = setmetatable({}, BaseMotor)
GroupMotor.__index = GroupMotor

local function toMotor(value)
	if isMotor(value) then
		return value
	end

	local valueType = typeof(value)

	if valueType == "number" then
		return SingleMotor.new(value, false)
	elseif valueType == "table" then
		return GroupMotor.new(value, false)
	end

	error(("Unable to convert %q to motor; type %s is unsupported"):format(value, valueType), 2)
end

function GroupMotor.new(initialValues, useImplicitConnections)
	assert(initialValues, "Missing argument #1: initialValues")
	assert(typeof(initialValues) == "table", "initialValues must be a table!")
	assert(
		not initialValues.step,
		'initialValues contains disallowed property "step". Did you mean to put a table of values here?'
	)

	local self = setmetatable(BaseMotor.new(), GroupMotor)

	if useImplicitConnections ~= nil then
		self._useImplicitConnections = useImplicitConnections
	else
		self._useImplicitConnections = true
	end

	self._complete = true
	self._motors = {}

	for key, value in pairs(initialValues) do
		self._motors[key] = toMotor(value)
	end

	return self
end

function GroupMotor:step(deltaTime)
	if self._complete then
		return true
	end

	local allMotorsComplete = true

	for _, motor in pairs(self._motors) do
		local complete = motor:step(deltaTime)
		if not complete then
			-- If any of the sub-motors are incomplete, the group motor will not be complete either
			allMotorsComplete = false
		end
	end

	self._onStep:fire(self:getValue())

	if allMotorsComplete then
		if self._useImplicitConnections then
			self:stop()
		end

		self._complete = true
		self._onComplete:fire()
	end

	return allMotorsComplete
end

function GroupMotor:setGoal(goals)
	assert(not goals.step, 'goals contains disallowed property "step". Did you mean to put a table of goals here?')

	self._complete = false
	self._onStart:fire()

	for key, goal in pairs(goals) do
		local motor = assert(self._motors[key], ("Unknown motor for key %s"):format(key))
		motor:setGoal(goal)
	end

	if self._useImplicitConnections then
		self:start()
	end
end

function GroupMotor:getValue()
	local values = {}

	for key, motor in pairs(self._motors) do
		values[key] = motor:getValue()
	end

	return values
end

function GroupMotor:__tostring()
	return "Motor(Group)"
end

return GroupMotor

end)

register("Packages.Flipper.GroupMotor.spec", function()
local script = create_mock_script("Packages.Flipper.GroupMotor.spec")
return function()
	local GroupMotor = require(script.Parent.GroupMotor)

	local Instant = require(script.Parent.Instant)
	local Spring = require(script.Parent.Spring)

	it("should complete when all child motors are complete", function()
		local motor = GroupMotor.new({
			A = 1,
			B = 2,
		}, false)

		expect(motor._complete).to.equal(true)

		motor:setGoal({
			A = Instant.new(3),
			B = Spring.new(4, { frequency = 7.5, dampingRatio = 1 }),
		})

		expect(motor._complete).to.equal(false)

		motor:step(1 / 60)

		expect(motor._complete).to.equal(false)

		for _ = 1, 0.5 * 60 do
			motor:step(1 / 60)
		end

		expect(motor._complete).to.equal(true)
	end)

	it("should start when the goal is set", function()
		local motor = GroupMotor.new({
			A = 0,
		}, false)

		local bool = false
		motor:onStart(function()
			bool = not bool
		end)

		motor:setGoal({
			A = Instant.new(1),
		})

		expect(bool).to.equal(true)

		motor:setGoal({
			A = Instant.new(1),
		})

		expect(bool).to.equal(false)
	end)

	it("should properly return all values", function()
		local motor = GroupMotor.new({
			A = 1,
			B = 2,
		}, false)

		local value = motor:getValue()

		expect(value.A).to.equal(1)
		expect(value.B).to.equal(2)
	end)

	it("should error when a goal is given to GroupMotor.new", function()
		local success = pcall(function()
			GroupMotor.new(Instant.new(0))
		end)

		expect(success).to.equal(false)
	end)

	it("should error when a single goal is provided to GroupMotor:step", function()
		local success = pcall(function()
			GroupMotor.new({ a = 1 }):setGoal(Instant.new(0))
		end)

		expect(success).to.equal(false)
	end)
end

end)

register("Packages.Flipper", function()
local script = create_mock_script("Packages.Flipper")
local Flipper = {
	SingleMotor = require(script.SingleMotor),
	GroupMotor = require(script.GroupMotor),

	Instant = require(script.Instant),
	Linear = require(script.Linear),
	Spring = require(script.Spring),

	isMotor = require(script.isMotor),
}

return Flipper

end)

register("Packages.Flipper.Instant", function()
local script = create_mock_script("Packages.Flipper.Instant")
local Instant = {}
Instant.__index = Instant

function Instant.new(targetValue)
	return setmetatable({
		_targetValue = targetValue,
	}, Instant)
end

function Instant:step()
	return {
		complete = true,
		value = self._targetValue,
	}
end

return Instant

end)

register("Packages.Flipper.Instant.spec", function()
local script = create_mock_script("Packages.Flipper.Instant.spec")
return function()
	local Instant = require(script.Parent.Instant)

	it("should return a completed state with the provided value", function()
		local goal = Instant.new(1.23)
		local state = goal:step(0.1, { value = 0, complete = false })
		expect(state.complete).to.equal(true)
		expect(state.value).to.equal(1.23)
	end)
end

end)

register("Packages.Flipper.isMotor", function()
local script = create_mock_script("Packages.Flipper.isMotor")
local function isMotor(value)
	local motorType = tostring(value):match("^Motor%((.+)%)$")

	if motorType then
		return true, motorType
	else
		return false
	end
end

return isMotor

end)

register("Packages.Flipper.isMotor.spec", function()
local script = create_mock_script("Packages.Flipper.isMotor.spec")
return function()
	local isMotor = require(script.Parent.isMotor)

	local SingleMotor = require(script.Parent.SingleMotor)
	local GroupMotor = require(script.Parent.GroupMotor)

	local singleMotor = SingleMotor.new(0)
	local groupMotor = GroupMotor.new({})

	it("should properly detect motors", function()
		expect(isMotor(singleMotor)).to.equal(true)
		expect(isMotor(groupMotor)).to.equal(true)
	end)

	it("shouldn't detect things that aren't motors", function()
		expect(isMotor({})).to.equal(false)
	end)

	it("should return the proper motor type", function()
		local _, singleMotorType = isMotor(singleMotor)
		local _, groupMotorType = isMotor(groupMotor)

		expect(singleMotorType).to.equal("Single")
		expect(groupMotorType).to.equal("Group")
	end)
end

end)

register("Packages.Flipper.Linear", function()
local script = create_mock_script("Packages.Flipper.Linear")
local Linear = {}
Linear.__index = Linear

function Linear.new(targetValue, options)
	assert(targetValue, "Missing argument #1: targetValue")

	options = options or {}

	return setmetatable({
		_targetValue = targetValue,
		_velocity = options.velocity or 1,
	}, Linear)
end

function Linear:step(state, dt)
	local position = state.value
	local velocity = self._velocity -- Linear motion ignores the state's velocity
	local goal = self._targetValue

	local dPos = dt * velocity

	local complete = dPos >= math.abs(goal - position)
	position = position + dPos * (goal > position and 1 or -1)
	if complete then
		position = self._targetValue
		velocity = 0
	end

	return {
		complete = complete,
		value = position,
		velocity = velocity,
	}
end

return Linear

end)

register("Packages.Flipper.Linear.spec", function()
local script = create_mock_script("Packages.Flipper.Linear.spec")
return function()
	local SingleMotor = require(script.Parent.SingleMotor)
	local Linear = require(script.Parent.Linear)

	describe("completed state", function()
		local motor = SingleMotor.new(0, false)

		local goal = Linear.new(1, { velocity = 1 })
		motor:setGoal(goal)

		for _ = 1, 60 do
			motor:step(1 / 60)
		end

		it("should complete", function()
			expect(motor._state.complete).to.equal(true)
		end)

		it("should be exactly the goal value when completed", function()
			expect(motor._state.value).to.equal(1)
		end)
	end)

	describe("uncompleted state", function()
		local motor = SingleMotor.new(0, false)

		local goal = Linear.new(1, { velocity = 1 })
		motor:setGoal(goal)

		for _ = 1, 59 do
			motor:step(1 / 60)
		end

		it("should be uncomplete", function()
			expect(motor._state.complete).to.equal(false)
		end)
	end)

	describe("negative velocity", function()
		local motor = SingleMotor.new(1, false)

		local goal = Linear.new(0, { velocity = 1 })
		motor:setGoal(goal)

		for _ = 1, 60 do
			motor:step(1 / 60)
		end

		it("should complete", function()
			expect(motor._state.complete).to.equal(true)
		end)

		it("should be exactly the goal value when completed", function()
			expect(motor._state.value).to.equal(0)
		end)
	end)
end

end)

register("Packages.Flipper.Signal", function()
local script = create_mock_script("Packages.Flipper.Signal")
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, handler)
	return setmetatable({
		signal = signal,
		connected = true,
		_handler = handler,
	}, Connection)
end

function Connection:disconnect()
	if self.connected then
		self.connected = false

		for index, connection in pairs(self.signal._connections) do
			if connection == self then
				table.remove(self.signal._connections, index)
				return
			end
		end
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {},
		_threads = {},
	}, Signal)
end

function Signal:fire(...)
	for _, connection in pairs(self._connections) do
		connection._handler(...)
	end

	for _, thread in pairs(self._threads) do
		coroutine.resume(thread, ...)
	end

	self._threads = {}
end

function Signal:connect(handler)
	local connection = Connection.new(self, handler)
	table.insert(self._connections, connection)
	return connection
end

function Signal:wait()
	table.insert(self._threads, coroutine.running())
	return coroutine.yield()
end

return Signal

end)

register("Packages.Flipper.Signal.spec", function()
local script = create_mock_script("Packages.Flipper.Signal.spec")
return function()
	local Signal = require(script.Parent.Signal)

	it("should invoke all connections, instantly", function()
		local signal = Signal.new()

		local a, b

		signal:connect(function(value)
			a = value
		end)

		signal:connect(function(value)
			b = value
		end)

		signal:fire("hello")

		expect(a).to.equal("hello")
		expect(b).to.equal("hello")
	end)

	it("should return values when :wait() is called", function()
		local signal = Signal.new()

		spawn(function()
			signal:fire(123, "hello")
		end)

		local a, b = signal:wait()

		expect(a).to.equal(123)
		expect(b).to.equal("hello")
	end)

	it("should properly handle disconnections", function()
		local signal = Signal.new()

		local didRun = false

		local connection = signal:connect(function()
			didRun = true
		end)
		connection:disconnect()

		signal:fire()
		expect(didRun).to.equal(false)
	end)
end

end)

register("Packages.Flipper.SingleMotor", function()
local script = create_mock_script("Packages.Flipper.SingleMotor")
local BaseMotor = require(script.Parent.BaseMotor)

local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.__index = SingleMotor

function SingleMotor.new(initialValue, useImplicitConnections)
	assert(initialValue, "Missing argument #1: initialValue")
	assert(typeof(initialValue) == "number", "initialValue must be a number!")

	local self = setmetatable(BaseMotor.new(), SingleMotor)

	if useImplicitConnections ~= nil then
		self._useImplicitConnections = useImplicitConnections
	else
		self._useImplicitConnections = true
	end

	self._goal = nil
	self._state = {
		complete = true,
		value = initialValue,
	}

	return self
end

function SingleMotor:step(deltaTime)
	if self._state.complete then
		return true
	end

	local newState = self._goal:step(self._state, deltaTime)

	self._state = newState
	self._onStep:fire(newState.value)

	if newState.complete then
		if self._useImplicitConnections then
			self:stop()
		end

		self._onComplete:fire()
	end

	return newState.complete
end

function SingleMotor:getValue()
	return self._state.value
end

function SingleMotor:setGoal(goal)
	self._state.complete = false
	self._goal = goal

	self._onStart:fire()

	if self._useImplicitConnections then
		self:start()
	end
end

function SingleMotor:__tostring()
	return "Motor(Single)"
end

return SingleMotor

end)

register("Packages.Flipper.SingleMotor.spec", function()
local script = create_mock_script("Packages.Flipper.SingleMotor.spec")
return function()
	local SingleMotor = require(script.Parent.SingleMotor)
	local Instant = require(script.Parent.Instant)

	it("should assign new state on step", function()
		local motor = SingleMotor.new(0, false)

		motor:setGoal(Instant.new(5))
		motor:step(1 / 60)

		expect(motor._state.complete).to.equal(true)
		expect(motor._state.value).to.equal(5)
	end)

	it("should invoke onComplete listeners when the goal is completed", function()
		local motor = SingleMotor.new(0, false)

		local didComplete = false
		motor:onComplete(function()
			didComplete = true
		end)

		motor:setGoal(Instant.new(5))
		motor:step(1 / 60)

		expect(didComplete).to.equal(true)
	end)

	it("should start when the goal is set", function()
		local motor = SingleMotor.new(0, false)

		local bool = false
		motor:onStart(function()
			bool = not bool
		end)

		motor:setGoal(Instant.new(5))

		expect(bool).to.equal(true)

		motor:setGoal(Instant.new(5))

		expect(bool).to.equal(false)
	end)
end

end)

register("Packages.Flipper.Spring", function()
local script = create_mock_script("Packages.Flipper.Spring")
local VELOCITY_THRESHOLD = 0.001
local POSITION_THRESHOLD = 0.001

local EPS = 0.0001

local Spring = {}
Spring.__index = Spring

function Spring.new(targetValue, options)
	assert(targetValue, "Missing argument #1: targetValue")
	options = options or {}

	return setmetatable({
		_targetValue = targetValue,
		_frequency = options.frequency or 4,
		_dampingRatio = options.dampingRatio or 1,
	}, Spring)
end

function Spring:step(state, dt)
	-- Copyright 2018 Parker Stebbins (parker@fractality.io)
	-- github.com/Fraktality/Spring
	-- Distributed under the MIT license

	local d = self._dampingRatio
	local f = self._frequency * 2 * math.pi
	local g = self._targetValue
	local p0 = state.value
	local v0 = state.velocity or 0

	local offset = p0 - g
	local decay = math.exp(-d * f * dt)

	local p1, v1

	if d == 1 then -- Critically damped
		p1 = (offset * (1 + f * dt) + v0 * dt) * decay + g
		v1 = (v0 * (1 - f * dt) - offset * (f * f * dt)) * decay
	elseif d < 1 then -- Underdamped
		local c = math.sqrt(1 - d * d)

		local i = math.cos(f * c * dt)
		local j = math.sin(f * c * dt)

		-- Damping ratios approaching 1 can cause division by small numbers.
		-- To fix that, group terms around z=j/c and find an approximation for z.
		-- Start with the definition of z:
		--    z = sin(dt*f*c)/c
		-- Substitute a=dt*f:
		--    z = sin(a*c)/c
		-- Take the Maclaurin expansion of z with respect to c:
		--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
		--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
		-- Rewrite in Horner form:
		--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

		local z
		if c > EPS then
			z = j / c
		else
			local a = dt * f
			z = a + ((a * a) * (c * c) * (c * c) / 20 - c * c) * (a * a * a) / 6
		end

		-- Frequencies approaching 0 present a similar problem.
		-- We want an approximation for y as f approaches 0, where:
		--    y = sin(dt*f*c)/(f*c)
		-- Substitute b=dt*c:
		--    y = sin(b*c)/b
		-- Now reapply the process from z.

		local y
		if f * c > EPS then
			y = j / (f * c)
		else
			local b = f * c
			y = dt + ((dt * dt) * (b * b) * (b * b) / 20 - b * b) * (dt * dt * dt) / 6
		end

		p1 = (offset * (i + d * z) + v0 * y) * decay + g
		v1 = (v0 * (i - z * d) - offset * (z * f)) * decay
	else -- Overdamped
		local c = math.sqrt(d * d - 1)

		local r1 = -f * (d - c)
		local r2 = -f * (d + c)

		local co2 = (v0 - offset * r1) / (2 * f * c)
		local co1 = offset - co2

		local e1 = co1 * math.exp(r1 * dt)
		local e2 = co2 * math.exp(r2 * dt)

		p1 = e1 + e2 + g
		v1 = e1 * r1 + e2 * r2
	end

	local complete = math.abs(v1) < VELOCITY_THRESHOLD and math.abs(p1 - g) < POSITION_THRESHOLD

	return {
		complete = complete,
		value = complete and g or p1,
		velocity = v1,
	}
end

return Spring

end)

register("Packages.Flipper.Spring.spec", function()
local script = create_mock_script("Packages.Flipper.Spring.spec")
return function()
	local SingleMotor = require(script.Parent.SingleMotor)
	local Spring = require(script.Parent.Spring)

	describe("completed state", function()
		local motor = SingleMotor.new(0, false)

		local goal = Spring.new(1, { frequency = 2, dampingRatio = 0.75 })
		motor:setGoal(goal)

		for _ = 1, 100 do
			motor:step(1 / 60)
		end

		it("should complete", function()
			expect(motor._state.complete).to.equal(true)
		end)

		it("should be exactly the goal value when completed", function()
			expect(motor._state.value).to.equal(1)
		end)
	end)

	it("should inherit velocity", function()
		local motor = SingleMotor.new(0, false)
		motor._state = { complete = false, value = 0, velocity = -5 }

		local goal = Spring.new(1, { frequency = 2, dampingRatio = 1 })

		motor:setGoal(goal)
		motor:step(1 / 60)

		expect(motor._state.velocity < 0).to.equal(true)
	end)
end

end)

register("Themes.Amethyst", function()
local script = create_mock_script("Themes.Amethyst")
return {
	Name = "Amethyst",
	Accent = Color3.fromRGB(97, 62, 167),

	AcrylicMain = Color3.fromRGB(20, 20, 20),
	AcrylicBorder = Color3.fromRGB(110, 90, 130),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(85, 57, 139), Color3.fromRGB(40, 25, 65)),
	AcrylicNoise = 0.92,

	TitleBarLine = Color3.fromRGB(95, 75, 110),
	Tab = Color3.fromRGB(160, 140, 180),

	Element = Color3.fromRGB(140, 120, 160),
	ElementBorder = Color3.fromRGB(60, 50, 70),
	InElementBorder = Color3.fromRGB(100, 90, 110),
	ElementTransparency = 0.87,

	ToggleSlider = Color3.fromRGB(140, 120, 160),
	ToggleToggled = Color3.fromRGB(0, 0, 0),

	SliderRail = Color3.fromRGB(140, 120, 160),

	DropdownFrame = Color3.fromRGB(170, 160, 200),
	DropdownHolder = Color3.fromRGB(60, 45, 80),
	DropdownBorder = Color3.fromRGB(50, 40, 65),
	DropdownOption = Color3.fromRGB(140, 120, 160),

	Keybind = Color3.fromRGB(140, 120, 160),

	Input = Color3.fromRGB(140, 120, 160),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),

	Dialog = Color3.fromRGB(60, 45, 80),
	DialogHolder = Color3.fromRGB(45, 30, 65),
	DialogHolderLine = Color3.fromRGB(40, 25, 60),
	DialogButton = Color3.fromRGB(60, 45, 80),
	DialogButtonBorder = Color3.fromRGB(95, 80, 110),
	DialogBorder = Color3.fromRGB(85, 70, 100),
	DialogInput = Color3.fromRGB(70, 55, 85),
	DialogInputLine = Color3.fromRGB(175, 160, 190),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(140, 120, 160),
	HoverChange = 0.04,
}

end)

register("Themes.Aqua", function()
local script = create_mock_script("Themes.Aqua")
return {
	Name = "Aqua",
	Accent = Color3.fromRGB(60, 165, 165),

	AcrylicMain = Color3.fromRGB(20, 20, 20),
	AcrylicBorder = Color3.fromRGB(50, 100, 100),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(60, 140, 140), Color3.fromRGB(40, 80, 80)),
	AcrylicNoise = 0.92,

	TitleBarLine = Color3.fromRGB(60, 120, 120),
	Tab = Color3.fromRGB(140, 180, 180),

	Element = Color3.fromRGB(110, 160, 160),
	ElementBorder = Color3.fromRGB(40, 70, 70),
	InElementBorder = Color3.fromRGB(80, 110, 110),
	ElementTransparency = 0.84,

	ToggleSlider = Color3.fromRGB(110, 160, 160),
	ToggleToggled = Color3.fromRGB(0, 0, 0),

	SliderRail = Color3.fromRGB(110, 160, 160),

	DropdownFrame = Color3.fromRGB(160, 200, 200),
	DropdownHolder = Color3.fromRGB(40, 80, 80),
	DropdownBorder = Color3.fromRGB(40, 65, 65),
	DropdownOption = Color3.fromRGB(110, 160, 160),

	Keybind = Color3.fromRGB(110, 160, 160),

	Input = Color3.fromRGB(110, 160, 160),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(130, 170, 170),

	Dialog = Color3.fromRGB(40, 80, 80),
	DialogHolder = Color3.fromRGB(30, 60, 60),
	DialogHolderLine = Color3.fromRGB(25, 50, 50),
	DialogButton = Color3.fromRGB(40, 80, 80),
	DialogButtonBorder = Color3.fromRGB(80, 110, 110),
	DialogBorder = Color3.fromRGB(50, 100, 100),
	DialogInput = Color3.fromRGB(45, 90, 90),
	DialogInputLine = Color3.fromRGB(130, 170, 170),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(110, 160, 160),
	HoverChange = 0.04,
}

end)

register("Themes.Dark", function()
local script = create_mock_script("Themes.Dark")
return {
	Name = "Dark",
	Accent = Color3.fromRGB(96, 205, 255),

	AcrylicMain = Color3.fromRGB(60, 60, 60),
	AcrylicBorder = Color3.fromRGB(90, 90, 90),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
	AcrylicNoise = 0.9,

	TitleBarLine = Color3.fromRGB(75, 75, 75),
	Tab = Color3.fromRGB(120, 120, 120),

	Element = Color3.fromRGB(120, 120, 120),
	ElementBorder = Color3.fromRGB(35, 35, 35),
	InElementBorder = Color3.fromRGB(90, 90, 90),
	ElementTransparency = 0.87,

	ToggleSlider = Color3.fromRGB(120, 120, 120),
	ToggleToggled = Color3.fromRGB(0, 0, 0),

	SliderRail = Color3.fromRGB(120, 120, 120),

	DropdownFrame = Color3.fromRGB(160, 160, 160),
	DropdownHolder = Color3.fromRGB(45, 45, 45),
	DropdownBorder = Color3.fromRGB(35, 35, 35),
	DropdownOption = Color3.fromRGB(120, 120, 120),

	Keybind = Color3.fromRGB(120, 120, 120),

	Input = Color3.fromRGB(160, 160, 160),
	InputFocused = Color3.fromRGB(10, 10, 10),
	InputIndicator = Color3.fromRGB(150, 150, 150),

	Dialog = Color3.fromRGB(45, 45, 45),
	DialogHolder = Color3.fromRGB(35, 35, 35),
	DialogHolderLine = Color3.fromRGB(30, 30, 30),
	DialogButton = Color3.fromRGB(45, 45, 45),
	DialogButtonBorder = Color3.fromRGB(80, 80, 80),
	DialogBorder = Color3.fromRGB(70, 70, 70),
	DialogInput = Color3.fromRGB(55, 55, 55),
	DialogInputLine = Color3.fromRGB(160, 160, 160),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(120, 120, 120),
	HoverChange = 0.07,
}

end)

register("Themes.Darker", function()
local script = create_mock_script("Themes.Darker")
return {
	Name = "Darker",
	Accent = Color3.fromRGB(72, 138, 182),

	AcrylicMain = Color3.fromRGB(30, 30, 30),
	AcrylicBorder = Color3.fromRGB(60, 60, 60),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(15, 15, 15)),
	AcrylicNoise = 0.94,

	TitleBarLine = Color3.fromRGB(65, 65, 65),
	Tab = Color3.fromRGB(100, 100, 100),

	Element = Color3.fromRGB(70, 70, 70),
	ElementBorder = Color3.fromRGB(25, 25, 25),
	InElementBorder = Color3.fromRGB(55, 55, 55),
	ElementTransparency = 0.82,

	DropdownFrame = Color3.fromRGB(120, 120, 120),
	DropdownHolder = Color3.fromRGB(35, 35, 35),
	DropdownBorder = Color3.fromRGB(25, 25, 25),

	Dialog = Color3.fromRGB(35, 35, 35),
	DialogHolder = Color3.fromRGB(25, 25, 25),
	DialogHolderLine = Color3.fromRGB(20, 20, 20),
	DialogButton = Color3.fromRGB(35, 35, 35),
	DialogButtonBorder = Color3.fromRGB(55, 55, 55),
	DialogBorder = Color3.fromRGB(50, 50, 50),
	DialogInput = Color3.fromRGB(45, 45, 45),
	DialogInputLine = Color3.fromRGB(120, 120, 120),
}

end)

register("Themes", function()
local script = create_mock_script("Themes")

local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose",
	},
}

Themes["Dark"] = require("Themes.Dark")
Themes["Darker"] = require("Themes.Darker")
Themes["Light"] = require("Themes.Light")
Themes["Aqua"] = require("Themes.Aqua")
Themes["Amethyst"] = require("Themes.Amethyst")
Themes["Rose"] = require("Themes.Rose")

return Themes

end)

register("Themes.Light", function()
local script = create_mock_script("Themes.Light")
return {
	Name = "Light",
	Accent = Color3.fromRGB(0, 103, 192),

	AcrylicMain = Color3.fromRGB(200, 200, 200),
	AcrylicBorder = Color3.fromRGB(120, 120, 120),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
	AcrylicNoise = 0.96,

	TitleBarLine = Color3.fromRGB(160, 160, 160),
	Tab = Color3.fromRGB(90, 90, 90),

	Element = Color3.fromRGB(255, 255, 255),
	ElementBorder = Color3.fromRGB(180, 180, 180),
	InElementBorder = Color3.fromRGB(150, 150, 150),
	ElementTransparency = 0.65,

	ToggleSlider = Color3.fromRGB(40, 40, 40),
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(40, 40, 40),

	DropdownFrame = Color3.fromRGB(200, 200, 200),
	DropdownHolder = Color3.fromRGB(240, 240, 240),
	DropdownBorder = Color3.fromRGB(200, 200, 200),
	DropdownOption = Color3.fromRGB(150, 150, 150),

	Keybind = Color3.fromRGB(120, 120, 120),

	Input = Color3.fromRGB(200, 200, 200),
	InputFocused = Color3.fromRGB(100, 100, 100),
	InputIndicator = Color3.fromRGB(80, 80, 80),

	Dialog = Color3.fromRGB(255, 255, 255),
	DialogHolder = Color3.fromRGB(240, 240, 240),
	DialogHolderLine = Color3.fromRGB(228, 228, 228),
	DialogButton = Color3.fromRGB(255, 255, 255),
	DialogButtonBorder = Color3.fromRGB(190, 190, 190),
	DialogBorder = Color3.fromRGB(140, 140, 140),
	DialogInput = Color3.fromRGB(250, 250, 250),
	DialogInputLine = Color3.fromRGB(160, 160, 160),

	Text = Color3.fromRGB(0, 0, 0),
	SubText = Color3.fromRGB(40, 40, 40),
	Hover = Color3.fromRGB(50, 50, 50),
	HoverChange = 0.16,
}

end)

register("Themes.Rose", function()
local script = create_mock_script("Themes.Rose")
return {
	Name = "Rose",
	Accent = Color3.fromRGB(180, 55, 90),

	AcrylicMain = Color3.fromRGB(40, 40, 40),
	AcrylicBorder = Color3.fromRGB(130, 90, 110),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(190, 60, 135), Color3.fromRGB(165, 50, 70)),
	AcrylicNoise = 0.92,

	TitleBarLine = Color3.fromRGB(140, 85, 105),
	Tab = Color3.fromRGB(180, 140, 160),

	Element = Color3.fromRGB(200, 120, 170),
	ElementBorder = Color3.fromRGB(110, 70, 85),
	InElementBorder = Color3.fromRGB(120, 90, 90),
	ElementTransparency = 0.86,

	ToggleSlider = Color3.fromRGB(200, 120, 170),
	ToggleToggled = Color3.fromRGB(0, 0, 0),

	SliderRail = Color3.fromRGB(200, 120, 170),

	DropdownFrame = Color3.fromRGB(200, 160, 180),
	DropdownHolder = Color3.fromRGB(120, 50, 75),
	DropdownBorder = Color3.fromRGB(90, 40, 55),
	DropdownOption = Color3.fromRGB(200, 120, 170),

	Keybind = Color3.fromRGB(200, 120, 170),

	Input = Color3.fromRGB(200, 120, 170),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),

	Dialog = Color3.fromRGB(120, 50, 75),
	DialogHolder = Color3.fromRGB(95, 40, 60),
	DialogHolderLine = Color3.fromRGB(90, 35, 55),
	DialogButton = Color3.fromRGB(120, 50, 75),
	DialogButtonBorder = Color3.fromRGB(155, 90, 115),
	DialogBorder = Color3.fromRGB(100, 70, 90),
	DialogInput = Color3.fromRGB(135, 55, 80),
	DialogInputLine = Color3.fromRGB(190, 160, 180),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(200, 120, 170),
	HoverChange = 0.04,
}

end)

register("ThemeValidator", function()
local script = create_mock_script("ThemeValidator")
--!strict

export type ContrastIssue = {
	Foreground: string,
	Background: string,
	Ratio: number,
	Minimum: number,
}

export type ContrastReport = {
	Theme: string,
	Passed: boolean,
	Minimum: number,
	Issues: { ContrastIssue },
	Ratios: { [string]: number },
}

local ThemeValidator = {}

local function Linearize(Value: number): number
	if Value <= 0.04045 then
		return Value / 12.92
	end
	return ((Value + 0.055) / 1.055) ^ 2.4
end

function ThemeValidator.GetLuminance(Color: Color3): number
	return 0.2126 * Linearize(Color.R)
		+ 0.7152 * Linearize(Color.G)
		+ 0.0722 * Linearize(Color.B)
end

function ThemeValidator.GetContrastRatio(Foreground: Color3, Background: Color3): number
	local ForegroundLuminance = ThemeValidator.GetLuminance(Foreground)
	local BackgroundLuminance = ThemeValidator.GetLuminance(Background)
	local Lighter = math.max(ForegroundLuminance, BackgroundLuminance)
	local Darker = math.min(ForegroundLuminance, BackgroundLuminance)
	return (Lighter + 0.05) / (Darker + 0.05)
end

function ThemeValidator.ValidateTheme(
	Theme: { [string]: any },
	Minimum: number?,
	Fallback: { [string]: any }?
): ContrastReport
	local MinimumRatio = Minimum or 4.5
	local Checks = {
		{ "Text", "AcrylicMain" },
		{ "Text", "Dialog" },
		{ "Text", "DropdownHolder" },
		{ "SubText", "AcrylicMain" },
		{ "SubText", "Dialog" },
		{ "SubText", "DropdownHolder" },
	}
	local Issues: { ContrastIssue } = {}
	local Ratios: { [string]: number } = {}

	for _, Check in ipairs(Checks) do
		local ForegroundName = Check[1]
		local BackgroundName = Check[2]
		local Foreground = Theme[ForegroundName] or (Fallback and Fallback[ForegroundName])
		local Background = Theme[BackgroundName] or (Fallback and Fallback[BackgroundName])
		if typeof(Foreground) == "Color3" and typeof(Background) == "Color3" then
			local Ratio = ThemeValidator.GetContrastRatio(Foreground, Background)
			local Key = ForegroundName .. "/" .. BackgroundName
			Ratios[Key] = Ratio
			if Ratio < MinimumRatio then
				table.insert(Issues, {
					Foreground = ForegroundName,
					Background = BackgroundName,
					Ratio = Ratio,
					Minimum = MinimumRatio,
				})
			end
		end
	end

	return {
		Theme = tostring(Theme.Name or "Unknown"),
		Passed = #Issues == 0,
		Minimum = MinimumRatio,
		Issues = Issues,
		Ratios = Ratios,
	}
end

function ThemeValidator.ValidateAll(Themes: { [string]: any }, Minimum: number?): { [string]: ContrastReport }
	local Reports: { [string]: ContrastReport } = {}
	for _, Name in ipairs(Themes.Names or {}) do
		local Theme = Themes[Name]
		if type(Theme) == "table" then
			Reports[Name] = ThemeValidator.ValidateTheme(Theme, Minimum, Themes.Dark)
		end
	end
	return Reports
end

return ThemeValidator

end)

register("Types", function()
local script = create_mock_script("Types")
--!strict

export type ButtonConfig = {
	Title: string,
	Description: string?,
	Callback: (() -> ())?,
}

export type ToggleConfig = {
	Title: string,
	Description: string?,
	Default: boolean?,
	Callback: ((Value: boolean) -> ())?,
}

export type SliderConfig = {
	Title: string,
	Description: string?,
	Default: number,
	Min: number,
	Max: number,
	Rounding: number,
	Step: number?,
	Callback: ((Value: number) -> ())?,
}

export type DropdownConfig = {
	Title: string,
	Description: string?,
	Values: { string },
	Multi: boolean?,
	Default: any?,
	AllowNull: boolean?,
	Callback: ((Value: any) -> ())?,
}

export type ColorpickerConfig = {
	Title: string,
	Description: string?,
	Default: Color3,
	Transparency: number?,
	Callback: ((Value: Color3) -> ())?,
}

export type KeybindConfig = {
	Title: string,
	Description: string?,
	Default: string?,
	Mode: ("Always" | "Toggle" | "Hold")?,
	Callback: ((Value: boolean) -> ())?,
	ChangedCallback: ((Value: any) -> ())?,
}

export type InputConfig = {
	Title: string,
	Description: string?,
	Default: string?,
	Placeholder: string?,
	Numeric: boolean?,
	Finished: boolean?,
	Callback: ((Value: string) -> ())?,
}

export type ParagraphConfig = {
	Title: string,
	Content: string,
}

export type NotificationConfig = {
	Title: string?,
	Content: string?,
	SubContent: string?,
	Duration: number?,
}

export type DialogButtonConfig = {
	Title: string,
	Callback: (() -> ())?,
}

export type DialogConfig = {
	Title: string,
	Content: string,
	Buttons: { DialogButtonConfig },
}

export type WindowConfig = {
	Title: string,
	SubTitle: string?,
	TabWidth: number?,
	Size: UDim2?,
	Acrylic: boolean?,
	Theme: string?,
	MinimizeKey: Enum.KeyCode?,
	ReducedMotion: boolean?,
	NotificationLimit: number?,
}

export type TabConfig = {
	Title: string,
	Icon: string?,
}

export type Tab = {
	AddSection: (self: Tab, Title: string) -> any,
	AddButton: (self: Tab, Config: ButtonConfig) -> any,
	AddToggle: (self: Tab, Id: string, Config: ToggleConfig) -> any,
	AddSlider: (self: Tab, Id: string, Config: SliderConfig) -> any,
	AddDropdown: (self: Tab, Id: string, Config: DropdownConfig) -> any,
	AddColorpicker: (self: Tab, Id: string, Config: ColorpickerConfig) -> any,
	AddKeybind: (self: Tab, Id: string, Config: KeybindConfig) -> any,
	AddInput: (self: Tab, Id: string, Config: InputConfig) -> any,
	AddParagraph: (self: Tab, Config: ParagraphConfig) -> any,
}

export type Window = {
	AddTab: (self: Window, Config: TabConfig) -> Tab,
	SelectTab: (self: Window, Tab: number) -> (),
	Dialog: (self: Window, Config: DialogConfig) -> (),
	Minimize: (self: Window) -> (),
	Maximize: (self: Window, Value: boolean, NoPosition: boolean?, Instant: boolean?) -> (),
	SetSize: (self: Window, Size: UDim2, Instant: boolean?) -> (),
	SetNavigationDrawer: (self: Window, Open: boolean) -> (),
	Destroy: (self: Window) -> (),
}

export type ContrastIssue = {
	Foreground: string,
	Background: string,
	Ratio: number,
	Minimum: number,
}

export type ContrastReport = {
	Theme: string,
	Passed: boolean,
	Minimum: number,
	Issues: { ContrastIssue },
	Ratios: { [string]: number },
}

export type Library = {
	Version: string,
	Theme: string,
	Themes: { string },
	Options: { [string]: any },
	ReducedMotion: boolean,
	NotificationLimit: number,
	CreateWindow: (self: Library, Config: WindowConfig) -> Window,
	Notify: (self: Library, Config: NotificationConfig) -> any,
	SetTheme: (self: Library, Theme: string) -> (),
	SetReducedMotion: (self: Library, Value: boolean) -> (),
	SetNotificationLimit: (self: Library, Value: number) -> (),
	CheckThemeContrast: (self: Library, Theme: string?, Minimum: number?) -> ContrastReport?,
	CheckAllThemeContrast: (self: Library, Minimum: number?) -> { [string]: ContrastReport },
	Destroy: (self: Library) -> (),
}

return table.freeze({
	Version = 1,
})

end)

return require("main")
