-- [ts]: Runtime.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local worldPointFromScreen, makeSegmentRect, gameWidthOf, gameHeightOf, makeClipStencil, makeCanvasBackground, makeGridLine, makeAxisLine, createRuntimeVisual, clearRecord, runtimeVisualKey, ensurePreviewRuntime, updatePreviewLayout, applyRuntimeTransform, ensureRuntimeVisual, syncPreviewNodes, runtimeVisualKeys, runtimeParentKeys, previewLayoutKey -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Line = ____Dora.Line -- 1
local Node = ____Dora.Node -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____SceneNodeRenderer = require("Script.Tools.SceneEditor.SceneNodeRenderer") -- 3
local applySceneNodeTransform = ____SceneNodeRenderer.applySceneNodeTransform -- 3
local createSceneNodeVisual = ____SceneNodeRenderer.createSceneNodeVisual -- 3
local sceneNodeVisualKey = ____SceneNodeRenderer.sceneNodeVisualKey -- 3
local updateSceneNodeDynamicVisual = ____SceneNodeRenderer.updateSceneNodeDynamicVisual -- 3
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 4
local greenAxisColor = ____Theme.greenAxisColor -- 4
local gridMajorColor = ____Theme.gridMajorColor -- 4
local gridMinorColor = ____Theme.gridMinorColor -- 4
local redAxisColor = ____Theme.redAxisColor -- 4
local viewportBgColor = ____Theme.viewportBgColor -- 4
local viewportFrameColor = ____Theme.viewportFrameColor -- 4
local viewportGameFrameColor = ____Theme.viewportGameFrameColor -- 4
function worldPointFromScreen(screenX, screenY) -- 6
	local size = App.visualSize -- 7
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 8
end -- 8
function makeSegmentRect(width, height, color, thickness) -- 15
	local hw = width / 2 -- 16
	local hh = height / 2 -- 17
	local rect = DrawNode() -- 18
	rect:drawSegment( -- 19
		Vec2(-hw, -hh), -- 19
		Vec2(hw, -hh), -- 19
		thickness, -- 19
		color -- 19
	) -- 19
	rect:drawSegment( -- 20
		Vec2(hw, -hh), -- 20
		Vec2(hw, hh), -- 20
		thickness, -- 20
		color -- 20
	) -- 20
	rect:drawSegment( -- 21
		Vec2(hw, hh), -- 21
		Vec2(-hw, hh), -- 21
		thickness, -- 21
		color -- 21
	) -- 21
	rect:drawSegment( -- 22
		Vec2(-hw, hh), -- 22
		Vec2(-hw, -hh), -- 22
		thickness, -- 22
		color -- 22
	) -- 22
	return rect -- 23
end -- 23
function gameWidthOf(state) -- 26
	return math.max(160, state.gameWidth) -- 27
end -- 27
function gameHeightOf(state) -- 30
	return math.max(120, state.gameHeight) -- 31
end -- 31
function makeClipStencil(width, height) -- 34
	local hw = width / 2 -- 35
	local hh = height / 2 -- 36
	local stencil = DrawNode() -- 37
	stencil:drawPolygon( -- 38
		{ -- 38
			Vec2(-hw, -hh), -- 39
			Vec2(hw, -hh), -- 40
			Vec2(hw, hh), -- 41
			Vec2(-hw, hh) -- 42
		}, -- 42
		Color(4294967295), -- 43
		0, -- 43
		Color() -- 43
	) -- 43
	return stencil -- 44
end -- 44
function makeCanvasBackground(width, height) -- 47
	local hw = width / 2 -- 48
	local hh = height / 2 -- 49
	local bg = DrawNode() -- 50
	bg:drawPolygon( -- 51
		{ -- 51
			Vec2(-hw, -hh), -- 52
			Vec2(hw, -hh), -- 53
			Vec2(hw, hh), -- 54
			Vec2(-hw, hh) -- 55
		}, -- 55
		viewportBgColor, -- 56
		1, -- 56
		viewportFrameColor -- 56
	) -- 56
	return bg -- 57
end -- 57
function makeGridLine(width, height) -- 60
	local grid = Node() -- 61
	local hw = width / 2 -- 62
	local hh = height / 2 -- 63
	local step = 32 -- 64
	local minor = DrawNode() -- 65
	local major = DrawNode() -- 66
	local i = 0 -- 67
	local x = -math.floor(hw / step) * step -- 68
	while x <= hw do -- 68
		if i % 5 == 0 then -- 68
			major:drawSegment( -- 71
				Vec2(x, -hh), -- 71
				Vec2(x, hh), -- 71
				0.55, -- 71
				gridMajorColor -- 71
			) -- 71
		else -- 71
			minor:drawSegment( -- 73
				Vec2(x, -hh), -- 73
				Vec2(x, hh), -- 73
				0.25, -- 73
				gridMinorColor -- 73
			) -- 73
		end -- 73
		x = x + step -- 75
		i = i + 1 -- 76
	end -- 76
	i = 0 -- 78
	local y = -math.floor(hh / step) * step -- 79
	while y <= hh do -- 79
		if i % 5 == 0 then -- 79
			major:drawSegment( -- 82
				Vec2(-hw, y), -- 82
				Vec2(hw, y), -- 82
				0.55, -- 82
				gridMajorColor -- 82
			) -- 82
		else -- 82
			minor:drawSegment( -- 84
				Vec2(-hw, y), -- 84
				Vec2(hw, y), -- 84
				0.25, -- 84
				gridMinorColor -- 84
			) -- 84
		end -- 84
		y = y + step -- 86
		i = i + 1 -- 87
	end -- 87
	grid:addChild(minor) -- 89
	grid:addChild(major) -- 90
	return grid -- 91
