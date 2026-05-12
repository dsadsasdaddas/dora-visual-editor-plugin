-- [ts]: Runtime.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local worldPointFromScreen, makeLine, makeThickLine, makeSegmentRect, addCornerHandles, gameWidthOf, gameHeightOf, selectionSize, addSelectionOverlay, makeClipStencil, makeCanvasBackground, makeGridLine, makeAxisLine, makeSpritePlaceholder, makeCameraShape, createRuntimeVisual, clearRecord, runtimeVisualKey, ensurePreviewRuntime, updatePreviewLayout, applyRuntimeTransform, ensureRuntimeVisual, syncPreviewNodes, runtimeVisualKeys, runtimeParentKeys, previewLayoutKey -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Line = ____Dora.Line -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____SpriteMetrics = require("Script.Tools.SceneEditor.SpriteMetrics") -- 3
local getNodeVisualSize = ____SpriteMetrics.getNodeVisualSize -- 3
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 4
local greenAxisColor = ____Theme.greenAxisColor -- 4
local gridMajorColor = ____Theme.gridMajorColor -- 4
local gridMinorColor = ____Theme.gridMinorColor -- 4
local helperColor = ____Theme.helperColor -- 4
local redAxisColor = ____Theme.redAxisColor -- 4
local selectionColor = ____Theme.selectionColor -- 4
local viewportBgColor = ____Theme.viewportBgColor -- 4
local viewportFrameColor = ____Theme.viewportFrameColor -- 4
local viewportGameFrameColor = ____Theme.viewportGameFrameColor -- 4
function worldPointFromScreen(screenX, screenY) -- 6
	local size = App.visualSize -- 7
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 8
end -- 8
function makeLine(points, color) -- 11
	return Line(points, color) -- 12
end -- 12
function makeThickLine(a, b, color, horizontal) -- 15
	local node = Node() -- 16
	do -- 16
		local offset = -1 -- 17
		while offset <= 1 do -- 17
			if horizontal then -- 17
				node:addChild(makeLine( -- 19
					{ -- 19
						Vec2(a.x, a.y + offset), -- 19
						Vec2(b.x, b.y + offset) -- 19
					}, -- 19
					color -- 19
				)) -- 19
			else -- 19
				node:addChild(makeLine( -- 21
					{ -- 21
						Vec2(a.x + offset, a.y), -- 21
						Vec2(b.x + offset, b.y) -- 21
					}, -- 21
					color -- 21
				)) -- 21
			end -- 21
			offset = offset + 1 -- 17
		end -- 17
	end -- 17
	return node -- 24
end -- 24
function makeSegmentRect(width, height, color, thickness) -- 27
	local hw = width / 2 -- 28
	local hh = height / 2 -- 29
	local rect = DrawNode() -- 30
	rect:drawSegment( -- 31
		Vec2(-hw, -hh), -- 31
		Vec2(hw, -hh), -- 31
		thickness, -- 31
		color -- 31
	) -- 31
	rect:drawSegment( -- 32
		Vec2(hw, -hh), -- 32
		Vec2(hw, hh), -- 32
		thickness, -- 32
		color -- 32
	) -- 32
	rect:drawSegment( -- 33
		Vec2(hw, hh), -- 33
		Vec2(-hw, hh), -- 33
		thickness, -- 33
		color -- 33
	) -- 33
	rect:drawSegment( -- 34
		Vec2(-hw, hh), -- 34
		Vec2(-hw, -hh), -- 34
		thickness, -- 34
		color -- 34
	) -- 34
	return rect -- 35
end -- 35
function addCornerHandles(node, width, height, color) -- 38
	local hw = width / 2 -- 39
	local hh = height / 2 -- 40
	local size = 8 -- 41
	local points = { -- 42
		Vec2(-hw, -hh), -- 43
		Vec2(hw, -hh), -- 44
		Vec2(hw, hh), -- 45
		Vec2(-hw, hh) -- 46
	} -- 46
	for ____, point in ipairs(points) do -- 48
		local handle = DrawNode() -- 49
		handle:drawPolygon( -- 50
			{ -- 50
				Vec2(point.x - size / 2, point.y - size / 2), -- 51
				Vec2(point.x + size / 2, point.y - size / 2), -- 52
				Vec2(point.x + size / 2, point.y + size / 2), -- 53
				Vec2(point.x - size / 2, point.y + size / 2) -- 54
			}, -- 54
			color, -- 55
			0, -- 55
			Color() -- 55
		) -- 55
		node:addChild(handle) -- 56
	end -- 56
