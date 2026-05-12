-- [ts]: Runtime.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local worldPointFromScreen, makeLine, makeThickLine, makeSegmentRect, addCornerHandles, selectionSize, addSelectionOverlay, makeClipStencil, makeCanvasBackground, makeGridLine, makeAxisLine, makeSpritePlaceholder, makeCameraShape, createRuntimeVisual, clearRecord, runtimeVisualKey, ensurePreviewRuntime, updatePreviewLayout, applyRuntimeTransform, ensureRuntimeVisual, syncPreviewNodes, runtimeVisualKeys, runtimeParentKeys, previewLayoutKey -- 1
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
function selectionSize(item) -- 60
	return getNodeVisualSize(item) -- 61
end -- 61
function addSelectionOverlay(state, item, node) -- 64
	local width, height = table.unpack( -- 65
		selectionSize(item), -- 65
		1, -- 65
		2 -- 65
	) -- 65
	local color = item.id == state.selectedId and selectionColor or helperColor -- 66
	node:addChild(makeSegmentRect(width, height, color, item.id == state.selectedId and 1.6 or 0.8)) -- 67
	if item.id == state.selectedId then -- 67
		addCornerHandles(node, width, height, color) -- 68
	end -- 68
end -- 68
function makeClipStencil(width, height) -- 72
	local hw = width / 2 -- 73
	local hh = height / 2 -- 74
	local stencil = DrawNode() -- 75
	stencil:drawPolygon( -- 76
		{ -- 76
			Vec2(-hw, -hh), -- 77
			Vec2(hw, -hh), -- 78
			Vec2(hw, hh), -- 79
			Vec2(-hw, hh) -- 80
		}, -- 80
		Color(4294967295), -- 81
		0, -- 81
		Color() -- 81
	) -- 81
	return stencil -- 82
end -- 82
function makeCanvasBackground(width, height) -- 85
	local hw = width / 2 -- 86
	local hh = height / 2 -- 87
	local bg = DrawNode() -- 88
	bg:drawPolygon( -- 89
		{ -- 89
			Vec2(-hw, -hh), -- 90
			Vec2(hw, -hh), -- 91
			Vec2(hw, hh), -- 92
			Vec2(-hw, hh) -- 93
		}, -- 93
		viewportBgColor, -- 94
		1, -- 94
		viewportFrameColor -- 94
	) -- 94
	return bg -- 95
end -- 95
function makeGridLine(width, height) -- 98
	local grid = Node() -- 99
	local hw = width / 2 -- 100
	local hh = height / 2 -- 101
	local step = 32 -- 102
	local minor = DrawNode() -- 103
	local major = DrawNode() -- 104
	local i = 0 -- 105
	local x = -math.floor(hw / step) * step -- 106
	while x <= hw do -- 106
		if i % 5 == 0 then -- 106
			major:drawSegment( -- 109
				Vec2(x, -hh), -- 109
				Vec2(x, hh), -- 109
				0.55, -- 109
				gridMajorColor -- 109
			) -- 109
		else -- 109
			minor:drawSegment( -- 111
				Vec2(x, -hh), -- 111
				Vec2(x, hh), -- 111
				0.25, -- 111
				gridMinorColor -- 111
			) -- 111
		end -- 111
		x = x + step -- 113
		i = i + 1 -- 114
	end -- 114
	i = 0 -- 116
	local y = -math.floor(hh / step) * step -- 117
	while y <= hh do -- 117
		if i % 5 == 0 then -- 117
			major:drawSegment( -- 120
				Vec2(-hw, y), -- 120
				Vec2(hw, y), -- 120
				0.55, -- 120
				gridMajorColor -- 120
			) -- 120
		else -- 120
			minor:drawSegment( -- 122
				Vec2(-hw, y), -- 122
				Vec2(hw, y), -- 122
				0.25, -- 122
				gridMinorColor -- 122
			) -- 122
		end -- 122
		y = y + step -- 124
		i = i + 1 -- 125
	end -- 125
	grid:addChild(minor) -- 127
	grid:addChild(major) -- 128
	return grid -- 129
