-- [ts]: Model.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local isPathInside, isProjectRootDir, detectWorkspaceRoot, hasAsset, rememberAsset, sortAssets, normalizeSlash, stripFolderPrefix, refreshAssetSearchPath, notifyWebIDEFileAdded, copyFileToImported, importedAssetRoot, importedAssetRootEntry -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Buffer = ____Dora.Buffer -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local emit = ____Dora.emit -- 1
local json = ____Dora.json -- 1
function isPathInside(path, root) -- 36
	local cleanPath = normalizeSlash(path) -- 37
	local cleanRoot = normalizeSlash(root) -- 38
	return cleanPath == cleanRoot or string.sub( -- 39
		cleanPath, -- 39
		1, -- 39
		string.len(cleanRoot) + 1 -- 39
	) == cleanRoot .. "/" -- 39
end -- 39
function isProjectRootDir(dir) -- 42
	if dir == "" or not Content:exist(dir) or not Content:isdir(dir) then -- 42
		return false -- 43
	end -- 43
	for ____, file in ipairs(Content:getFiles(dir)) do -- 44
		if string.lower(Path:getName(file)) == "init" then -- 44
			return true -- 45
		end -- 45
	end -- 45
	local agentDir = Path(dir, ".agent") -- 47
	return Content:exist(agentDir) and Content:isdir(agentDir) -- 48
end -- 48
function detectWorkspaceRoot() -- 51
	for ____, searchPath in ipairs(Content.searchPaths) do -- 52
		local candidate = searchPath -- 53
		if Path:getFilename(candidate) == "Script" then -- 53
			candidate = Path:getPath(candidate) -- 54
		end -- 54
		if candidate ~= Content.writablePath and isPathInside(candidate, Content.writablePath) and isProjectRootDir(candidate) then -- 54
			return candidate -- 56
		end -- 56
	end -- 56
	return Content.writablePath -- 59
end -- 59
function ____exports.workspaceRoot() -- 62
	return detectWorkspaceRoot() -- 63
end -- 62
function ____exports.workspacePath(path) -- 66
	return Path( -- 67
		____exports.workspaceRoot(), -- 67
		path -- 67
	) -- 67
