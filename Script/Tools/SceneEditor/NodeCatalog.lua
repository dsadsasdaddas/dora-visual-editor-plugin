-- [ts]: NodeCatalog.ts
local ____exports = {} -- 1
____exports.nodeCategoryDefinitions = {{id = "structure", labelZh = "结构节点", labelEn = "Structure"}, {id = "renderable", labelZh = "可见对象", labelEn = "Renderable"}, {id = "view", labelZh = "视图", labelEn = "View"}} -- 40
____exports.nodeKindDefinitions = { -- 46
	{ -- 47
		kind = "Root", -- 48
		category = "structure", -- 49
		icon = "◎", -- 50
		labelZh = "根节点", -- 51
		labelEn = "Root", -- 52
		descriptionZh = "场景根节点。一个场景只能有一个。", -- 53
		descriptionEn = "Scene root. A scene has exactly one root.", -- 54
		canCreate = false, -- 55
		canDelete = false, -- 56
		canHaveChildren = true, -- 57
		canBindTexture = false, -- 58
		canBindScript = false, -- 59
		canEditText = false, -- 60
		canFollowTarget = false, -- 61
		canBeFollowTarget = false, -- 62
		selectableInViewport = false, -- 63
		viewportPickLayer = "none", -- 64
		usesTextureSize = false, -- 65
		usesGameFrameSize = false, -- 66
		spawnAtOrigin = true, -- 67
		defaultName = "MainScene", -- 68
		defaultNamePrefix = "Root", -- 69
		defaultText = "", -- 70
		defaultWidth = 72, -- 71
		defaultHeight = 72 -- 72
	}, -- 72
	{ -- 74
		kind = "Node", -- 75
		category = "structure", -- 76
		icon = "○", -- 77
		labelZh = "空节点", -- 78
		labelEn = "Node", -- 79
		descriptionZh = "用于分组、变换和挂载脚本。", -- 80
		descriptionEn = "Group node for transforms and scripts.", -- 81
		canCreate = true, -- 82
		canDelete = true, -- 83
		canHaveChildren = true, -- 84
		canBindTexture = false, -- 85
		canBindScript = true, -- 86
		canEditText = false, -- 87
		canFollowTarget = false, -- 88
		canBeFollowTarget = true, -- 89
		selectableInViewport = true, -- 90
		viewportPickLayer = "object", -- 91
		usesTextureSize = false, -- 92
		usesGameFrameSize = false, -- 93
		spawnAtOrigin = false, -- 94
		defaultName = "", -- 95
		defaultNamePrefix = "Node", -- 96
		defaultText = "", -- 97
		defaultWidth = 72, -- 98
		defaultHeight = 72 -- 99
	}, -- 99
	{ -- 101
		kind = "Sprite", -- 102
		category = "renderable", -- 103
		icon = "▣", -- 104
		labelZh = "精灵", -- 105
		labelEn = "Sprite", -- 106
		descriptionZh = "图片节点，可绑定 texture。", -- 107
		descriptionEn = "Image node with an optional texture.", -- 108
		canCreate = true, -- 109
		canDelete = true, -- 110
		canHaveChildren = true, -- 111
		canBindTexture = true, -- 112
		canBindScript = true, -- 113
		canEditText = false, -- 114
		canFollowTarget = false, -- 115
		canBeFollowTarget = true, -- 116
		selectableInViewport = true, -- 117
		viewportPickLayer = "object", -- 118
		usesTextureSize = true, -- 119
		usesGameFrameSize = false, -- 120
		spawnAtOrigin = false, -- 121
		defaultName = "", -- 122
		defaultNamePrefix = "Sprite", -- 123
		defaultText = "", -- 124
		defaultWidth = 128, -- 125
		defaultHeight = 96 -- 126
	}, -- 126
	{ -- 128
		kind = "Label", -- 129
		category = "renderable", -- 130
		icon = "T", -- 131
		labelZh = "文本", -- 132
		labelEn = "Label", -- 133
		descriptionZh = "文字节点，用于显示文本。", -- 134
		descriptionEn = "Text node for simple labels.", -- 135
		canCreate = true, -- 136
		canDelete = true, -- 137
		canHaveChildren = true, -- 138
		canBindTexture = false, -- 139
		canBindScript = true, -- 140
		canEditText = true, -- 141
		canFollowTarget = false, -- 142
		canBeFollowTarget = true, -- 143
		selectableInViewport = true, -- 144
		viewportPickLayer = "object", -- 145
		usesTextureSize = false, -- 146
		usesGameFrameSize = false, -- 147
		spawnAtOrigin = false, -- 148
		defaultName = "", -- 149
		defaultNamePrefix = "Label", -- 150
		defaultText = "Label", -- 151
		defaultWidth = 180, -- 152
		defaultHeight = 56 -- 153
	}, -- 153
	{ -- 155
		kind = "Camera", -- 156
		category = "view", -- 157
		icon = "◉", -- 158
		labelZh = "相机", -- 159
		labelEn = "Camera", -- 160
		descriptionZh = "定义运行时可见区域。", -- 161
		descriptionEn = "Defines the runtime visible area.", -- 162
		canCreate = true, -- 163
		canDelete = true, -- 164
		canHaveChildren = false, -- 165
		canBindTexture = false, -- 166
		canBindScript = false, -- 167
		canEditText = false, -- 168
		canFollowTarget = true, -- 169
		canBeFollowTarget = false, -- 170
		selectableInViewport = true, -- 171
		viewportPickLayer = "camera", -- 172
		usesTextureSize = false, -- 173
		usesGameFrameSize = true, -- 174
		spawnAtOrigin = true, -- 175
		defaultName = "", -- 176
		defaultNamePrefix = "Camera", -- 177
		defaultText = "", -- 178
		defaultWidth = 960, -- 179
		defaultHeight = 540 -- 180
	} -- 180
} -- 180
function ____exports.normalizeNodeKind(value) -- 184
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 184
		return value -- 185
	end -- 185
	return "Node" -- 186
