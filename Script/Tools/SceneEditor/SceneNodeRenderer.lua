-- [ts]: SceneNodeRenderer.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 3
local canNodeKindEditText = ____NodeCapabilities.canNodeKindEditText -- 3
local defaultNodeText = ____NodeCapabilities.defaultNodeText -- 3
local nodeKindUsesGameFrameSize = ____NodeCapabilities.nodeKindUsesGameFrameSize -- 3
local nodeKindUsesTextureSize = ____NodeCapabilities.nodeKindUsesTextureSize -- 3
local ____SpriteMetrics = require("Script.Tools.SceneEditor.SpriteMetrics") -- 4
local getNodeVisualSize = ____SpriteMetrics.getNodeVisualSize -- 4
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local helperColor = ____Theme.helperColor -- 5
local selectionColor = ____Theme.selectionColor -- 5
local viewportGameFrameColor = ____Theme.viewportGameFrameColor -- 5
local function makeSegmentRect(width, height, color, thickness) -- 17
	local hw = width / 2 -- 18
	local hh = height / 2 -- 19
	local rect = DrawNode() -- 20
	rect:drawSegment( -- 21
		Vec2(-hw, -hh), -- 21
		Vec2(hw, -hh), -- 21
		thickness, -- 21
		color -- 21
	) -- 21
	rect:drawSegment( -- 22
		Vec2(hw, -hh), -- 22
		Vec2(hw, hh), -- 22
		thickness, -- 22
		color -- 22
	) -- 22
	rect:drawSegment( -- 23
		Vec2(hw, hh), -- 23
		Vec2(-hw, hh), -- 23
		thickness, -- 23
		color -- 23
	) -- 23
	rect:drawSegment( -- 24
		Vec2(-hw, hh), -- 24
		Vec2(-hw, -hh), -- 24
		thickness, -- 24
		color -- 24
	) -- 24
	return rect -- 25
end -- 17
local function makeNodeCross(color) -- 28
	local node = Node() -- 29
	local horizontal = DrawNode() -- 30
	horizontal:drawSegment( -- 31
		Vec2(-20, 0), -- 31
		Vec2(20, 0), -- 31
		1, -- 31
		color -- 31
	) -- 31
	local vertical = DrawNode() -- 32
	vertical:drawSegment( -- 33
		Vec2(0, -20), -- 33
		Vec2(0, 20), -- 33
		1, -- 33
		color -- 33
	) -- 33
	node:addChild(horizontal) -- 34
	node:addChild(vertical) -- 35
	return node -- 36
end -- 28
local function addCornerHandles(node, width, height, color) -- 39
	local hw = width / 2 -- 40
	local hh = height / 2 -- 41
	local size = 8 -- 42
	local points = { -- 43
		Vec2(-hw, -hh), -- 44
		Vec2(hw, -hh), -- 45
		Vec2(hw, hh), -- 46
		Vec2(-hw, hh) -- 47
	} -- 47
	for ____, point in ipairs(points) do -- 49
		local handle = DrawNode() -- 50
		handle:drawPolygon( -- 51
			{ -- 51
				Vec2(point.x - size / 2, point.y - size / 2), -- 52
				Vec2(point.x + size / 2, point.y - size / 2), -- 53
				Vec2(point.x + size / 2, point.y + size / 2), -- 54
				Vec2(point.x - size / 2, point.y + size / 2) -- 55
			}, -- 55
			color, -- 56
			0, -- 56
			Color() -- 56
		) -- 56
		node:addChild(handle) -- 57
	end -- 57
end -- 39
local function makeSpritePlaceholder(width, height) -- 61
	local node = Node() -- 62
	node:addChild(makeSegmentRect(width, height, helperColor, 1.1)) -- 63
	local cross = DrawNode() -- 64
	local hw = width / 2 -- 65
	local hh = height / 2 -- 66
	cross:drawSegment( -- 67
		Vec2(-hw, -hh), -- 67
		Vec2(hw, hh), -- 67
		0.6, -- 67
		helperColor -- 67
	) -- 67
	cross:drawSegment( -- 68
		Vec2(-hw, hh), -- 68
		Vec2(hw, -hh), -- 68
		0.6, -- 68
		helperColor -- 68
	) -- 68
	node:addChild(cross) -- 69
	return node -- 70
end -- 61
local function makeCameraShape(width, height) -- 73
	local node = Node() -- 74
	node:addChild(makeSegmentRect(width, height, viewportGameFrameColor, 1.1)) -- 75
	return node -- 76
