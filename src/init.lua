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
	Commands = {},
	Errors = {},
	DisabledCallbacks = setmetatable({}, { __mode = "k" }),
	CallbackContexts = setmetatable({}, { __mode = "k" }),
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
	Creator = Creator,
	Acrylic = Acrylic,
}

function Library:RegisterCommand(Command)
	assert(type(Command) == "table" and Command.Id and Command.Title and type(Command.Callback) == "function", "RegisterCommand - Id, Title and Callback are required")
	Library.Commands[Command.Id] = Command
	return Command
end

function Library:UnregisterCommand(Id)
	Library.Commands[Id] = nil
end

function Library:GetCommands()
	local Result = {}
	for _, Command in pairs(Library.Commands) do table.insert(Result, Command) end
	for Id, Option in pairs(Library.Options) do
		if Option.Type == "Toggle" and type(Option.SetValue) == "function" then
			table.insert(Result, {
				Id = "toggle:" .. tostring(Id),
				Title = (Option.Value and "Disable " or "Enable ") .. tostring(Option.Title or Id),
				Keywords = { tostring(Id), "toggle" },
				Callback = function() Option:SetValue(not Option.Value) end,
			})
		end
	end
	return Result
end

function Library:ExecuteCommand(Command)
	if type(Command) == "string" then Command = Library.Commands[Command] end
	if not Command then return false end
	Library:SafeCallback(Command.Callback)
	return true
end

function Library:RegisterCallbackContext(Callback, Context)
	if type(Callback) == "function" then
		Library.CallbackContexts[Callback] = Context
	end
	return Callback
end

function Library:GetErrors()
	return Library.Errors
end

function Library:ClearErrors()
	table.clear(Library.Errors)
end

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
	if Library.DisabledCallbacks[Function] then return end
	local Arguments = table.pack(...)
	local Context = Library.CallbackContexts[Function]

	local Success, Event = xpcall(function()
		return Function(table.unpack(Arguments, 1, Arguments.n))
	end, function(Error)
		return debug.traceback(tostring(Error), 2)
	end)
	if not Success then
		local Record = { Id = #Library.Errors + 1, Message = tostring(Event):match("^[^\n]+") or "Callback error", Traceback = tostring(Event), Callback = Function, Arguments = Arguments, Context = Context, Count = 1, Time = os.time() }
		table.insert(Library.Errors, Record)
		local ErrorTitle = Context and Context.Title and (Context.Title .. " encountered an error") or "Callback error"
		Library:Notify({ Title = ErrorTitle, Content = Record.Message, SubContent = "Open the error dialog for details.", Duration = 6 })
		if Library.Window and not Library.DialogOpen then
			Library.Window:Dialog({
				Title = ErrorTitle,
				Content = Record.Message,
				Buttons = {
					{ Title = "Retry", Callback = function() Library:SafeCallback(Function, table.unpack(Arguments, 1, Arguments.n)) end },
					{ Title = "Disable", Callback = function() Library.DisabledCallbacks[Function] = true end },
					{ Title = "Copy error", Callback = function() if setclipboard then setclipboard(Record.Traceback) end end },
				},
			})
		end
		return nil, Event
	end
	return Event
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
	if not Library.CommandPalette then
		Library.CommandPalette = require(Components.CommandPalette)(Library)
	end

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

function Library:OpenCommandPalette()
	if not Library.CommandPalette then
		Library.CommandPalette = require(Components.CommandPalette)(Library)
	end
	Library.CommandPalette:Open()
end

function Library:CloseCommandPalette()
	if Library.CommandPalette then
		Library.CommandPalette:Close()
	end
end

Library:RegisterCommand({
	Id = "disable-all",
	Title = "Disable all toggles",
	Keywords = { "stop", "off", "reset" },
	Callback = function()
		for _, Option in pairs(Library.Options) do
			if Option.Type == "Toggle" and Option.Value and type(Option.SetValue) == "function" then
				Option:SetValue(false)
			end
		end
	end,
})

for _, ThemeName in ipairs(Library.Themes) do
	Library:RegisterCommand({
		Id = "theme:" .. ThemeName,
		Title = "Change theme to " .. ThemeName,
		Keywords = { "appearance", "color", "theme" },
		Callback = function() Library:SetTheme(ThemeName) end,
	})
end

if getgenv then
	getgenv().Fluent = Library
	getgenv().CoreX = Library
end

return Library
