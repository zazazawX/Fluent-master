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
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60),
		Info = Color3.fromRGB(52, 152, 219),
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

	if Type and TypeColors[Type] then
		New("Frame", {
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = TypeColors[Type],
			BorderSizePixel = 0,
			Parent = NewNotification.AcrylicPaint.Frame,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})
	end

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