end -- 73
local function makePlayFallback(width, height, color) -- 79
	return makeSegmentRect(width, height, color, 1) -- 80
end -- 79
local function addEditorSelectionOverlay(item, context, node) -- 83
	local width, height = table.unpack( -- 84
		getNodeVisualSize(item, context.gameWidth, context.gameHeight), -- 84
		1, -- 84
		2 -- 84
	) -- 84
	local color = context.selected and selectionColor or helperColor -- 85
	node:addChild(makeSegmentRect(width, height, color, context.selected and 1.6 or 0.8)) -- 86
	if context.selected then -- 86
		addCornerHandles(node, width, height, color) -- 87
	end -- 87
end -- 83
local function createTextureVisual(item, context) -- 90
	if item.texture ~= "" then -- 90
		local sprite = Sprite(item.texture) -- 92
		if sprite ~= nil then -- 92
			return sprite -- 93
		end -- 93
	end -- 93
	local width, height = table.unpack( -- 95
		getNodeVisualSize(item, context.gameWidth, context.gameHeight), -- 95
		1, -- 95
		2 -- 95
	) -- 95
	if context.mode == "play" then -- 95
		return makePlayFallback( -- 96
			width, -- 96
			height, -- 96
			Color(2859640520) -- 96
		) -- 96
	end -- 96
	return makeSpritePlaceholder(width, height) -- 97
end -- 90
local function createLabelVisual(item, context) -- 100
	local label = Label("sarasa-mono-sc-regular", 32) -- 101
	if label ~= nil then -- 101
		label.text = item.text or defaultNodeText(item.kind) -- 103
		context.labels[item.id] = label -- 104
		return label -- 105
	end -- 105
	local width, height = table.unpack( -- 107
		getNodeVisualSize(item, context.gameWidth, context.gameHeight), -- 107
		1, -- 107
		2 -- 107
	) -- 107
	return makePlayFallback( -- 108
		width, -- 108
		height, -- 108
		Color(2866196799) -- 108
	) -- 108
end -- 100
local function createBaseVisual(item, context) -- 111
	local width, height = table.unpack( -- 112
		getNodeVisualSize(item, context.gameWidth, context.gameHeight), -- 112
		1, -- 112
		2 -- 112
	) -- 112
	if nodeKindUsesTextureSize(item.kind) then -- 112
		return createTextureVisual(item, context) -- 113
	end -- 113
	if canNodeKindEditText(item.kind) then -- 113
		return createLabelVisual(item, context) -- 114
	end -- 114
	if nodeKindUsesGameFrameSize(item.kind) then -- 114
		return context.mode == "editor" and makeCameraShape(width, height) or Node() -- 115
	end -- 115
	return context.mode == "editor" and makeNodeCross(helperColor) or Node() -- 116
end -- 111
function ____exports.createSceneNodeVisual(item, context) -- 119
	local visual = createBaseVisual(item, context) -- 120
	if context.mode == "play" then -- 120
		return visual -- 121
	end -- 121
	local wrapper = Node() -- 122
	wrapper:addChild(visual) -- 123
	addEditorSelectionOverlay(item, context, wrapper) -- 124
	return wrapper -- 125
end -- 119
function ____exports.sceneNodeVisualKey(item, context) -- 128
	return table.concat( -- 129
		{ -- 129
			context.mode, -- 130
			item.kind, -- 131
			item.texture or "", -- 132
			item.text or "", -- 133
			item.name or "", -- 134
			context.selected and "selected" or "normal", -- 135
			tostring(context.gameWidth), -- 136
			tostring(context.gameHeight) -- 137
		}, -- 137
		"|" -- 138
	) -- 138
end -- 128
function ____exports.applySceneNodeTransform(target, item) -- 141
	target.x = item.x -- 142
	target.y = item.y -- 143
	target.scaleX = item.scaleX -- 144
	target.scaleY = item.scaleY -- 145
	target.angle = item.rotation -- 146
	target.visible = item.visible -- 147
	target.tag = item.name -- 148
end -- 141
function ____exports.updateSceneNodeDynamicVisual(item, labels) -- 151
	local label = labels[item.id] -- 152
	if label ~= nil then -- 152
		label.text = item.text or defaultNodeText(item.kind) -- 153
	end -- 153
end -- 151
return ____exports -- 151