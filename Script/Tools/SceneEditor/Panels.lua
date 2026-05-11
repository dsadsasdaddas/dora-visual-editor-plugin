-- [ts]: Panels.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Mouse = ____Dora.Mouse -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local emit = ____Dora.emit -- 1
local json = ____Dora.json -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local inputTextFlags = ____Theme.inputTextFlags -- 5
local mainWindowFlags = ____Theme.mainWindowFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local okColor = ____Theme.okColor -- 5
local panelBg = ____Theme.panelBg -- 5
local scriptPanelBg = ____Theme.scriptPanelBg -- 5
local themeColor = ____Theme.themeColor -- 5
local transparent = ____Theme.transparent -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addAssetPath = ____Model.addAssetPath -- 6
local addChildNode = ____Model.addChildNode -- 6
local iconFor = ____Model.iconFor -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local importFolderDialog = ____Model.importFolderDialog -- 6
local isFolderAsset = ____Model.isFolderAsset -- 6
local isScriptAsset = ____Model.isScriptAsset -- 6
local isTextureAsset = ____Model.isTextureAsset -- 6
local lowerExt = ____Model.lowerExt -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____Player = require("Script.Tools.SceneEditor.Player") -- 8
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 8
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 9
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 9
local ____HeaderPanel = require("Script.Tools.SceneEditor.Panels.HeaderPanel") -- 10
local drawHeaderPanel = ____HeaderPanel.drawHeaderPanel -- 10
local ____ConsolePanel = require("Script.Tools.SceneEditor.Panels.ConsolePanel") -- 11
local drawConsolePanel = ____ConsolePanel.drawConsolePanel -- 11
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 16
local function workspacePath(path) -- 17
	return SceneModel.workspacePath(path) -- 17
end -- 17
local function workspaceRoot() -- 18
	return SceneModel.workspaceRoot() -- 18
end -- 18
local function sceneSaveFile() -- 20
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 21
end -- 20
local function drawNodeRow(state, id, depth) -- 24
	local node = state.nodes[id] -- 25
	if node == nil then -- 25
		return -- 26
	end -- 26
	local indent = string.rep("  ", depth) -- 27
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 28
	if ImGui.Selectable(label, state.selectedId == id) then -- 28
		state.selectedId = id -- 30
		state.previewDirty = true -- 31
	end -- 31
	for ____, childId in ipairs(node.children) do -- 33
		drawNodeRow(state, childId, depth + 1) -- 34
	end -- 34
end -- 24
local function writeSceneFile(state) -- 38
	Content:mkdir(workspacePath(".dora")) -- 39
	local data = {version = 1, nodes = {}} -- 40
	for ____, id in ipairs(state.order) do -- 41
		local node = state.nodes[id] -- 42
		if node ~= nil then -- 42
			local ____data_nodes_0 = data.nodes -- 42
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 44
				id = node.id, -- 45
				kind = node.kind, -- 46
				name = node.name, -- 47
				parentId = node.parentId, -- 48
				x = node.x, -- 49
				y = node.y, -- 50
				scaleX = node.scaleX, -- 51
				scaleY = node.scaleY, -- 52
				rotation = node.rotation, -- 53
				visible = node.visible, -- 54
				texture = node.texture, -- 55
				text = node.text, -- 56
				script = node.script -- 57
			} -- 57
		end -- 57
	end -- 57
	local text = json.encode(data) -- 61
	local file = sceneSaveFile() -- 62
	if text ~= nil and Content:save(file, text) then -- 62
		return file -- 63
	end -- 63
	return nil -- 64
end -- 38
local function saveScene(state) -- 67
	local file = writeSceneFile(state) -- 68
	if file ~= nil then -- 68
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 70
	else -- 70
		state.status = zh and "保存失败" or "Save failed" -- 72
	end -- 72
	pushConsole(state, state.status) -- 74
end -- 67
local function attachScriptToNode(state, node, scriptPath, message) -- 77
	node.script = scriptPath -- 78
	node.scriptBuffer.text = scriptPath -- 79
	state.activeScriptNodeId = node.id -- 80
	local sceneFile = writeSceneFile(state) -- 81
	if sceneFile == nil then -- 81
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 83
	else -- 83
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 85
	end -- 85
	pushConsole(state, state.status) -- 87
