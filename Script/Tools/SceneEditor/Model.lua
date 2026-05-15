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
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 3
local canNodeKindHaveChildren = ____NodeCatalog.canNodeKindHaveChildren -- 3
local defaultNodeName = ____NodeCatalog.defaultNodeName -- 3
local nodeKindIcon = ____NodeCatalog.nodeKindIcon -- 3
local normalizeNodeKind = ____NodeCatalog.normalizeNodeKind -- 3
local ____SceneGraph = require("Script.Tools.SceneEditor.SceneGraph") -- 4
local graphNodePath = ____SceneGraph.nodePath -- 4
local normalizeSceneGraph = ____SceneGraph.normalizeSceneGraph -- 4
local reparentSceneNode = ____SceneGraph.reparentSceneNode -- 4
local resolveGraphAddParentId = ____SceneGraph.resolveAddParentId -- 4
function isPathInside(path, root) -- 39
	local cleanPath = normalizeSlash(path) -- 40
	local cleanRoot = normalizeSlash(root) -- 41
	return cleanPath == cleanRoot or string.sub( -- 42
		cleanPath, -- 42
		1, -- 42
		string.len(cleanRoot) + 1 -- 42
	) == cleanRoot .. "/" -- 42
end -- 42
function isProjectRootDir(dir) -- 45
	if dir == "" or not Content:exist(dir) or not Content:isdir(dir) then -- 45
		return false -- 46
	end -- 46
	for ____, file in ipairs(Content:getFiles(dir)) do -- 47
		if string.lower(Path:getName(file)) == "init" then -- 47
			return true -- 48
		end -- 48
	end -- 48
	local agentDir = Path(dir, ".agent") -- 50
	return Content:exist(agentDir) and Content:isdir(agentDir) -- 51
end -- 51
function detectWorkspaceRoot() -- 54
	for ____, searchPath in ipairs(Content.searchPaths) do -- 55
		local candidate = searchPath -- 56
		if Path:getFilename(candidate) == "Script" then -- 56
			candidate = Path:getPath(candidate) -- 57
		end -- 57
		if candidate ~= Content.writablePath and isPathInside(candidate, Content.writablePath) and isProjectRootDir(candidate) then -- 57
			return candidate -- 59
		end -- 59
	end -- 59
	return Content.writablePath -- 62
end -- 62
function ____exports.workspaceRoot() -- 65
	return detectWorkspaceRoot() -- 66
end -- 65
function ____exports.workspacePath(path) -- 69
	return Path( -- 70
		____exports.workspaceRoot(), -- 70
		path -- 70
	) -- 70
