local Root = script.Parent.Parent
local Components = Root.Components
local Creator = require(Root.Creator)
local New = Creator.New

local ImageElement = {}
ImageElement.__index = ImageElement
ImageElement.__type = "Image"

function ImageElement:New(Config)
	assert(Config.Title, "Image - Missing Title")
	assert(Config.Image, "Image - Missing Image ID")

	local ImageFrame = require(Components.Element)(Config.Title, Config.Description or "", self.Container, false)
	ImageFrame.Frame.Selectable = false

	local ImageSize = Config.Size or UDim2.fromOffset(64, 64)

	local ImageLabel = New("ImageLabel", {
		Image = Config.Image,
		Size = ImageSize,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		ScaleType = Config.ScaleType or Enum.ScaleType.Fit,
		Parent = ImageFrame.Frame,
	})

	ImageFrame.DescLabel.Size = UDim2.new(1, -(ImageSize.X.Offset + 30), 0, 14)

	function ImageFrame:SetImage(ImageId)
		ImageLabel.Image = ImageId
	end

	return ImageFrame
end

return ImageElement
