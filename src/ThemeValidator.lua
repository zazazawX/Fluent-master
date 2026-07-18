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
