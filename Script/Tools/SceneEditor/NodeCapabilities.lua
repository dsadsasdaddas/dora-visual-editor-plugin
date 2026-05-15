-- [ts]: NodeCapabilities.ts
local ____exports = {} -- 1
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 2
local getNodeKindDefinition = ____NodeCatalog.getNodeKindDefinition -- 2
local function nodeCapability(kind) -- 24
	return getNodeKindDefinition(kind) -- 25
end -- 24
function ____exports.isRootNodeKind(kind) -- 28
	return kind == "Root" -- 29
end -- 28
function ____exports.canDeleteNodeKind(kind) -- 32
	return nodeCapability(kind).canDelete == true -- 33
end -- 32
function ____exports.canNodeKindHaveChildren(kind) -- 36
	return nodeCapability(kind).canHaveChildren == true -- 37
end -- 36
function ____exports.canNodeKindBindTexture(kind) -- 40
	return nodeCapability(kind).canBindTexture == true -- 41
end -- 40
function ____exports.canNodeKindBindScript(kind) -- 44
	return nodeCapability(kind).canBindScript == true -- 45
end -- 44
function ____exports.canNodeKindEditText(kind) -- 48
	return nodeCapability(kind).canEditText == true -- 49
end -- 48
function ____exports.canNodeKindFollowTarget(kind) -- 52
	return nodeCapability(kind).canFollowTarget == true -- 53
end -- 52
function ____exports.canNodeKindBeFollowTarget(kind) -- 56
	return nodeCapability(kind).canBeFollowTarget == true -- 57
end -- 56
function ____exports.canSelectNodeKindInViewport(kind) -- 60
	return nodeCapability(kind).selectableInViewport == true -- 61
end -- 60
function ____exports.nodeKindViewportPickLayer(kind) -- 64
	return nodeCapability(kind).viewportPickLayer or "none" -- 65
end -- 64
function ____exports.nodeKindUsesTextureSize(kind) -- 68
	return nodeCapability(kind).usesTextureSize == true -- 69
end -- 68
function ____exports.nodeKindUsesGameFrameSize(kind) -- 72
	return nodeCapability(kind).usesGameFrameSize == true -- 73
end -- 72
function ____exports.defaultNodeText(kind) -- 76
	return nodeCapability(kind).defaultText or "" -- 77
end -- 76
function ____exports.defaultNodeVisualSize(kind) -- 80
	local capability = nodeCapability(kind) -- 81
	return {capability.defaultWidth or 72, capability.defaultHeight or 72} -- 82
end -- 80
function ____exports.shouldSpawnNodeAtOrigin(kind) -- 85
	return nodeCapability(kind).spawnAtOrigin == true -- 86
end -- 85
return ____exports -- 85