-- [ts]: SpriteMetrics.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Texture2D = ____Dora.Texture2D -- 1
local textureSizeCache = {} -- 4
local function safeScale(value) -- 6
	local scale = math.abs(value) -- 7
	return scale > 0.001 and scale or 1 -- 8
end -- 6
function ____exports.getTextureSize(texture) -- 11
	if texture == "" then -- 11
		return nil -- 12
	end -- 12
	local cached = textureSizeCache[texture] -- 13
	if cached ~= nil then -- 13
		return cached -- 14
	end -- 14
	local image = Texture2D(texture) -- 15
	if image == nil then -- 15
		return nil -- 16
	end -- 16
	local size = { -- 17
		math.max(1, image.width), -- 17
		math.max(1, image.height) -- 17
	} -- 17
	textureSizeCache[texture] = size -- 18
	return size -- 19
end -- 11
function ____exports.getNodeVisualSize(item, gameWidth, gameHeight) -- 22
	if item.kind == "Camera" then -- 22
		return { -- 23
			math.max(160, gameWidth or 960), -- 23
			math.max(120, gameHeight or 540) -- 23
		} -- 23
	end -- 23
	if item.kind == "Sprite" then -- 23
		local size = ____exports.getTextureSize(item.texture) -- 25
		if size ~= nil then -- 25
			return size -- 26
		end -- 26
		return {128, 96} -- 27
	end -- 27
	if item.kind == "Label" then -- 27
		return {180, 56} -- 29
	end -- 29
	return {72, 72} -- 30
end -- 22
function ____exports.isScenePointInsideNode(item, sceneX, sceneY, gameWidth, gameHeight) -- 33
	local width, height = table.unpack( -- 34
		____exports.getNodeVisualSize(item, gameWidth, gameHeight), -- 34
		1, -- 34
		2 -- 34
	) -- 34
	local dx = sceneX - item.x -- 35
	local dy = sceneY - item.y -- 36
	local radians = -item.rotation * math.pi / 180 -- 37
	local cos = math.cos(radians) -- 38
	local sin = math.sin(radians) -- 39
	local localX = (dx * cos - dy * sin) / safeScale(item.scaleX) -- 40
	local localY = (dx * sin + dy * cos) / safeScale(item.scaleY) -- 41
	return math.abs(localX) <= width / 2 and math.abs(localY) <= height / 2 -- 42
end -- 33
return ____exports -- 33