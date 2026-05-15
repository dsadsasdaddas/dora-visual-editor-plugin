-- [ts]: NodeFactory.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Buffer = ____Dora.Buffer -- 1
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 3
local defaultNodeName = ____NodeCatalog.defaultNodeName -- 3
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 4
local defaultNodeText = ____NodeCapabilities.defaultNodeText -- 4
local shouldSpawnNodeAtOrigin = ____NodeCapabilities.shouldSpawnNodeAtOrigin -- 4
local function nodeBuffer(text, size) -- 26
	local buffer = Buffer(size) -- 27
	buffer.text = text -- 28
	return buffer -- 29
end -- 26
local function indexedSpawnPosition(kind, index) -- 32
	if shouldSpawnNodeAtOrigin(kind) then -- 32
		return {0, 0} -- 33
	end -- 33
	return { -- 34
		(index % 5 - 2) * 70, -- 34
		math.floor(index / 5) % 4 * 55 -- 34
	} -- 34
end -- 32
function ____exports.createSceneNodeData(input) -- 37
	local index = input.index ~= nil and input.index or 0 -- 38
	local defaultX, defaultY = table.unpack( -- 39
		indexedSpawnPosition(input.kind, index), -- 39
		1, -- 39
		2 -- 39
	) -- 39
	local text = input.text ~= nil and input.text or defaultNodeText(input.kind) -- 40
	local name = input.name ~= nil and input.name or defaultNodeName(input.kind, index) -- 41
	local texture = input.texture ~= nil and input.texture or "" -- 42
	local script = input.script ~= nil and input.script or "" -- 43
	local followTargetId = input.followTargetId ~= nil and input.followTargetId or "" -- 44
	local ____input_id_1 = input.id -- 46
	local ____input_kind_2 = input.kind -- 47
	local ____name_3 = name -- 48
	local ____input_parentId_4 = input.parentId -- 49
	local ____temp_5 = {} -- 50
	local ____temp_6 = input.x ~= nil and input.x or defaultX -- 51
	local ____temp_7 = input.y ~= nil and input.y or defaultY -- 52
	local ____temp_8 = input.scaleX ~= nil and input.scaleX or 1 -- 53
	local ____temp_9 = input.scaleY ~= nil and input.scaleY or 1 -- 54
	local ____temp_10 = input.rotation ~= nil and input.rotation or 0 -- 55
	local ____temp_0 -- 56
	if input.visible ~= nil then -- 56
		____temp_0 = input.visible -- 56
	else -- 56
		____temp_0 = true -- 56
	end -- 56
	return { -- 45
		id = ____input_id_1, -- 46
		kind = ____input_kind_2, -- 47
		name = ____name_3, -- 48
		parentId = ____input_parentId_4, -- 49
		children = ____temp_5, -- 50
		x = ____temp_6, -- 51
		y = ____temp_7, -- 52
		scaleX = ____temp_8, -- 53
		scaleY = ____temp_9, -- 54
		rotation = ____temp_10, -- 55
		visible = ____temp_0, -- 56
		texture = texture, -- 57
		text = text, -- 58
		script = script, -- 59
		followTargetId = followTargetId, -- 60
		followOffsetX = input.followOffsetX ~= nil and input.followOffsetX or 0, -- 61
		followOffsetY = input.followOffsetY ~= nil and input.followOffsetY or 0, -- 62
		nameBuffer = nodeBuffer(name, 128), -- 63
		textureBuffer = nodeBuffer(texture, 256), -- 64
		textBuffer = nodeBuffer(text, 256), -- 65
		scriptBuffer = nodeBuffer(script, 256), -- 66
		followTargetBuffer = nodeBuffer(followTargetId, 128) -- 67
	} -- 67
end -- 37
function ____exports.refreshSceneNodeBuffers(node) -- 71
	node.nameBuffer.text = node.name -- 72
	node.textureBuffer.text = node.texture -- 73
	node.textBuffer.text = node.text -- 74
	node.scriptBuffer.text = node.script -- 75
	node.followTargetBuffer.text = node.followTargetId -- 76
end -- 71
return ____exports -- 71