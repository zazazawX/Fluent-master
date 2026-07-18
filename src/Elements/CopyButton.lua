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
