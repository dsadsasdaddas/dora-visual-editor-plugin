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
	return (string.lower(kind) .. "-") .. (tostring(state.nextId) or "0") -- 302
end -- 300
function ____exports.addNode(state, kind, name, parentId) -- 305
	local resolvedParentId = "root" -- 306
	if kind == "Root" then -- 306
		resolvedParentId = "" -- 308
	elseif parentId ~= nil and parentId ~= "" then -- 308
		resolvedParentId = parentId -- 310
	end -- 310
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 312
	local index = state.nextId -- 313
	local node = { -- 314
		id = id, -- 315
		kind = kind, -- 316
		name = name, -- 317
		parentId = resolvedParentId, -- 318
		children = {}, -- 319
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 320
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 321
		scaleX = 1, -- 322
		scaleY = 1, -- 323
		rotation = 0, -- 324
		visible = true, -- 325
		texture = "", -- 326
		text = kind == "Label" and "Label" or "", -- 327
		script = "", -- 328
		followTargetId = "", -- 329
		followOffsetX = 0, -- 330
		followOffsetY = 0, -- 331
		nameBuffer = ____exports.makeBuffer(name, 128), -- 332
		textureBuffer = ____exports.makeBuffer("", 256), -- 333
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 334
		scriptBuffer = ____exports.makeBuffer("", 256), -- 335
		followTargetBuffer = ____exports.makeBuffer("", 128) -- 336
	} -- 336
	state.nodes[id] = node -- 338
	local ____state_order_2 = state.order -- 338
	____state_order_2[#____state_order_2 + 1] = id -- 339
	local parent = resolvedParentId ~= "" and state.nodes[resolvedParentId] or nil -- 340
	if id ~= "root" and parent ~= nil then -- 340
		local ____parent_children_3 = parent.children -- 340
		____parent_children_3[#____parent_children_3 + 1] = id -- 342
	end -- 342
	return node -- 344
end -- 305
local function sceneNodeKind(value) -- 347
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 347
		return value -- 349
	end -- 349
	return "Node" -- 351
end -- 347
local function stringValue(value, fallback) -- 354
	return type(value) == "string" and value or fallback -- 355
end -- 354
local function numberValue(value, fallback) -- 358
	if type(value) ~= "number" and type(value) ~= "string" then -- 358
		return fallback -- 359
	end -- 359
	local parsed = tonumber(value) -- 360
	return parsed ~= nil and parsed or fallback -- 361
end -- 358
local function booleanValue(value, fallback) -- 364
	local ____temp_4 -- 365
	if type(value) == "boolean" then -- 365
		____temp_4 = value -- 365
	else -- 365
		____temp_4 = fallback -- 365
	end -- 365
	return ____temp_4 -- 365
end -- 364
local function updateNextIdFromNodeId(state, id) -- 368
	local digits = string.match(id, "%-(%d+)$") -- 369
	if digits ~= nil then -- 369
		local value = tonumber(digits) -- 371
		if value ~= nil and value > state.nextId then -- 371
			state.nextId = value -- 372
		end -- 372
	end -- 372
end -- 368
function ____exports.loadSceneFromFile(state, file) -- 376
	if not Content:exist(file) then -- 376
		return false -- 377
	end -- 377
	local decoded = json.decode(Content:load(file)) -- 378
	local data = decoded -- 379
	if data == nil then -- 379
		return false -- 380
	end -- 380
	local rawNodes = data.nodes -- 381
	if rawNodes == nil then -- 381
		return false -- 382
	end -- 382
	state.gameWidth = math.max( -- 383
		160, -- 383
		math.min( -- 383
			8192, -- 383
			numberValue(data.gameWidth, state.gameWidth or 960) -- 383
		) -- 383
	) -- 383
	state.gameHeight = math.max( -- 384
		120, -- 384
		math.min( -- 384
			8192, -- 384
			numberValue(data.gameHeight, state.gameHeight or 540) -- 384
		) -- 384
	) -- 384
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 385
	state.gameScriptBuffer.text = state.gameScript -- 386
	state.nodes = {} -- 388
	state.order = {} -- 389
	state.runtimeNodes = {} -- 390
	state.runtimeLabels = {} -- 391
	state.playRuntimeNodes = {} -- 392
	state.playRuntimeLabels = {} -- 393
	state.nextId = 0 -- 394
	for ____, raw in ipairs(rawNodes) do -- 396
		local kind = sceneNodeKind(raw.kind) -- 397
		local id = stringValue( -- 398
			raw.id, -- 398
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 398
		) -- 398
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 399
		local texture = stringValue(raw.texture, "") -- 400
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 401
		local script = stringValue(raw.script, "") -- 402
		local followTargetId = stringValue(raw.followTargetId, "") -- 403
		local followOffsetX = numberValue(raw.followOffsetX, 0) -- 404
		local followOffsetY = numberValue(raw.followOffsetY, 0) -- 405
		local ____temp_5 -- 406
		if id == "root" then -- 406
			____temp_5 = nil -- 406
		else -- 406
			____temp_5 = stringValue(raw.parentId, "root") -- 406
		end -- 406
		local parentId = ____temp_5 -- 406
		local node = { -- 407
			id = id, -- 408
			kind = kind, -- 409
			name = name, -- 410
			parentId = parentId, -- 411
			children = {}, -- 412
			x = numberValue(raw.x, 0), -- 413
			y = numberValue(raw.y, 0), -- 414
			scaleX = numberValue(raw.scaleX, 1), -- 415
			scaleY = numberValue(raw.scaleY, 1), -- 416
			rotation = numberValue(raw.rotation, 0), -- 417
			visible = booleanValue(raw.visible, true), -- 418
			texture = texture, -- 419
			text = text, -- 420
			script = script, -- 421
			followTargetId = followTargetId, -- 422
			followOffsetX = followOffsetX, -- 423
			followOffsetY = followOffsetY, -- 424
			nameBuffer = ____exports.makeBuffer(name, 128), -- 425
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 426
			textBuffer = ____exports.makeBuffer(text, 256), -- 427
			scriptBuffer = ____exports.makeBuffer(script, 256), -- 428
			followTargetBuffer = ____exports.makeBuffer(followTargetId, 128) -- 429
		} -- 429
		state.nodes[id] = node -- 431
		local ____state_order_6 = state.order -- 431
		____state_order_6[#____state_order_6 + 1] = id -- 432
		updateNextIdFromNodeId(state, id) -- 433
	end -- 433
	if state.nodes.root == nil then -- 433
		____exports.addNode(state, "Root", "MainScene") -- 437
	end -- 437
	for ____, id in ipairs(state.order) do -- 439
		do -- 439
			if id == "root" then -- 439
				goto __continue86 -- 440
			end -- 440
			local node = state.nodes[id] -- 441
			if node == nil then -- 441
				goto __continue86 -- 442
			end -- 442
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 442
				node.parentId = "root" -- 444
			end -- 444
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 444
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 446
		end -- 446
		::__continue86:: -- 446
	end -- 446
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 448
	state.previewDirty = true -- 449
	state.playDirty = true -- 450
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 451
	____exports.pushConsole(state, state.status) -- 452
	return true -- 453
end -- 376
local function removeFromOrder(state, id) -- 456
	do -- 456
		local i = #state.order -- 457
		while i >= 1 do -- 457
			if state.order[i] == id then -- 457
				table.remove(state.order, i) -- 459
			end -- 459
			i = i - 1 -- 457
		end -- 457
	end -- 457
end -- 456
function ____exports.deleteNode(state, id) -- 464
	if id == "root" then -- 464
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 466
		return -- 467
	end -- 467
	local node = state.nodes[id] -- 469
	if node == nil then -- 469
		return -- 470
	end -- 470
	do -- 470
		local i = #node.children -- 471
		while i >= 1 do -- 471
			____exports.deleteNode(state, node.children[i]) -- 472
			i = i - 1 -- 471
		end -- 471
	end -- 471
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 474
	if parent ~= nil then -- 474
		do -- 474
			local i = #parent.children -- 476
			while i >= 1 do -- 476
				if parent.children[i] == id then -- 476
					table.remove(parent.children, i) -- 477
				end -- 477
				i = i - 1 -- 476
			end -- 476
		end -- 476
	end -- 476
	__TS__Delete(state.nodes, id) -- 480
	removeFromOrder(state, id) -- 481
	state.selectedId = "root" -- 482
	state.draggingNodeId = nil -- 483
	state.previewDirty = true -- 484
	state.playDirty = true -- 485
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 486
	____exports.pushConsole(state, state.status) -- 487
end -- 464
local function worldPositionOf(state, id) -- 490
	local x = 0 -- 491
	local y = 0 -- 492
	local visited = {} -- 493
	local cursor = state.nodes[id] -- 494
	while cursor ~= nil do -- 494
		if visited[cursor.id] then -- 494
			break -- 496
		end -- 496
		visited[cursor.id] = true -- 497
		x = x + cursor.x -- 498
		y = y + cursor.y -- 499
		if cursor.parentId == nil or cursor.parentId == cursor.id then -- 499
			break -- 500
		end -- 500
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 501
	end -- 501
	return {x, y} -- 503
end -- 490
function ____exports.reparentNode(state, id, newParentId) -- 506
	if id == "root" then -- 506
		return false -- 507
	end -- 507
	local node = state.nodes[id] -- 508
	local newParent = state.nodes[newParentId] -- 509
	if node == nil or newParent == nil or node.parentId == newParentId then -- 509
		return false -- 510
	end -- 510
	local worldX, worldY = table.unpack( -- 511
		worldPositionOf(state, id), -- 511
		1, -- 511
		2 -- 511
	) -- 511
	local visited = {} -- 512
	local cursor = newParent -- 513
	while cursor ~= nil do -- 513
		if cursor.id == id then -- 513
			return false -- 515
		end -- 515
		if visited[cursor.id] then -- 515
			return false -- 516
		end -- 516
		visited[cursor.id] = true -- 517
		if cursor.parentId == nil or cursor.parentId == cursor.id then -- 517
			break -- 518
		end -- 518
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 519
	end -- 519
	local oldParent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 521
	if oldParent ~= nil then -- 521
		do -- 521
			local i = #oldParent.children -- 523
			while i >= 1 do -- 523
				if oldParent.children[i] == id then -- 523
					table.remove(oldParent.children, i) -- 524
				end -- 524
				i = i - 1 -- 523
			end -- 523
		end -- 523
	end -- 523
	node.parentId = newParentId -- 527
	local parentWorldX, parentWorldY = table.unpack( -- 528
		worldPositionOf(state, newParentId), -- 528
		1, -- 528
		2 -- 528
	) -- 528
	node.x = worldX - parentWorldX -- 529
	node.y = worldY - parentWorldY -- 530
	local ____newParent_children_8 = newParent.children -- 530
	____newParent_children_8[#____newParent_children_8 + 1] = id -- 531
	state.previewDirty = true -- 532
	state.playDirty = true -- 533
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 534
	____exports.pushConsole(state, state.status) -- 535
	return true -- 536
end -- 506
function ____exports.resolveAddParentId(state) -- 539
	local parentId = state.selectedId or "root" -- 540
	if state.nodes[parentId] == nil then -- 540
		parentId = "root" -- 541
	end -- 541
	local selected = state.nodes[parentId] -- 542
	if selected ~= nil and selected.kind == "Camera" then -- 542
		parentId = selected.parentId or "root" -- 544
	end -- 544
	if state.nodes[parentId] == nil then -- 544
		return "root" -- 546
	end -- 546
	return parentId -- 547
end -- 539
function ____exports.nodePath(state, id) -- 550
	local parts = {} -- 551
	local visited = {} -- 552
	local cursor = state.nodes[id] -- 553
	while cursor ~= nil do -- 553
		if visited[cursor.id] then -- 553
			break -- 555
		end -- 555
		visited[cursor.id] = true -- 556
		parts[#parts + 1] = cursor.name -- 557
		if cursor.parentId == nil or cursor.parentId == cursor.id then -- 557
			break -- 558
		end -- 558
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 559
	end -- 559
	local path = "" -- 561
	do -- 561
		local i = #parts -- 562
		while i >= 1 do -- 562
			path = path .. (path == "" and "" or " / ") .. parts[i] -- 563
			i = i - 1 -- 562
		end -- 562
	end -- 562
	return path == "" and "Root" or path -- 565
end -- 550
function ____exports.addChildNode(state, kind) -- 568
	local parentId = ____exports.resolveAddParentId(state) -- 569
	local node = ____exports.addNode( -- 570
		state, -- 570
		kind, -- 570
		kind .. (tostring(state.nextId + 1) or ""), -- 570
		parentId -- 570
	) -- 570
	state.selectedId = node.id -- 571
	state.previewDirty = true -- 572
	state.playDirty = true -- 573
	local parent = state.nodes[parentId] -- 574
	state.status = ((____exports.zh and "已添加 " or "Added ") .. node.name) .. (parent ~= nil and (____exports.zh and " 到 " or " under ") .. parent.name or "") -- 575
	____exports.pushConsole(state, state.status) -- 576
end -- 568
return ____exports -- 568