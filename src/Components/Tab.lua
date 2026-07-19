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
		Selectable = false,
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
