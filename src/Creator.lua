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
			Connection:Disconnect()
		end
	end
	table.clear(Creator.SignalCleanups)
end

function Creator.GetThemeProperty(Property)
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