end -- 56
function gameWidthOf(state) -- 60
	return math.max(160, state.gameWidth) -- 61
end -- 61
function gameHeightOf(state) -- 64
	return math.max(120, state.gameHeight) -- 65
end -- 65
function selectionSize(state, item) -- 68
	if item.kind == "Camera" then -- 68
		return { -- 69
			gameWidthOf(state), -- 69
			gameHeightOf(state) -- 69
		} -- 69
	end -- 69
	return getNodeVisualSize(item) -- 70
end -- 70
function addSelectionOverlay(state, item, node) -- 73
	local width, height = table.unpack( -- 74
		selectionSize(state, item), -- 74
		1, -- 74
		2 -- 74
	) -- 74
	local color = item.id == state.selectedId and selectionColor or helperColor -- 75
	node:addChild(makeSegmentRect(width, height, color, item.id == state.selectedId and 1.6 or 0.8)) -- 76
	if item.id == state.selectedId then -- 76
		addCornerHandles(node, width, height, color) -- 77
	end -- 77
end -- 77
function makeClipStencil(width, height) -- 81
	local hw = width / 2 -- 82
	local hh = height / 2 -- 83
	local stencil = DrawNode() -- 84
	stencil:drawPolygon( -- 85
		{ -- 85
			Vec2(-hw, -hh), -- 86
			Vec2(hw, -hh), -- 87
			Vec2(hw, hh), -- 88
			Vec2(-hw, hh) -- 89
		}, -- 89
		Color(4294967295), -- 90
		0, -- 90
		Color() -- 90
	) -- 90
	return stencil -- 91
end -- 91
function makeCanvasBackground(width, height) -- 94
	local hw = width / 2 -- 95
	local hh = height / 2 -- 96
	local bg = DrawNode() -- 97
	bg:drawPolygon( -- 98
		{ -- 98
			Vec2(-hw, -hh), -- 99
			Vec2(hw, -hh), -- 100
			Vec2(hw, hh), -- 101
			Vec2(-hw, hh) -- 102
		}, -- 102
		viewportBgColor, -- 103
		1, -- 103
		viewportFrameColor -- 103
	) -- 103
	return bg -- 104
end -- 104
function makeGridLine(width, height) -- 107
	local grid = Node() -- 108
	local hw = width / 2 -- 109
	local hh = height / 2 -- 110
	local step = 32 -- 111
	local minor = DrawNode() -- 112
	local major = DrawNode() -- 113
	local i = 0 -- 114
	local x = -math.floor(hw / step) * step -- 115
	while x <= hw do -- 115
		if i % 5 == 0 then -- 115
			major:drawSegment( -- 118
				Vec2(x, -hh), -- 118
				Vec2(x, hh), -- 118
				0.55, -- 118
				gridMajorColor -- 118
			) -- 118
		else -- 118
			minor:drawSegment( -- 120
				Vec2(x, -hh), -- 120
				Vec2(x, hh), -- 120
				0.25, -- 120
				gridMinorColor -- 120
			) -- 120
		end -- 120
		x = x + step -- 122
		i = i + 1 -- 123
	end -- 123
	i = 0 -- 125
	local y = -math.floor(hh / step) * step -- 126
	while y <= hh do -- 126
		if i % 5 == 0 then -- 126
			major:drawSegment( -- 129
				Vec2(-hw, y), -- 129
				Vec2(hw, y), -- 129
				0.55, -- 129
				gridMajorColor -- 129
			) -- 129
		else -- 129
			minor:drawSegment( -- 131
				Vec2(-hw, y), -- 131
				Vec2(hw, y), -- 131
				0.25, -- 131
				gridMinorColor -- 131
			) -- 131
		end -- 131
		y = y + step -- 133
		i = i + 1 -- 134
	end -- 134
	grid:addChild(minor) -- 136
	grid:addChild(major) -- 137
	return grid -- 138
