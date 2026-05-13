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
function isPathInside(path, root) -- 10
	local cleanPath = normalizeSlash(path) -- 11
	local cleanRoot = normalizeSlash(root) -- 12
	return cleanPath == cleanRoot or string.sub( -- 13
		cleanPath, -- 13
		1, -- 13
		string.len(cleanRoot) + 1 -- 13
	) == cleanRoot .. "/" -- 13
end -- 13
function isProjectRootDir(dir) -- 16
	if dir == "" or not Content:exist(dir) or not Content:isdir(dir) then -- 16
		return false -- 17
	end -- 17
	for ____, file in ipairs(Content:getFiles(dir)) do -- 18
		if string.lower(Path:getName(file)) == "init" then -- 18
			return true -- 19
		end -- 19
	end -- 19
	local agentDir = Path(dir, ".agent") -- 21
	return Content:exist(agentDir) and Content:isdir(agentDir) -- 22
end -- 22
function detectWorkspaceRoot() -- 25
	for ____, searchPath in ipairs(Content.searchPaths) do -- 26
		local candidate = searchPath -- 27
		if Path:getFilename(candidate) == "Script" then -- 27
			candidate = Path:getPath(candidate) -- 28
		end -- 28
		if candidate ~= Content.writablePath and isPathInside(candidate, Content.writablePath) and isProjectRootDir(candidate) then -- 28
			return candidate -- 30
		end -- 30
	end -- 30
	return Content.writablePath -- 33
end -- 33
function ____exports.workspaceRoot() -- 36
	return detectWorkspaceRoot() -- 37
end -- 36
function ____exports.workspacePath(path) -- 40
	return Path( -- 41
		____exports.workspaceRoot(), -- 41
		path -- 41
	) -- 41
