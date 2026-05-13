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
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 66
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 67
		nodes = {}, -- 68
		order = {}, -- 69
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 70
		previewDirty = true, -- 71
		runtimeNodes = {}, -- 72
		runtimeLabels = {}, -- 73
		externalPreviewRunning = false, -- 74
		externalPreviewRoot = "", -- 75
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
		nameBuffer = ____exports.makeBuffer(name, 128), -- 297
		textureBuffer = ____exports.makeBuffer("", 256), -- 298
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 299
		scriptBuffer = ____exports.makeBuffer("", 256) -- 300
	} -- 300
	state.nodes[id] = node -- 302
	local ____state_order_2 = state.order -- 302
	____state_order_2[#____state_order_2 + 1] = id -- 303
	local parent = state.nodes[resolvedParentId] -- 304
	if id ~= "root" and parent ~= nil then -- 304
		local ____parent_children_3 = parent.children -- 304
		____parent_children_3[#____parent_children_3 + 1] = id -- 306
	end -- 306
	return node -- 308
end -- 278
local function sceneNodeKind(value) -- 311
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 311
		return value -- 313
	end -- 313
	return "Node" -- 315
end -- 311
local function stringValue(value, fallback) -- 318
	return type(value) == "string" and value or fallback -- 319
end -- 318
local function numberValue(value, fallback) -- 322
	local parsed = tonumber(value) -- 323
	return parsed ~= nil and parsed or fallback -- 324
end -- 322
local function booleanValue(value, fallback) -- 327
	local ____temp_4 -- 328
	if type(value) == "boolean" then -- 328
		____temp_4 = value -- 328
	else -- 328
		____temp_4 = fallback -- 328
	end -- 328
	return ____temp_4 -- 328
end -- 327
local function updateNextIdFromNodeId(state, id) -- 331
	local digits = string.match(id, "%-(%d+)$") -- 332
	if digits ~= nil then -- 332
		local value = tonumber(digits) -- 334
		if value ~= nil and value > state.nextId then -- 334
			state.nextId = value -- 335
		end -- 335
	end -- 335
end -- 331
function ____exports.loadSceneFromFile(state, file) -- 339
	if not Content:exist(file) then -- 339
		return false -- 340
	end -- 340
	local data = json.decode(Content:load(file)) -- 341
	if data == nil then -- 341
		return false -- 342
	end -- 342
	local rawNodes = data.nodes -- 343
	if rawNodes == nil then -- 343
		return false -- 344
	end -- 344
	state.gameWidth = math.max( -- 345
		160, -- 345
		math.min( -- 345
			8192, -- 345
			numberValue(data.gameWidth, state.gameWidth or 960) -- 345
		) -- 345
	) -- 345
	state.gameHeight = math.max( -- 346
		120, -- 346
		math.min( -- 346
			8192, -- 346
			numberValue(data.gameHeight, state.gameHeight or 540) -- 346
		) -- 346
	) -- 346
	state.nodes = {} -- 348
	state.order = {} -- 349
	state.runtimeNodes = {} -- 350
	state.runtimeLabels = {} -- 351
	state.playRuntimeNodes = {} -- 352
	state.playRuntimeLabels = {} -- 353
	state.nextId = 0 -- 354
	for ____, raw in ipairs(rawNodes) do -- 356
		local kind = sceneNodeKind(raw.kind) -- 357
		local id = stringValue( -- 358
			raw.id, -- 358
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 358
		) -- 358
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 359
		local texture = stringValue(raw.texture, "") -- 360
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 361
		local script = stringValue(raw.script, "") -- 362
		local ____temp_5 -- 363
		if id == "root" then -- 363
			____temp_5 = nil -- 363
		else -- 363
			____temp_5 = stringValue(raw.parentId, "root") -- 363
		end -- 363
		local parentId = ____temp_5 -- 363
		local node = { -- 364
			id = id, -- 365
			kind = kind, -- 366
			name = name, -- 367
			parentId = parentId, -- 368
			children = {}, -- 369
			x = numberValue(raw.x, 0), -- 370
			y = numberValue(raw.y, 0), -- 371
			scaleX = numberValue(raw.scaleX, 1), -- 372
			scaleY = numberValue(raw.scaleY, 1), -- 373
			rotation = numberValue(raw.rotation, 0), -- 374
			visible = booleanValue(raw.visible, true), -- 375
			texture = texture, -- 376
			text = text, -- 377
			script = script, -- 378
			nameBuffer = ____exports.makeBuffer(name, 128), -- 379
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 380
			textBuffer = ____exports.makeBuffer(text, 256), -- 381
			scriptBuffer = ____exports.makeBuffer(script, 256) -- 382
		} -- 382
		state.nodes[id] = node -- 384
		local ____state_order_6 = state.order -- 384
		____state_order_6[#____state_order_6 + 1] = id -- 385
		updateNextIdFromNodeId(state, id) -- 386
	end -- 386
	if state.nodes.root == nil then -- 386
		____exports.addNode(state, "Root", "MainScene") -- 390
	end -- 390
	for ____, id in ipairs(state.order) do -- 392
		do -- 392
			if id == "root" then -- 392
				goto __continue83 -- 393
			end -- 393
			local node = state.nodes[id] -- 394
			if node == nil then -- 394
				goto __continue83 -- 395
			end -- 395
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 395
				node.parentId = "root" -- 397
			end -- 397
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 397
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 399
		end -- 399
		::__continue83:: -- 399
	end -- 399
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 401
	state.previewDirty = true -- 402
	state.playDirty = true -- 403
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 404
	____exports.pushConsole(state, state.status) -- 405
	return true -- 406
end -- 339
local function removeFromOrder(state, id) -- 409
	do -- 409
		local i = #state.order -- 410
		while i >= 1 do -- 410
			if state.order[i] == id then -- 410
				table.remove(state.order, i) -- 412
			end -- 412
			i = i - 1 -- 410
		end -- 410
	end -- 410
end -- 409
function ____exports.deleteNode(state, id) -- 417
	if id == "root" then -- 417
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 419
		return -- 420
	end -- 420
	local node = state.nodes[id] -- 422
	if node == nil then -- 422
		return -- 423
	end -- 423
	do -- 423
		local i = #node.children -- 424
		while i >= 1 do -- 424
			____exports.deleteNode(state, node.children[i]) -- 425
			i = i - 1 -- 424
		end -- 424
	end -- 424
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 427
	if parent ~= nil then -- 427
		do -- 427
			local i = #parent.children -- 429
			while i >= 1 do -- 429
				if parent.children[i] == id then -- 429
					table.remove(parent.children, i) -- 430
				end -- 430
				i = i - 1 -- 429
			end -- 429
		end -- 429
	end -- 429
	__TS__Delete(state.nodes, id) -- 433
	removeFromOrder(state, id) -- 434
	state.selectedId = "root" -- 435
	state.draggingNodeId = nil -- 436
	state.previewDirty = true -- 437
	state.playDirty = true -- 438
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 439
	____exports.pushConsole(state, state.status) -- 440
end -- 417
function ____exports.addChildNode(state, kind) -- 443
	local parentId = state.selectedId or "root" -- 444
	if state.nodes[parentId] == nil then -- 444
		parentId = "root" -- 445
	end -- 445
	local node = ____exports.addNode( -- 446
		state, -- 446
		kind, -- 446
		kind .. tostring(state.nextId + 1), -- 446
		parentId -- 446
	) -- 446
	state.selectedId = node.id -- 447
	state.previewDirty = true -- 448
	state.playDirty = true -- 449
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 450
	____exports.pushConsole(state, state.status) -- 451
end -- 443
return ____exports -- 443