end -- 77
local function drawScenePanel(state) -- 90
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 91
	ImGui.SameLine() -- 92
	if ImGui.SmallButton("＋##scene_add") then -- 92
		ImGui.OpenPopup("AddNodePopup") -- 93
	end -- 93
	drawAddNodePopup(state) -- 94
	ImGui.Separator() -- 95
	drawNodeRow(state, "root", 0) -- 96
	ImGui.Separator() -- 97
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 98
end -- 90
local function bindTextureToSprite(state, node, texture) -- 101
	node.texture = texture -- 102
	node.textureBuffer.text = texture -- 103
	state.selectedAsset = texture -- 104
	state.previewDirty = true -- 105
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 106
	pushConsole(state, state.status) -- 107
end -- 101
local function createSpriteFromTexture(state, texture) -- 110
	addChildNode(state, "Sprite") -- 111
	local node = state.nodes[state.selectedId] -- 112
	if node ~= nil and node.kind == "Sprite" then -- 112
		bindTextureToSprite(state, node, texture) -- 114
	end -- 114
end -- 110
local function assetIcon(asset) -- 118
	if isFolderAsset(asset) then -- 118
		return "📁" -- 119
	end -- 119
	if isTextureAsset(asset) then -- 119
		return "🖼" -- 120
	end -- 120
	if isScriptAsset(asset) then -- 120
		return "◇" -- 121
	end -- 121
	local ext = lowerExt(asset) -- 122
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 122
		return "♪" -- 123
	end -- 123
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 123
		return "F" -- 124
	end -- 124
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 124
		return "{}" -- 125
	end -- 125
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 125
		return "◆" -- 126
	end -- 126
	return "·" -- 127
end -- 118
local function startsWith(text, prefix) -- 130
	return string.sub( -- 131
		text, -- 131
		1, -- 131
		string.len(prefix) -- 131
	) == prefix -- 131
end -- 130
local function drawAssetRow(state, asset) -- 134
	if isFolderAsset(asset) then -- 134
		ImGui.TreeNode( -- 136
			(assetIcon(asset) .. "  ") .. asset, -- 136
			function() -- 136
				for ____, child in ipairs(state.assets) do -- 137
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 137
						drawAssetRow(state, child) -- 139
					end -- 139
				end -- 139
			end -- 136
		) -- 136
		return -- 143
	end -- 143
	if ImGui.Selectable( -- 143
		(assetIcon(asset) .. "  ") .. asset, -- 145
		state.selectedAsset == asset -- 145
	) then -- 145
		state.selectedAsset = asset -- 146
		local node = state.nodes[state.selectedId] -- 147
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 147
			bindTextureToSprite(state, node, asset) -- 149
			return -- 150
		elseif node ~= nil and isScriptAsset(asset) then -- 150
			attachScriptToNode(state, node, asset, (zh and "已绑定脚本并保存：" or "Script assigned and saved: ") .. asset) -- 152
			return -- 153
		else -- 153
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 155
		end -- 155
		pushConsole(state, state.status) -- 157
	end -- 157
end -- 134
local function drawAssetsPanel(state) -- 161
	ImGui.TextColored(themeColor, zh and "资源" or "Assets") -- 162
	ImGui.SameLine() -- 163
	if ImGui.SmallButton(zh and "＋ 文件" or "＋ File") then -- 163
		importFileDialog(state) -- 164
	end -- 164
	ImGui.SameLine() -- 165
	if ImGui.SmallButton(zh and "＋ 文件夹" or "＋ Folder") then -- 165
		importFolderDialog(state) -- 166
	end -- 166
	ImGui.Separator() -- 167
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 168
	ImGui.Separator() -- 169
	if #state.assets == 0 then -- 169
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 171
		return -- 172
	end -- 172
	for ____, asset in ipairs(state.assets) do -- 174
		if isFolderAsset(asset) then -- 174
			drawAssetRow(state, asset) -- 176
		end -- 176
	end -- 176
	for ____, asset in ipairs(state.assets) do -- 179
		local insideFolder = false -- 180
		for ____, folder in ipairs(state.assets) do -- 181
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 181
				insideFolder = true -- 182
			end -- 182
		end -- 182
		if not insideFolder and not isFolderAsset(asset) then -- 182
			drawAssetRow(state, asset) -- 184
		end -- 184
	end -- 184
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 184
		ImGui.Separator() -- 187
		ImGui.TextColored(themeColor, zh and "贴图预览" or "Texture Preview") -- 188
		local ok = pcall(function() return ImGui.Image( -- 189
			state.selectedAsset, -- 189
			Vec2(160, 120) -- 189
		) end) -- 189
		if not ok then -- 189
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 190
		end -- 190
		local selectedNode = state.nodes[state.selectedId] -- 191
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 191
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 191
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 193
			end -- 193
			ImGui.SameLine() -- 194
		end -- 194
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 194
			createSpriteFromTexture(state, state.selectedAsset) -- 196
		end -- 196
	end -- 196
