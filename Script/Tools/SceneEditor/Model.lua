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
function ____exports.pushConsole(state, message) -- 93
	local ____state_console_0 = state.console -- 93
	____state_console_0[#____state_console_0 + 1] = message -- 94
	if #state.console > 7 then -- 94
		table.remove(state.console, 1) -- 96
	end -- 96
end -- 93
function ____exports.isFolderAsset(path) -- 122
	return path ~= "" and string.sub( -- 123
		path, -- 123
		string.len(path), -- 123
		string.len(path) -- 123
	) == "/" -- 123
end -- 122
function hasAsset(state, asset) -- 126
	for ____, item in ipairs(state.assets) do -- 127
		if item == asset then -- 127
			return true -- 128
		end -- 128
	end -- 128
	return false -- 130
end -- 130
function rememberAsset(state, asset) -- 133
	if asset == "" then -- 133
		return -- 134
	end -- 134
	if not hasAsset(state, asset) then -- 134
		local ____state_assets_1 = state.assets -- 134
		____state_assets_1[#____state_assets_1 + 1] = asset -- 135
	end -- 135
end -- 135
function sortAssets(state) -- 138
	table.sort( -- 139
		state.assets, -- 139
		function(a, b) -- 139
			local aFolder = ____exports.isFolderAsset(a) -- 140
			local bFolder = ____exports.isFolderAsset(b) -- 141
			if aFolder == bFolder then -- 141
				return a < b -- 142
			end -- 142
			return aFolder -- 143
		end -- 139
	) -- 139
end -- 139
function normalizeSlash(path) -- 147
	local result = string.gsub(path, "\\", "/") -- 148
	local found = string.find(result, "//") -- 149
	while found ~= nil do -- 149
		result = string.gsub(result, "//", "/") -- 151
		found = string.find(result, "//") -- 152
	end -- 152
	return result -- 154
end -- 154
function stripFolderPrefix(folder, path) -- 157
	local cleanFolder = normalizeSlash(folder) -- 158
	local cleanPath = normalizeSlash(path) -- 159
	if string.sub( -- 159
		cleanPath, -- 160
		1, -- 160
		string.len(cleanFolder) -- 160
	) == cleanFolder then -- 160
		local rest = string.sub( -- 161
			cleanPath, -- 161
			string.len(cleanFolder) + 1 -- 161
		) -- 161
		if string.sub(rest, 1, 1) == "/" then -- 161
			rest = string.sub(rest, 2) -- 162
		end -- 162
		return rest -- 163
	end -- 163
	return Path:getFilename(path) -- 165
end -- 165
function refreshAssetSearchPath(importedPath) -- 168
	Content:addSearchPath(____exports.workspaceRoot()) -- 169
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 170
	if importedPath ~= nil and importedPath ~= "" then -- 170
		local importedFolder = Path:getPath(importedPath) -- 172
		if importedFolder ~= "" then -- 172
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 173
		end -- 173
	end -- 173
	Content:clearPathCache() -- 175
end -- 175
function ____exports.refreshImportedAssets(state) -- 178
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 179
	Content:mkdir(importedAbsolutePath) -- 180
	refreshAssetSearchPath(importedAssetRoot) -- 181
	rememberAsset(state, importedAssetRootEntry) -- 182
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 183
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 184
		rememberAsset(state, asset) -- 185
	end -- 185
	sortAssets(state) -- 187
end -- 178
function notifyWebIDEFileAdded(workspaceRelativePath) -- 190
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 191
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 192
	if payload ~= nil then -- 192
		emit("AppWS", "Send", payload) -- 199
	end -- 199
end -- 199
function copyFileToImported(srcPath, importedPath) -- 203
	local target = ____exports.workspacePath(importedPath) -- 204
	Content:mkdir(Path:getPath(target)) -- 205
	if srcPath == target or Content:copy(srcPath, target) then -- 205
		refreshAssetSearchPath(importedPath) -- 207
		notifyWebIDEFileAdded(importedPath) -- 208
		return importedPath -- 209
	end -- 209
	Content:clearPathCache() -- 211
	return nil -- 212
end -- 212
function ____exports.addAssetFolder(state, folderPath) -- 235
	if folderPath == "" then -- 235
		return nil -- 236
	end -- 236
	local folderName = Path:getName(folderPath) or "Folder" -- 237
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 238
	rememberAsset(state, importedAssetRootEntry) -- 239
	rememberAsset(state, rootAsset) -- 240
	local added = 0 -- 241
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 242
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 243
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 244
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 245
		local asset = copyFileToImported(absoluteFile, importedFile) -- 246
		if asset ~= nil then -- 246
			rememberAsset(state, asset) -- 248
			added = added + 1 -- 249
		end -- 249
	end -- 249
	____exports.refreshImportedAssets(state) -- 252
	state.selectedAsset = rootAsset -- 253
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 254
	____exports.pushConsole(state, state.status) -- 255
	return rootAsset -- 256
end -- 235
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
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 64
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 65
		nodes = {}, -- 66
		order = {}, -- 67
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 68
		previewDirty = true, -- 69
		runtimeNodes = {}, -- 70
		runtimeLabels = {}, -- 71
		isPlaying = false, -- 72
		gameWindowOpen = false, -- 73
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 74
		playDirty = true, -- 75
		playRuntimeNodes = {}, -- 76
		playRuntimeLabels = {}, -- 77
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 78
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 79
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 80
		selectedAsset = "", -- 81
		assets = {}, -- 82
		viewportPanX = 0, -- 83
		viewportPanY = 0, -- 84
		draggingViewport = false -- 85
	} -- 85
	state.gameWidth = 960 -- 87
	state.gameHeight = 540 -- 88
	____exports.refreshImportedAssets(state) -- 89
	return state -- 90
end -- 50
function ____exports.iconFor(kind) -- 100
	if kind == "Sprite" then -- 100
		return "▣" -- 101
	end -- 101
	if kind == "Label" then -- 101
		return "T" -- 102
	end -- 102
	if kind == "Camera" then -- 102
		return "◉" -- 103
	end -- 103
	return "○" -- 104
end -- 100
function ____exports.lowerExt(path) -- 107
	local ext = Path:getExt(path or "") or "" -- 108
	return string.lower(ext) -- 109
end -- 107
function ____exports.isTextureAsset(path) -- 112
	local ext = ____exports.lowerExt(path) -- 113
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 114
end -- 112
function ____exports.isScriptAsset(path) -- 117
	local ext = ____exports.lowerExt(path) -- 118
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 119
end -- 117
function ____exports.addAssetPath(state, path, importedPath) -- 215
	if path == nil or path == "" then -- 215
		return nil -- 216
	end -- 216
	if Content:isdir(path) then -- 216
		return ____exports.addAssetFolder(state, path) -- 218
	end -- 218
	local asset = copyFileToImported( -- 220
		path, -- 220
		importedPath or Path( -- 220
			importedAssetRoot, -- 220
			Path:getFilename(path) -- 220
		) -- 220
	) -- 220
	if asset == nil then -- 220
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 222
		____exports.pushConsole(state, state.status) -- 223
		return nil -- 224
	end -- 224
	rememberAsset(state, asset) -- 226
	rememberAsset(state, importedAssetRootEntry) -- 227
	____exports.refreshImportedAssets(state) -- 228
	state.selectedAsset = asset -- 229
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 230
	____exports.pushConsole(state, state.status) -- 231
	return asset -- 232
end -- 215
function ____exports.importFileDialog(state) -- 259
	App:openFileDialog( -- 260
		false, -- 260
		function(path) -- 260
			____exports.addAssetPath(state, path) -- 261
		end -- 260
	) -- 260
end -- 259
function ____exports.importFolderDialog(state) -- 265
	App:openFileDialog( -- 266
		true, -- 266
		function(path) -- 266
			____exports.addAssetFolder(state, path) -- 267
		end -- 266
	) -- 266
end -- 265
local function newNodeId(state, kind) -- 271
	state.nextId = state.nextId + 1 -- 272
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 273
end -- 271
function ____exports.addNode(state, kind, name, parentId) -- 276
	local resolvedParentId = parentId or "root" -- 277
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 278
	local index = state.nextId -- 279
	local node = { -- 280
		id = id, -- 281
		kind = kind, -- 282
		name = name, -- 283
		parentId = resolvedParentId, -- 284
		children = {}, -- 285
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 286
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 287
		scaleX = 1, -- 288
		scaleY = 1, -- 289
		rotation = 0, -- 290
		visible = true, -- 291
		texture = "", -- 292
		text = kind == "Label" and "Label" or "", -- 293
		script = "", -- 294
		nameBuffer = ____exports.makeBuffer(name, 128), -- 295
		textureBuffer = ____exports.makeBuffer("", 256), -- 296
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 297
		scriptBuffer = ____exports.makeBuffer("", 256) -- 298
	} -- 298
	state.nodes[id] = node -- 300
	local ____state_order_2 = state.order -- 300
	____state_order_2[#____state_order_2 + 1] = id -- 301
	local parent = state.nodes[resolvedParentId] -- 302
	if id ~= "root" and parent ~= nil then -- 302
		local ____parent_children_3 = parent.children -- 302
		____parent_children_3[#____parent_children_3 + 1] = id -- 304
	end -- 304
	return node -- 306
end -- 276
local function sceneNodeKind(value) -- 309
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 309
		return value -- 311
	end -- 311
	return "Node" -- 313
end -- 309
local function stringValue(value, fallback) -- 316
	return type(value) == "string" and value or fallback -- 317
end -- 316
local function numberValue(value, fallback) -- 320
	local parsed = tonumber(value) -- 321
	return parsed ~= nil and parsed or fallback -- 322
end -- 320
local function booleanValue(value, fallback) -- 325
	local ____temp_4 -- 326
	if type(value) == "boolean" then -- 326
		____temp_4 = value -- 326
	else -- 326
		____temp_4 = fallback -- 326
	end -- 326
	return ____temp_4 -- 326
end -- 325
local function updateNextIdFromNodeId(state, id) -- 329
	local digits = string.match(id, "%-(%d+)$") -- 330
	if digits ~= nil then -- 330
		local value = tonumber(digits) -- 332
		if value ~= nil and value > state.nextId then -- 332
			state.nextId = value -- 333
		end -- 333
	end -- 333
end -- 329
function ____exports.loadSceneFromFile(state, file) -- 337
	if not Content:exist(file) then -- 337
		return false -- 338
	end -- 338
	local data = json.decode(Content:load(file)) -- 339
	if data == nil then -- 339
		return false -- 340
	end -- 340
	local rawNodes = data.nodes -- 341
	if rawNodes == nil then -- 341
		return false -- 342
	end -- 342
	state.gameWidth = math.max( -- 343
		160, -- 343
		math.min( -- 343
			8192, -- 343
			numberValue(data.gameWidth, state.gameWidth or 960) -- 343
		) -- 343
	) -- 343
	state.gameHeight = math.max( -- 344
		120, -- 344
		math.min( -- 344
			8192, -- 344
			numberValue(data.gameHeight, state.gameHeight or 540) -- 344
		) -- 344
	) -- 344
	state.nodes = {} -- 346
	state.order = {} -- 347
	state.runtimeNodes = {} -- 348
	state.runtimeLabels = {} -- 349
	state.playRuntimeNodes = {} -- 350
	state.playRuntimeLabels = {} -- 351
	state.nextId = 0 -- 352
	for ____, raw in ipairs(rawNodes) do -- 354
		local kind = sceneNodeKind(raw.kind) -- 355
		local id = stringValue( -- 356
			raw.id, -- 356
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 356
		) -- 356
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 357
		local texture = stringValue(raw.texture, "") -- 358
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 359
		local script = stringValue(raw.script, "") -- 360
		local ____temp_5 -- 361
		if id == "root" then -- 361
			____temp_5 = nil -- 361
		else -- 361
			____temp_5 = stringValue(raw.parentId, "root") -- 361
		end -- 361
		local parentId = ____temp_5 -- 361
		local node = { -- 362
			id = id, -- 363
			kind = kind, -- 364
			name = name, -- 365
			parentId = parentId, -- 366
			children = {}, -- 367
			x = numberValue(raw.x, 0), -- 368
			y = numberValue(raw.y, 0), -- 369
			scaleX = numberValue(raw.scaleX, 1), -- 370
			scaleY = numberValue(raw.scaleY, 1), -- 371
			rotation = numberValue(raw.rotation, 0), -- 372
			visible = booleanValue(raw.visible, true), -- 373
			texture = texture, -- 374
			text = text, -- 375
			script = script, -- 376
			nameBuffer = ____exports.makeBuffer(name, 128), -- 377
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 378
			textBuffer = ____exports.makeBuffer(text, 256), -- 379
			scriptBuffer = ____exports.makeBuffer(script, 256) -- 380
		} -- 380
		state.nodes[id] = node -- 382
		local ____state_order_6 = state.order -- 382
		____state_order_6[#____state_order_6 + 1] = id -- 383
		updateNextIdFromNodeId(state, id) -- 384
	end -- 384
	if state.nodes.root == nil then -- 384
		____exports.addNode(state, "Root", "MainScene") -- 388
	end -- 388
	for ____, id in ipairs(state.order) do -- 390
		do -- 390
			if id == "root" then -- 390
				goto __continue83 -- 391
			end -- 391
			local node = state.nodes[id] -- 392
			if node == nil then -- 392
				goto __continue83 -- 393
			end -- 393
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 393
				node.parentId = "root" -- 395
			end -- 395
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 395
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 397
		end -- 397
		::__continue83:: -- 397
	end -- 397
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 399
	state.previewDirty = true -- 400
	state.playDirty = true -- 401
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 402
	____exports.pushConsole(state, state.status) -- 403
	return true -- 404
end -- 337
local function removeFromOrder(state, id) -- 407
	do -- 407
		local i = #state.order -- 408
		while i >= 1 do -- 408
			if state.order[i] == id then -- 408
				table.remove(state.order, i) -- 410
			end -- 410
			i = i - 1 -- 408
		end -- 408
	end -- 408
end -- 407
function ____exports.deleteNode(state, id) -- 415
	if id == "root" then -- 415
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 417
		return -- 418
	end -- 418
	local node = state.nodes[id] -- 420
	if node == nil then -- 420
		return -- 421
	end -- 421
	do -- 421
		local i = #node.children -- 422
		while i >= 1 do -- 422
			____exports.deleteNode(state, node.children[i]) -- 423
			i = i - 1 -- 422
		end -- 422
	end -- 422
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 425
	if parent ~= nil then -- 425
		do -- 425
			local i = #parent.children -- 427
			while i >= 1 do -- 427
				if parent.children[i] == id then -- 427
					table.remove(parent.children, i) -- 428
				end -- 428
				i = i - 1 -- 427
			end -- 427
		end -- 427
	end -- 427
	__TS__Delete(state.nodes, id) -- 431
	removeFromOrder(state, id) -- 432
	state.selectedId = "root" -- 433
	state.draggingNodeId = nil -- 434
	state.previewDirty = true -- 435
	state.playDirty = true -- 436
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 437
	____exports.pushConsole(state, state.status) -- 438
end -- 415
function ____exports.addChildNode(state, kind) -- 441
	local parentId = state.selectedId or "root" -- 442
	if state.nodes[parentId] == nil then -- 442
		parentId = "root" -- 443
	end -- 443
	local node = ____exports.addNode( -- 444
		state, -- 444
		kind, -- 444
		kind .. tostring(state.nextId + 1), -- 444
		parentId -- 444
	) -- 444
	state.selectedId = node.id -- 445
	state.previewDirty = true -- 446
	state.playDirty = true -- 447
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 448
	____exports.pushConsole(state, state.status) -- 449
end -- 441
return ____exports -- 441