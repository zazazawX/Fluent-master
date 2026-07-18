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
	Name = "Fluent",
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

	return Window
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
	Creator.Disconnect()
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

if getgenv then
	getgenv().Fluent = Library
end

return Library
