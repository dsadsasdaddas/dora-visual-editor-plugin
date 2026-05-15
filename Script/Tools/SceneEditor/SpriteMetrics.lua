-- [ts]: SpriteMetrics.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Texture2D = ____Dora.Texture2D -- 1
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 3
local defaultNodeVisualSize = ____NodeCapabilities.defaultNodeVisualSize -- 3
local nodeKindUsesGameFrameSize = ____NodeCapabilities.nodeKindUsesGameFrameSize -- 3
local nodeKindUsesTextureSize = ____NodeCapabilities.nodeKindUsesTextureSize -- 3
local textureSizeCache = {} -- 5
local function safeScale(value) -- 7
	local scale = math.abs(value) -- 8
	return scale > 0.001 and scale or 1 -- 9
end -- 7
function ____exports.getTextureSize(texture) -- 12
	if texture == "" then -- 12
		return nil -- 13
	end -- 13
	local cached = textureSizeCache[texture] -- 14
	if cached ~= nil then -- 14
		return cached -- 15
	end -- 15
	local image = Texture2D(texture) -- 16
	if image == nil then -- 16
		return nil -- 17
	end -- 17
	local size = { -- 18
		math.max(1, image.width), -- 18
		math.max(1, image.height) -- 18
	} -- 18
	textureSizeCache[texture] = size -- 19
	return size -- 20
end -- 12
function ____exports.getNodeVisualSize(item, gameWidth, gameHeight) -- 23
	if nodeKindUsesGameFrameSize(item.kind) then -- 23
		return { -- 24
			math.max(160, gameWidth or 960), -- 24
			math.max(120, gameHeight or 540) -- 24
		} -- 24
	end -- 24
	if nodeKindUsesTextureSize(item.kind) then -- 24
		local size = ____exports.getTextureSize(item.texture) -- 26
		if size ~= nil then -- 26
			return size -- 27
		end -- 27
	end -- 27
	return defaultNodeVisualSize(item.kind) -- 29
end -- 23
function ____exports.isScenePointInsideNode(item, sceneX, sceneY, gameWidth, gameHeight) -- 32
	local width, height = table.unpack( -- 33
		____exports.getNodeVisualSize(item, gameWidth, gameHeight), -- 33
		1, -- 33
		2 -- 33
	) -- 33
	local dx = sceneX - item.x -- 34
	local dy = sceneY - item.y -- 35
	local radians = -item.rotation * math.pi / 180 -- 36
	local cos = math.cos(radians) -- 37
	local sin = math.sin(radians) -- 38
	local localX = (dx * cos - dy * sin) / safeScale(item.scaleX) -- 39
	local localY = (dx * sin + dy * cos) / safeScale(item.scaleY) -- 40
	return math.abs(localX) <= width / 2 and math.abs(localY) <= height / 2 -- 41
end -- 32
return ____exports -- 32