end -- 138
function makeAxisLine(width, height) -- 141
	local hw = width / 2 -- 142
	local hh = height / 2 -- 143
	local axis = Node() -- 144
	local xAxis = DrawNode() -- 145
	xAxis:drawSegment( -- 146
		Vec2(-hw, 0), -- 146
		Vec2(hw, 0), -- 146
		1.2, -- 146
		redAxisColor -- 146
	) -- 146
	local yAxis = DrawNode() -- 147
	yAxis:drawSegment( -- 148
		Vec2(0, -hh), -- 148
		Vec2(0, hh), -- 148
		1.2, -- 148
		greenAxisColor -- 148
	) -- 148
	axis:addChild(xAxis) -- 149
	axis:addChild(yAxis) -- 150
	return axis -- 151
end -- 151
function makeSpritePlaceholder(width, height) -- 154
	local node = Node() -- 155
	node:addChild(makeSegmentRect(width, height, helperColor, 1.1)) -- 156
	local cross = DrawNode() -- 157
	local hw = width / 2 -- 158
	local hh = height / 2 -- 159
	cross:drawSegment( -- 160
		Vec2(-hw, -hh), -- 160
		Vec2(hw, hh), -- 160
		0.6, -- 160
		helperColor -- 160
	) -- 160
	cross:drawSegment( -- 161
		Vec2(-hw, hh), -- 161
		Vec2(hw, -hh), -- 161
		0.6, -- 161
		helperColor -- 161
	) -- 161
	node:addChild(cross) -- 162
	return node -- 163
end -- 163
function makeCameraShape(state) -- 166
	local node = Node() -- 167
	node:addChild(makeSegmentRect( -- 168
		gameWidthOf(state), -- 168
		gameHeightOf(state), -- 168
		viewportGameFrameColor, -- 168
		1.1 -- 168
	)) -- 168
	return node -- 169
end -- 169
function createRuntimeVisual(state, item) -- 172
	local wrapper = Node() -- 173
	if item.kind == "Sprite" then -- 173
		local visual = nil -- 175
		if item.texture ~= "" then -- 175
			visual = Sprite(item.texture) -- 177
		end -- 177
		local width, height = table.unpack( -- 179
			selectionSize(state, item), -- 179
			1, -- 179
			2 -- 179
		) -- 179
		wrapper:addChild(visual ~= nil and visual or makeSpritePlaceholder(width, height)) -- 180
		addSelectionOverlay(state, item, wrapper) -- 181
	elseif item.kind == "Label" then -- 181
		local label = Label("sarasa-mono-sc-regular", 32) -- 183
		if label ~= nil then -- 183
			label.text = item.text or "Label" -- 185
			state.runtimeLabels[item.id] = label -- 186
			wrapper:addChild(label) -- 187
		else -- 187
			wrapper:addChild(makeSegmentRect( -- 189
				180, -- 189
				56, -- 189
				Color(4294967295), -- 189
				3 -- 189
			)) -- 189
		end -- 189
		addSelectionOverlay(state, item, wrapper) -- 191
	elseif item.kind == "Camera" then -- 191
		wrapper:addChild(makeCameraShape(state)) -- 193
		addSelectionOverlay(state, item, wrapper) -- 194
	else -- 194
		wrapper:addChild(makeThickLine( -- 196
			Vec2(-20, 0), -- 196
			Vec2(20, 0), -- 196
			helperColor, -- 196
			true -- 196
		)) -- 196
		wrapper:addChild(makeThickLine( -- 197
			Vec2(0, -20), -- 197
			Vec2(0, 20), -- 197
			helperColor, -- 197
			false -- 197
		)) -- 197
		addSelectionOverlay(state, item, wrapper) -- 198
	end -- 198
	return wrapper -- 200
end -- 200
function clearRecord(record) -- 207
	for key in pairs(record) do -- 208
		__TS__Delete(record, key) -- 209
	end -- 209
