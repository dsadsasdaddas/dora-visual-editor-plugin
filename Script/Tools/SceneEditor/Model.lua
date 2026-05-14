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
function isPathInside(path, root) -- 37
	local cleanPath = normalizeSlash(path) -- 38
	local cleanRoot = normalizeSlash(root) -- 39
	return cleanPath == cleanRoot or string.sub( -- 40
		cleanPath, -- 40
		1, -- 40
		string.len(cleanRoot) + 1 -- 40
	) == cleanRoot .. "/" -- 40
end -- 40
function isProjectRootDir(dir) -- 43
	if dir == "" or not Content:exist(dir) or not Content:isdir(dir) then -- 43
		return false -- 44
	end -- 44
	for ____, file in ipairs(Content:getFiles(dir)) do -- 45
		if string.lower(Path:getName(file)) == "init" then -- 45
			return true -- 46
		end -- 46
	end -- 46
	local agentDir = Path(dir, ".agent") -- 48
	return Content:exist(agentDir) and Content:isdir(agentDir) -- 49
end -- 49
function detectWorkspaceRoot() -- 52
	for ____, searchPath in ipairs(Content.searchPaths) do -- 53
		local candidate = searchPath -- 54
		if Path:getFilename(candidate) == "Script" then -- 54
			candidate = Path:getPath(candidate) -- 55
		end -- 55
		if candidate ~= Content.writablePath and isPathInside(candidate, Content.writablePath) and isProjectRootDir(candidate) then -- 55
			return candidate -- 57
		end -- 57
	end -- 57
	return Content.writablePath -- 60
end -- 60
function ____exports.workspaceRoot() -- 63
	return detectWorkspaceRoot() -- 64
end -- 63
function ____exports.workspacePath(path) -- 67
	return Path( -- 68
		____exports.workspaceRoot(), -- 68
		path -- 68
	) -- 68