end -- 129
function makeAxisLine(width, height) -- 132
	local hw = width / 2 -- 133
	local hh = height / 2 -- 134
	local axis = Node() -- 135
	local xAxis = DrawNode() -- 136
	xAxis:drawSegment( -- 137
		Vec2(-hw, 0), -- 137
		Vec2(hw, 0), -- 137
		1.2, -- 137
		redAxisColor -- 137
	) -- 137
	local yAxis = DrawNode() -- 138
	yAxis:drawSegment( -- 139
		Vec2(0, -hh), -- 139
		Vec2(0, hh), -- 139
		1.2, -- 139
		greenAxisColor -- 139
	) -- 139
	axis:addChild(xAxis) -- 140
	axis:addChild(yAxis) -- 141
	return axis -- 142
end -- 142
function makeSpritePlaceholder(width, height) -- 145
	local node = Node() -- 146
	node:addChild(makeSegmentRect(width, height, helperColor, 1.1)) -- 147
	local cross = DrawNode() -- 148
	local hw = width / 2 -- 149
	local hh = height / 2 -- 150
	cross:drawSegment( -- 151
		Vec2(-hw, -hh), -- 151
		Vec2(hw, hh), -- 151
		0.6, -- 151
		helperColor -- 151
	) -- 151
	cross:drawSegment( -- 152
		Vec2(-hw, hh), -- 152
		Vec2(hw, -hh), -- 152
		0.6, -- 152
		helperColor -- 152
	) -- 152
	node:addChild(cross) -- 153
	return node -- 154
end -- 154
function makeCameraShape() -- 157
	local node = Node() -- 158
	node:addChild(makeSegmentRect(320, 180, viewportGameFrameColor, 1.1)) -- 159
	return node -- 160
end -- 160
function createRuntimeVisual(state, item) -- 163
	local wrapper = Node() -- 164
	if item.kind == "Sprite" then -- 164
		local visual = nil -- 166
		if item.texture ~= "" then -- 166
			visual = Sprite(item.texture) -- 168
		end -- 168
		local width, height = table.unpack( -- 170
			selectionSize(item), -- 170
			1, -- 170
			2 -- 170
		) -- 170
		wrapper:addChild(visual ~= nil and visual or makeSpritePlaceholder(width, height)) -- 171
		addSelectionOverlay(state, item, wrapper) -- 172
	elseif item.kind == "Label" then -- 172
		local label = Label("sarasa-mono-sc-regular", 32) -- 174
		if label ~= nil then -- 174
			label.text = item.text or "Label" -- 176
			state.runtimeLabels[item.id] = label -- 177
			wrapper:addChild(label) -- 178
		else -- 178
			wrapper:addChild(makeSegmentRect( -- 180
				180, -- 180
				56, -- 180
				Color(4294967295), -- 180
				3 -- 180
			)) -- 180
		end -- 180
		addSelectionOverlay(state, item, wrapper) -- 182
	elseif item.kind == "Camera" then -- 182
		wrapper:addChild(makeCameraShape()) -- 184
		addSelectionOverlay(state, item, wrapper) -- 185
	else -- 185
		wrapper:addChild(makeThickLine( -- 187
			Vec2(-20, 0), -- 187
			Vec2(20, 0), -- 187
			helperColor, -- 187
			true -- 187
		)) -- 187
		wrapper:addChild(makeThickLine( -- 188
			Vec2(0, -20), -- 188
			Vec2(0, 20), -- 188
			helperColor, -- 188
			false -- 188
		)) -- 188
		addSelectionOverlay(state, item, wrapper) -- 189
	end -- 189
	return wrapper -- 191
end -- 191
function clearRecord(record) -- 198
	for key in pairs(record) do -- 199
		__TS__Delete(record, key) -- 200
	end -- 200
