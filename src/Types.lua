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