end -- 66
function ____exports.pushConsole(state, message) -- 121
	local ____state_console_0 = state.console -- 121
	____state_console_0[#____state_console_0 + 1] = message -- 122
	if #state.console > 7 then -- 122
		table.remove(state.console, 1) -- 124
	end -- 124
end -- 121
function ____exports.isFolderAsset(path) -- 150
	return path ~= "" and string.sub( -- 151
		path, -- 151
		string.len(path), -- 151
		string.len(path) -- 151
	) == "/" -- 151
end -- 150
function hasAsset(state, asset) -- 154
	for ____, item in ipairs(state.assets) do -- 155
		if item == asset then -- 155
			return true -- 156
		end -- 156
	end -- 156
	return false -- 158
end -- 158
function rememberAsset(state, asset) -- 161
	if asset == "" then -- 161
		return -- 162
	end -- 162
	if not hasAsset(state, asset) then -- 162
		local ____state_assets_1 = state.assets -- 162
		____state_assets_1[#____state_assets_1 + 1] = asset -- 163
	end -- 163
end -- 163
function sortAssets(state) -- 166
	table.sort( -- 167
		state.assets, -- 167
		function(a, b) -- 167
			local aFolder = ____exports.isFolderAsset(a) -- 168
			local bFolder = ____exports.isFolderAsset(b) -- 169
			if aFolder == bFolder then -- 169
				return a < b -- 170
			end -- 170
			return aFolder -- 171
		end -- 167
	) -- 167
end -- 167
function normalizeSlash(path) -- 175
	local result = string.gsub(path, "\\", "/") -- 176
	local found = string.find(result, "//") -- 177
	while found ~= nil do -- 177
		result = string.gsub(result, "//", "/") -- 179
		found = string.find(result, "//") -- 180
	end -- 180
	return result -- 182
end -- 182
function stripFolderPrefix(folder, path) -- 185
	local cleanFolder = normalizeSlash(folder) -- 186
	local cleanPath = normalizeSlash(path) -- 187
	if string.sub( -- 187
		cleanPath, -- 188
		1, -- 188
		string.len(cleanFolder) -- 188
	) == cleanFolder then -- 188
		local rest = string.sub( -- 189
			cleanPath, -- 189
			string.len(cleanFolder) + 1 -- 189
		) -- 189
		if string.sub(rest, 1, 1) == "/" then -- 189
			rest = string.sub(rest, 2) -- 190
		end -- 190
		return rest -- 191
	end -- 191
	return Path:getFilename(path) -- 193
end -- 193
function refreshAssetSearchPath(importedPath) -- 196
	Content:addSearchPath(____exports.workspaceRoot()) -- 197
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 198
	if importedPath ~= nil and importedPath ~= "" then -- 198
		local importedFolder = Path:getPath(importedPath) -- 200
		if importedFolder ~= "" then -- 200
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 201
		end -- 201
	end -- 201
	Content:clearPathCache() -- 203
end -- 203
function ____exports.refreshImportedAssets(state) -- 206
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 207
	Content:mkdir(importedAbsolutePath) -- 208
	refreshAssetSearchPath(importedAssetRoot) -- 209
	rememberAsset(state, importedAssetRootEntry) -- 210
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 211
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 212
		rememberAsset(state, asset) -- 213
	end -- 213
	sortAssets(state) -- 215
end -- 206
function notifyWebIDEFileAdded(workspaceRelativePath) -- 218
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 219
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 220
	if payload ~= nil then -- 220
		emit("AppWS", "Send", payload) -- 227
	end -- 227
end -- 227
function copyFileToImported(srcPath, importedPath) -- 231
	local target = ____exports.workspacePath(importedPath) -- 232
	Content:mkdir(Path:getPath(target)) -- 233
	if srcPath == target or Content:copy(srcPath, target) then -- 233
		refreshAssetSearchPath(importedPath) -- 235
		notifyWebIDEFileAdded(importedPath) -- 236
		return importedPath -- 237
	end -- 237
	Content:clearPathCache() -- 239
	return nil -- 240
end -- 240
function ____exports.addAssetFolder(state, folderPath) -- 263
	if folderPath == "" then -- 263
		return nil -- 264
	end -- 264
	local folderName = Path:getName(folderPath) or "Folder" -- 265
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 266
	rememberAsset(state, importedAssetRootEntry) -- 267
	rememberAsset(state, rootAsset) -- 268
	local added = 0 -- 269
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 270
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 271
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 272
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 273
		local asset = copyFileToImported(absoluteFile, importedFile) -- 274
		if asset ~= nil then -- 274
			rememberAsset(state, asset) -- 276
			added = added + 1 -- 277
		end -- 277
	end -- 277
	____exports.refreshImportedAssets(state) -- 280
	state.selectedAsset = rootAsset -- 281
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 282
	____exports.pushConsole(state, state.status) -- 283
	return rootAsset -- 284
end -- 263
local localeMatch = string.match(App.locale, "^zh") -- 30
____exports.zh = localeMatch ~= nil -- 31
importedAssetRoot = "Imported" -- 33
importedAssetRootEntry = importedAssetRoot .. "/" -- 34
function ____exports.makeBuffer(text, size) -- 70
	local buffer = Buffer(size) -- 71
	buffer.text = text -- 72
	return buffer -- 73
end -- 70
function ____exports.createEditorState() -- 76
	Content:addSearchPath(____exports.workspaceRoot()) -- 77
	Content:mkdir(____exports.workspacePath(importedAssetRoot)) -- 78
	local state = { -- 79
		nextId = 0, -- 80
		selectedId = "root", -- 81
		mode = "2D", -- 82
		zoom = 100, -- 83
		showGrid = true, -- 84
		snapEnabled = false, -- 85
		viewportTool = "Select", -- 86
		leftWidth = 280, -- 87
		rightWidth = 340, -- 88
		bottomHeight = 132, -- 89
		gameWidth = 960, -- 90
		gameHeight = 540, -- 91
		gameScript = "Script/Main.lua", -- 92
		gameScriptBuffer = ____exports.makeBuffer("Script/Main.lua", 256), -- 93
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 94
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 95
		nodes = {}, -- 96
		order = {}, -- 97
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 98
		previewDirty = true, -- 99
		runtimeNodes = {}, -- 100
		runtimeLabels = {}, -- 101
		isPlaying = false, -- 102
		gameWindowOpen = false, -- 103
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 104
		playDirty = true, -- 105
		playRuntimeNodes = {}, -- 106
		playRuntimeLabels = {}, -- 107
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 108
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 109
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 110
		selectedAsset = "", -- 111
		assets = {}, -- 112
		viewportPanX = 0, -- 113
		viewportPanY = 0, -- 114
		draggingViewport = false -- 115
	} -- 115
	____exports.refreshImportedAssets(state) -- 117
	return state -- 118
end -- 76
function ____exports.iconFor(kind) -- 128
	if kind == "Sprite" then -- 128
		return "▣" -- 129
	end -- 129
	if kind == "Label" then -- 129
		return "T" -- 130
	end -- 130
	if kind == "Camera" then -- 130
		return "◉" -- 131
	end -- 131
	return "○" -- 132
end -- 128
function ____exports.lowerExt(path) -- 135
	local ext = Path:getExt(path or "") or "" -- 136
	return string.lower(ext) -- 137
end -- 135
function ____exports.isTextureAsset(path) -- 140
	local ext = ____exports.lowerExt(path) -- 141
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 142
end -- 140
function ____exports.isScriptAsset(path) -- 145
	local ext = ____exports.lowerExt(path) -- 146
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 147
end -- 145
function ____exports.addAssetPath(state, path, importedPath) -- 243
	if path == nil or path == "" then -- 243
		return nil -- 244
	end -- 244
	if Content:isdir(path) then -- 244
		return ____exports.addAssetFolder(state, path) -- 246
	end -- 246
	local asset = copyFileToImported( -- 248
		path, -- 248
		importedPath or Path( -- 248
			importedAssetRoot, -- 248
			Path:getFilename(path) -- 248
		) -- 248
	) -- 248
	if asset == nil then -- 248
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 250
		____exports.pushConsole(state, state.status) -- 251
		return nil -- 252
	end -- 252
	rememberAsset(state, asset) -- 254
	rememberAsset(state, importedAssetRootEntry) -- 255
	____exports.refreshImportedAssets(state) -- 256
	state.selectedAsset = asset -- 257
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 258
	____exports.pushConsole(state, state.status) -- 259
	return asset -- 260
end -- 243
function ____exports.importFileDialog(state) -- 287
	App:openFileDialog( -- 288
		false, -- 288
		function(path) -- 288
			____exports.addAssetPath(state, path) -- 289
		end -- 288
	) -- 288
end -- 287
function ____exports.importFolderDialog(state) -- 293
	App:openFileDialog( -- 294
		true, -- 294
		function(path) -- 294
			____exports.addAssetFolder(state, path) -- 295
		end -- 294
	) -- 294
end -- 293
local function newNodeId(state, kind) -- 299
	state.nextId = state.nextId + 1 -- 300
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 301
end -- 299
function ____exports.addNode(state, kind, name, parentId) -- 304
	local resolvedParentId = parentId or "root" -- 305
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 306
	local index = state.nextId -- 307
	local node = { -- 308
		id = id, -- 309
		kind = kind, -- 310
		name = name, -- 311
		parentId = resolvedParentId, -- 312
		children = {}, -- 313
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 314
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 315
		scaleX = 1, -- 316
		scaleY = 1, -- 317
		rotation = 0, -- 318
		visible = true, -- 319
		texture = "", -- 320
		text = kind == "Label" and "Label" or "", -- 321
		script = "", -- 322
		followTargetId = "", -- 323
		followOffsetX = 0, -- 324
		followOffsetY = 0, -- 325
		nameBuffer = ____exports.makeBuffer(name, 128), -- 326
		textureBuffer = ____exports.makeBuffer("", 256), -- 327
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 328
		scriptBuffer = ____exports.makeBuffer("", 256), -- 329
		followTargetBuffer = ____exports.makeBuffer("", 128) -- 330
	} -- 330
	state.nodes[id] = node -- 332
	local ____state_order_2 = state.order -- 332
	____state_order_2[#____state_order_2 + 1] = id -- 333
	local parent = state.nodes[resolvedParentId] -- 334
	if id ~= "root" and parent ~= nil then -- 334
		local ____parent_children_3 = parent.children -- 334
		____parent_children_3[#____parent_children_3 + 1] = id -- 336
	end -- 336
	return node -- 338
end -- 304
local function sceneNodeKind(value) -- 341
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 341
		return value -- 343
	end -- 343
	return "Node" -- 345
end -- 341
local function stringValue(value, fallback) -- 348
	return type(value) == "string" and value or fallback -- 349
end -- 348
local function numberValue(value, fallback) -- 352
	if type(value) ~= "number" and type(value) ~= "string" then -- 352
		return fallback -- 353
	end -- 353
	local parsed = tonumber(value) -- 354
	return parsed ~= nil and parsed or fallback -- 355
end -- 352
local function booleanValue(value, fallback) -- 358
	local ____temp_4 -- 359
	if type(value) == "boolean" then -- 359
		____temp_4 = value -- 359
	else -- 359
		____temp_4 = fallback -- 359
	end -- 359
	return ____temp_4 -- 359
end -- 358
local function updateNextIdFromNodeId(state, id) -- 362
	local digits = string.match(id, "%-(%d+)$") -- 363
	if digits ~= nil then -- 363
		local value = tonumber(digits) -- 365
		if value ~= nil and value > state.nextId then -- 365
			state.nextId = value -- 366
		end -- 366
	end -- 366
end -- 362
function ____exports.loadSceneFromFile(state, file) -- 370
	if not Content:exist(file) then -- 370
		return false -- 371
	end -- 371
	local decoded = json.decode(Content:load(file)) -- 372
	local data = decoded -- 373
	if data == nil then -- 373
		return false -- 374
	end -- 374
	local rawNodes = data.nodes -- 375
	if rawNodes == nil then -- 375
		return false -- 376
	end -- 376
	state.gameWidth = math.max( -- 377
		160, -- 377
		math.min( -- 377
			8192, -- 377
			numberValue(data.gameWidth, state.gameWidth or 960) -- 377
		) -- 377
	) -- 377
	state.gameHeight = math.max( -- 378
		120, -- 378
		math.min( -- 378
			8192, -- 378
			numberValue(data.gameHeight, state.gameHeight or 540) -- 378
		) -- 378
	) -- 378
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 379
	state.gameScriptBuffer.text = state.gameScript -- 380
	state.nodes = {} -- 382
	state.order = {} -- 383
	state.runtimeNodes = {} -- 384
	state.runtimeLabels = {} -- 385
	state.playRuntimeNodes = {} -- 386
	state.playRuntimeLabels = {} -- 387
	state.nextId = 0 -- 388
	for ____, raw in ipairs(rawNodes) do -- 390
		local kind = sceneNodeKind(raw.kind) -- 391
		local id = stringValue( -- 392
			raw.id, -- 392
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 392
		) -- 392
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 393
		local texture = stringValue(raw.texture, "") -- 394
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 395
		local script = stringValue(raw.script, "") -- 396
		local followTargetId = stringValue(raw.followTargetId, "") -- 397
		local followOffsetX = numberValue(raw.followOffsetX, 0) -- 398
		local followOffsetY = numberValue(raw.followOffsetY, 0) -- 399
		local ____temp_5 -- 400
		if id == "root" then -- 400
			____temp_5 = nil -- 400
		else -- 400
			____temp_5 = stringValue(raw.parentId, "root") -- 400
		end -- 400
		local parentId = ____temp_5 -- 400
		local node = { -- 401
			id = id, -- 402
			kind = kind, -- 403
			name = name, -- 404
			parentId = parentId, -- 405
			children = {}, -- 406
			x = numberValue(raw.x, 0), -- 407
			y = numberValue(raw.y, 0), -- 408
			scaleX = numberValue(raw.scaleX, 1), -- 409
			scaleY = numberValue(raw.scaleY, 1), -- 410
			rotation = numberValue(raw.rotation, 0), -- 411
			visible = booleanValue(raw.visible, true), -- 412
			texture = texture, -- 413
			text = text, -- 414
			script = script, -- 415
			followTargetId = followTargetId, -- 416
			followOffsetX = followOffsetX, -- 417
			followOffsetY = followOffsetY, -- 418
			nameBuffer = ____exports.makeBuffer(name, 128), -- 419
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 420
			textBuffer = ____exports.makeBuffer(text, 256), -- 421
			scriptBuffer = ____exports.makeBuffer(script, 256), -- 422
			followTargetBuffer = ____exports.makeBuffer(followTargetId, 128) -- 423
		} -- 423
		state.nodes[id] = node -- 425
		local ____state_order_6 = state.order -- 425
		____state_order_6[#____state_order_6 + 1] = id -- 426
		updateNextIdFromNodeId(state, id) -- 427
	end -- 427
	if state.nodes.root == nil then -- 427
		____exports.addNode(state, "Root", "MainScene") -- 431
	end -- 431
	for ____, id in ipairs(state.order) do -- 433
		do -- 433
			if id == "root" then -- 433
				goto __continue84 -- 434
			end -- 434
			local node = state.nodes[id] -- 435
			if node == nil then -- 435
				goto __continue84 -- 436
			end -- 436
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 436
				node.parentId = "root" -- 438
			end -- 438
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 438
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 440
		end -- 440
		::__continue84:: -- 440
	end -- 440
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 442
	state.previewDirty = true -- 443
	state.playDirty = true -- 444
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 445
	____exports.pushConsole(state, state.status) -- 446
	return true -- 447
end -- 370
local function removeFromOrder(state, id) -- 450
	do -- 450
		local i = #state.order -- 451
		while i >= 1 do -- 451
			if state.order[i] == id then -- 451
				table.remove(state.order, i) -- 453
			end -- 453
			i = i - 1 -- 451
		end -- 451
	end -- 451
end -- 450
function ____exports.deleteNode(state, id) -- 458
	if id == "root" then -- 458
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 460
		return -- 461
	end -- 461
	local node = state.nodes[id] -- 463
	if node == nil then -- 463
		return -- 464
	end -- 464
	do -- 464
		local i = #node.children -- 465
		while i >= 1 do -- 465
			____exports.deleteNode(state, node.children[i]) -- 466
			i = i - 1 -- 465
		end -- 465
	end -- 465
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 468
	if parent ~= nil then -- 468
		do -- 468
			local i = #parent.children -- 470
			while i >= 1 do -- 470
				if parent.children[i] == id then -- 470
					table.remove(parent.children, i) -- 471
				end -- 471
				i = i - 1 -- 470
			end -- 470
		end -- 470
	end -- 470
	__TS__Delete(state.nodes, id) -- 474
	removeFromOrder(state, id) -- 475
	state.selectedId = "root" -- 476
	state.draggingNodeId = nil -- 477
	state.previewDirty = true -- 478
	state.playDirty = true -- 479
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 480
	____exports.pushConsole(state, state.status) -- 481
end -- 458
local function worldPositionOf(state, id) -- 484
	local x = 0 -- 485
	local y = 0 -- 486
	local cursor = state.nodes[id] -- 487
	while cursor ~= nil do -- 487
		x = x + cursor.x -- 489
		y = y + cursor.y -- 490
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 491
	end -- 491
	return {x, y} -- 493
end -- 484
function ____exports.reparentNode(state, id, newParentId) -- 496
	if id == "root" then -- 496
		return false -- 497
	end -- 497
	local node = state.nodes[id] -- 498
	local newParent = state.nodes[newParentId] -- 499
	if node == nil or newParent == nil or node.parentId == newParentId then -- 499
		return false -- 500
	end -- 500
	local worldX, worldY = table.unpack( -- 501
		worldPositionOf(state, id), -- 501
		1, -- 501
		2 -- 501
	) -- 501
	local cursor = newParent -- 502
	while cursor ~= nil do -- 502
		if cursor.id == id then -- 502
			return false -- 504
		end -- 504
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 505
	end -- 505
	local oldParent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 507
	if oldParent ~= nil then -- 507
		do -- 507
			local i = #oldParent.children -- 509
			while i >= 1 do -- 509
				if oldParent.children[i] == id then -- 509
					table.remove(oldParent.children, i) -- 510
				end -- 510
				i = i - 1 -- 509
			end -- 509
		end -- 509
	end -- 509
	node.parentId = newParentId -- 513
	local parentWorldX, parentWorldY = table.unpack( -- 514
		worldPositionOf(state, newParentId), -- 514
		1, -- 514
		2 -- 514
	) -- 514
	node.x = worldX - parentWorldX -- 515
	node.y = worldY - parentWorldY -- 516
	local ____newParent_children_8 = newParent.children -- 516
	____newParent_children_8[#____newParent_children_8 + 1] = id -- 517
	state.previewDirty = true -- 518
	state.playDirty = true -- 519
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 520
	____exports.pushConsole(state, state.status) -- 521
	return true -- 522
end -- 496
function ____exports.addChildNode(state, kind) -- 525
	local parentId = state.selectedId or "root" -- 526
	if state.nodes[parentId] == nil then -- 526
		parentId = "root" -- 527
	end -- 527
	if state.nodes[parentId].kind == "Camera" then -- 527
		parentId = state.nodes[parentId].parentId or "root" -- 529
	end -- 529
	local node = ____exports.addNode( -- 531
		state, -- 531
		kind, -- 531
		kind .. tostring(state.nextId + 1), -- 531
		parentId -- 531
	) -- 531
	state.selectedId = node.id -- 532
	state.previewDirty = true -- 533
	state.playDirty = true -- 534
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 535
	____exports.pushConsole(state, state.status) -- 536
end -- 525
return ____exports -- 525