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
function ____exports.pushConsole(state, message) -- 91
	local ____state_console_0 = state.console -- 91
	____state_console_0[#____state_console_0 + 1] = message -- 92
	if #state.console > 7 then -- 92
		table.remove(state.console, 1) -- 94
	end -- 94
end -- 91
function ____exports.isFolderAsset(path) -- 120
	return path ~= "" and string.sub( -- 121
		path, -- 121
		string.len(path), -- 121
		string.len(path) -- 121
	) == "/" -- 121
end -- 120
function hasAsset(state, asset) -- 124
	for ____, item in ipairs(state.assets) do -- 125
		if item == asset then -- 125
			return true -- 126
		end -- 126
	end -- 126
	return false -- 128
end -- 128
function rememberAsset(state, asset) -- 131
	if asset == "" then -- 131
		return -- 132
	end -- 132
	if not hasAsset(state, asset) then -- 132
		local ____state_assets_1 = state.assets -- 132
		____state_assets_1[#____state_assets_1 + 1] = asset -- 133
	end -- 133
end -- 133
function sortAssets(state) -- 136
	table.sort( -- 137
		state.assets, -- 137
		function(a, b) -- 137
			local aFolder = ____exports.isFolderAsset(a) -- 138
			local bFolder = ____exports.isFolderAsset(b) -- 139
			if aFolder == bFolder then -- 139
				return a < b -- 140
			end -- 140
			return aFolder -- 141
		end -- 137
	) -- 137
end -- 137
function normalizeSlash(path) -- 145
	local result = string.gsub(path, "\\", "/") -- 146
	local found = string.find(result, "//") -- 147
	while found ~= nil do -- 147
		result = string.gsub(result, "//", "/") -- 149
		found = string.find(result, "//") -- 150
	end -- 150
	return result -- 152
end -- 152
function stripFolderPrefix(folder, path) -- 155
	local cleanFolder = normalizeSlash(folder) -- 156
	local cleanPath = normalizeSlash(path) -- 157
	if string.sub( -- 157
		cleanPath, -- 158
		1, -- 158
		string.len(cleanFolder) -- 158
	) == cleanFolder then -- 158
		local rest = string.sub( -- 159
			cleanPath, -- 159
			string.len(cleanFolder) + 1 -- 159
		) -- 159
		if string.sub(rest, 1, 1) == "/" then -- 159
			rest = string.sub(rest, 2) -- 160
		end -- 160
		return rest -- 161
	end -- 161
	return Path:getFilename(path) -- 163
end -- 163
function refreshAssetSearchPath(importedPath) -- 166
	Content:addSearchPath(____exports.workspaceRoot()) -- 167
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 168
	if importedPath ~= nil and importedPath ~= "" then -- 168
		local importedFolder = Path:getPath(importedPath) -- 170
		if importedFolder ~= "" then -- 170
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 171
		end -- 171
	end -- 171
	Content:clearPathCache() -- 173
end -- 173
function ____exports.refreshImportedAssets(state) -- 176
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 177
	Content:mkdir(importedAbsolutePath) -- 178
	refreshAssetSearchPath(importedAssetRoot) -- 179
	rememberAsset(state, importedAssetRootEntry) -- 180
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 181
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 182
		rememberAsset(state, asset) -- 183
	end -- 183
	sortAssets(state) -- 185
end -- 176
function notifyWebIDEFileAdded(workspaceRelativePath) -- 188
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 189
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 190
	if payload ~= nil then -- 190
		emit("AppWS", "Send", payload) -- 197
	end -- 197
end -- 197
function copyFileToImported(srcPath, importedPath) -- 201
	local target = ____exports.workspacePath(importedPath) -- 202
	Content:mkdir(Path:getPath(target)) -- 203
	if srcPath == target or Content:copy(srcPath, target) then -- 203
		refreshAssetSearchPath(importedPath) -- 205
		notifyWebIDEFileAdded(importedPath) -- 206
		return importedPath -- 207
	end -- 207
	Content:clearPathCache() -- 209
	return nil -- 210
end -- 210
function ____exports.addAssetFolder(state, folderPath) -- 233
	if folderPath == "" then -- 233
		return nil -- 234
	end -- 234
	local folderName = Path:getName(folderPath) or "Folder" -- 235
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 236
	rememberAsset(state, importedAssetRootEntry) -- 237
	rememberAsset(state, rootAsset) -- 238
	local added = 0 -- 239
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 240
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 241
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 242
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 243
		local asset = copyFileToImported(absoluteFile, importedFile) -- 244
		if asset ~= nil then -- 244
			rememberAsset(state, asset) -- 246
			added = added + 1 -- 247
		end -- 247
	end -- 247
	____exports.refreshImportedAssets(state) -- 250
	state.selectedAsset = rootAsset -- 251
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 252
	____exports.pushConsole(state, state.status) -- 253
	return rootAsset -- 254
end -- 233
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
	____exports.refreshImportedAssets(state) -- 87
	return state -- 88
end -- 50
function ____exports.iconFor(kind) -- 98
	if kind == "Sprite" then -- 98
		return "▣" -- 99
	end -- 99
	if kind == "Label" then -- 99
		return "T" -- 100
	end -- 100
	if kind == "Camera" then -- 100
		return "◉" -- 101
	end -- 101
	return "○" -- 102
end -- 98
function ____exports.lowerExt(path) -- 105
	local ext = Path:getExt(path or "") or "" -- 106
	return string.lower(ext) -- 107
end -- 105
function ____exports.isTextureAsset(path) -- 110
	local ext = ____exports.lowerExt(path) -- 111
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 112
end -- 110
function ____exports.isScriptAsset(path) -- 115
	local ext = ____exports.lowerExt(path) -- 116
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 117
end -- 115
function ____exports.addAssetPath(state, path, importedPath) -- 213
	if path == nil or path == "" then -- 213
		return nil -- 214
	end -- 214
	if Content:isdir(path) then -- 214
		return ____exports.addAssetFolder(state, path) -- 216
	end -- 216
	local asset = copyFileToImported( -- 218
		path, -- 218
		importedPath or Path( -- 218
			importedAssetRoot, -- 218
			Path:getFilename(path) -- 218
		) -- 218
	) -- 218
	if asset == nil then -- 218
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 220
		____exports.pushConsole(state, state.status) -- 221
		return nil -- 222
	end -- 222
	rememberAsset(state, asset) -- 224
	rememberAsset(state, importedAssetRootEntry) -- 225
	____exports.refreshImportedAssets(state) -- 226
	state.selectedAsset = asset -- 227
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 228
	____exports.pushConsole(state, state.status) -- 229
	return asset -- 230
end -- 213
function ____exports.importFileDialog(state) -- 257
	App:openFileDialog( -- 258
		false, -- 258
		function(path) -- 258
			____exports.addAssetPath(state, path) -- 259
		end -- 258
	) -- 258
end -- 257
function ____exports.importFolderDialog(state) -- 263
	App:openFileDialog( -- 264
		true, -- 264
		function(path) -- 264
			____exports.addAssetFolder(state, path) -- 265
		end -- 264
	) -- 264
end -- 263
local function newNodeId(state, kind) -- 269
	state.nextId = state.nextId + 1 -- 270
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 271
end -- 269
function ____exports.addNode(state, kind, name, parentId) -- 274
	local resolvedParentId = parentId or "root" -- 275
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 276
	local index = state.nextId -- 277
	local node = { -- 278
		id = id, -- 279
		kind = kind, -- 280
		name = name, -- 281
		parentId = resolvedParentId, -- 282
		children = {}, -- 283
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 284
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 285
		scaleX = 1, -- 286
		scaleY = 1, -- 287
		rotation = 0, -- 288
		visible = true, -- 289
		texture = "", -- 290
		text = kind == "Label" and "Label" or "", -- 291
		script = "", -- 292
		nameBuffer = ____exports.makeBuffer(name, 128), -- 293
		textureBuffer = ____exports.makeBuffer("", 256), -- 294
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 295
		scriptBuffer = ____exports.makeBuffer("", 256) -- 296
	} -- 296
	state.nodes[id] = node -- 298
	local ____state_order_2 = state.order -- 298
	____state_order_2[#____state_order_2 + 1] = id -- 299
	local parent = state.nodes[resolvedParentId] -- 300
	if id ~= "root" and parent ~= nil then -- 300
		local ____parent_children_3 = parent.children -- 300
		____parent_children_3[#____parent_children_3 + 1] = id -- 302
	end -- 302
	return node -- 304
end -- 274
local function sceneNodeKind(value) -- 307
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 307
		return value -- 309
	end -- 309
	return "Node" -- 311
end -- 307
local function stringValue(value, fallback) -- 314
	return type(value) == "string" and value or fallback -- 315
end -- 314
local function numberValue(value, fallback) -- 318
	local parsed = tonumber(value) -- 319
	return parsed ~= nil and parsed or fallback -- 320
end -- 318
local function booleanValue(value, fallback) -- 323
	local ____temp_4 -- 324
	if type(value) == "boolean" then -- 324
		____temp_4 = value -- 324
	else -- 324
		____temp_4 = fallback -- 324
	end -- 324
	return ____temp_4 -- 324
end -- 323
local function updateNextIdFromNodeId(state, id) -- 327
	local digits = string.match(id, "%-(%d+)$") -- 328
	if digits ~= nil then -- 328
		local value = tonumber(digits) -- 330
		if value ~= nil and value > state.nextId then -- 330
			state.nextId = value -- 331
		end -- 331
	end -- 331
end -- 327
function ____exports.loadSceneFromFile(state, file) -- 335
	if not Content:exist(file) then -- 335
		return false -- 336
	end -- 336
	local data = json.decode(Content:load(file)) -- 337
	if data == nil then -- 337
		return false -- 338
	end -- 338
	local rawNodes = data.nodes -- 339
	if rawNodes == nil then -- 339
		return false -- 340
	end -- 340
	state.nodes = {} -- 342
	state.order = {} -- 343
	state.runtimeNodes = {} -- 344
	state.runtimeLabels = {} -- 345
	state.playRuntimeNodes = {} -- 346
	state.playRuntimeLabels = {} -- 347
	state.nextId = 0 -- 348
	for ____, raw in ipairs(rawNodes) do -- 350
		local kind = sceneNodeKind(raw.kind) -- 351
		local id = stringValue( -- 352
			raw.id, -- 352
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 352
		) -- 352
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 353
		local texture = stringValue(raw.texture, "") -- 354
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 355
		local script = stringValue(raw.script, "") -- 356
		local ____temp_5 -- 357
		if id == "root" then -- 357
			____temp_5 = nil -- 357
		else -- 357
			____temp_5 = stringValue(raw.parentId, "root") -- 357
		end -- 357
		local parentId = ____temp_5 -- 357
		local node = { -- 358
			id = id, -- 359
			kind = kind, -- 360
			name = name, -- 361
			parentId = parentId, -- 362
			children = {}, -- 363
			x = numberValue(raw.x, 0), -- 364
			y = numberValue(raw.y, 0), -- 365
			scaleX = numberValue(raw.scaleX, 1), -- 366
			scaleY = numberValue(raw.scaleY, 1), -- 367
			rotation = numberValue(raw.rotation, 0), -- 368
			visible = booleanValue(raw.visible, true), -- 369
			texture = texture, -- 370
			text = text, -- 371
			script = script, -- 372
			nameBuffer = ____exports.makeBuffer(name, 128), -- 373
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 374
			textBuffer = ____exports.makeBuffer(text, 256), -- 375
			scriptBuffer = ____exports.makeBuffer(script, 256) -- 376
		} -- 376
		state.nodes[id] = node -- 378
		local ____state_order_6 = state.order -- 378
		____state_order_6[#____state_order_6 + 1] = id -- 379
		updateNextIdFromNodeId(state, id) -- 380
	end -- 380
	if state.nodes.root == nil then -- 380
		____exports.addNode(state, "Root", "MainScene") -- 384
	end -- 384
	for ____, id in ipairs(state.order) do -- 386
		do -- 386
			if id == "root" then -- 386
				goto __continue83 -- 387
			end -- 387
			local node = state.nodes[id] -- 388
			if node == nil then -- 388
				goto __continue83 -- 389
			end -- 389
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 389
				node.parentId = "root" -- 391
			end -- 391
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 391
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 393
		end -- 393
		::__continue83:: -- 393
	end -- 393
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 395
	state.previewDirty = true -- 396
	state.playDirty = true -- 397
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 398
	____exports.pushConsole(state, state.status) -- 399
	return true -- 400
end -- 335
local function removeFromOrder(state, id) -- 403
	do -- 403
		local i = #state.order -- 404
		while i >= 1 do -- 404
			if state.order[i] == id then -- 404
				table.remove(state.order, i) -- 406
			end -- 406
			i = i - 1 -- 404
		end -- 404
	end -- 404
end -- 403
function ____exports.deleteNode(state, id) -- 411
	if id == "root" then -- 411
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 413
		return -- 414
	end -- 414
	local node = state.nodes[id] -- 416
	if node == nil then -- 416
		return -- 417
	end -- 417
	do -- 417
		local i = #node.children -- 418
		while i >= 1 do -- 418
			____exports.deleteNode(state, node.children[i]) -- 419
			i = i - 1 -- 418
		end -- 418
	end -- 418
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 421
	if parent ~= nil then -- 421
		do -- 421
			local i = #parent.children -- 423
			while i >= 1 do -- 423
				if parent.children[i] == id then -- 423
					table.remove(parent.children, i) -- 424
				end -- 424
				i = i - 1 -- 423
			end -- 423
		end -- 423
	end -- 423
	__TS__Delete(state.nodes, id) -- 427
	removeFromOrder(state, id) -- 428
	state.selectedId = "root" -- 429
	state.draggingNodeId = nil -- 430
	state.previewDirty = true -- 431
	state.playDirty = true -- 432
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 433
	____exports.pushConsole(state, state.status) -- 434
end -- 411
function ____exports.addChildNode(state, kind) -- 437
	local parentId = state.selectedId or "root" -- 438
	if state.nodes[parentId] == nil then -- 438
		parentId = "root" -- 439
	end -- 439
	local node = ____exports.addNode( -- 440
		state, -- 440
		kind, -- 440
		kind .. tostring(state.nextId + 1), -- 440
		parentId -- 440
	) -- 440
	state.selectedId = node.id -- 441
	state.previewDirty = true -- 442
	state.playDirty = true -- 443
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 444
	____exports.pushConsole(state, state.status) -- 445
end -- 437
return ____exports -- 437