end -- 161
local function scriptTemplate(node) -- 200
	local name = node ~= nil and node.name or "Script" -- 201
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 200
local function loadScriptIntoEditor(state, node, scriptPath) -- 212
	if node ~= nil then -- 212
		attachScriptToNode(state, node, scriptPath) -- 214
	else -- 214
		state.activeScriptNodeId = nil -- 216
	end -- 216
	state.scriptPathBuffer.text = scriptPath -- 218
	local scriptFile = workspacePath(scriptPath) -- 219
	if Content:exist(scriptFile) then -- 219
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 221
	elseif Content:exist(scriptPath) then -- 221
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 223
	else -- 223
		state.scriptContentBuffer.text = scriptTemplate(node) -- 225
	end -- 225
	state.mode = "Script" -- 227
end -- 212
local function openScriptForNode(state, node) -- 230
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 231
	loadScriptIntoEditor(state, node, path) -- 232
end -- 230
local function saveScriptFile(state, node) -- 235
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 236
	state.scriptPathBuffer.text = path -- 237
	local scriptFile = workspacePath(path) -- 238
	Content:mkdir(Path:getPath(scriptFile)) -- 239
	local statusAlreadyLogged = false -- 240
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 240
		if node ~= nil then -- 240
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 243
			statusAlreadyLogged = true -- 244
		else -- 244
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 246
		end -- 246
		if state.selectedAsset ~= path then -- 246
			state.selectedAsset = path -- 248
		end -- 248
		local exists = false -- 249
		for ____, asset in ipairs(state.assets) do -- 250
			if asset == path then -- 250
				exists = true -- 250
			end -- 250
		end -- 250
		if not exists then -- 250
			local ____state_assets_1 = state.assets -- 250
			____state_assets_1[#____state_assets_1 + 1] = path -- 251
		end -- 251
	else -- 251
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 253
	end -- 253
	if not statusAlreadyLogged then -- 253
		pushConsole(state, state.status) -- 255
	end -- 255
end -- 235
local function currentScriptPath(state, node) -- 258
	if state.scriptPathBuffer.text ~= "" then -- 258
		return state.scriptPathBuffer.text -- 259
	end -- 259
	if node ~= nil and node.script ~= "" then -- 259
		return node.script -- 260
	end -- 260
	if node ~= nil then -- 260
		return ("Script/" .. node.name) .. ".lua" -- 261
	end -- 261
	return "Script/NewScript.lua" -- 262
end -- 258
local function sendWebIDEMessage(payload) -- 265
	local text = json.encode(payload) -- 266
	if text ~= nil then -- 266
		emit("AppWS", "Send", text) -- 267
	end -- 267
end -- 265
local function openScriptInWebIDE(state, node) -- 270
	local scriptPath = currentScriptPath(state, node) -- 271
	state.scriptPathBuffer.text = scriptPath -- 272
	if state.scriptContentBuffer.text == "" then -- 272
		state.scriptContentBuffer.text = scriptTemplate(node) -- 274
	end -- 274
	saveScriptFile(state, node) -- 276
	local title = Path:getFilename(scriptPath) or scriptPath -- 277
	local root = workspaceRoot() -- 278
	local rootTitle = Path:getFilename(root) or "Workspace" -- 279
	local fullScriptPath = workspacePath(scriptPath) -- 280
	local openWorkspaceMessage = { -- 281
		name = "OpenFile", -- 282
		file = root, -- 283
		title = rootTitle, -- 284
		folder = true, -- 285
		workspaceView = "agent" -- 286
	} -- 286
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 288
	local openScriptMessage = { -- 294
		name = "OpenFile", -- 295
		file = fullScriptPath, -- 296
		title = title, -- 297
		folder = false, -- 298
		position = {lineNumber = 1, column = 1} -- 299
	} -- 299
	local function sendOpenMessages() -- 301
		sendWebIDEMessage(openWorkspaceMessage) -- 302
		sendWebIDEMessage(updateScriptMessage) -- 303
		sendWebIDEMessage(openScriptMessage) -- 304
	end -- 301
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 306
	local editingText = json.encode(editingInfo) -- 323
	if editingText ~= nil then -- 323
		Content:mkdir(workspacePath(".dora")) -- 325
		Content:save( -- 326
			workspacePath(Path(".dora", "open-script.editing.json")), -- 326
			editingText -- 326
		) -- 326
		pcall(function() -- 327
			local Entry = require("Script.Dev.Entry") -- 328
			local config = Entry.getConfig() -- 329
			if config ~= nil then -- 329
				config.editingInfo = editingText -- 330
			end -- 330
		end) -- 327
	end -- 327
	App:openURL("http://127.0.0.1:8866/") -- 333
	sendOpenMessages() -- 334
	thread(function() -- 335
		do -- 335
			local i = 0 -- 336
			while i < 4 do -- 336
				sleep(0.5) -- 337
				sendOpenMessages() -- 338
				i = i + 1 -- 336
			end -- 336
		end -- 336
	end) -- 335
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 341
	pushConsole(state, state.status) -- 342
end -- 270
local function drawScriptAssetList(state, node) -- 345
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 346
	for ____, asset in ipairs(state.assets) do -- 347
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 347
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 347
				state.selectedAsset = asset -- 350
				loadScriptIntoEditor(state, node, asset) -- 351
			end -- 351
		end -- 351
	end -- 351
end -- 345
local function drawScriptPanel(state) -- 357
	local activeId = state.activeScriptNodeId or state.selectedId -- 358
	local node = state.nodes[activeId] -- 359
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 360
	ImGui.SameLine() -- 361
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 362
	ImGui.Separator() -- 363
	ImGui.BeginChild( -- 364
		"ScriptSidebar", -- 364
		Vec2(220, 0), -- 364
		{}, -- 364
		noScrollFlags, -- 364
		function() -- 364
			drawScriptAssetList(state, node) -- 365
			ImGui.Separator() -- 366
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 366
				local scriptName = node ~= nil and node.name or "NewScript" -- 368
				local path = ("Script/" .. scriptName) .. ".lua" -- 369
				state.scriptPathBuffer.text = path -- 370
				state.scriptContentBuffer.text = scriptTemplate(node) -- 371
				if node ~= nil then -- 371
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 373
				end -- 373
			end -- 373
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 373
				importFileDialog(state) -- 376
			end -- 376
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 376
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 376
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 379
				end -- 379
			end -- 379
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 379
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 383
			end -- 383
		end -- 364
	) -- 364
	ImGui.SameLine() -- 386
	ImGui.PushStyleColor( -- 387
		"ChildBg", -- 387
		scriptPanelBg, -- 387
		function() -- 387
			ImGui.BeginChild( -- 388
				"ScriptEditorPane", -- 388
				Vec2(0, 0), -- 388
				{}, -- 388
				noScrollFlags, -- 388
				function() -- 388
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 389
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 390
					ImGui.SameLine() -- 391
					if ImGui.Button(zh and "保存" or "Save") then -- 391
						saveScriptFile(state, node) -- 392
					end -- 392
					ImGui.SameLine() -- 393
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 393
						openScriptInWebIDE(state, node) -- 394
					end -- 394
					if node ~= nil then -- 394
						ImGui.SameLine() -- 396
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 396
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 398
						end -- 398
					end -- 398
					ImGui.Separator() -- 401
					ImGui.InputTextMultiline( -- 402
						"##ScriptEditor", -- 402
						state.scriptContentBuffer, -- 402
						Vec2(0, -4), -- 402
						{} -- 402
					) -- 402
				end -- 388
			) -- 388
		end -- 387
	) -- 387
end -- 357
local function viewportScale(state) -- 407
	return math.max(0.25, state.zoom / 100) -- 408
end -- 407
local function clampZoom(value) -- 411
	return math.max( -- 412
		25, -- 412
		math.min(400, value) -- 412
	) -- 412
end -- 411
local function zoomViewportAt(state, delta, screenX, screenY) -- 415
	if delta == 0 then -- 415
		return -- 416
	end -- 416
	local before = state.zoom -- 417
	local beforeScale = viewportScale(state) -- 418
	local p = state.preview -- 419
	local centerX = p.x + p.width / 2 -- 420
	local centerY = p.y + p.height / 2 -- 421
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 422
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 423
	state.zoom = clampZoom(state.zoom + delta) -- 424
	if state.zoom ~= before then -- 424
		local afterScale = viewportScale(state) -- 426
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 427
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 428
		state.previewDirty = true -- 429
	end -- 429
end -- 415
local function zoomViewportFromCenter(state, delta) -- 433
	local p = state.preview -- 434
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 435
end -- 433
local function screenToScene(state, screenX, screenY) -- 438
	local p = state.preview -- 439
	local scale = viewportScale(state) -- 440
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 441
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 442
	return {localX / scale, localY / scale} -- 443
end -- 438
local function pickNodeAt(state, screenX, screenY) -- 446
	local sceneX, sceneY = table.unpack( -- 447
		screenToScene(state, screenX, screenY), -- 447
		1, -- 447
		2 -- 447
	) -- 447
	do -- 447
		local i = #state.order -- 448
		while i >= 1 do -- 448
			local id = state.order[i] -- 449
			local node = state.nodes[id] -- 450
			if node ~= nil and id ~= "root" and node.visible then -- 450
				local dx = sceneX - node.x -- 452
				local dy = sceneY - node.y -- 453
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 454
				if dx * dx + dy * dy <= radius * radius then -- 454
					return id -- 455
				end -- 455
			end -- 455
			i = i - 1 -- 448
		end -- 448
	end -- 448
	return nil -- 458
end -- 446
local function handleViewportMouse(state, hovered) -- 461
	if not hovered then -- 461
		return -- 462
	end -- 462
	local spacePressed = Keyboard:isKeyPressed("Space") -- 463
	local wheel = Mouse.wheel -- 464
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 465
	if wheelDelta ~= 0 then -- 465
		local mouse = ImGui.GetMousePos() -- 467
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 468
	end -- 468
	if ImGui.IsMouseClicked(2) then -- 468
		state.draggingNodeId = nil -- 471
		state.draggingViewport = true -- 472
		ImGui.ResetMouseDragDelta(2) -- 473
	end -- 473
	if ImGui.IsMouseClicked(0) then -- 473
		if spacePressed then -- 473
			state.draggingNodeId = nil -- 477
			state.draggingViewport = true -- 478
		else -- 478
			local mouse = ImGui.GetMousePos() -- 480
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 481
			if picked ~= nil then -- 481
				state.selectedId = picked -- 483
				state.previewDirty = true -- 484
				state.draggingNodeId = picked -- 485
				state.draggingViewport = false -- 486
			else -- 486
				state.draggingNodeId = nil -- 488
				state.draggingViewport = true -- 489
			end -- 489
		end -- 489
		ImGui.ResetMouseDragDelta(0) -- 492
	end -- 492
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 492
		state.draggingNodeId = nil -- 495
		state.draggingViewport = false -- 496
	end -- 496
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 496
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 499
		local delta = ImGui.GetMouseDragDelta(panButton) -- 500
		if delta.x ~= 0 or delta.y ~= 0 then -- 500
			if state.draggingNodeId ~= nil and panButton == 0 then -- 500
				local node = state.nodes[state.draggingNodeId] -- 503
				if node ~= nil then -- 503
					local scale = viewportScale(state) -- 505
					node.x = node.x + delta.x / scale -- 506
					node.y = node.y - delta.y / scale -- 507
					if state.snapEnabled then -- 507
						local step = 16 -- 509
						node.x = math.floor(node.x / step + 0.5) * step -- 510
						node.y = math.floor(node.y / step + 0.5) * step -- 511
					end -- 511
				end -- 511
			elseif state.draggingViewport then -- 511
				state.viewportPanX = state.viewportPanX + delta.x -- 515
				state.viewportPanY = state.viewportPanY - delta.y -- 516
			end -- 516
			ImGui.ResetMouseDragDelta(panButton) -- 518
		end -- 518
	end -- 518
end -- 461
local function drawViewportToolButton(state, tool, label) -- 523
	local active = state.viewportTool == tool -- 524
	if active then -- 524
		ImGui.PushStyleColor( -- 526
			"Button", -- 526
			Color(4281349698), -- 526
			function() -- 526
				ImGui.PushStyleColor( -- 527
					"Text", -- 527
					themeColor, -- 527
					function() -- 527
						if ImGui.Button(label) then -- 527
							state.viewportTool = tool -- 528
						end -- 528
					end -- 527
				) -- 527
			end -- 526
		) -- 526
	elseif ImGui.Button(label) then -- 526
		state.viewportTool = tool -- 532
	end -- 532
end -- 523
local function drawViewport(state) -- 536
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 537
	ImGui.SameLine() -- 538
	drawViewportToolButton(state, "Select", "Select") -- 539
	ImGui.SameLine() -- 540
	drawViewportToolButton(state, "Move", "Move") -- 541
	ImGui.SameLine() -- 542
	drawViewportToolButton(state, "Rotate", "Rotate") -- 543
	ImGui.SameLine() -- 544
	drawViewportToolButton(state, "Scale", "Scale") -- 545
	ImGui.SameLine() -- 546
	ImGui.TextDisabled("|") -- 547
	ImGui.SameLine() -- 548
	local snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 549
	if snapChanged then -- 549
		state.snapEnabled = snap -- 550
	end -- 550
	ImGui.SameLine() -- 551
	local gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 552
	if gridChanged then -- 552
		state.showGrid = grid -- 553
		state.previewDirty = true -- 553
	end -- 553
	ImGui.SameLine() -- 554
	if ImGui.Button(zh and "居中" or "Center") then -- 554
		state.viewportPanX = 0 -- 556
		state.viewportPanY = 0 -- 557
		state.zoom = 100 -- 558
		state.previewDirty = true -- 559
	end -- 559
	ImGui.SameLine() -- 561
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 562
	ImGui.Separator() -- 563
	local cursor = ImGui.GetCursorScreenPos() -- 564
	local avail = ImGui.GetContentRegionAvail() -- 565
	local viewportWidth = math.max(360, avail.x - 8) -- 566
	local viewportHeight = math.max(300, avail.y - 38) -- 567
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 567
		state.previewDirty = true -- 569
	end -- 569
	state.preview.x = cursor.x -- 571
	state.preview.y = cursor.y -- 572
	state.preview.width = viewportWidth -- 573
	state.preview.height = viewportHeight -- 574
	updatePreviewRuntime(state) -- 575
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 576
	local hovered = ImGui.IsItemHovered() -- 577
	handleViewportMouse(state, hovered) -- 578
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 579
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 579
		zoomViewportFromCenter(state, -10) -- 580
	end -- 580
	ImGui.SameLine() -- 581
	ImGui.PushStyleColor( -- 582
		"Text", -- 582
		themeColor, -- 582
		function() -- 582
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 582
				state.zoom = 100 -- 584
				state.viewportPanX = 0 -- 585
				state.viewportPanY = 0 -- 586
				state.previewDirty = true -- 587
			end -- 587
		end -- 582
	) -- 582
	ImGui.SameLine() -- 590
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 590
		zoomViewportFromCenter(state, 10) -- 591
	end -- 591
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 592
	ImGui.Separator() -- 593
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 594
	ImGui.SameLine() -- 595
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 596
end -- 536
local function drawInspector(state) -- 599
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 600
	ImGui.Separator() -- 601
	local node = state.nodes[state.selectedId] -- 602
	if node == nil then -- 602
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 604
		return -- 605
	end -- 605
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 607
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 607
		node.name = node.nameBuffer.text -- 608
	end -- 608
	local changed, x, y = ImGui.DragFloat2( -- 609
		"Position", -- 609
		node.x, -- 609
		node.y, -- 609
		1, -- 609
		-10000, -- 609
		10000, -- 609
		"%.1f" -- 609
	) -- 609
	if changed then -- 609
		node.x = x -- 610
		node.y = y -- 610
	end -- 610
	changed, x, y = ImGui.DragFloat2( -- 611
		"Scale", -- 611
		node.scaleX, -- 611
		node.scaleY, -- 611
		0.01, -- 611
		-100, -- 611
		100, -- 611
		"%.2f" -- 611
	) -- 611
	if changed then -- 611
		node.scaleX = x -- 612
		node.scaleY = y -- 612
	end -- 612
	local angleChanged, angle = ImGui.DragFloat( -- 613
		"Rotation", -- 613
		node.rotation, -- 613
		1, -- 613
		-360, -- 613
		360, -- 613
		"%.1f" -- 613
	) -- 613
	if angleChanged then -- 613
		node.rotation = angle -- 614
	end -- 614
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 615
	if visibleChanged then -- 615
		node.visible = visible -- 616
	end -- 616
	ImGui.Separator() -- 617
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 617
		node.script = node.scriptBuffer.text -- 618
	end -- 618
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 618
		openScriptForNode(state, node) -- 619
	end -- 619
	if node.kind == "Sprite" then -- 619
		ImGui.Separator() -- 621
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 621
			node.texture = node.textureBuffer.text -- 623
			state.previewDirty = true -- 624
		end -- 624
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 624
			App:openFileDialog( -- 627
				false, -- 627
				function(path) -- 627
					local asset = addAssetPath(state, path) -- 628
					if asset ~= nil and isTextureAsset(asset) then -- 628
						bindTextureToSprite(state, node, asset) -- 629
					end -- 629
				end -- 627
			) -- 627
		end -- 627
		ImGui.SameLine() -- 632
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 632
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 632
				bindTextureToSprite(state, node, state.selectedAsset) -- 634
			end -- 634
		end -- 634
	elseif node.kind == "Label" then -- 634
		ImGui.Separator() -- 637
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 637
			node.text = node.textBuffer.text -- 638
		end -- 638
	elseif node.kind == "Camera" then -- 638
		ImGui.Separator() -- 640
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 641
	end -- 641
end -- 599
local function drawVerticalSplitter(id, height, onDrag) -- 645
	ImGui.PushStyleColor( -- 646
		"Button", -- 646
		Color(4281612868), -- 646
		function() -- 646
			ImGui.PushStyleColor( -- 647
				"ButtonHovered", -- 647
				Color(4283259240), -- 647
				function() -- 647
					ImGui.PushStyleColor( -- 648
						"ButtonActive", -- 648
						Color(4294954035), -- 648
						function() -- 648
							ImGui.Button( -- 649
								"##" .. id, -- 649
								Vec2(8, height) -- 649
							) -- 649
						end -- 648
					) -- 648
				end -- 647
			) -- 647
		end -- 646
	) -- 646
	if ImGui.IsItemHovered() then -- 646
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 654
	end -- 654
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 654
		local delta = ImGui.GetMouseDragDelta(0) -- 657
		if delta.x ~= 0 then -- 657
			onDrag(delta.x) -- 659
			ImGui.ResetMouseDragDelta(0) -- 660
		end -- 660
	end -- 660
end -- 645
function ____exports.drawEditor(state) -- 665
	local size = App.visualSize -- 666
	local margin = 10 -- 667
	local nativeFooterSafeArea = 60 -- 668
	local windowWidth = math.max(360, size.width - margin * 2) -- 669
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 670
	ImGui.SetNextWindowPos( -- 671
		Vec2(margin, margin), -- 671
		"Always" -- 671
	) -- 671
	ImGui.SetNextWindowSize( -- 672
		Vec2(windowWidth, windowHeight), -- 672
		"Always" -- 672
	) -- 672
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 673
	ImGui.Begin( -- 674
		"Dora Visual Editor", -- 674
		mainWindowFlags, -- 674
		function() -- 674
			drawHeaderPanel(state, saveScene) -- 675
			local avail = ImGui.GetContentRegionAvail() -- 676
			local bottomHeight = math.max( -- 677
				72, -- 677
				math.min( -- 677
					state.bottomHeight, -- 677
					math.floor(avail.y * 0.28) -- 677
				) -- 677
			) -- 677
			if state.mode == "Script" then -- 677
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 679
				ImGui.PushStyleColor( -- 680
					"ChildBg", -- 680
					panelBg, -- 680
					function() -- 680
						ImGui.BeginChild( -- 681
							"ScriptWorkspaceRoot", -- 681
							Vec2(0, scriptHeight), -- 681
							{}, -- 681
							noScrollFlags, -- 681
							function() return drawScriptPanel(state) end -- 681
						) -- 681
					end -- 680
				) -- 680
				ImGui.BeginChild( -- 683
					"ScriptConsoleDock", -- 683
					Vec2(0, bottomHeight), -- 683
					{}, -- 683
					noScrollFlags, -- 683
					function() return drawConsolePanel(state) end -- 683
				) -- 683
				return -- 684
			end -- 684
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 686
			local availableWidth = math.max(320, avail.x) -- 687
			local splitterWidth = 8 -- 688
			local compactLayout = availableWidth < 760 -- 689
			local minLeftWidth = compactLayout and 110 or 170 -- 690
			local minRightWidth = compactLayout and 130 or 220 -- 691
			local minCenterWidth = compactLayout and 80 or 180 -- 692
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 693
			if sideBudget <= minLeftWidth + minRightWidth then -- 693
				state.leftWidth = math.max( -- 695
					1, -- 695
					math.floor(sideBudget * 0.45) -- 695
				) -- 695
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 696
			else -- 696
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 698
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 699
				if state.leftWidth + state.rightWidth > sideBudget then -- 699
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 701
					state.leftWidth = math.max( -- 702
						minLeftWidth, -- 702
						math.floor(sideBudget * ratio) -- 702
					) -- 702
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 703
				end -- 703
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 705
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 706
			end -- 706
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 708
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 709
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 710
			local function clampPanelWidth(value, minValue, maxValue) -- 711
				local safeMax = math.max(1, maxValue) -- 712
				local safeMin = math.min(minValue, safeMax) -- 713
				return math.max( -- 714
					safeMin, -- 714
					math.min(value, safeMax) -- 714
				) -- 714
			end -- 711
			local function resizeSidePanels(deltaX, side) -- 716
				if side == "left" then -- 716
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 718
				else -- 718
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 720
				end -- 720
			end -- 716
			ImGui.BeginChild( -- 724
				"LeftDock", -- 724
				Vec2(state.leftWidth, mainHeight), -- 724
				{}, -- 724
				noScrollFlags, -- 724
				function() -- 724
					ImGui.BeginChild( -- 725
						"SceneDock", -- 725
						Vec2(0, leftTopHeight), -- 725
						{}, -- 725
						noScrollFlags, -- 725
						function() return drawScenePanel(state) end -- 725
					) -- 725
					ImGui.BeginChild( -- 726
						"AssetDock", -- 726
						Vec2(0, leftBottomHeight), -- 726
						{}, -- 726
						noScrollFlags, -- 726
						function() return drawAssetsPanel(state) end -- 726
					) -- 726
				end -- 724
			) -- 724
			ImGui.SameLine(0, 0) -- 728
			drawVerticalSplitter( -- 729
				"LeftSplitter", -- 729
				mainHeight, -- 729
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 729
			) -- 729
			ImGui.SameLine(0, 0) -- 730
			ImGui.PushStyleColor( -- 731
				"ChildBg", -- 731
				transparent, -- 731
				function() -- 731
					ImGui.BeginChild( -- 732
						"CenterDock", -- 732
						Vec2(centerWidth, mainHeight), -- 732
						{}, -- 732
						noScrollFlags, -- 732
						function() -- 732
							if state.mode == "Script" then -- 732
								drawScriptPanel(state) -- 733
							else -- 733
								drawViewport(state) -- 733
							end -- 733
						end -- 732
					) -- 732
				end -- 731
			) -- 731
			ImGui.SameLine(0, 0) -- 736
			drawVerticalSplitter( -- 737
				"RightSplitter", -- 737
				mainHeight, -- 737
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 737
			) -- 737
			ImGui.SameLine(0, 0) -- 738
			ImGui.BeginChild( -- 739
				"RightDock", -- 739
				Vec2(state.rightWidth, mainHeight), -- 739
				{}, -- 739
				noScrollFlags, -- 739
				function() return drawInspector(state) end -- 739
			) -- 739
			ImGui.BeginChild( -- 740
				"BottomConsoleDock", -- 740
				Vec2(0, bottomHeight), -- 740
				{}, -- 740
				noScrollFlags, -- 740
				function() return drawConsolePanel(state) end -- 740
			) -- 740
		end -- 674
	) -- 674
	drawGamePreviewWindow(state) -- 742
end -- 665
function ____exports.drawRuntimeError(message) -- 745
	local size = App.visualSize -- 746
	ImGui.SetNextWindowPos( -- 747
		Vec2(10, 10), -- 747
		"Always" -- 747
	) -- 747
	ImGui.SetNextWindowSize( -- 748
		Vec2( -- 748
			math.max(320, size.width - 20), -- 748
			math.max(220, size.height - 20) -- 748
		), -- 748
		"Always" -- 748
	) -- 748
	ImGui.Begin( -- 749
		"Dora Visual Editor Error", -- 749
		mainWindowFlags, -- 749
		function() -- 749
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 750
			ImGui.Separator() -- 751
			ImGui.TextWrapped(message or "unknown error") -- 752
		end -- 749
	) -- 749
end -- 745
return ____exports -- 745