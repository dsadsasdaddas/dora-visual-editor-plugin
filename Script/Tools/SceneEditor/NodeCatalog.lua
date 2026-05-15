-- [ts]: NodeCatalog.ts
local ____exports = {} -- 1
____exports.nodeCategoryDefinitions = {{id = "structure", labelZh = "结构节点", labelEn = "Structure"}, {id = "renderable", labelZh = "可见对象", labelEn = "Renderable"}, {id = "view", labelZh = "视图", labelEn = "View"}} -- 24
____exports.nodeKindDefinitions = { -- 30
	{ -- 31
		kind = "Root", -- 32
		category = "structure", -- 33
		icon = "◎", -- 34
		labelZh = "根节点", -- 35
		labelEn = "Root", -- 36
		descriptionZh = "场景根节点。一个场景只能有一个。", -- 37
		descriptionEn = "Scene root. A scene has exactly one root.", -- 38
		canCreate = false, -- 39
		canDelete = false, -- 40
		canHaveChildren = true -- 41
	}, -- 41
	{ -- 43
		kind = "Node", -- 44
		category = "structure", -- 45
		icon = "○", -- 46
		labelZh = "空节点", -- 47
		labelEn = "Node", -- 48
		descriptionZh = "用于分组、变换和挂载脚本。", -- 49
		descriptionEn = "Group node for transforms and scripts.", -- 50
		canCreate = true, -- 51
		canDelete = true, -- 52
		canHaveChildren = true -- 53
	}, -- 53
	{ -- 55
		kind = "Sprite", -- 56
		category = "renderable", -- 57
		icon = "▣", -- 58
		labelZh = "精灵", -- 59
		labelEn = "Sprite", -- 60
		descriptionZh = "图片节点，可绑定 texture。", -- 61
		descriptionEn = "Image node with an optional texture.", -- 62
		canCreate = true, -- 63
		canDelete = true, -- 64
		canHaveChildren = true -- 65
	}, -- 65
	{ -- 67
		kind = "Label", -- 68
		category = "renderable", -- 69
		icon = "T", -- 70
		labelZh = "文本", -- 71
		labelEn = "Label", -- 72
		descriptionZh = "文字节点，用于显示文本。", -- 73
		descriptionEn = "Text node for simple labels.", -- 74
		canCreate = true, -- 75
		canDelete = true, -- 76
		canHaveChildren = true -- 77
	}, -- 77
	{ -- 79
		kind = "Camera", -- 80
		category = "view", -- 81
		icon = "◉", -- 82
		labelZh = "相机", -- 83
		labelEn = "Camera", -- 84
		descriptionZh = "定义运行时可见区域。", -- 85
		descriptionEn = "Defines the runtime visible area.", -- 86
		canCreate = true, -- 87
		canDelete = true, -- 88
		canHaveChildren = false -- 89
	} -- 89
} -- 89
function ____exports.normalizeNodeKind(value) -- 93
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 93
		return value -- 94
	end -- 94
	return "Node" -- 95
end -- 93
function ____exports.getNodeKindDefinition(kind) -- 98
	for ____, definition in ipairs(____exports.nodeKindDefinitions) do -- 99
		if definition.kind == kind then -- 99
			return definition -- 100
		end -- 100
	end -- 100
	return ____exports.nodeKindDefinitions[2] -- 102
end -- 98
function ____exports.nodeKindIcon(kind) -- 105
	return ____exports.getNodeKindDefinition(kind).icon -- 106
end -- 105
function ____exports.nodeKindLabel(kind, zh) -- 109
	local definition = ____exports.getNodeKindDefinition(kind) -- 110
	return zh and definition.labelZh or definition.labelEn -- 111
end -- 109
function ____exports.nodeKindDescription(kind, zh) -- 114
	local definition = ____exports.getNodeKindDefinition(kind) -- 115
	return zh and definition.descriptionZh or definition.descriptionEn -- 116
end -- 114
function ____exports.canCreateNodeKind(kind) -- 119
	return ____exports.getNodeKindDefinition(kind).canCreate -- 120
end -- 119
function ____exports.canDeleteNodeKind(kind) -- 123
	return ____exports.getNodeKindDefinition(kind).canDelete -- 124
end -- 123
function ____exports.canNodeKindHaveChildren(kind) -- 127
	return ____exports.getNodeKindDefinition(kind).canHaveChildren -- 128
end -- 127
function ____exports.categoryLabel(category, zh) -- 131
	return zh and category.labelZh or category.labelEn -- 132
end -- 131
function ____exports.defaultNodeName(kind, index) -- 135
	if kind == "Root" then -- 135
		return "MainScene" -- 136
	end -- 136
	if kind == "Camera" then -- 136
		return "Camera" .. (tostring(index) or "") -- 137
	end -- 137
	return kind .. (tostring(index) or "") -- 138
end -- 135
return ____exports -- 135