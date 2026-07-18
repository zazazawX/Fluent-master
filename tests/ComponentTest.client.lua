--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FluentModule = ReplicatedStorage:WaitForChild("Fluent") :: ModuleScript
local Fluent = require(FluentModule)
local StressModule =
	ReplicatedStorage:WaitForChild("Tests"):WaitForChild("PerformanceStressTest") :: ModuleScript
local StressTest = require(StressModule)

local Window = Fluent:CreateWindow({
	Title = "Fluent Component Test",
	SubTitle = Fluent.Version,
	TabWidth = 170,
	Size = UDim2.fromOffset(780, 560),
	Acrylic = false,
	Theme = "Dark",
	ReducedMotion = false,
	NotificationLimit = 3,
})

local Tabs = {
	Overview = Window:AddTab({ Title = "Overview", Icon = "layout-dashboard" }),
	Elements = Window:AddTab({ Title = "Elements", Icon = "component" }),
	Inputs = Window:AddTab({ Title = "Inputs", Icon = "text-cursor-input" }),
	Overlays = Window:AddTab({ Title = "Overlays", Icon = "panels-top-left" }),
	Diagnostics = Window:AddTab({ Title = "Diagnostics", Icon = "activity" }),
}

local SizeSection = Tabs.Overview:AddSection("Responsive presets")
SizeSection:AddParagraph({
	Title = "Device coverage",
	Content = "Use these presets together with Roblox Studio Device Emulator. The phone preset activates the mobile navigation drawer.",
})
SizeSection:AddButton({
	Title = "Desktop · 780 × 560",
	Callback = function()
		Window:SetSize(UDim2.fromOffset(780, 560))
	end,
})
SizeSection:AddButton({
	Title = "Tablet · 520 × 600",
	Callback = function()
		Window:SetSize(UDim2.fromOffset(520, 600))
	end,
})
SizeSection:AddButton({
	Title = "Phone · 360 × 640",
	Callback = function()
		Window:SetSize(UDim2.fromOffset(360, 640))
	end,
})

Tabs.Elements:AddParagraph({
	Title = "Paragraph",
	Content = "Every public element is represented in this test place.",
})
Tabs.Elements:AddButton({
	Title = "Button",
	Description = "Opens a confirmation dialog.",
	Callback = function()
		Window:Dialog({
			Title = "Button test",
			Content = "Dialog focus, scaling, modal lock, and dismissal can be tested here.",
			Buttons = {
				{ Title = "Confirm" },
				{ Title = "Cancel" },
			},
		})
	end,
})
Tabs.Elements:AddToggle("TestToggle", {
	Title = "Toggle",
	Description = "Tests callbacks and reduced motion.",
	Default = false,
})
Tabs.Elements:AddSlider("TestSlider", {
	Title = "Slider",
	Description = "Drag, use arrow keys, or use the gamepad D-pad.",
	Default = 50,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Step = 5,
})
Tabs.Elements:AddDropdown("TestDropdown", {
	Title = "Single dropdown",
	Values = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon" },
	Default = 1,
})
Tabs.Elements:AddDropdown("TestMultiDropdown", {
	Title = "Multi dropdown",
	Values = { "Mouse", "Touch", "Keyboard", "Gamepad" },
	Multi = true,
	Default = { "Mouse", "Touch" },
})
Tabs.Elements:AddColorpicker("TestColor", {
	Title = "Colorpicker",
	Default = Color3.fromRGB(96, 205, 255),
	Transparency = 0.15,
})

Tabs.Inputs:AddInput("TestInput", {
	Title = "Text input",
	Placeholder = "Type text here",
	Default = "",
})
Tabs.Inputs:AddInput("TestNumericInput", {
	Title = "Numeric input",
	Placeholder = "123",
	Default = "42",
	Numeric = true,
})
Tabs.Inputs:AddKeybind("TestKeybind", {
	Title = "Keybind",
	Default = "RightShift",
	Mode = "Toggle",
})
Tabs.Inputs:AddParagraph({
	Title = "Navigation keys",
	Content = "PageUp/PageDown or L1/R1 changes tabs. M or gamepad X toggles the mobile drawer. Escape or gamepad B closes the active overlay.",
})

Tabs.Overlays:AddButton({
	Title = "Open dialog",
	Callback = function()
		Window:Dialog({
			Title = "Overlay test",
			Content = "The first button receives focus. Escape or gamepad B closes this dialog.",
			Buttons = {
				{ Title = "Primary" },
				{ Title = "Secondary" },
				{ Title = "Cancel" },
			},
		})
	end,
})
Tabs.Overlays:AddButton({
	Title = "Queue 6 notifications",
	Description = "Only three notifications should be visible at once.",
	Callback = function()
		for Index = 1, 6 do
			Fluent:Notify({
				Title = "Queue item " .. tostring(Index),
				Content = "Swipe horizontally on touch to dismiss.",
				Duration = 4,
			})
		end
	end,
})

local ThemeSection = Tabs.Diagnostics:AddSection("Accessibility")
ThemeSection:AddDropdown("TestTheme", {
	Title = "Theme",
	Values = Fluent.Themes,
	Default = Fluent.Theme,
	Callback = function(Value)
		Fluent:SetTheme(Value)
	end,
})
ThemeSection:AddToggle("TestReducedMotion", {
	Title = "Reduced motion",
	Default = Fluent.ReducedMotion,
	Callback = function(Value)
		Fluent:SetReducedMotion(Value)
	end,
})
ThemeSection:AddButton({
	Title = "Check current theme contrast",
	Callback = function()
		local Report = Fluent:CheckThemeContrast()
		local Content = Report and (
			Report.Passed
				and "All tested text/background pairs pass."
				or tostring(#Report.Issues) .. " contrast pair(s) need attention."
		) or "Theme report is unavailable."
		Fluent:Notify({
			Title = "Theme contrast",
			Content = Content,
			Duration = 5,
		})
	end,
})
ThemeSection:AddButton({
	Title = "Check all theme contrast",
	Callback = function()
		local Reports = Fluent:CheckAllThemeContrast()
		local Passed = 0
		local Total = 0
		for _, Report in Reports do
			Total += 1
			if Report.Passed then
				Passed += 1
			end
		end
		Fluent:Notify({
			Title = "All theme contrast",
			Content = string.format("%d of %d themes pass every tested pair.", Passed, Total),
			Duration = 5,
		})
	end,
})

Tabs.Diagnostics:AddButton({
	Title = "Run 120-element stress test",
	Description = "Creates and destroys Buttons, Toggles, and Sliders, then reports retained state.",
	Callback = function()
		local Result = StressTest.Run(Tabs.Diagnostics, Fluent, FluentModule, 120)
		Fluent:Notify({
			Title = "Stress test complete",
			Content = string.format(
				"Created %d in %.3fs · signals %+d · registry %+d · options %+d · memory %+.1f KB",
				Result.Count,
				Result.CreateSeconds,
				Result.SignalDelta,
				Result.RegistryDelta,
				Result.OptionsDelta,
				Result.MemoryDeltaKB
			),
			Duration = 8,
		})
	end,
})

Window:SelectTab(1)
Fluent:Notify({
	Title = "Component test ready",
	Content = "Start with the responsive presets on the Overview tab.",
	Duration = 5,
})