end -- 40
function ____exports.pushConsole(state, message) -- 95
	local ____state_console_0 = state.console -- 95
	____state_console_0[#____state_console_0 + 1] = message -- 96
	if #state.console > 7 then -- 96
		table.remove(state.console, 1) -- 98
	end -- 98
end -- 95
function ____exports.isFolderAsset(path) -- 124
	return path ~= "" and string.sub( -- 125
		path, -- 125
		string.len(path), -- 125
		string.len(path) -- 125
	) == "/" -- 125
end -- 124
function hasAsset(state, asset) -- 128
	for ____, item in ipairs(state.assets) do -- 129
		if item == asset then -- 129
			return true -- 130
		end -- 130
	end -- 130
	return false -- 132
end -- 132
function rememberAsset(state, asset) -- 135
	if asset == "" then -- 135
		return -- 136
	end -- 136
	if not hasAsset(state, asset) then -- 136
		local ____state_assets_1 = state.assets -- 136
		____state_assets_1[#____state_assets_1 + 1] = asset -- 137
	end -- 137
end -- 137
function sortAssets(state) -- 140
	table.sort( -- 141
		state.assets, -- 141
		function(a, b) -- 141
			local aFolder = ____exports.isFolderAsset(a) -- 142
			local bFolder = ____exports.isFolderAsset(b) -- 143
			if aFolder == bFolder then -- 143
				return a < b -- 144
			end -- 144
			return aFolder -- 145
		end -- 141
	) -- 141
end -- 141
function normalizeSlash(path) -- 149
	local result = string.gsub(path, "\\", "/") -- 150
	local found = string.find(result, "//") -- 151
	while found ~= nil do -- 151
		result = string.gsub(result, "//", "/") -- 153
		found = string.find(result, "//") -- 154
	end -- 154
	return result -- 156
end -- 156
function stripFolderPrefix(folder, path) -- 159
	local cleanFolder = normalizeSlash(folder) -- 160
	local cleanPath = normalizeSlash(path) -- 161
	if string.sub( -- 161
		cleanPath, -- 162
		1, -- 162
		string.len(cleanFolder) -- 162
	) == cleanFolder then -- 162
		local rest = string.sub( -- 163
			cleanPath, -- 163
			string.len(cleanFolder) + 1 -- 163
		) -- 163
		if string.sub(rest, 1, 1) == "/" then -- 163
			rest = string.sub(rest, 2) -- 164
		end -- 164
		return rest -- 165
	end -- 165
	return Path:getFilename(path) -- 167
end -- 167
function refreshAssetSearchPath(importedPath) -- 170
	Content:addSearchPath(____exports.workspaceRoot()) -- 171
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 172
	if importedPath ~= nil and importedPath ~= "" then -- 172
		local importedFolder = Path:getPath(importedPath) -- 174
		if importedFolder ~= "" then -- 174
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 175
		end -- 175
	end -- 175
	Content:clearPathCache() -- 177
end -- 177
function ____exports.refreshImportedAssets(state) -- 180
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 181
	Content:mkdir(importedAbsolutePath) -- 182
	refreshAssetSearchPath(importedAssetRoot) -- 183
	rememberAsset(state, importedAssetRootEntry) -- 184
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 185
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 186
		rememberAsset(state, asset) -- 187
	end -- 187
	sortAssets(state) -- 189
end -- 180
function notifyWebIDEFileAdded(workspaceRelativePath) -- 192
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 193
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 194
	if payload ~= nil then -- 194
		emit("AppWS", "Send", payload) -- 201
	end -- 201
end -- 201
function copyFileToImported(srcPath, importedPath) -- 205
	local target = ____exports.workspacePath(importedPath) -- 206
	Content:mkdir(Path:getPath(target)) -- 207
	if srcPath == target or Content:copy(srcPath, target) then -- 207
		refreshAssetSearchPath(importedPath) -- 209
		notifyWebIDEFileAdded(importedPath) -- 210
		return importedPath -- 211
	end -- 211
	Content:clearPathCache() -- 213
	return nil -- 214
end -- 214
function ____exports.addAssetFolder(state, folderPath) -- 237
	if folderPath == "" then -- 237
		return nil -- 238
	end -- 238
	local folderName = Path:getName(folderPath) or "Folder" -- 239
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 240
	rememberAsset(state, importedAssetRootEntry) -- 241
	rememberAsset(state, rootAsset) -- 242
	local added = 0 -- 243
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 244
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 245
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 246
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 247
		local asset = copyFileToImported(absoluteFile, importedFile) -- 248
		if asset ~= nil then -- 248
			rememberAsset(state, asset) -- 250
			added = added + 1 -- 251
		end -- 251
	end -- 251
	____exports.refreshImportedAssets(state) -- 254
	state.selectedAsset = rootAsset -- 255
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 256
	____exports.pushConsole(state, state.status) -- 257
	return rootAsset -- 258
end -- 237
local localeMatch = string.match(App.locale, "^zh") -- 4
____exports.zh = localeMatch ~= nil -- 5
importedAssetRoot = "Imported" -- 7
importedAssetRootEntry = importedAssetRoot .. "/" -- 8
function ____exports.makeBuffer(text, size) -- 44
	local buffer = Buffer(size) -- 45
	buffer.text = text -- 46
	return buffer -- 47
end -- 44
function ____exports.createEditorState() -- 50
	Content:addSearchPath(____exports.workspaceRoot()) -- 51
	Content:mkdir(____exports.workspacePath(importedAssetRoot)) -- 52
	local state = { -- 53
		nextId = 0, -- 54
		selectedId = "root", -- 55
		mode = "2D", -- 56
		zoom = 100, -- 57
		showGrid = true, -- 58
		snapEnabled = false, -- 59
		viewportTool = "Select", -- 60
		leftWidth = 280, -- 61
		rightWidth = 340, -- 62
		bottomHeight = 132, -- 63
		gameWidth = 960, -- 64
		gameHeight = 540, -- 65
		gameScript = "Script/Main.lua", -- 66
		gameScriptBuffer = ____exports.makeBuffer("Script/Main.lua", 256), -- 67
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 68
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 69
		nodes = {}, -- 70
		order = {}, -- 71
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 72
		previewDirty = true, -- 73
		runtimeNodes = {}, -- 74
		runtimeLabels = {}, -- 75
		isPlaying = false, -- 76
		gameWindowOpen = false, -- 77
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 78
		playDirty = true, -- 79
		playRuntimeNodes = {}, -- 80
		playRuntimeLabels = {}, -- 81
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 82
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 83
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 84
		selectedAsset = "", -- 85
		assets = {}, -- 86
		viewportPanX = 0, -- 87
		viewportPanY = 0, -- 88
		draggingViewport = false -- 89
	} -- 89
	____exports.refreshImportedAssets(state) -- 91
	return state -- 92
end -- 50
function ____exports.iconFor(kind) -- 102
	if kind == "Sprite" then -- 102
		return "▣" -- 103
	end -- 103
	if kind == "Label" then -- 103
		return "T" -- 104
	end -- 104
	if kind == "Camera" then -- 104
		return "◉" -- 105
	end -- 105
	return "○" -- 106
end -- 102
function ____exports.lowerExt(path) -- 109
	local ext = Path:getExt(path or "") or "" -- 110
	return string.lower(ext) -- 111
end -- 109
function ____exports.isTextureAsset(path) -- 114
	local ext = ____exports.lowerExt(path) -- 115
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 116
end -- 114
function ____exports.isScriptAsset(path) -- 119
	local ext = ____exports.lowerExt(path) -- 120
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 121
end -- 119
function ____exports.addAssetPath(state, path, importedPath) -- 217
	if path == nil or path == "" then -- 217
		return nil -- 218
	end -- 218
	if Content:isdir(path) then -- 218
		return ____exports.addAssetFolder(state, path) -- 220
	end -- 220
	local asset = copyFileToImported( -- 222
		path, -- 222
		importedPath or Path( -- 222
			importedAssetRoot, -- 222
			Path:getFilename(path) -- 222
		) -- 222
	) -- 222
	if asset == nil then -- 222
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 224
		____exports.pushConsole(state, state.status) -- 225
		return nil -- 226
	end -- 226
	rememberAsset(state, asset) -- 228
	rememberAsset(state, importedAssetRootEntry) -- 229
	____exports.refreshImportedAssets(state) -- 230
	state.selectedAsset = asset -- 231
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 232
	____exports.pushConsole(state, state.status) -- 233
	return asset -- 234
end -- 217
function ____exports.importFileDialog(state) -- 261
	App:openFileDialog( -- 262
		false, -- 262
		function(path) -- 262
			____exports.addAssetPath(state, path) -- 263
		end -- 262
	) -- 262
end -- 261
function ____exports.importFolderDialog(state) -- 267
	App:openFileDialog( -- 268
		true, -- 268
		function(path) -- 268
			____exports.addAssetFolder(state, path) -- 269
		end -- 268
	) -- 268
end -- 267
local function newNodeId(state, kind) -- 273
	state.nextId = state.nextId + 1 -- 274
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 275
end -- 273
function ____exports.addNode(state, kind, name, parentId) -- 278
	local resolvedParentId = parentId or "root" -- 279
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 280
	local index = state.nextId -- 281
	local node = { -- 282
		id = id, -- 283
		kind = kind, -- 284
		name = name, -- 285
		parentId = resolvedParentId, -- 286
		children = {}, -- 287
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 288
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 289
		scaleX = 1, -- 290
		scaleY = 1, -- 291
		rotation = 0, -- 292
		visible = true, -- 293
		texture = "", -- 294
		text = kind == "Label" and "Label" or "", -- 295
		script = "", -- 296
		followTargetId = "", -- 297
		followOffsetX = 0, -- 298
		followOffsetY = 0, -- 299
		nameBuffer = ____exports.makeBuffer(name, 128), -- 300
		textureBuffer = ____exports.makeBuffer("", 256), -- 301
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 302
		scriptBuffer = ____exports.makeBuffer("", 256), -- 303
		followTargetBuffer = ____exports.makeBuffer("", 128) -- 304
	} -- 304
	state.nodes[id] = node -- 306
	local ____state_order_2 = state.order -- 306
	____state_order_2[#____state_order_2 + 1] = id -- 307
	local parent = state.nodes[resolvedParentId] -- 308
	if id ~= "root" and parent ~= nil then -- 308
		local ____parent_children_3 = parent.children -- 308
		____parent_children_3[#____parent_children_3 + 1] = id -- 310
	end -- 310
	return node -- 312
end -- 278
local function sceneNodeKind(value) -- 315
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 315
		return value -- 317
	end -- 317
	return "Node" -- 319
end -- 315
local function stringValue(value, fallback) -- 322
	return type(value) == "string" and value or fallback -- 323
end -- 322
local function numberValue(value, fallback) -- 326
	local parsed = tonumber(value) -- 327
	return parsed ~= nil and parsed or fallback -- 328
end -- 326
local function booleanValue(value, fallback) -- 331
	local ____temp_4 -- 332
	if type(value) == "boolean" then -- 332
		____temp_4 = value -- 332
	else -- 332
		____temp_4 = fallback -- 332
	end -- 332
	return ____temp_4 -- 332
end -- 331
local function updateNextIdFromNodeId(state, id) -- 335
	local digits = string.match(id, "%-(%d+)$") -- 336
	if digits ~= nil then -- 336
		local value = tonumber(digits) -- 338
		if value ~= nil and value > state.nextId then -- 338
			state.nextId = value -- 339
		end -- 339
	end -- 339
end -- 335
function ____exports.loadSceneFromFile(state, file) -- 343
	if not Content:exist(file) then -- 343
		return false -- 344
	end -- 344
	local data = json.decode(Content:load(file)) -- 345
	if data == nil then -- 345
		return false -- 346
	end -- 346
	local rawNodes = data.nodes -- 347
	if rawNodes == nil then -- 347
		return false -- 348
	end -- 348
	state.gameWidth = math.max( -- 349
		160, -- 349
		math.min( -- 349
			8192, -- 349
			numberValue(data.gameWidth, state.gameWidth or 960) -- 349
		) -- 349
	) -- 349
	state.gameHeight = math.max( -- 350
		120, -- 350
		math.min( -- 350
			8192, -- 350
			numberValue(data.gameHeight, state.gameHeight or 540) -- 350
		) -- 350
	) -- 350
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 351
	state.gameScriptBuffer.text = state.gameScript -- 352
	state.nodes = {} -- 354
	state.order = {} -- 355
	state.runtimeNodes = {} -- 356
	state.runtimeLabels = {} -- 357
	state.playRuntimeNodes = {} -- 358
	state.playRuntimeLabels = {} -- 359
	state.nextId = 0 -- 360
	for ____, raw in ipairs(rawNodes) do -- 362
		local kind = sceneNodeKind(raw.kind) -- 363
		local id = stringValue( -- 364
			raw.id, -- 364
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 364
		) -- 364
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 365
		local texture = stringValue(raw.texture, "") -- 366
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 367
		local script = stringValue(raw.script, "") -- 368
		local followTargetId = stringValue(raw.followTargetId, "") -- 369
		local followOffsetX = numberValue(raw.followOffsetX, 0) -- 370
		local followOffsetY = numberValue(raw.followOffsetY, 0) -- 371
		local ____temp_5 -- 372
		if id == "root" then -- 372
			____temp_5 = nil -- 372
		else -- 372
			____temp_5 = stringValue(raw.parentId, "root") -- 372
		end -- 372
		local parentId = ____temp_5 -- 372
		local node = { -- 373
			id = id, -- 374
			kind = kind, -- 375
			name = name, -- 376
			parentId = parentId, -- 377
			children = {}, -- 378
			x = numberValue(raw.x, 0), -- 379
			y = numberValue(raw.y, 0), -- 380
			scaleX = numberValue(raw.scaleX, 1), -- 381
			scaleY = numberValue(raw.scaleY, 1), -- 382
			rotation = numberValue(raw.rotation, 0), -- 383
			visible = booleanValue(raw.visible, true), -- 384
			texture = texture, -- 385
			text = text, -- 386
			script = script, -- 387
			followTargetId = followTargetId, -- 388
			followOffsetX = followOffsetX, -- 389
			followOffsetY = followOffsetY, -- 390
			nameBuffer = ____exports.makeBuffer(name, 128), -- 391
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 392
			textBuffer = ____exports.makeBuffer(text, 256), -- 393
			scriptBuffer = ____exports.makeBuffer(script, 256), -- 394
			followTargetBuffer = ____exports.makeBuffer(followTargetId, 128) -- 395
		} -- 395
		state.nodes[id] = node -- 397
		local ____state_order_6 = state.order -- 397
		____state_order_6[#____state_order_6 + 1] = id -- 398
		updateNextIdFromNodeId(state, id) -- 399
	end -- 399
	if state.nodes.root == nil then -- 399
		____exports.addNode(state, "Root", "MainScene") -- 403
	end -- 403
	for ____, id in ipairs(state.order) do -- 405
		do -- 405
			if id == "root" then -- 405
				goto __continue83 -- 406
			end -- 406
			local node = state.nodes[id] -- 407
			if node == nil then -- 407
				goto __continue83 -- 408
			end -- 408
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 408
				node.parentId = "root" -- 410
			end -- 410
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 410
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 412
		end -- 412
		::__continue83:: -- 412
	end -- 412
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 414
	state.previewDirty = true -- 415
	state.playDirty = true -- 416
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 417
	____exports.pushConsole(state, state.status) -- 418
	return true -- 419
end -- 343
local function removeFromOrder(state, id) -- 422
	do -- 422
		local i = #state.order -- 423
		while i >= 1 do -- 423
			if state.order[i] == id then -- 423
				table.remove(state.order, i) -- 425
			end -- 425
			i = i - 1 -- 423
		end -- 423
	end -- 423
end -- 422
function ____exports.deleteNode(state, id) -- 430
	if id == "root" then -- 430
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 432
		return -- 433
	end -- 433
	local node = state.nodes[id] -- 435
	if node == nil then -- 435
		return -- 436
	end -- 436
	do -- 436
		local i = #node.children -- 437
		while i >= 1 do -- 437
			____exports.deleteNode(state, node.children[i]) -- 438
			i = i - 1 -- 437
		end -- 437
	end -- 437
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 440
	if parent ~= nil then -- 440
		do -- 440
			local i = #parent.children -- 442
			while i >= 1 do -- 442
				if parent.children[i] == id then -- 442
					table.remove(parent.children, i) -- 443
				end -- 443
				i = i - 1 -- 442
			end -- 442
		end -- 442
	end -- 442
	__TS__Delete(state.nodes, id) -- 446
	removeFromOrder(state, id) -- 447
	state.selectedId = "root" -- 448
	state.draggingNodeId = nil -- 449
	state.previewDirty = true -- 450
	state.playDirty = true -- 451
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 452
	____exports.pushConsole(state, state.status) -- 453
end -- 430
local function worldPositionOf(state, id) -- 456
	local x = 0 -- 457
	local y = 0 -- 458
	local cursor = state.nodes[id] -- 459
	while cursor ~= nil do -- 459
		x = x + cursor.x -- 461
		y = y + cursor.y -- 462
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 463
	end -- 463
	return {x, y} -- 465
end -- 456
function ____exports.reparentNode(state, id, newParentId) -- 468
	if id == "root" then -- 468
		return false -- 469
	end -- 469
	local node = state.nodes[id] -- 470
	local newParent = state.nodes[newParentId] -- 471
	if node == nil or newParent == nil or node.parentId == newParentId then -- 471
		return false -- 472
	end -- 472
	local worldX, worldY = table.unpack( -- 473
		worldPositionOf(state, id), -- 473
		1, -- 473
		2 -- 473
	) -- 473
	local cursor = newParent -- 474
	while cursor ~= nil do -- 474
		if cursor.id == id then -- 474
			return false -- 476
		end -- 476
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 477
	end -- 477
	local oldParent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 479
	if oldParent ~= nil then -- 479
		do -- 479
			local i = #oldParent.children -- 481
			while i >= 1 do -- 481
				if oldParent.children[i] == id then -- 481
					table.remove(oldParent.children, i) -- 482
				end -- 482
				i = i - 1 -- 481
			end -- 481
		end -- 481
	end -- 481
	node.parentId = newParentId -- 485
	local parentWorldX, parentWorldY = table.unpack( -- 486
		worldPositionOf(state, newParentId), -- 486
		1, -- 486
		2 -- 486
	) -- 486
	node.x = worldX - parentWorldX -- 487
	node.y = worldY - parentWorldY -- 488
	local ____newParent_children_8 = newParent.children -- 488
	____newParent_children_8[#____newParent_children_8 + 1] = id -- 489
	state.previewDirty = true -- 490
	state.playDirty = true -- 491
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 492
	____exports.pushConsole(state, state.status) -- 493
	return true -- 494
end -- 468
function ____exports.addChildNode(state, kind) -- 497
	local parentId = state.selectedId or "root" -- 498
	if state.nodes[parentId] == nil then -- 498
		parentId = "root" -- 499
	end -- 499
	if state.nodes[parentId].kind == "Camera" then -- 499
		parentId = state.nodes[parentId].parentId or "root" -- 501
	end -- 501
	local node = ____exports.addNode( -- 503
		state, -- 503
		kind, -- 503
		kind .. tostring(state.nextId + 1), -- 503
		parentId -- 503
	) -- 503
	state.selectedId = node.id -- 504
	state.previewDirty = true -- 505
	state.playDirty = true -- 506
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 507
	____exports.pushConsole(state, state.status) -- 508
end -- 497
return ____exports -- 497