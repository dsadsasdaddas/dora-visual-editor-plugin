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
local defaultNodeName = ____NodeCatalog.defaultNodeName -- 3
local nodeKindIcon = ____NodeCatalog.nodeKindIcon -- 3
local normalizeNodeKind = ____NodeCatalog.normalizeNodeKind -- 3
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 4
local canDeleteNodeKind = ____NodeCapabilities.canDeleteNodeKind -- 4
local canNodeKindHaveChildren = ____NodeCapabilities.canNodeKindHaveChildren -- 4
local isRootNodeKind = ____NodeCapabilities.isRootNodeKind -- 4
local ____NodeFactory = require("Script.Tools.SceneEditor.NodeFactory") -- 5
local createSceneNodeData = ____NodeFactory.createSceneNodeData -- 5
local ____SceneGraph = require("Script.Tools.SceneEditor.SceneGraph") -- 6
local graphNodePath = ____SceneGraph.nodePath -- 6
local normalizeSceneGraph = ____SceneGraph.normalizeSceneGraph -- 6
local reparentSceneNode = ____SceneGraph.reparentSceneNode -- 6
local resolveGraphAddParentId = ____SceneGraph.resolveAddParentId -- 6
function isPathInside(path, root) -- 41
	local cleanPath = normalizeSlash(path) -- 42
	local cleanRoot = normalizeSlash(root) -- 43
	return cleanPath == cleanRoot or string.sub( -- 44
		cleanPath, -- 44
		1, -- 44
		string.len(cleanRoot) + 1 -- 44
	) == cleanRoot .. "/" -- 44
end -- 44
function isProjectRootDir(dir) -- 47
	if dir == "" or not Content:exist(dir) or not Content:isdir(dir) then -- 47
		return false -- 48
	end -- 48
	for ____, file in ipairs(Content:getFiles(dir)) do -- 49
		if string.lower(Path:getName(file)) == "init" then -- 49
			return true -- 50
		end -- 50
	end -- 50
	local agentDir = Path(dir, ".agent") -- 52
	return Content:exist(agentDir) and Content:isdir(agentDir) -- 53
end -- 53
function detectWorkspaceRoot() -- 56
	for ____, searchPath in ipairs(Content.searchPaths) do -- 57
		local candidate = searchPath -- 58
		if Path:getFilename(candidate) == "Script" then -- 58
			candidate = Path:getPath(candidate) -- 59
		end -- 59
		if candidate ~= Content.writablePath and isPathInside(candidate, Content.writablePath) and isProjectRootDir(candidate) then -- 59
			return candidate -- 61
		end -- 61
	end -- 61
	return Content.writablePath -- 64
end -- 64
function ____exports.workspaceRoot() -- 67
	return detectWorkspaceRoot() -- 68
end -- 67
function ____exports.workspacePath(path) -- 71
	return Path( -- 72
		____exports.workspaceRoot(), -- 72
		path -- 72
	) -- 72