end -- 69
function ____exports.pushConsole(state, message) -- 125
	local ____state_console_0 = state.console -- 125
	____state_console_0[#____state_console_0 + 1] = message -- 126
	if #state.console > 7 then -- 126
		table.remove(state.console, 1) -- 128
	end -- 128
end -- 125
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
local localeMatch = string.match(App.locale, "^zh") -- 32
____exports.zh = localeMatch ~= nil -- 33
importedAssetRoot = "Imported" -- 36
importedAssetRootEntry = importedAssetRoot .. "/" -- 37
function ____exports.makeBuffer(text, size) -- 73
	local buffer = Buffer(size) -- 74
	buffer.text = text -- 75
	return buffer -- 76
end -- 73
function ____exports.createEditorState() -- 79
	Content:addSearchPath(____exports.workspaceRoot()) -- 80
	Content:mkdir(____exports.workspacePath(importedAssetRoot)) -- 81
	local state = { -- 82
		nextId = 0, -- 83
		selectedId = "root", -- 84
		mode = "2D", -- 85
		zoom = 100, -- 86
		showGrid = true, -- 87
		snapEnabled = false, -- 88
		viewportTool = "Select", -- 89
		leftWidth = 280, -- 90
		rightWidth = 340, -- 91
		bottomHeight = 132, -- 92
		gameWidth = 960, -- 93
		gameHeight = 540, -- 94
		gameScript = "Script/Main.lua", -- 95
		gameScriptBuffer = ____exports.makeBuffer("Script/Main.lua", 256), -- 96
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 97
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 98
		nodes = {}, -- 99
		order = {}, -- 100
		treeExpanded = {root = true}, -- 101
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 102
		previewDirty = true, -- 103
		runtimeNodes = {}, -- 104
		runtimeLabels = {}, -- 105
		isPlaying = false, -- 106
		gameWindowOpen = false, -- 107
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 108
		playDirty = true, -- 109
		playRuntimeNodes = {}, -- 110
		playRuntimeLabels = {}, -- 111
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 112
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 113
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 114
		selectedAsset = "", -- 115
		assets = {}, -- 116
		viewportPanX = 0, -- 117
		viewportPanY = 0, -- 118
		draggingViewport = false -- 119
	} -- 119
	____exports.refreshImportedAssets(state) -- 121
	return state -- 122
end -- 79
function ____exports.iconFor(kind) -- 132
	return nodeKindIcon(kind) -- 133
end -- 132
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
	elseif parentId ~= nil and parentId ~= "" and state.nodes[parentId] ~= nil and canNodeKindHaveChildren(state.nodes[parentId].kind) then -- 308
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
		state.treeExpanded[resolvedParentId] = true -- 343
	end -- 343
	if state.treeExpanded[id] == nil then -- 343
		state.treeExpanded[id] = true -- 345
	end -- 345
	return node -- 346
end -- 305
local function sceneNodeKind(value) -- 349
	return normalizeNodeKind(value) -- 350
end -- 349
local function stringValue(value, fallback) -- 353
	return type(value) == "string" and value or fallback -- 354
end -- 353
local function numberValue(value, fallback) -- 357
	if type(value) ~= "number" and type(value) ~= "string" then -- 357
		return fallback -- 358
	end -- 358
	local parsed = tonumber(value) -- 359
	return parsed ~= nil and parsed or fallback -- 360
end -- 357
local function booleanValue(value, fallback) -- 363
	local ____temp_4 -- 364
	if type(value) == "boolean" then -- 364
		____temp_4 = value -- 364
	else -- 364
		____temp_4 = fallback -- 364
	end -- 364
	return ____temp_4 -- 364
end -- 363
local function updateNextIdFromNodeId(state, id) -- 367
	local digits = string.match(id, "%-(%d+)$") -- 368
	if digits ~= nil then -- 368
		local value = tonumber(digits) -- 370
		if value ~= nil and value > state.nextId then -- 370
			state.nextId = value -- 371
		end -- 371
	end -- 371
end -- 367
function ____exports.loadSceneFromFile(state, file) -- 375
	if not Content:exist(file) then -- 375
		return false -- 376
	end -- 376
	local decoded = json.decode(Content:load(file)) -- 377
	local data = decoded -- 378
	if data == nil then -- 378
		return false -- 379
	end -- 379
	local rawNodes = data.nodes -- 380
	if rawNodes == nil then -- 380
		return false -- 381
	end -- 381
	state.gameWidth = math.max( -- 382
		160, -- 382
		math.min( -- 382
			8192, -- 382
			numberValue(data.gameWidth, state.gameWidth or 960) -- 382
		) -- 382
	) -- 382
	state.gameHeight = math.max( -- 383
		120, -- 383
		math.min( -- 383
			8192, -- 383
			numberValue(data.gameHeight, state.gameHeight or 540) -- 383
		) -- 383
	) -- 383
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 384
	state.gameScriptBuffer.text = state.gameScript -- 385
	state.nodes = {} -- 387
	state.order = {} -- 388
	state.runtimeNodes = {} -- 389
	state.runtimeLabels = {} -- 390
	state.playRuntimeNodes = {} -- 391
	state.playRuntimeLabels = {} -- 392
	state.nextId = 0 -- 393
	for ____, raw in ipairs(rawNodes) do -- 395
		local kind = sceneNodeKind(raw.kind) -- 396
		local id = stringValue( -- 397
			raw.id, -- 397
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. (tostring(state.nextId + 1) or "") -- 397
		) -- 397
		if state.nodes[id] ~= nil then -- 397
			id = kind == "Root" and "root" or (string.lower(kind) .. "-") .. (tostring(state.nextId + 1) or "") -- 398
		end -- 398
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
	normalizeSceneGraph(state) -- 439
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 440
	state.previewDirty = true -- 441
	state.playDirty = true -- 442
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 443
	____exports.pushConsole(state, state.status) -- 444
	return true -- 445
end -- 375
local function removeFromOrder(state, id) -- 448
	do -- 448
		local i = #state.order -- 449
		while i >= 1 do -- 449
			if state.order[i] == id then -- 449
				table.remove(state.order, i) -- 451
			end -- 451
			i = i - 1 -- 449
		end -- 449
	end -- 449
end -- 448
function ____exports.deleteNode(state, id) -- 456
	if id == "root" then -- 456
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 458
		return -- 459
	end -- 459
	local node = state.nodes[id] -- 461
	if node == nil then -- 461
		return -- 462
	end -- 462
	do -- 462
		local i = #node.children -- 463
		while i >= 1 do -- 463
			____exports.deleteNode(state, node.children[i]) -- 464
			i = i - 1 -- 463
		end -- 463
	end -- 463
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 466
	if parent ~= nil then -- 466
		do -- 466
			local i = #parent.children -- 468
			while i >= 1 do -- 468
				if parent.children[i] == id then -- 468
					table.remove(parent.children, i) -- 469
				end -- 469
				i = i - 1 -- 468
			end -- 468
		end -- 468
	end -- 468
	__TS__Delete(state.nodes, id) -- 472
	__TS__Delete(state.treeExpanded, id) -- 473
	removeFromOrder(state, id) -- 474
	state.selectedId = "root" -- 475
	state.draggingNodeId = nil -- 476
	state.previewDirty = true -- 477
	state.playDirty = true -- 478
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 479
	____exports.pushConsole(state, state.status) -- 480
end -- 456
function ____exports.reparentNode(state, id, newParentId) -- 483
	local node = state.nodes[id] -- 484
	local newParent = state.nodes[newParentId] -- 485
	if node == nil or newParent == nil then -- 485
		return false -- 486
	end -- 486
	if not reparentSceneNode(state, id, newParentId) then -- 486
		return false -- 487
	end -- 487
	state.previewDirty = true -- 488
	state.playDirty = true -- 489
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 490
	____exports.pushConsole(state, state.status) -- 491
	return true -- 492
end -- 483
function ____exports.resolveAddParentId(state) -- 495
	return resolveGraphAddParentId(state) -- 496
end -- 495
function ____exports.nodePath(state, id) -- 499
	return graphNodePath(state, id) -- 500
end -- 499
function ____exports.addChildNode(state, kind) -- 503
	local parentId = ____exports.resolveAddParentId(state) -- 504
	local node = ____exports.addNode( -- 505
		state, -- 505
		kind, -- 505
		defaultNodeName(kind, state.nextId + 1), -- 505
		parentId -- 505
	) -- 505
	state.selectedId = node.id -- 506
	state.previewDirty = true -- 507
	state.playDirty = true -- 508
	local parent = state.nodes[parentId] -- 509
	state.status = ((____exports.zh and "已添加 " or "Added ") .. node.name) .. (parent ~= nil and (____exports.zh and " 到 " or " under ") .. parent.name or "") -- 510
	____exports.pushConsole(state, state.status) -- 511
end -- 503
return ____exports -- 503