end -- 91
function makeAxisLine(width, height) -- 94
	local hw = width / 2 -- 95
	local hh = height / 2 -- 96
	local axis = Node() -- 97
	local xAxis = DrawNode() -- 98
	xAxis:drawSegment( -- 99
		Vec2(-hw, 0), -- 99
		Vec2(hw, 0), -- 99
		1.2, -- 99
		redAxisColor -- 99
	) -- 99
	local yAxis = DrawNode() -- 100
	yAxis:drawSegment( -- 101
		Vec2(0, -hh), -- 101
		Vec2(0, hh), -- 101
		1.2, -- 101
		greenAxisColor -- 101
	) -- 101
	axis:addChild(xAxis) -- 102
	axis:addChild(yAxis) -- 103
	return axis -- 104
end -- 104
function createRuntimeVisual(state, item) -- 107
	return createSceneNodeVisual( -- 108
		item, -- 108
		{ -- 108
			mode = "editor", -- 109
			selected = item.id == state.selectedId, -- 110
			gameWidth = gameWidthOf(state), -- 111
			gameHeight = gameHeightOf(state), -- 112
			labels = state.runtimeLabels -- 113
		} -- 113
	) -- 113
end -- 113
function clearRecord(record) -- 121
	for key in pairs(record) do -- 122
		__TS__Delete(record, key) -- 123
	end -- 123
end -- 123
function runtimeVisualKey(state, item) -- 135
	return sceneNodeVisualKey( -- 136
		item, -- 136
		{ -- 136
			mode = "editor", -- 137
			selected = item.id == state.selectedId, -- 138
			gameWidth = gameWidthOf(state), -- 139
			gameHeight = gameHeightOf(state), -- 140
			labels = state.runtimeLabels -- 141
		} -- 141
	) -- 141
end -- 141
function ensurePreviewRuntime(state) -- 145
	if state.previewRoot == nil then -- 145
		state.previewRoot = Node() -- 147
		state.previewRoot.tag = "__DoraImGuiEditorViewport__" -- 148
		Director.entry:addChild(state.previewRoot) -- 149
	end -- 149
	if state.previewWorld == nil then -- 149
		state.previewWorld = Node() -- 152
	end -- 152
	if state.previewContent == nil then -- 152
		state.previewContent = Node() -- 155
	end -- 155
	state.runtimeNodes.root = state.previewContent -- 157
end -- 157
function updatePreviewLayout(state) -- 160
	local renderScale = App.devicePixelRatio or 1 -- 161
	local width = math.max(160, state.preview.width * renderScale) -- 162
	local height = math.max(120, state.preview.height * renderScale) -- 163
	local layoutKey = table.concat( -- 164
		{ -- 164
			math.floor(width), -- 165
			math.floor(height), -- 166
			renderScale, -- 167
			state.showGrid and "grid" or "no-grid" -- 168
		}, -- 168
		"|" -- 169
	) -- 169
	if layoutKey == previewLayoutKey then -- 169
		return -- 170
	end -- 170
	previewLayoutKey = layoutKey -- 171
	local root = state.previewRoot -- 173
	local world = state.previewWorld -- 174
	local content = state.previewContent -- 175
	if root == nil or world == nil or content == nil then -- 175
		return -- 176
	end -- 176
	world:removeFromParent(false) -- 178
	content:removeFromParent(false) -- 179
	root:removeAllChildren(true) -- 180
	world:removeAllChildren(true) -- 181
	local clip = ClipNode(makeClipStencil(width, height)) -- 183
	clip.alphaThreshold = 0.01 -- 184
	root:addChild(clip) -- 185
	clip:addChild(makeCanvasBackground(width, height)) -- 186
	clip:addChild(world) -- 188
	local worldWidth = 20000 -- 189
	local worldHeight = 20000 -- 190
	if state.showGrid then -- 190
		world:addChild(makeGridLine(worldWidth, worldHeight)) -- 192
	end -- 192
	world:addChild(makeAxisLine(worldWidth, worldHeight)) -- 194
	world:addChild(content) -- 195
	clip:addChild(makeSegmentRect(width, height, viewportGameFrameColor, 0.9)) -- 196
end -- 196
function applyRuntimeTransform(state, item, runtime) -- 199
	applySceneNodeTransform(runtime, item) -- 200
	updateSceneNodeDynamicVisual(item, state.runtimeLabels) -- 201