end -- 71
function ____exports.pushConsole(state, message) -- 127
	local ____state_console_0 = state.console -- 127
	____state_console_0[#____state_console_0 + 1] = message -- 128
	if #state.console > 7 then -- 128
		table.remove(state.console, 1) -- 130
	end -- 130
end -- 127
function ____exports.isFolderAsset(path) -- 153
	return path ~= "" and string.sub( -- 154
		path, -- 154
		string.len(path), -- 154
		string.len(path) -- 154
	) == "/" -- 154
end -- 153
function hasAsset(state, asset) -- 157
	for ____, item in ipairs(state.assets) do -- 158
		if item == asset then -- 158
			return true -- 159
		end -- 159
	end -- 159
	return false -- 161
end -- 161
function rememberAsset(state, asset) -- 164
	if asset == "" then -- 164
		return -- 165
	end -- 165
	if not hasAsset(state, asset) then -- 165
		local ____state_assets_1 = state.assets -- 165
		____state_assets_1[#____state_assets_1 + 1] = asset -- 166
	end -- 166
end -- 166
function sortAssets(state) -- 169
	table.sort( -- 170
		state.assets, -- 170
		function(a, b) -- 170
			local aFolder = ____exports.isFolderAsset(a) -- 171
			local bFolder = ____exports.isFolderAsset(b) -- 172
			if aFolder == bFolder then -- 172
				return a < b -- 173
			end -- 173
			return aFolder -- 174
		end -- 170
	) -- 170
end -- 170
function normalizeSlash(path) -- 178
	local result = string.gsub(path, "\\", "/") -- 179
	local found = string.find(result, "//") -- 180
	while found ~= nil do -- 180
		result = string.gsub(result, "//", "/") -- 182
		found = string.find(result, "//") -- 183
	end -- 183
	return result -- 185
end -- 185
function stripFolderPrefix(folder, path) -- 188
	local cleanFolder = normalizeSlash(folder) -- 189
	local cleanPath = normalizeSlash(path) -- 190
	if string.sub( -- 190
		cleanPath, -- 191
		1, -- 191
		string.len(cleanFolder) -- 191
	) == cleanFolder then -- 191
		local rest = string.sub( -- 192
			cleanPath, -- 192
			string.len(cleanFolder) + 1 -- 192
		) -- 192
		if string.sub(rest, 1, 1) == "/" then -- 192
			rest = string.sub(rest, 2) -- 193
		end -- 193
		return rest -- 194
	end -- 194
	return Path:getFilename(path) -- 196
end -- 196
function refreshAssetSearchPath(importedPath) -- 199
	Content:addSearchPath(____exports.workspaceRoot()) -- 200
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 201
	if importedPath ~= nil and importedPath ~= "" then -- 201
		local importedFolder = Path:getPath(importedPath) -- 203
		if importedFolder ~= "" then -- 203
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 204
		end -- 204
	end -- 204
	Content:clearPathCache() -- 206
end -- 206
function ____exports.refreshImportedAssets(state) -- 209
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 210
	Content:mkdir(importedAbsolutePath) -- 211
	refreshAssetSearchPath(importedAssetRoot) -- 212
	rememberAsset(state, importedAssetRootEntry) -- 213
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 214
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 215
		rememberAsset(state, asset) -- 216
	end -- 216
	sortAssets(state) -- 218
end -- 209
function notifyWebIDEFileAdded(workspaceRelativePath) -- 221
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 222
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 223
	if payload ~= nil then -- 223
		emit("AppWS", "Send", payload) -- 230
	end -- 230
end -- 230
function copyFileToImported(srcPath, importedPath) -- 234
	local target = ____exports.workspacePath(importedPath) -- 235
	Content:mkdir(Path:getPath(target)) -- 236
	if srcPath == target or Content:copy(srcPath, target) then -- 236
		refreshAssetSearchPath(importedPath) -- 238
		notifyWebIDEFileAdded(importedPath) -- 239
		return importedPath -- 240
	end -- 240
	Content:clearPathCache() -- 242
	return nil -- 243
end -- 243
function ____exports.addAssetFolder(state, folderPath) -- 266
	if folderPath == "" then -- 266
		return nil -- 267
	end -- 267
	local folderName = Path:getName(folderPath) or "Folder" -- 268
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 269
	rememberAsset(state, importedAssetRootEntry) -- 270
	rememberAsset(state, rootAsset) -- 271
	local added = 0 -- 272
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 273
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 274
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 275
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 276
		local asset = copyFileToImported(absoluteFile, importedFile) -- 277
		if asset ~= nil then -- 277
			rememberAsset(state, asset) -- 279
			added = added + 1 -- 280
		end -- 280
	end -- 280
	____exports.refreshImportedAssets(state) -- 283
	state.selectedAsset = rootAsset -- 284
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 285
	____exports.pushConsole(state, state.status) -- 286
	return rootAsset -- 287
end -- 266
local localeMatch = string.match(App.locale, "^zh") -- 34
____exports.zh = localeMatch ~= nil -- 35
importedAssetRoot = "Imported" -- 38
importedAssetRootEntry = importedAssetRoot .. "/" -- 39
function ____exports.makeBuffer(text, size) -- 75
	local buffer = Buffer(size) -- 76
	buffer.text = text -- 77
	return buffer -- 78
end -- 75
function ____exports.createEditorState() -- 81
	Content:addSearchPath(____exports.workspaceRoot()) -- 82
	Content:mkdir(____exports.workspacePath(importedAssetRoot)) -- 83
	local state = { -- 84
		nextId = 0, -- 85
		selectedId = "root", -- 86
		mode = "2D", -- 87
		zoom = 100, -- 88
		showGrid = true, -- 89
		snapEnabled = false, -- 90
		viewportTool = "Select", -- 91
		leftWidth = 280, -- 92
		rightWidth = 340, -- 93
		bottomHeight = 132, -- 94
		gameWidth = 960, -- 95
		gameHeight = 540, -- 96
		gameScript = "Script/Main.lua", -- 97
		gameScriptBuffer = ____exports.makeBuffer("Script/Main.lua", 256), -- 98
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 99
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 100
		nodes = {}, -- 101
		order = {}, -- 102
		treeExpanded = {root = true}, -- 103
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 104
		previewDirty = true, -- 105
		runtimeNodes = {}, -- 106
		runtimeLabels = {}, -- 107
		isPlaying = false, -- 108
		gameWindowOpen = false, -- 109
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 110
		playDirty = true, -- 111
		playRuntimeNodes = {}, -- 112
		playRuntimeLabels = {}, -- 113
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 114
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 115
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 116
		selectedAsset = "", -- 117
		assets = {}, -- 118
		viewportPanX = 0, -- 119
		viewportPanY = 0, -- 120
		draggingViewport = false -- 121
	} -- 121
	____exports.refreshImportedAssets(state) -- 123
	return state -- 124
end -- 81
function ____exports.iconFor(kind) -- 134
	return nodeKindIcon(kind) -- 135
end -- 134
function ____exports.lowerExt(path) -- 138
	local ext = Path:getExt(path or "") or "" -- 139
	return string.lower(ext) -- 140
end -- 138
function ____exports.isTextureAsset(path) -- 143
	local ext = ____exports.lowerExt(path) -- 144
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 145
end -- 143
function ____exports.isScriptAsset(path) -- 148
	local ext = ____exports.lowerExt(path) -- 149
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 150
end -- 148
function ____exports.addAssetPath(state, path, importedPath) -- 246
	if path == nil or path == "" then -- 246
		return nil -- 247
	end -- 247
	if Content:isdir(path) then -- 247
		return ____exports.addAssetFolder(state, path) -- 249
	end -- 249
	local asset = copyFileToImported( -- 251
		path, -- 251
		importedPath or Path( -- 251
			importedAssetRoot, -- 251
			Path:getFilename(path) -- 251
		) -- 251
	) -- 251
	if asset == nil then -- 251
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 253
		____exports.pushConsole(state, state.status) -- 254
		return nil -- 255
	end -- 255
	rememberAsset(state, asset) -- 257
	rememberAsset(state, importedAssetRootEntry) -- 258
	____exports.refreshImportedAssets(state) -- 259
	state.selectedAsset = asset -- 260
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 261
	____exports.pushConsole(state, state.status) -- 262
	return asset -- 263
end -- 246
function ____exports.importFileDialog(state) -- 290
	App:openFileDialog( -- 291
		false, -- 291
		function(path) -- 291
			____exports.addAssetPath(state, path) -- 292
		end -- 291
	) -- 291
end -- 290
function ____exports.importFolderDialog(state) -- 296
	App:openFileDialog( -- 297
		true, -- 297
		function(path) -- 297
			____exports.addAssetFolder(state, path) -- 298
		end -- 297
	) -- 297
end -- 296
local function newNodeId(state, kind) -- 302
	state.nextId = state.nextId + 1 -- 303
	return (string.lower(kind) .. "-") .. (tostring(state.nextId) or "0") -- 304
end -- 302
function ____exports.addNode(state, kind, name, parentId) -- 307
	local resolvedParentId = "root" -- 308
	if isRootNodeKind(kind) then -- 308
		resolvedParentId = "" -- 310
	elseif parentId ~= nil and parentId ~= "" and state.nodes[parentId] ~= nil and canNodeKindHaveChildren(state.nodes[parentId].kind) then -- 310
		resolvedParentId = parentId -- 312
	end -- 312
	local id = isRootNodeKind(kind) and "root" or newNodeId(state, kind) -- 314
	local index = state.nextId -- 315
	local node = createSceneNodeData({ -- 316
		id = id, -- 317
		kind = kind, -- 318
		name = name, -- 319
		parentId = resolvedParentId, -- 320
		index = index -- 321
	}) -- 321
	state.nodes[id] = node -- 323
	local ____state_order_2 = state.order -- 323
	____state_order_2[#____state_order_2 + 1] = id -- 324
	local parent = resolvedParentId ~= "" and state.nodes[resolvedParentId] or nil -- 325
	if id ~= "root" and parent ~= nil then -- 325
		local ____parent_children_3 = parent.children -- 325
		____parent_children_3[#____parent_children_3 + 1] = id -- 327
		state.treeExpanded[resolvedParentId] = true -- 328
	end -- 328
	if state.treeExpanded[id] == nil then -- 328
		state.treeExpanded[id] = true -- 330
	end -- 330
	return node -- 331
end -- 307
local function sceneNodeKind(value) -- 334
	return normalizeNodeKind(value) -- 335
end -- 334
local function stringValue(value, fallback) -- 338
	return type(value) == "string" and value or fallback -- 339
end -- 338
local function optionalStringValue(value) -- 342
	return type(value) == "string" and value or nil -- 343
end -- 342
local function numberValue(value, fallback) -- 346
	if type(value) ~= "number" and type(value) ~= "string" then -- 346
		return fallback -- 347
	end -- 347
	local parsed = tonumber(value) -- 348
	return parsed ~= nil and parsed or fallback -- 349
end -- 346
local function booleanValue(value, fallback) -- 352
	local ____temp_4 -- 353
	if type(value) == "boolean" then -- 353
		____temp_4 = value -- 353
	else -- 353
		____temp_4 = fallback -- 353
	end -- 353
	return ____temp_4 -- 353
end -- 352
local function updateNextIdFromNodeId(state, id) -- 356
	local digits = string.match(id, "%-(%d+)$") -- 357
	if digits ~= nil then -- 357
		local value = tonumber(digits) -- 359
		if value ~= nil and value > state.nextId then -- 359
			state.nextId = value -- 360
		end -- 360
	end -- 360
end -- 356
function ____exports.loadSceneFromFile(state, file) -- 364
	if not Content:exist(file) then -- 364
		return false -- 365
	end -- 365
	local decoded = json.decode(Content:load(file)) -- 366
	local data = decoded -- 367
	if data == nil then -- 367
		return false -- 368
	end -- 368
	local rawNodes = data.nodes -- 369
	if rawNodes == nil then -- 369
		return false -- 370
	end -- 370
	state.gameWidth = math.max( -- 371
		160, -- 371
		math.min( -- 371
			8192, -- 371
			numberValue(data.gameWidth, state.gameWidth or 960) -- 371
		) -- 371
	) -- 371
	state.gameHeight = math.max( -- 372
		120, -- 372
		math.min( -- 372
			8192, -- 372
			numberValue(data.gameHeight, state.gameHeight or 540) -- 372
		) -- 372
	) -- 372
	state.gameScript = stringValue(data.gameScript, state.gameScript or "Script/Main.lua") -- 373
	state.gameScriptBuffer.text = state.gameScript -- 374
	state.nodes = {} -- 376
	state.order = {} -- 377
	state.runtimeNodes = {} -- 378
	state.runtimeLabels = {} -- 379
	state.playRuntimeNodes = {} -- 380
	state.playRuntimeLabels = {} -- 381
	state.nextId = 0 -- 382
	for ____, raw in ipairs(rawNodes) do -- 384
		local kind = sceneNodeKind(raw.kind) -- 385
		local id = stringValue( -- 386
			raw.id, -- 386
			isRootNodeKind(kind) and "root" or (string.lower(kind) .. "-") .. (tostring(state.nextId + 1) or "") -- 386
		) -- 386
		if state.nodes[id] ~= nil then -- 386
			id = isRootNodeKind(kind) and "root" or (string.lower(kind) .. "-") .. (tostring(state.nextId + 1) or "") -- 387
		end -- 387
		local name = stringValue( -- 388
			raw.name, -- 388
			defaultNodeName(kind, state.nextId + 1) -- 388
		) -- 388
		local texture = stringValue(raw.texture, "") -- 389
		local text = optionalStringValue(raw.text) -- 390
		local script = stringValue(raw.script, "") -- 391
		local followTargetId = stringValue(raw.followTargetId, "") -- 392
		local followOffsetX = numberValue(raw.followOffsetX, 0) -- 393
		local followOffsetY = numberValue(raw.followOffsetY, 0) -- 394
		local ____temp_5 -- 395
		if id == "root" then -- 395
			____temp_5 = nil -- 395
		else -- 395
			____temp_5 = stringValue(raw.parentId, "root") -- 395
		end -- 395
		local parentId = ____temp_5 -- 395
		local node = createSceneNodeData({ -- 396
			id = id, -- 397
			kind = kind, -- 398
			name = name, -- 399
			parentId = parentId, -- 400
			x = numberValue(raw.x, 0), -- 401
			y = numberValue(raw.y, 0), -- 402
			scaleX = numberValue(raw.scaleX, 1), -- 403
			scaleY = numberValue(raw.scaleY, 1), -- 404
			rotation = numberValue(raw.rotation, 0), -- 405
			visible = booleanValue(raw.visible, true), -- 406
			texture = texture, -- 407
			text = text, -- 408
			script = script, -- 409
			followTargetId = followTargetId, -- 410
			followOffsetX = followOffsetX, -- 411
			followOffsetY = followOffsetY -- 412
		}) -- 412
		state.nodes[id] = node -- 414
		local ____state_order_6 = state.order -- 414
		____state_order_6[#____state_order_6 + 1] = id -- 415
		updateNextIdFromNodeId(state, id) -- 416
	end -- 416
	if state.nodes.root == nil then -- 416
		____exports.addNode(state, "Root", "MainScene") -- 420
	end -- 420
	normalizeSceneGraph(state) -- 422
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 423
	state.previewDirty = true -- 424
	state.playDirty = true -- 425
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 426
	____exports.pushConsole(state, state.status) -- 427
	return true -- 428
end -- 364
local function removeFromOrder(state, id) -- 431
	do -- 431
		local i = #state.order -- 432
		while i >= 1 do -- 432
			if state.order[i] == id then -- 432
				table.remove(state.order, i) -- 434
			end -- 434
			i = i - 1 -- 432
		end -- 432
	end -- 432
end -- 431
function ____exports.deleteNode(state, id) -- 439
	local node = state.nodes[id] -- 440
	if node == nil then -- 440
		return -- 441
	end -- 441
	if not canDeleteNodeKind(node.kind) then -- 441
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 443
		return -- 444
	end -- 444
	do -- 444
		local i = #node.children -- 446
		while i >= 1 do -- 446
			____exports.deleteNode(state, node.children[i]) -- 447
			i = i - 1 -- 446
		end -- 446
	end -- 446
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 449
	if parent ~= nil then -- 449
		do -- 449
			local i = #parent.children -- 451
			while i >= 1 do -- 451
				if parent.children[i] == id then -- 451
					table.remove(parent.children, i) -- 452
				end -- 452
				i = i - 1 -- 451
			end -- 451
		end -- 451
	end -- 451
	__TS__Delete(state.nodes, id) -- 455
	__TS__Delete(state.treeExpanded, id) -- 456
	removeFromOrder(state, id) -- 457
	state.selectedId = "root" -- 458
	state.draggingNodeId = nil -- 459
	state.previewDirty = true -- 460
	state.playDirty = true -- 461
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 462
	____exports.pushConsole(state, state.status) -- 463
end -- 439
function ____exports.reparentNode(state, id, newParentId) -- 466
	local node = state.nodes[id] -- 467
	local newParent = state.nodes[newParentId] -- 468
	if node == nil or newParent == nil then -- 468
		return false -- 469
	end -- 469
	if not reparentSceneNode(state, id, newParentId) then -- 469
		return false -- 470
	end -- 470
	state.previewDirty = true -- 471
	state.playDirty = true -- 472
	state.status = (____exports.zh and "已移动节点到：" or "Moved node under: ") .. newParent.name -- 473
	____exports.pushConsole(state, state.status) -- 474
	return true -- 475
end -- 466
function ____exports.resolveAddParentId(state) -- 478
	return resolveGraphAddParentId(state) -- 479
end -- 478
function ____exports.nodePath(state, id) -- 482
	return graphNodePath(state, id) -- 483
end -- 482
function ____exports.addChildNode(state, kind) -- 486
	local parentId = ____exports.resolveAddParentId(state) -- 487
	local node = ____exports.addNode( -- 488
		state, -- 488
		kind, -- 488
		defaultNodeName(kind, state.nextId + 1), -- 488
		parentId -- 488
	) -- 488
	state.selectedId = node.id -- 489
	state.previewDirty = true -- 490
	state.playDirty = true -- 491
	local parent = state.nodes[parentId] -- 492
	state.status = ((____exports.zh and "已添加 " or "Added ") .. node.name) .. (parent ~= nil and (____exports.zh and " 到 " or " under ") .. parent.name or "") -- 493
	____exports.pushConsole(state, state.status) -- 494
end -- 486
return ____exports -- 486