end -- 200
function runtimeVisualKey(state, item) -- 212
	return table.concat({ -- 213
		item.kind, -- 214
		item.texture or "", -- 215
		item.text or "", -- 216
		item.name or "", -- 217
		item.id == state.selectedId and "selected" or "normal" -- 218
	}, "|") -- 218
end -- 218
function ensurePreviewRuntime(state) -- 222
	if state.previewRoot == nil then -- 222
		state.previewRoot = Node() -- 224
		state.previewRoot.tag = "__DoraImGuiEditorViewport__" -- 225
		Director.entry:addChild(state.previewRoot) -- 226
	end -- 226
	if state.previewWorld == nil then -- 226
		state.previewWorld = Node() -- 229
	end -- 229
	if state.previewContent == nil then -- 229
		state.previewContent = Node() -- 232
	end -- 232
	state.runtimeNodes.root = state.previewContent -- 234
end -- 234
function updatePreviewLayout(state) -- 237
	local renderScale = App.devicePixelRatio or 1 -- 238
	local width = math.max(160, state.preview.width * renderScale) -- 239
	local height = math.max(120, state.preview.height * renderScale) -- 240
	local layoutKey = table.concat( -- 241
		{ -- 241
			math.floor(width), -- 242
			math.floor(height), -- 243
			renderScale, -- 244
			state.showGrid and "grid" or "no-grid" -- 245
		}, -- 245
		"|" -- 246
	) -- 246
	if layoutKey == previewLayoutKey then -- 246
		return -- 247
	end -- 247
	previewLayoutKey = layoutKey -- 248
	local root = state.previewRoot -- 250
	local world = state.previewWorld -- 251
	local content = state.previewContent -- 252
	if root == nil or world == nil or content == nil then -- 252
		return -- 253
	end -- 253
	world:removeFromParent(false) -- 255
	content:removeFromParent(false) -- 256
	root:removeAllChildren(true) -- 257
	world:removeAllChildren(true) -- 258
	local clip = ClipNode(makeClipStencil(width, height)) -- 260
	clip.alphaThreshold = 0.01 -- 261
	root:addChild(clip) -- 262
	clip:addChild(makeCanvasBackground(width, height)) -- 263
	clip:addChild(world) -- 265
	local worldWidth = 20000 -- 266
	local worldHeight = 20000 -- 267
	if state.showGrid then -- 267
		world:addChild(makeGridLine(worldWidth, worldHeight)) -- 269
	end -- 269
	world:addChild(makeAxisLine(worldWidth, worldHeight)) -- 271
	world:addChild(content) -- 272
	clip:addChild(makeSegmentRect(width, height, viewportGameFrameColor, 0.9)) -- 273
end -- 273
function applyRuntimeTransform(state, item, runtime) -- 276
	runtime.x = item.x -- 277
	runtime.y = item.y -- 278
	runtime.scaleX = item.scaleX -- 279
	runtime.scaleY = item.scaleY -- 280
	runtime.angle = item.rotation -- 281
	runtime.visible = item.visible -- 282
	runtime.tag = item.name -- 283
	local label = state.runtimeLabels[item.id] -- 284
	if label ~= nil then -- 284
		label.text = item.text or "Label" -- 285
	end -- 285
end -- 285
function ensureRuntimeVisual(state, item) -- 288
	local key = runtimeVisualKey(state, item) -- 289
	local runtime = state.runtimeNodes[item.id] -- 290
	if runtime == nil or runtimeVisualKeys[item.id] ~= key then -- 290
		if runtime ~= nil then -- 290
			runtime:removeFromParent(false) -- 295
		end -- 295
		__TS__Delete(state.runtimeLabels, item.id) -- 297
		runtime = createRuntimeVisual(state, item) -- 298
		state.runtimeNodes[item.id] = runtime -- 299
		runtimeVisualKeys[item.id] = key -- 300
		clearRecord(runtimeParentKeys) -- 301
	end -- 301
	return runtime -- 303