end -- 184
function ____exports.getNodeKindDefinition(kind) -- 189
	for ____, definition in ipairs(____exports.nodeKindDefinitions) do -- 190
		if definition.kind == kind then -- 190
			return definition -- 191
		end -- 191
	end -- 191
	return ____exports.nodeKindDefinitions[2] -- 193
end -- 189
function ____exports.isRootNodeKind(kind) -- 196
	return kind == "Root" -- 197
end -- 196
function ____exports.nodeKindIcon(kind) -- 200
	return ____exports.getNodeKindDefinition(kind).icon -- 201
end -- 200
function ____exports.nodeKindLabel(kind, zh) -- 204
	local definition = ____exports.getNodeKindDefinition(kind) -- 205
	return zh and definition.labelZh or definition.labelEn -- 206
end -- 204
function ____exports.nodeKindDescription(kind, zh) -- 209
	local definition = ____exports.getNodeKindDefinition(kind) -- 210
	return zh and definition.descriptionZh or definition.descriptionEn -- 211
end -- 209
function ____exports.canCreateNodeKind(kind) -- 214
	return ____exports.getNodeKindDefinition(kind).canCreate -- 215
end -- 214
function ____exports.canDeleteNodeKind(kind) -- 218
	return ____exports.getNodeKindDefinition(kind).canDelete -- 219
end -- 218
function ____exports.canNodeKindHaveChildren(kind) -- 222
	return ____exports.getNodeKindDefinition(kind).canHaveChildren -- 223
end -- 222
function ____exports.canNodeKindBindTexture(kind) -- 226
	return ____exports.getNodeKindDefinition(kind).canBindTexture -- 227
end -- 226
function ____exports.canNodeKindBindScript(kind) -- 230
	return ____exports.getNodeKindDefinition(kind).canBindScript -- 231
end -- 230
function ____exports.canNodeKindEditText(kind) -- 234
	return ____exports.getNodeKindDefinition(kind).canEditText -- 235
end -- 234
function ____exports.canNodeKindFollowTarget(kind) -- 238
	return ____exports.getNodeKindDefinition(kind).canFollowTarget -- 239
end -- 238
function ____exports.canNodeKindBeFollowTarget(kind) -- 242
	return ____exports.getNodeKindDefinition(kind).canBeFollowTarget -- 243
end -- 242
function ____exports.canSelectNodeKindInViewport(kind) -- 246
	return ____exports.getNodeKindDefinition(kind).selectableInViewport -- 247
end -- 246
function ____exports.nodeKindViewportPickLayer(kind) -- 250
	return ____exports.getNodeKindDefinition(kind).viewportPickLayer -- 251
end -- 250
function ____exports.nodeKindUsesTextureSize(kind) -- 254
	return ____exports.getNodeKindDefinition(kind).usesTextureSize -- 255
end -- 254
function ____exports.nodeKindUsesGameFrameSize(kind) -- 258
	return ____exports.getNodeKindDefinition(kind).usesGameFrameSize -- 259
end -- 258
function ____exports.defaultNodeText(kind) -- 262
	return ____exports.getNodeKindDefinition(kind).defaultText -- 263
end -- 262
function ____exports.defaultNodeVisualSize(kind) -- 266
	local definition = ____exports.getNodeKindDefinition(kind) -- 267
	return {definition.defaultWidth, definition.defaultHeight} -- 268
end -- 266
function ____exports.shouldSpawnNodeAtOrigin(kind) -- 271
	return ____exports.getNodeKindDefinition(kind).spawnAtOrigin -- 272
end -- 271
function ____exports.categoryLabel(category, zh) -- 275
	return zh and category.labelZh or category.labelEn -- 276
end -- 275
function ____exports.defaultNodeName(kind, index) -- 279
	local definition = ____exports.getNodeKindDefinition(kind) -- 280
	if definition.defaultName ~= "" then -- 280
		return definition.defaultName -- 281
	end -- 281
	return definition.defaultNamePrefix .. (tostring(index) or "") -- 282
end -- 279
return ____exports -- 279