end -- 67
function ____exports.pushConsole(state, message) -- 122
	local ____state_console_0 = state.console -- 122
	____state_console_0[#____state_console_0 + 1] = message -- 123
	if #state.console > 7 then -- 123
		table.remove(state.console, 1) -- 125
	end -- 125
end -- 122
function ____exports.isFolderAsset(path) -- 151
	return path ~= "" and string.sub( -- 152
		path, -- 152
		string.len(path), -- 152
		string.len(path) -- 152
	) == "/" -- 152
end -- 151
function hasAsset(state, asset) -- 155
	for ____, item in ipairs(state.assets) do -- 156
		if item == asset then -- 156
			return true -- 157
		end -- 157
	end -- 157
	return false -- 159
end -- 159
function rememberAsset(state, asset) -- 162
	if asset == "" then -- 162
		return -- 163
	end -- 163
	if not hasAsset(state, asset) then -- 163
		local ____state_assets_1 = state.assets -- 163
		____state_assets_1[#____state_assets_1 + 1] = asset -- 164
	end -- 164
end -- 164
function sortAssets(state) -- 167
	table.sort( -- 168
		state.assets, -- 168
		function(a, b) -- 168
			local aFolder = ____exports.isFolderAsset(a) -- 169
			local bFolder = ____exports.isFolderAsset(b) -- 170
			if aFolder == bFolder then -- 170
				return a < b -- 171
			end -- 171
			return aFolder -- 172
		end -- 168
	) -- 168
end -- 168
function normalizeSlash(path) -- 176
	local result = string.gsub(path, "\\", "/") -- 177
	local found = string.find(result, "//") -- 178
	while found ~= nil do -- 178
		result = string.gsub(result, "//", "/") -- 180
		found = string.find(result, "//") -- 181
	end -- 181
	return result -- 183
end -- 183
function stripFolderPrefix(folder, path) -- 186
	local cleanFolder = normalizeSlash(folder) -- 187
	local cleanPath = normalizeSlash(path) -- 188
	if string.sub( -- 188
		cleanPath, -- 189
		1, -- 189
		string.len(cleanFolder) -- 189
	) == cleanFolder then -- 189
		local rest = string.sub( -- 190
			cleanPath, -- 190
			string.len(cleanFolder) + 1 -- 190
		) -- 190
		if string.sub(rest, 1, 1) == "/" then -- 190
			rest = string.sub(rest, 2) -- 191
		end -- 191
		return rest -- 192
	end -- 192
	return Path:getFilename(path) -- 194
end -- 194
function refreshAssetSearchPath(importedPath) -- 197
	Content:addSearchPath(____exports.workspaceRoot()) -- 198
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 199
	if importedPath ~= nil and importedPath ~= "" then -- 199
		local importedFolder = Path:getPath(importedPath) -- 201
		if importedFolder ~= "" then -- 201
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 202
		end -- 202
	end -- 202
	Content:clearPathCache() -- 204
end -- 204
function ____exports.refreshImportedAssets(state) -- 207
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 208
	Content:mkdir(importedAbsolutePath) -- 209
	refreshAssetSearchPath(importedAssetRoot) -- 210
	rememberAsset(state, importedAssetRootEntry) -- 211
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 212
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 213
		rememberAsset(state, asset) -- 214
	end -- 214
	sortAssets(state) -- 216
end -- 207
function notifyWebIDEFileAdded(workspaceRelativePath) -- 219
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 220
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 221
	if payload ~= nil then -- 221
		emit("AppWS", "Send", payload) -- 228
	end -- 228
end -- 228
function copyFileToImported(srcPath, importedPath) -- 232
	local target = ____exports.workspacePath(importedPath) -- 233
	Content:mkdir(Path:getPath(target)) -- 234
	if srcPath == target or Content:copy(srcPath, target) then -- 234
		refreshAssetSearchPath(importedPath) -- 236
		notifyWebIDEFileAdded(importedPath) -- 237
		return importedPath -- 238
	end -- 238
	Content:clearPathCache() -- 240
	return nil -- 241
end -- 241
function ____exports.addAssetFolder(state, folderPath) -- 264
	if folderPath == "" then -- 264
		return nil -- 265
	end -- 265
	local folderName = Path:getName(folderPath) or "Folder" -- 266
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 267
	rememberAsset(state, importedAssetRootEntry) -- 268
	rememberAsset(state, rootAsset) -- 269
	local added = 0 -- 270
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 271
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 272
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 273
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 274
		local asset = copyFileToImported(absoluteFile, importedFile) -- 275
		if asset ~= nil then -- 275
			rememberAsset(state, asset) -- 277
			added = added + 1 -- 278
		end -- 278
	end -- 278
	____exports.refreshImportedAssets(state) -- 281
	state.selectedAsset = rootAsset -- 282
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 283
	____exports.pushConsole(state, state.status) -- 284
	return rootAsset -- 285
end -- 264
local localeMatch = string.match(App.locale, "^zh") -- 30
____exports.zh = localeMatch ~= nil -- 31
importedAssetRoot = "Imported" -- 34
importedAssetRootEntry = importedAssetRoot .. "/" -- 35
function ____exports.makeBuffer(text, size) -- 71
	local buffer = Buffer(size) -- 72
	buffer.text = text -- 73
	return buffer -- 74
end -- 71
function ____exports.createEditorState() -- 77
	Content:addSearchPath(____exports.workspaceRoot()) -- 78
	Content:mkdir(____exports.workspacePath(importedAssetRoot)) -- 79
	local state = { -- 80
		nextId = 0, -- 81
		selectedId = "root", -- 82
		mode = "2D", -- 83
		zoom = 100, -- 84
		showGrid = true, -- 85
		snapEnabled = false, -- 86
		viewportTool = "Select", -- 87
		leftWidth = 280, -- 88
		rightWidth = 340, -- 89
		bottomHeight = 132, -- 90
		gameWidth = 960, -- 91
		gameHeight = 540, -- 92
		gameScript = "Script/Main.lua", -- 93
		gameScriptBuffer = ____exports.makeBuffer("Script/Main.lua", 256), -- 94
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 95
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 96
		nodes = {}, -- 97
		order = {}, -- 98
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 99
		previewDirty = true, -- 100
		runtimeNodes = {}, -- 101
		runtimeLabels = {}, -- 102
		isPlaying = false, -- 103
		gameWindowOpen = false, -- 104
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 105
		playDirty = true, -- 106
		playRuntimeNodes = {}, -- 107
		playRuntimeLabels = {}, -- 108
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 109
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 110
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 111
		selectedAsset = "", -- 112
		assets = {}, -- 113
		viewportPanX = 0, -- 114
		viewportPanY = 0, -- 115
		draggingViewport = false -- 116
	} -- 116
	____exports.refreshImportedAssets(state) -- 118
	return state -- 119
end -- 77
function ____exports.iconFor(kind) -- 129
	if kind == "Sprite" then -- 129
		return "▣" -- 130
	end -- 130
	if kind == "Label" then -- 130
		return "T" -- 131
	end -- 131
	if kind == "Camera" then -- 131
		return "◉" -- 132
	end -- 132
	return "○" -- 133
end -- 129
function ____exports.lowerExt(path) -- 136
	local ext = Path:getExt(path or "") or "" -- 137
	return string.lower(ext) -- 138
end -- 136
function ____exports.isTextureAsset(path) -- 141
	local ext = ____exports.lowerExt(path) -- 142
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 143
end -- 141
function ____exports.isScriptAsset(path) -- 146
	local ext = ____exports.lowerExt(path) -- 147
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 148
end -- 146
function ____exports.addAssetPath(state, path, importedPath) -- 244
	if path == nil or path == "" then -- 244
		return nil -- 245
	end -- 245
	if Content:isdir(path) then -- 245
		return ____exports.addAssetFolder(state, path) -- 247
	end -- 247
	local asset = copyFileToImported( -- 249
		path, -- 249
		importedPath or Path( -- 249
			importedAssetRoot, -- 249
			Path:getFilename(path) -- 249
		) -- 249
	) -- 249
	if asset == nil then -- 249
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 251
		____exports.pushConsole(state, state.status) -- 252
		return nil -- 253
	end -- 253
	rememberAsset(state, asset) -- 255
	rememberAsset(state, importedAssetRootEntry) -- 256
	____exports.refreshImportedAssets(state) -- 257
	state.selectedAsset = asset -- 258
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 259
	____exports.pushConsole(state, state.status) -- 260
	return asset -- 261
end -- 244
function ____exports.importFileDialog(state) -- 288
	App:openFileDialog( -- 289
		false, -- 289
		function(path) -- 289
			____exports.addAssetPath(state, path) -- 290
		end -- 289
	) -- 289
end -- 288
function ____exports.importFolderDialog(state) -- 294
	App:openFileDialog( -- 295
		true, -- 295
		function(path) -- 295
			____exports.addAssetFolder(state, path) -- 296
		end -- 295
	) -- 295
end -- 294
local function newNodeId(state, kind) -- 300
	state.nextId = state.nextId + 1 -- 301
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 302
end -- 300
function ____exports.addNode(state, kind, name, parentId) -- 305
	local resolvedParentId = parentId or "root" -- 306
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 307
	local index = state.nextId -- 308
	local node = { -- 309
		id = id, -- 310
		kind = kind, -- 311
		name = name, -- 312
		parentId = resolvedParentId, -- 313
		children = {}, -- 314
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 315
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 316
		scaleX = 1, -- 317
		scaleY = 1, -- 318
		rotation = 0, -- 319
		visible = true, -- 320
		texture = "", -- 321
		text = kind == "Label" and "Label" or "", -- 322
		script = "", -- 323
		followTargetId = "", -- 324
		followOffsetX = 0, -- 325
		followOffsetY = 0, -- 326
		nameBuffer = ____exports.makeBuffer(name, 128), -- 327
		textureBuffer = ____exports.makeBuffer("", 256), -- 328
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 329
		scriptBuffer = ____exports.makeBuffer("", 256), -- 330
		followTargetBuffer = ____exports.makeBuffer("", 128) -- 331
	} -- 331
	state.nodes[id] = node -- 333
	local ____state_order_2 = state.order -- 333
	____state_order_2[#____state_order_2 + 1] = id -- 334
	local parent = state.nodes[resolvedParentId] -- 335
	if id ~= "root" and parent ~= nil then -- 335
		local ____parent_children_3 = parent.children -- 335
		____parent_children_3[#____parent_children_3 + 1] = id -- 337
	end -- 337
	return node -- 339
end -- 305
local function sceneNodeKind(value) -- 342
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 342
		return value -- 344
	end -- 344
	return "Node" -- 346
end -- 342
local function stringValue(value, fallback) -- 349
	return type(value) == "string" and value or fallback -- 350
end -- 349
local function numberValue(value, fallback) -- 353
	if type(value) ~= "number" and type(value) ~= "string" then -- 353
		return fallback -- 354
	end -- 354
	local parsed = tonumber(value) -- 355
	return parsed ~= nil and parsed or fallback -- 356
end -- 353
local function booleanValue(value, fallback) -- 359
	local ____temp_4 -- 360
	if type(value) == "boolean" then -- 360
		____temp_4 = value -- 360
	else -- 360
		____temp_4 = fallback -- 360
	end -- 360
	return ____temp_4 -- 360
end -- 359
local function updateNextIdFromNodeId(state, id) -- 363
	local digits = string.match(id, "%-(%d+)$") -- 364
	if digits ~= nil then -- 364
		local value = tonumber(digits) -- 366
		if value ~= nil and value > state.nextId then -- 366
			state.nextId = value -- 367
		end -- 367
	end -- 367
end -- 363
function ____exports.loadSceneFromFile(state, file) -- 371
	if not Content:exist(file) then -- 371
		return false -- 372
	end -- 372
	local decoded = json.decode(Content:load(file)) -- 373
	local data = decoded -- 374
	if data == nil then -- 374
		return false -- 375
	end -- 375
	local rawNodes = data.nodes -- 376
	if rawNodes == nil then -- 376
		return false -- 377
	end -- 377
	state.gameWidth = math.max( -- 378
		160, -- 378
		math.min( -- 378
			8192, -- 378
			numberValue(data.gameWidth, state.gameWidth or 960) -- 378
		) -- 378
	) -- 378
	state.gameHeight = math.max( -- 379
		120, -- 379
		math.min( -- 379
			8192, -- 379
			numberValue(data.gameHeight, state.gameHeight or 540) -- 379
		) -- 379
	) -- 379
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 380
	state.gameScriptBuffer.text = state.gameScript -- 381
	state.nodes = {} -- 383
	state.order = {} -- 384
	state.runtimeNodes = {} -- 385
	state.runtimeLabels = {} -- 386
	state.playRuntimeNodes = {} -- 387
	state.playRuntimeLabels = {} -- 388
	state.nextId = 0 -- 389
	for ____, raw in ipairs(rawNodes) do -- 391
		local kind = sceneNodeKind(raw.kind) -- 392
		local id = stringValue( -- 393
			raw.id, -- 393
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 393
		) -- 393
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 394
		local texture = stringValue(raw.texture, "") -- 395
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 396
		local script = stringValue(raw.script, "") -- 397
		local followTargetId = stringValue(raw.followTargetId, "") -- 398
		local followOffsetX = numberValue(raw.followOffsetX, 0) -- 399
		local followOffsetY = numberValue(raw.followOffsetY, 0) -- 400
		local ____temp_5 -- 401
		if id == "root" then -- 401
			____temp_5 = nil -- 401
		else -- 401
			____temp_5 = stringValue(raw.parentId, "root") -- 401
		end -- 401
		local parentId = ____temp_5 -- 401
		local node = { -- 402
			id = id, -- 403
			kind = kind, -- 404
			name = name, -- 405
			parentId = parentId, -- 406
			children = {}, -- 407
			x = numberValue(raw.x, 0), -- 408
			y = numberValue(raw.y, 0), -- 409
			scaleX = numberValue(raw.scaleX, 1), -- 410
			scaleY = numberValue(raw.scaleY, 1), -- 411
			rotation = numberValue(raw.rotation, 0), -- 412
			visible = booleanValue(raw.visible, true), -- 413
			texture = texture, -- 414
			text = text, -- 415
			script = script, -- 416
			followTargetId = followTargetId, -- 417
			followOffsetX = followOffsetX, -- 418
			followOffsetY = followOffsetY, -- 419
			nameBuffer = ____exports.makeBuffer(name, 128), -- 420
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 421
			textBuffer = ____exports.makeBuffer(text, 256), -- 422
			scriptBuffer = ____exports.makeBuffer(script, 256), -- 423
			followTargetBuffer = ____exports.makeBuffer(followTargetId, 128) -- 424
		} -- 424
		state.nodes[id] = node -- 426
		local ____state_order_6 = state.order -- 426
		____state_order_6[#____state_order_6 + 1] = id -- 427
		updateNextIdFromNodeId(state, id) -- 428
	end -- 428
	if state.nodes.root == nil then -- 428
		____exports.addNode(state, "Root", "MainScene") -- 432
	end -- 432
	for ____, id in ipairs(state.order) do -- 434
		do -- 434
			if id == "root" then -- 434
				goto __continue84 -- 435
			end -- 435
			local node = state.nodes[id] -- 436
			if node == nil then -- 436
				goto __continue84 -- 437
			end -- 437
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 437
				node.parentId = "root" -- 439
			end -- 439
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 439
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 441
		end -- 441
		::__continue84:: -- 441
	end -- 441
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 443
	state.previewDirty = true -- 444
	state.playDirty = true -- 445
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 446
	____exports.pushConsole(state, state.status) -- 447
	return true -- 448
end -- 371
local function removeFromOrder(state, id) -- 451
	do -- 451
		local i = #state.order -- 452
		while i >= 1 do -- 452
			if state.order[i] == id then -- 452
				table.remove(state.order, i) -- 454
			end -- 454
			i = i - 1 -- 452
		end -- 452
	end -- 452
end -- 451
function ____exports.deleteNode(state, id) -- 459
	if id == "root" then -- 459
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 461
		return -- 462
	end -- 462
	local node = state.nodes[id] -- 464
	if node == nil then -- 464
		return -- 465
	end -- 465
	do -- 465
		local i = #node.children -- 466
		while i >= 1 do -- 466
			____exports.deleteNode(state, node.children[i]) -- 467
			i = i - 1 -- 466
		end -- 466
	end -- 466
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 469
	if parent ~= nil then -- 469
		do -- 469
			local i = #parent.children -- 471
			while i >= 1 do -- 471
				if parent.children[i] == id then -- 471
					table.remove(parent.children, i) -- 472
				end -- 472
				i = i - 1 -- 471
			end -- 471
		end -- 471
	end -- 471
	__TS__Delete(state.nodes, id) -- 475
	removeFromOrder(state, id) -- 476
	state.selectedId = "root" -- 477
	state.draggingNodeId = nil -- 478
	state.previewDirty = true -- 479
	state.playDirty = true -- 480
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 481
	____exports.pushConsole(state, state.status) -- 482
end -- 459
local function worldPositionOf(state, id) -- 485
	local x = 0 -- 486
	local y = 0 -- 487
	local cursor = state.nodes[id] -- 488
	while cursor ~= nil do -- 488
		x = x + cursor.x -- 490
		y = y + cursor.y -- 491
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 492
	end -- 492
	return {x, y} -- 494
end -- 485
function ____exports.reparentNode(state, id, newParentId) -- 497
	if id == "root" then -- 497
		return false -- 498
	end -- 498
	local node = state.nodes[id] -- 499
	local newParent = state.nodes[newParentId] -- 500
	if node == nil or newParent == nil or node.parentId == newParentId then -- 500
		return false -- 501
	end -- 501
	local worldX, worldY = table.unpack( -- 502
		worldPositionOf(state, id), -- 502
		1, -- 502
		2 -- 502
	) -- 502
	local cursor = newParent -- 503
	while cursor ~= nil do -- 503
		if cursor.id == id then -- 503
			return false -- 505
		end -- 505
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 506
	end -- 506
	local oldParent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 508
	if oldParent ~= nil then -- 508
		do -- 508
			local i = #oldParent.children -- 510
			while i >= 1 do -- 510
				if oldParent.children[i] == id then -- 510
					table.remove(oldParent.children, i) -- 511
				end -- 511
				i = i - 1 -- 510
			end -- 510
		end -- 510
	end -- 510
	node.parentId = newParentId -- 514
	local parentWorldX, parentWorldY = table.unpack( -- 515
		worldPositionOf(state, newParentId), -- 515
		1, -- 515
		2 -- 515
	) -- 515
	node.x = worldX - parentWorldX -- 516
	node.y = worldY - parentWorldY -- 517
	local ____newParent_children_8 = newParent.children -- 517
	____newParent_children_8[#____newParent_children_8 + 1] = id -- 518
	state.previewDirty = true -- 519
	state.playDirty = true -- 520
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 521
	____exports.pushConsole(state, state.status) -- 522
	return true -- 523
end -- 497
function ____exports.addChildNode(state, kind) -- 526
	local parentId = state.selectedId or "root" -- 527
	if state.nodes[parentId] == nil then -- 527
		parentId = "root" -- 528
	end -- 528
	if state.nodes[parentId].kind == "Camera" then -- 528
		parentId = state.nodes[parentId].parentId or "root" -- 530
	end -- 530
	local node = ____exports.addNode( -- 532
		state, -- 532
		kind, -- 532
		kind .. tostring(state.nextId + 1), -- 532
		parentId -- 532
	) -- 532
	state.selectedId = node.id -- 533
	state.previewDirty = true -- 534
	state.playDirty = true -- 535
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 536
	____exports.pushConsole(state, state.status) -- 537
end -- 526
return ____exports -- 526