end -- 303
function syncPreviewNodes(state) -- 306
	local content = state.previewContent -- 307
	if content == nil then -- 307
		return -- 308
	end -- 308
	local alive = {} -- 309
	for ____, id in ipairs(state.order) do -- 311
		do -- 311
			if id == "root" then -- 311
				goto __continue56 -- 312
			end -- 312
			local item = state.nodes[id] -- 313
			if item == nil then -- 313
				goto __continue56 -- 314
			end -- 314
			alive[id] = true -- 315
			local runtime = ensureRuntimeVisual(state, item) -- 316
			applyRuntimeTransform(state, item, runtime) -- 317
		end -- 317
		::__continue56:: -- 317
	end -- 317
	for ____, id in ipairs(state.order) do -- 320
		do -- 320
			if id == "root" then -- 320
				goto __continue60 -- 321
			end -- 321
			local item = state.nodes[id] -- 322
			local runtime = state.runtimeNodes[id] -- 323
			if item == nil or runtime == nil then -- 323
				goto __continue60 -- 324
			end -- 324
			local parentId = item.parentId or "root" -- 325
			local parent = state.runtimeNodes[parentId] or content -- 326
			if runtimeParentKeys[id] ~= parentId then -- 326
				runtime:removeFromParent(false) -- 328
				parent:addChild(runtime) -- 329
				runtimeParentKeys[id] = parentId -- 330
			end -- 330
		end -- 330
		::__continue60:: -- 330
	end -- 330
	for id in pairs(state.runtimeNodes) do -- 334
		do -- 334
			if id == "root" then -- 334
				goto __continue65 -- 335
			end -- 335
			if alive[id] then -- 335
				goto __continue65 -- 336
			end -- 336
			local runtime = state.runtimeNodes[id] -- 337
			if runtime ~= nil then -- 337
				runtime:removeFromParent(true) -- 338
			end -- 338
			__TS__Delete(state.runtimeNodes, id) -- 339
			__TS__Delete(state.runtimeLabels, id) -- 340
			__TS__Delete(runtimeVisualKeys, id) -- 341
			__TS__Delete(runtimeParentKeys, id) -- 342
		end -- 342
		::__continue65:: -- 342
	end -- 342
end -- 342
function ____exports.updatePreviewRuntime(state) -- 357
	ensurePreviewRuntime(state) -- 358
	updatePreviewLayout(state) -- 359
	local p = state.preview -- 360
	local cx, cy = table.unpack( -- 361
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 361
		1, -- 361
		2 -- 361
	) -- 361
	local previewRoot = state.previewRoot -- 362
	if previewRoot == nil then -- 362
		return -- 363
	end -- 363
	previewRoot.x = cx -- 364
	previewRoot.y = cy -- 365
	if state.previewWorld ~= nil then -- 365
		local scale = math.max(0.25, state.zoom / 100) -- 367
		state.previewWorld.x = state.viewportPanX -- 368
		state.previewWorld.y = state.viewportPanY -- 369
		state.previewWorld.scaleX = scale -- 370
		state.previewWorld.scaleY = scale -- 371
	end -- 371
	syncPreviewNodes(state) -- 373
	state.previewDirty = false -- 374
end -- 357
runtimeVisualKeys = {} -- 194
runtimeParentKeys = {} -- 195
previewLayoutKey = "" -- 196
local function resetPreviewCaches(state) -- 204
	previewLayoutKey = "" -- 205
	clearRecord(runtimeVisualKeys) -- 206
	clearRecord(runtimeParentKeys) -- 207
	state.runtimeNodes = {} -- 208
	state.runtimeLabels = {} -- 209
end -- 204
function ____exports.rebuildPreviewRuntime(state) -- 346
	if state.previewRoot ~= nil then -- 346
		state.previewRoot:removeAllChildren(true) -- 348
	end -- 348
	state.previewWorld = nil -- 350
	state.previewContent = nil -- 351
	resetPreviewCaches(state) -- 352
	state.previewDirty = true -- 353
	____exports.updatePreviewRuntime(state) -- 354
end -- 346
return ____exports -- 346