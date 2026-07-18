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

Library.Language = "en"
Library.CompactMode = false

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

function Library:SetLanguage(Lang)
	if Library.Translations[Lang] then
		Library.Language = Lang
		Creator.UpdateTheme()
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

if getgenv then
	getgenv().Fluent = Library
end

return Library