end -- 209
function runtimeVisualKey(state, item) -- 221
	return table.concat( -- 222
		{ -- 222
			item.kind, -- 223
			item.texture or "", -- 224
			item.text or "", -- 225
			item.name or "", -- 226
			item.id == state.selectedId and "selected" or "normal", -- 227
			item.kind == "Camera" and (tostring(gameWidthOf(state)) .. "x") .. tostring(gameHeightOf(state)) or "" -- 228
		}, -- 228
		"|" -- 229
	) -- 229
end -- 229
function ensurePreviewRuntime(state) -- 232
	if state.previewRoot == nil then -- 232
		state.previewRoot = Node() -- 234
		state.previewRoot.tag = "__DoraImGuiEditorViewport__" -- 235
		Director.entry:addChild(state.previewRoot) -- 236
	end -- 236
	if state.previewWorld == nil then -- 236
		state.previewWorld = Node() -- 239
	end -- 239
	if state.previewContent == nil then -- 239
		state.previewContent = Node() -- 242
	end -- 242
	state.runtimeNodes.root = state.previewContent -- 244
end -- 244
function updatePreviewLayout(state) -- 247
	local renderScale = App.devicePixelRatio or 1 -- 248
	local width = math.max(160, state.preview.width * renderScale) -- 249
	local height = math.max(120, state.preview.height * renderScale) -- 250
	local layoutKey = table.concat( -- 251
		{ -- 251
			math.floor(width), -- 252
			math.floor(height), -- 253
			renderScale, -- 254
			state.showGrid and "grid" or "no-grid" -- 255
		}, -- 255
		"|" -- 256
	) -- 256
	if layoutKey == previewLayoutKey then -- 256
		return -- 257
	end -- 257
	previewLayoutKey = layoutKey -- 258
	local root = state.previewRoot -- 260
	local world = state.previewWorld -- 261
	local content = state.previewContent -- 262
	if root == nil or world == nil or content == nil then -- 262
		return -- 263
	end -- 263
	world:removeFromParent(false) -- 265
	content:removeFromParent(false) -- 266
	root:removeAllChildren(true) -- 267
	world:removeAllChildren(true) -- 268
	local clip = ClipNode(makeClipStencil(width, height)) -- 270
	clip.alphaThreshold = 0.01 -- 271
	root:addChild(clip) -- 272
	clip:addChild(makeCanvasBackground(width, height)) -- 273
	clip:addChild(world) -- 275
	local worldWidth = 20000 -- 276
	local worldHeight = 20000 -- 277
	if state.showGrid then -- 277
		world:addChild(makeGridLine(worldWidth, worldHeight)) -- 279
	end -- 279
	world:addChild(makeAxisLine(worldWidth, worldHeight)) -- 281
	world:addChild(content) -- 282
	clip:addChild(makeSegmentRect(width, height, viewportGameFrameColor, 0.9)) -- 283
end -- 283
function applyRuntimeTransform(state, item, runtime) -- 286
	runtime.x = item.x -- 287
	runtime.y = item.y -- 288
	runtime.scaleX = item.scaleX -- 289
	runtime.scaleY = item.scaleY -- 290
	runtime.angle = item.rotation -- 291
	runtime.visible = item.visible -- 292
	runtime.tag = item.name -- 293
	local label = state.runtimeLabels[item.id] -- 294
	if label ~= nil then -- 294
		label.text = item.text or "Label" -- 295
	end -- 295
end -- 295
function ensureRuntimeVisual(state, item) -- 298
	local key = runtimeVisualKey(state, item) -- 299
	local runtime = state.runtimeNodes[item.id] -- 300
	if runtime == nil or runtimeVisualKeys[item.id] ~= key then -- 300
		if runtime ~= nil then -- 300
			runtime:removeFromParent(false) -- 305
		end -- 305
		__TS__Delete(state.runtimeLabels, item.id) -- 307
		runtime = createRuntimeVisual(state, item) -- 308
		state.runtimeNodes[item.id] = runtime -- 309
		runtimeVisualKeys[item.id] = key -- 310
		clearRecord(runtimeParentKeys) -- 311
	end -- 311
	return runtime -- 313
