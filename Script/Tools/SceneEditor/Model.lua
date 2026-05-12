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
function ____exports.pushConsole(state, message) -- 92
	local ____state_console_0 = state.console -- 92
	____state_console_0[#____state_console_0 + 1] = message -- 93
	if #state.console > 7 then -- 93
		table.remove(state.console, 1) -- 95
	end -- 95
end -- 92
function ____exports.isFolderAsset(path) -- 121
	return path ~= "" and string.sub( -- 122
		path, -- 122
		string.len(path), -- 122
		string.len(path) -- 122
	) == "/" -- 122
end -- 121
function hasAsset(state, asset) -- 125
	for ____, item in ipairs(state.assets) do -- 126
		if item == asset then -- 126
			return true -- 127
		end -- 127
	end -- 127
	return false -- 129
end -- 129
function rememberAsset(state, asset) -- 132
	if asset == "" then -- 132
		return -- 133
	end -- 133
	if not hasAsset(state, asset) then -- 133
		local ____state_assets_1 = state.assets -- 133
		____state_assets_1[#____state_assets_1 + 1] = asset -- 134
	end -- 134
end -- 134
function sortAssets(state) -- 137
	table.sort( -- 138
		state.assets, -- 138
		function(a, b) -- 138
			local aFolder = ____exports.isFolderAsset(a) -- 139
			local bFolder = ____exports.isFolderAsset(b) -- 140
			if aFolder == bFolder then -- 140
				return a < b -- 141
			end -- 141
			return aFolder -- 142
		end -- 138
	) -- 138
end -- 138
function normalizeSlash(path) -- 146
	local result = string.gsub(path, "\\", "/") -- 147
	local found = string.find(result, "//") -- 148
	while found ~= nil do -- 148
		result = string.gsub(result, "//", "/") -- 150
		found = string.find(result, "//") -- 151
	end -- 151
	return result -- 153
end -- 153
function stripFolderPrefix(folder, path) -- 156
	local cleanFolder = normalizeSlash(folder) -- 157
	local cleanPath = normalizeSlash(path) -- 158
	if string.sub( -- 158
		cleanPath, -- 159
		1, -- 159
		string.len(cleanFolder) -- 159
	) == cleanFolder then -- 159
		local rest = string.sub( -- 160
			cleanPath, -- 160
			string.len(cleanFolder) + 1 -- 160
		) -- 160
		if string.sub(rest, 1, 1) == "/" then -- 160
			rest = string.sub(rest, 2) -- 161
		end -- 161
		return rest -- 162
	end -- 162
	return Path:getFilename(path) -- 164
end -- 164
function refreshAssetSearchPath(importedPath) -- 167
	Content:addSearchPath(____exports.workspaceRoot()) -- 168
	Content:addSearchPath(____exports.workspacePath(importedAssetRoot)) -- 169
	if importedPath ~= nil and importedPath ~= "" then -- 169
		local importedFolder = Path:getPath(importedPath) -- 171
		if importedFolder ~= "" then -- 171
			Content:addSearchPath(____exports.workspacePath(importedFolder)) -- 172
		end -- 172
	end -- 172
	Content:clearPathCache() -- 174
end -- 174
function ____exports.refreshImportedAssets(state) -- 177
	local importedAbsolutePath = ____exports.workspacePath(importedAssetRoot) -- 178
	Content:mkdir(importedAbsolutePath) -- 179
	refreshAssetSearchPath(importedAssetRoot) -- 180
	rememberAsset(state, importedAssetRootEntry) -- 181
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 182
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 183
		rememberAsset(state, asset) -- 184
	end -- 184
	sortAssets(state) -- 186
end -- 177
function notifyWebIDEFileAdded(workspaceRelativePath) -- 189
	local fullPath = ____exports.workspacePath(workspaceRelativePath) -- 190
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 191
	if payload ~= nil then -- 191
		emit("AppWS", "Send", payload) -- 198
	end -- 198
end -- 198
function copyFileToImported(srcPath, importedPath) -- 202
	local target = ____exports.workspacePath(importedPath) -- 203
	Content:mkdir(Path:getPath(target)) -- 204
	if srcPath == target or Content:copy(srcPath, target) then -- 204
		refreshAssetSearchPath(importedPath) -- 206
		notifyWebIDEFileAdded(importedPath) -- 207
		return importedPath -- 208
	end -- 208
	Content:clearPathCache() -- 210
	return nil -- 211
end -- 211
function ____exports.addAssetFolder(state, folderPath) -- 234
	if folderPath == "" then -- 234
		return nil -- 235
	end -- 235
	local folderName = Path:getName(folderPath) or "Folder" -- 236
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 237
	rememberAsset(state, importedAssetRootEntry) -- 238
	rememberAsset(state, rootAsset) -- 239
	local added = 0 -- 240
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 241
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 242
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 243
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 244
		local asset = copyFileToImported(absoluteFile, importedFile) -- 245
		if asset ~= nil then -- 245
			rememberAsset(state, asset) -- 247
			added = added + 1 -- 248
		end -- 248
	end -- 248
	____exports.refreshImportedAssets(state) -- 251
	state.selectedAsset = rootAsset -- 252
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 253
	____exports.pushConsole(state, state.status) -- 254
	return rootAsset -- 255
end -- 234
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
	state.playWindow = {x = 0, y = 0, width = 960, height = 620} -- 87
	____exports.refreshImportedAssets(state) -- 88
	return state -- 89
end -- 50
function ____exports.iconFor(kind) -- 99
	if kind == "Sprite" then -- 99
		return "▣" -- 100
	end -- 100
	if kind == "Label" then -- 100
		return "T" -- 101
	end -- 101
	if kind == "Camera" then -- 101
		return "◉" -- 102
	end -- 102
	return "○" -- 103
end -- 99
function ____exports.lowerExt(path) -- 106
	local ext = Path:getExt(path or "") or "" -- 107
	return string.lower(ext) -- 108
end -- 106
function ____exports.isTextureAsset(path) -- 111
	local ext = ____exports.lowerExt(path) -- 112
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 113
end -- 111
function ____exports.isScriptAsset(path) -- 116
	local ext = ____exports.lowerExt(path) -- 117
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 118
end -- 116
function ____exports.addAssetPath(state, path, importedPath) -- 214
	if path == nil or path == "" then -- 214
		return nil -- 215
	end -- 215
	if Content:isdir(path) then -- 215
		return ____exports.addAssetFolder(state, path) -- 217
	end -- 217
	local asset = copyFileToImported( -- 219
		path, -- 219
		importedPath or Path( -- 219
			importedAssetRoot, -- 219
			Path:getFilename(path) -- 219
		) -- 219
	) -- 219
	if asset == nil then -- 219
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 221
		____exports.pushConsole(state, state.status) -- 222
		return nil -- 223
	end -- 223
	rememberAsset(state, asset) -- 225
	rememberAsset(state, importedAssetRootEntry) -- 226
	____exports.refreshImportedAssets(state) -- 227
	state.selectedAsset = asset -- 228
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 229
	____exports.pushConsole(state, state.status) -- 230
	return asset -- 231
end -- 214
function ____exports.importFileDialog(state) -- 258
	App:openFileDialog( -- 259
		false, -- 259
		function(path) -- 259
			____exports.addAssetPath(state, path) -- 260
		end -- 259
	) -- 259
end -- 258
function ____exports.importFolderDialog(state) -- 264
	App:openFileDialog( -- 265
		true, -- 265
		function(path) -- 265
			____exports.addAssetFolder(state, path) -- 266
		end -- 265
	) -- 265
end -- 264
local function newNodeId(state, kind) -- 270
	state.nextId = state.nextId + 1 -- 271
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 272
end -- 270
function ____exports.addNode(state, kind, name, parentId) -- 275
	local resolvedParentId = parentId or "root" -- 276
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 277
	local index = state.nextId -- 278
	local node = { -- 279
		id = id, -- 280
		kind = kind, -- 281
		name = name, -- 282
		parentId = resolvedParentId, -- 283
		children = {}, -- 284
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 285
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 286
		scaleX = 1, -- 287
		scaleY = 1, -- 288
		rotation = 0, -- 289
		visible = true, -- 290
		texture = "", -- 291
		text = kind == "Label" and "Label" or "", -- 292
		script = "", -- 293
		nameBuffer = ____exports.makeBuffer(name, 128), -- 294
		textureBuffer = ____exports.makeBuffer("", 256), -- 295
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 296
		scriptBuffer = ____exports.makeBuffer("", 256) -- 297
	} -- 297
	state.nodes[id] = node -- 299
	local ____state_order_2 = state.order -- 299
	____state_order_2[#____state_order_2 + 1] = id -- 300
	local parent = state.nodes[resolvedParentId] -- 301
	if id ~= "root" and parent ~= nil then -- 301
		local ____parent_children_3 = parent.children -- 301
		____parent_children_3[#____parent_children_3 + 1] = id -- 303
	end -- 303
	return node -- 305
end -- 275
local function sceneNodeKind(value) -- 308
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then -- 308
		return value -- 310
	end -- 310
	return "Node" -- 312
end -- 308
local function stringValue(value, fallback) -- 315
	return type(value) == "string" and value or fallback -- 316
end -- 315
local function numberValue(value, fallback) -- 319
	local parsed = tonumber(value) -- 320
	return parsed ~= nil and parsed or fallback -- 321
end -- 319
local function booleanValue(value, fallback) -- 324
	local ____temp_4 -- 325
	if type(value) == "boolean" then -- 325
		____temp_4 = value -- 325
	else -- 325
		____temp_4 = fallback -- 325
	end -- 325
	return ____temp_4 -- 325
end -- 324
local function updateNextIdFromNodeId(state, id) -- 328
	local digits = string.match(id, "%-(%d+)$") -- 329
	if digits ~= nil then -- 329
		local value = tonumber(digits) -- 331
		if value ~= nil and value > state.nextId then -- 331
			state.nextId = value -- 332
		end -- 332
	end -- 332
end -- 328
function ____exports.loadSceneFromFile(state, file) -- 336
	if not Content:exist(file) then -- 336
		return false -- 337
	end -- 337
	local data = json.decode(Content:load(file)) -- 338
	if data == nil then -- 338
		return false -- 339
	end -- 339
	local rawNodes = data.nodes -- 340
	if rawNodes == nil then -- 340
		return false -- 341
	end -- 341
	state.nodes = {} -- 343
	state.order = {} -- 344
	state.runtimeNodes = {} -- 345
	state.runtimeLabels = {} -- 346
	state.playRuntimeNodes = {} -- 347
	state.playRuntimeLabels = {} -- 348
	state.nextId = 0 -- 349
	for ____, raw in ipairs(rawNodes) do -- 351
		local kind = sceneNodeKind(raw.kind) -- 352
		local id = stringValue( -- 353
			raw.id, -- 353
			kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1) -- 353
		) -- 353
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind) -- 354
		local texture = stringValue(raw.texture, "") -- 355
		local text = stringValue(raw.text, kind == "Label" and "Label" or "") -- 356
		local script = stringValue(raw.script, "") -- 357
		local ____temp_5 -- 358
		if id == "root" then -- 358
			____temp_5 = nil -- 358
		else -- 358
			____temp_5 = stringValue(raw.parentId, "root") -- 358
		end -- 358
		local parentId = ____temp_5 -- 358
		local node = { -- 359
			id = id, -- 360
			kind = kind, -- 361
			name = name, -- 362
			parentId = parentId, -- 363
			children = {}, -- 364
			x = numberValue(raw.x, 0), -- 365
			y = numberValue(raw.y, 0), -- 366
			scaleX = numberValue(raw.scaleX, 1), -- 367
			scaleY = numberValue(raw.scaleY, 1), -- 368
			rotation = numberValue(raw.rotation, 0), -- 369
			visible = booleanValue(raw.visible, true), -- 370
			texture = texture, -- 371
			text = text, -- 372
			script = script, -- 373
			nameBuffer = ____exports.makeBuffer(name, 128), -- 374
			textureBuffer = ____exports.makeBuffer(texture, 256), -- 375
			textBuffer = ____exports.makeBuffer(text, 256), -- 376
			scriptBuffer = ____exports.makeBuffer(script, 256) -- 377
		} -- 377
		state.nodes[id] = node -- 379
		local ____state_order_6 = state.order -- 379
		____state_order_6[#____state_order_6 + 1] = id -- 380
		updateNextIdFromNodeId(state, id) -- 381
	end -- 381
	if state.nodes.root == nil then -- 381
		____exports.addNode(state, "Root", "MainScene") -- 385
	end -- 385
	for ____, id in ipairs(state.order) do -- 387
		do -- 387
			if id == "root" then -- 387
				goto __continue83 -- 388
			end -- 388
			local node = state.nodes[id] -- 389
			if node == nil then -- 389
				goto __continue83 -- 390
			end -- 390
			if node.parentId == nil or state.nodes[node.parentId] == nil then -- 390
				node.parentId = "root" -- 392
			end -- 392
			local ____state_nodes_node_parentId_children_7 = state.nodes[node.parentId].children -- 392
			____state_nodes_node_parentId_children_7[#____state_nodes_node_parentId_children_7 + 1] = id -- 394
		end -- 394
		::__continue83:: -- 394
	end -- 394
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 396
	state.previewDirty = true -- 397
	state.playDirty = true -- 398
	state.status = ____exports.zh and "已加载场景" or "Scene loaded" -- 399
	____exports.pushConsole(state, state.status) -- 400
	return true -- 401
end -- 336
local function removeFromOrder(state, id) -- 404
	do -- 404
		local i = #state.order -- 405
		while i >= 1 do -- 405
			if state.order[i] == id then -- 405
				table.remove(state.order, i) -- 407
			end -- 407
			i = i - 1 -- 405
		end -- 405
	end -- 405
end -- 404
function ____exports.deleteNode(state, id) -- 412
	if id == "root" then -- 412
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 414
		return -- 415
	end -- 415
	local node = state.nodes[id] -- 417
	if node == nil then -- 417
		return -- 418
	end -- 418
	do -- 418
		local i = #node.children -- 419
		while i >= 1 do -- 419
			____exports.deleteNode(state, node.children[i]) -- 420
			i = i - 1 -- 419
		end -- 419
	end -- 419
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 422
	if parent ~= nil then -- 422
		do -- 422
			local i = #parent.children -- 424
			while i >= 1 do -- 424
				if parent.children[i] == id then -- 424
					table.remove(parent.children, i) -- 425
				end -- 425
				i = i - 1 -- 424
			end -- 424
		end -- 424
	end -- 424
	__TS__Delete(state.nodes, id) -- 428
	removeFromOrder(state, id) -- 429
	state.selectedId = "root" -- 430
	state.draggingNodeId = nil -- 431
	state.previewDirty = true -- 432
	state.playDirty = true -- 433
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 434
	____exports.pushConsole(state, state.status) -- 435
end -- 412
function ____exports.addChildNode(state, kind) -- 438
	local parentId = state.selectedId or "root" -- 439
	if state.nodes[parentId] == nil then -- 439
		parentId = "root" -- 440
	end -- 440
	local node = ____exports.addNode( -- 441
		state, -- 441
		kind, -- 441
		kind .. tostring(state.nextId + 1), -- 441
		parentId -- 441
	) -- 441
	state.selectedId = node.id -- 442
	state.previewDirty = true -- 443
	state.playDirty = true -- 444
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 445
	____exports.pushConsole(state, state.status) -- 446
end -- 438
return ____exports -- 438