end -- 201
function ensureRuntimeVisual(state, item) -- 204
	local key = runtimeVisualKey(state, item) -- 205
	local runtime = state.runtimeNodes[item.id] -- 206
	if runtime == nil or runtimeVisualKeys[item.id] ~= key then -- 206
		if runtime ~= nil then -- 206
			runtime:removeFromParent(false) -- 211
		end -- 211
		__TS__Delete(state.runtimeLabels, item.id) -- 213
		runtime = createRuntimeVisual(state, item) -- 214
		state.runtimeNodes[item.id] = runtime -- 215
		runtimeVisualKeys[item.id] = key -- 216
		clearRecord(runtimeParentKeys) -- 217
	end -- 217
	return runtime -- 219
end -- 219
function syncPreviewNodes(state) -- 222
	local content = state.previewContent -- 223
	if content == nil then -- 223
		return -- 224
	end -- 224
	local alive = {} -- 225
	for ____, id in ipairs(state.order) do -- 227
		do -- 227
			if id == "root" then -- 227
				goto __continue37 -- 228
			end -- 228
			local item = state.nodes[id] -- 229
			if item == nil then -- 229
				goto __continue37 -- 230
			end -- 230
			alive[id] = true -- 231
			local runtime = ensureRuntimeVisual(state, item) -- 232
			applyRuntimeTransform(state, item, runtime) -- 233
		end -- 233
		::__continue37:: -- 233
	end -- 233
	for ____, id in ipairs(state.order) do -- 236
		do -- 236
			if id == "root" then -- 236
				goto __continue41 -- 237
			end -- 237
			local item = state.nodes[id] -- 238
			local runtime = state.runtimeNodes[id] -- 239
			if item == nil or runtime == nil then -- 239
				goto __continue41 -- 240
			end -- 240
			local parentId = item.parentId or "root" -- 241
			local parent = state.runtimeNodes[parentId] or content -- 242
			if runtimeParentKeys[id] ~= parentId then -- 242
				runtime:removeFromParent(false) -- 244
				parent:addChild(runtime) -- 245
				runtimeParentKeys[id] = parentId -- 246
			end -- 246
		end -- 246
		::__continue41:: -- 246
	end -- 246
	for id in pairs(state.runtimeNodes) do -- 250
		do -- 250
			if id == "root" then -- 250
				goto __continue46 -- 251
			end -- 251
			if alive[id] then -- 251
				goto __continue46 -- 252
			end -- 252
			local runtime = state.runtimeNodes[id] -- 253
			if runtime ~= nil then -- 253
				runtime:removeFromParent(true) -- 254
			end -- 254
			__TS__Delete(state.runtimeNodes, id) -- 255
			__TS__Delete(state.runtimeLabels, id) -- 256
			__TS__Delete(runtimeVisualKeys, id) -- 257
			__TS__Delete(runtimeParentKeys, id) -- 258
		end -- 258
		::__continue46:: -- 258
	end -- 258
end -- 258
function ____exports.updatePreviewRuntime(state) -- 273
	ensurePreviewRuntime(state) -- 274
	updatePreviewLayout(state) -- 275
	local p = state.preview -- 276
	local cx, cy = table.unpack( -- 277
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 277
		1, -- 277
		2 -- 277
	) -- 277
	local previewRoot = state.previewRoot -- 278
	if previewRoot == nil then -- 278
		return -- 279
	end -- 279
	previewRoot.x = cx -- 280
	previewRoot.y = cy -- 281
	if state.previewWorld ~= nil then -- 281
		local scale = math.max(0.25, state.zoom / 100) -- 283
		state.previewWorld.x = state.viewportPanX -- 284
		state.previewWorld.y = state.viewportPanY -- 285
		state.previewWorld.scaleX = scale -- 286
		state.previewWorld.scaleY = scale -- 287
	end -- 287
	syncPreviewNodes(state) -- 289
	state.previewDirty = false -- 290
end -- 273
local function makeLine(points, color) -- 11
	return Line(points, color) -- 12
end -- 11
runtimeVisualKeys = {} -- 117
runtimeParentKeys = {} -- 118
previewLayoutKey = "" -- 119
local function resetPreviewCaches(state) -- 127
	previewLayoutKey = "" -- 128
	clearRecord(runtimeVisualKeys) -- 129
	clearRecord(runtimeParentKeys) -- 130
	state.runtimeNodes = {} -- 131
	state.runtimeLabels = {} -- 132
end -- 127
function ____exports.rebuildPreviewRuntime(state) -- 262
	if state.previewRoot ~= nil then -- 262
		state.previewRoot:removeAllChildren(true) -- 264
	end -- 264
	state.previewWorld = nil -- 266
	state.previewContent = nil -- 267
	resetPreviewCaches(state) -- 268
	state.previewDirty = true -- 269
	____exports.updatePreviewRuntime(state) -- 270
end -- 262
return ____exports -- 262