end -- 313
function syncPreviewNodes(state) -- 316
	local content = state.previewContent -- 317
	if content == nil then -- 317
		return -- 318
	end -- 318
	local alive = {} -- 319
	for ____, id in ipairs(state.order) do -- 321
		do -- 321
			if id == "root" then -- 321
				goto __continue59 -- 322
			end -- 322
			local item = state.nodes[id] -- 323
			if item == nil then -- 323
				goto __continue59 -- 324
			end -- 324
			alive[id] = true -- 325
			local runtime = ensureRuntimeVisual(state, item) -- 326
			applyRuntimeTransform(state, item, runtime) -- 327
		end -- 327
		::__continue59:: -- 327
	end -- 327
	for ____, id in ipairs(state.order) do -- 330
		do -- 330
			if id == "root" then -- 330
				goto __continue63 -- 331
			end -- 331
			local item = state.nodes[id] -- 332
			local runtime = state.runtimeNodes[id] -- 333
			if item == nil or runtime == nil then -- 333
				goto __continue63 -- 334
			end -- 334
			local parentId = item.parentId or "root" -- 335
			local parent = state.runtimeNodes[parentId] or content -- 336
			if runtimeParentKeys[id] ~= parentId then -- 336
				runtime:removeFromParent(false) -- 338
				parent:addChild(runtime) -- 339
				runtimeParentKeys[id] = parentId -- 340
			end -- 340
		end -- 340
		::__continue63:: -- 340
	end -- 340
	for id in pairs(state.runtimeNodes) do -- 344
		do -- 344
			if id == "root" then -- 344
				goto __continue68 -- 345
			end -- 345
			if alive[id] then -- 345
				goto __continue68 -- 346
			end -- 346
			local runtime = state.runtimeNodes[id] -- 347
			if runtime ~= nil then -- 347
				runtime:removeFromParent(true) -- 348
			end -- 348
			__TS__Delete(state.runtimeNodes, id) -- 349
			__TS__Delete(state.runtimeLabels, id) -- 350
			__TS__Delete(runtimeVisualKeys, id) -- 351
			__TS__Delete(runtimeParentKeys, id) -- 352
		end -- 352
		::__continue68:: -- 352
	end -- 352
end -- 352
function ____exports.updatePreviewRuntime(state) -- 367
	ensurePreviewRuntime(state) -- 368
	updatePreviewLayout(state) -- 369
	local p = state.preview -- 370
	local cx, cy = table.unpack( -- 371
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 371
		1, -- 371
		2 -- 371
	) -- 371
	local previewRoot = state.previewRoot -- 372
	if previewRoot == nil then -- 372
		return -- 373
	end -- 373
	previewRoot.x = cx -- 374
	previewRoot.y = cy -- 375
	if state.previewWorld ~= nil then -- 375
		local scale = math.max(0.25, state.zoom / 100) -- 377
		state.previewWorld.x = state.viewportPanX -- 378
		state.previewWorld.y = state.viewportPanY -- 379
		state.previewWorld.scaleX = scale -- 380
		state.previewWorld.scaleY = scale -- 381
	end -- 381
	syncPreviewNodes(state) -- 383
	state.previewDirty = false -- 384
end -- 367
runtimeVisualKeys = {} -- 203
runtimeParentKeys = {} -- 204
previewLayoutKey = "" -- 205
local function resetPreviewCaches(state) -- 213
	previewLayoutKey = "" -- 214
	clearRecord(runtimeVisualKeys) -- 215
	clearRecord(runtimeParentKeys) -- 216
	state.runtimeNodes = {} -- 217
	state.runtimeLabels = {} -- 218
end -- 213
function ____exports.rebuildPreviewRuntime(state) -- 356
	if state.previewRoot ~= nil then -- 356
		state.previewRoot:removeAllChildren(true) -- 358
	end -- 358
	state.previewWorld = nil -- 360
	state.previewContent = nil -- 361
	resetPreviewCaches(state) -- 362
	state.previewDirty = true -- 363
	____exports.updatePreviewRuntime(state) -- 364
end -- 356
return ____exports -- 356