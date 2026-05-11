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
local deleteNode = ____Model.deleteNode -- 6
local iconFor = ____Model.iconFor -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local importFolderDialog = ____Model.importFolderDialog -- 6
local isFolderAsset = ____Model.isFolderAsset -- 6
local isScriptAsset = ____Model.isScriptAsset -- 6
local isTextureAsset = ____Model.isTextureAsset -- 6
local lowerExt = ____Model.lowerExt -- 6
local pushConsole = ____Model.pushConsole -- 6
local workspacePath = ____Model.workspacePath -- 6
local workspaceRoot = ____Model.workspaceRoot -- 6
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____Player = require("Script.Tools.SceneEditor.Player") -- 8
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 8
local startPlay = ____Player.startPlay -- 8
local stopPlay = ____Player.stopPlay -- 8
local function sceneSaveFile() -- 13
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 14
end -- 13
local function drawNodeRow(state, id, depth) -- 17
	local node = state.nodes[id] -- 18
	if node == nil then -- 18
		return -- 19
	end -- 19
	local indent = string.rep("  ", depth) -- 20
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 21
	if ImGui.Selectable(label, state.selectedId == id) then -- 21
		state.selectedId = id -- 23
		state.previewDirty = true -- 24
	end -- 24
	for ____, childId in ipairs(node.children) do -- 26
		drawNodeRow(state, childId, depth + 1) -- 27
	end -- 27
end -- 17
local function drawAddNodePopup(state) -- 31
	ImGui.BeginPopup( -- 32
		"AddNodePopup", -- 32
		function() -- 32
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 33
			ImGui.Separator() -- 34
			if ImGui.Selectable("○  Node", false) then -- 34
				addChildNode(state, "Node") -- 35
				ImGui.CloseCurrentPopup() -- 35
			end -- 35
			if ImGui.Selectable("▣  Sprite", false) then -- 35
				addChildNode(state, "Sprite") -- 36
				ImGui.CloseCurrentPopup() -- 36
			end -- 36
			if ImGui.Selectable("T  Label", false) then -- 36
				addChildNode(state, "Label") -- 37
				ImGui.CloseCurrentPopup() -- 37
			end -- 37
			if ImGui.Selectable("◉  Camera", false) then -- 37
				addChildNode(state, "Camera") -- 38
				ImGui.CloseCurrentPopup() -- 38
			end -- 38
		end -- 32
	) -- 32
end -- 31
local function writeSceneFile(state) -- 42
	Content:mkdir(workspacePath(".dora")) -- 43
	local data = {version = 1, nodes = {}} -- 44
	for ____, id in ipairs(state.order) do -- 45
		local node = state.nodes[id] -- 46
		if node ~= nil then -- 46
			local ____data_nodes_0 = data.nodes -- 46
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 48
				id = node.id, -- 49
				kind = node.kind, -- 50
				name = node.name, -- 51
				parentId = node.parentId, -- 52
				x = node.x, -- 53
				y = node.y, -- 54
				scaleX = node.scaleX, -- 55
				scaleY = node.scaleY, -- 56
				rotation = node.rotation, -- 57
				visible = node.visible, -- 58
				texture = node.texture, -- 59
				text = node.text, -- 60
				script = node.script -- 61
			} -- 61
		end -- 61
	end -- 61
	local text = json.encode(data) -- 65
	local file = sceneSaveFile() -- 66
	if text ~= nil and Content:save(file, text) then -- 66
		return file -- 67
	end -- 67
	return nil -- 68
end -- 42
local function saveScene(state) -- 71
	local file = writeSceneFile(state) -- 72
	if file ~= nil then -- 72
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 74
	else -- 74
		state.status = zh and "保存失败" or "Save failed" -- 76
	end -- 76
	pushConsole(state, state.status) -- 78
end -- 71
local function attachScriptToNode(state, node, scriptPath, message) -- 81
	node.script = scriptPath -- 82
	node.scriptBuffer.text = scriptPath -- 83
	state.activeScriptNodeId = node.id -- 84
	local sceneFile = writeSceneFile(state) -- 85
	if sceneFile == nil then -- 85
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 87
	else -- 87
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 89
	end -- 89
	pushConsole(state, state.status) -- 91
end -- 81
local function drawHeader(state) -- 94
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 95
	ImGui.SameLine() -- 96
	if ImGui.Button("2D") then -- 96
		state.mode = "2D" -- 97
	end -- 97
	ImGui.SameLine() -- 98
	if ImGui.Button("Script") then -- 98
		state.mode = "Script" -- 99
	end -- 99
	ImGui.SameLine() -- 100
	ImGui.TextDisabled(zh and "Native ImGui / Godot-like" or "Native ImGui / Godot-like") -- 101
	ImGui.Separator() -- 102
	if state.isPlaying then -- 102
		if ImGui.Button("■ Stop") then -- 102
			stopPlay(state) -- 104
		end -- 104
	elseif ImGui.Button("▶ Run") then -- 104
		startPlay(state) -- 106
	end -- 106
	ImGui.SameLine() -- 108
	if ImGui.Button("▣ Save") then -- 108
		saveScene(state) -- 109
	end -- 109
	ImGui.SameLine() -- 110
	if ImGui.Button("◇ Build") then -- 110
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 112
		pushConsole(state, state.status) -- 113
	end -- 113
	ImGui.SameLine() -- 115
	ImGui.TextDisabled("|") -- 116
	ImGui.SameLine() -- 117
	if ImGui.Button("＋ Add") then -- 117
		ImGui.OpenPopup("AddNodePopup") -- 118
	end -- 118
	drawAddNodePopup(state) -- 119
	ImGui.SameLine() -- 120
	if ImGui.Button("Delete") then -- 120
		deleteNode(state, state.selectedId) -- 121
	end -- 121
	ImGui.Separator() -- 122
end -- 94
local function drawScenePanel(state) -- 125
	ImGui.TextColored(themeColor, "Scene Tree") -- 126
	ImGui.SameLine() -- 127
	if ImGui.SmallButton("＋##scene_add") then -- 127
		ImGui.OpenPopup("AddNodePopup") -- 128
	end -- 128
	drawAddNodePopup(state) -- 129
	ImGui.Separator() -- 130
	drawNodeRow(state, "root", 0) -- 131
	ImGui.Separator() -- 132
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 133
end -- 125
local function bindTextureToSprite(state, node, texture) -- 136
	node.texture = texture -- 137
	node.textureBuffer.text = texture -- 138
	state.selectedAsset = texture -- 139
	state.previewDirty = true -- 140
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 141
	pushConsole(state, state.status) -- 142
end -- 136
local function createSpriteFromTexture(state, texture) -- 145
	addChildNode(state, "Sprite") -- 146
	local node = state.nodes[state.selectedId] -- 147
	if node ~= nil and node.kind == "Sprite" then -- 147
		bindTextureToSprite(state, node, texture) -- 149
	end -- 149
end -- 145
local function assetIcon(asset) -- 153
	if isFolderAsset(asset) then -- 153
		return "📁" -- 154
	end -- 154
	if isTextureAsset(asset) then -- 154
		return "🖼" -- 155
	end -- 155
	if isScriptAsset(asset) then -- 155
		return "◇" -- 156
	end -- 156
	local ext = lowerExt(asset) -- 157
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 157
		return "♪" -- 158
	end -- 158
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 158
		return "F" -- 159
	end -- 159
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 159
		return "{}" -- 160
	end -- 160
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 160
		return "◆" -- 161
	end -- 161
	return "·" -- 162
end -- 153
local function startsWith(text, prefix) -- 165
	return string.sub( -- 166
		text, -- 166
		1, -- 166
		string.len(prefix) -- 166
	) == prefix -- 166
end -- 165
local function drawAssetRow(state, asset) -- 169
	if isFolderAsset(asset) then -- 169
		ImGui.TreeNode( -- 171
			(assetIcon(asset) .. "  ") .. asset, -- 171
			function() -- 171
				for ____, child in ipairs(state.assets) do -- 172
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 172
						drawAssetRow(state, child) -- 174
					end -- 174
				end -- 174
			end -- 171
		) -- 171
		return -- 178
	end -- 178
	if ImGui.Selectable( -- 178
		(assetIcon(asset) .. "  ") .. asset, -- 180
		state.selectedAsset == asset -- 180
	) then -- 180
		state.selectedAsset = asset -- 181
		local node = state.nodes[state.selectedId] -- 182
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 182
			bindTextureToSprite(state, node, asset) -- 184
			return -- 185
		elseif node ~= nil and isScriptAsset(asset) then -- 185
			attachScriptToNode(state, node, asset, (zh and "已绑定脚本并保存：" or "Script assigned and saved: ") .. asset) -- 187
			return -- 188
		else -- 188
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 190
		end -- 190
		pushConsole(state, state.status) -- 192
	end -- 192
end -- 169
local function drawAssetsPanel(state) -- 196
	ImGui.TextColored(themeColor, "FileSystem") -- 197
	ImGui.SameLine() -- 198
	if ImGui.SmallButton("＋ File") then -- 198
		importFileDialog(state) -- 199
	end -- 199
	ImGui.SameLine() -- 200
	if ImGui.SmallButton("＋ Folder") then -- 200
		importFolderDialog(state) -- 201
	end -- 201
	ImGui.Separator() -- 202
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 203
	ImGui.Separator() -- 204
	if #state.assets == 0 then -- 204
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 206
		return -- 207
	end -- 207
	for ____, asset in ipairs(state.assets) do -- 209
		if isFolderAsset(asset) then -- 209
			drawAssetRow(state, asset) -- 211
		end -- 211
	end -- 211
	for ____, asset in ipairs(state.assets) do -- 214
		local insideFolder = false -- 215
		for ____, folder in ipairs(state.assets) do -- 216
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 216
				insideFolder = true -- 217
			end -- 217
		end -- 217
		if not insideFolder and not isFolderAsset(asset) then -- 217
			drawAssetRow(state, asset) -- 219
		end -- 219
	end -- 219
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 219
		ImGui.Separator() -- 222
		ImGui.TextColored(themeColor, "Texture Preview") -- 223
		local ok = pcall(function() return ImGui.Image( -- 224
			state.selectedAsset, -- 224
			Vec2(160, 120) -- 224
		) end) -- 224
		if not ok then -- 224
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 225
		end -- 225
		local selectedNode = state.nodes[state.selectedId] -- 226
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 226
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 226
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 228
			end -- 228
			ImGui.SameLine() -- 229
		end -- 229
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 229
			createSpriteFromTexture(state, state.selectedAsset) -- 231
		end -- 231
	end -- 231
end -- 196
local function scriptTemplate(node) -- 235
	local name = node ~= nil and node.name or "Script" -- 236
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 235
local function loadScriptIntoEditor(state, node, scriptPath) -- 247
	if node ~= nil then -- 247
		attachScriptToNode(state, node, scriptPath) -- 249
	else -- 249
		state.activeScriptNodeId = nil -- 251
	end -- 251
	state.scriptPathBuffer.text = scriptPath -- 253
	local scriptFile = workspacePath(scriptPath) -- 254
	if Content:exist(scriptFile) then -- 254
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 256
	elseif Content:exist(scriptPath) then -- 256
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 258
	else -- 258
		state.scriptContentBuffer.text = scriptTemplate(node) -- 260
	end -- 260
	state.mode = "Script" -- 262
end -- 247
local function openScriptForNode(state, node) -- 265
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 266
	loadScriptIntoEditor(state, node, path) -- 267
end -- 265
local function saveScriptFile(state, node) -- 270
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 271
	state.scriptPathBuffer.text = path -- 272
	local scriptFile = workspacePath(path) -- 273
	Content:mkdir(Path:getPath(scriptFile)) -- 274
	local statusAlreadyLogged = false -- 275
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 275
		if node ~= nil then -- 275
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 278
			statusAlreadyLogged = true -- 279
		else -- 279
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 281
		end -- 281
		if state.selectedAsset ~= path then -- 281
			state.selectedAsset = path -- 283
		end -- 283
		local exists = false -- 284
		for ____, asset in ipairs(state.assets) do -- 285
			if asset == path then -- 285
				exists = true -- 285
			end -- 285
		end -- 285
		if not exists then -- 285
			local ____state_assets_1 = state.assets -- 285
			____state_assets_1[#____state_assets_1 + 1] = path -- 286
		end -- 286
	else -- 286
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 288
	end -- 288
	if not statusAlreadyLogged then -- 288
		pushConsole(state, state.status) -- 290
	end -- 290
end -- 270
local function currentScriptPath(state, node) -- 293
	if state.scriptPathBuffer.text ~= "" then -- 293
		return state.scriptPathBuffer.text -- 294
	end -- 294
	if node ~= nil and node.script ~= "" then -- 294
		return node.script -- 295
	end -- 295
	if node ~= nil then -- 295
		return ("Script/" .. node.name) .. ".lua" -- 296
	end -- 296
	return "Script/NewScript.lua" -- 297
end -- 293
local function sendWebIDEMessage(payload) -- 300
	local text = json.encode(payload) -- 301
	if text ~= nil then -- 301
		emit("AppWS", "Send", text) -- 302
	end -- 302
end -- 300
local function openScriptInWebIDE(state, node) -- 305
	local scriptPath = currentScriptPath(state, node) -- 306
	state.scriptPathBuffer.text = scriptPath -- 307
	if state.scriptContentBuffer.text == "" then -- 307
		state.scriptContentBuffer.text = scriptTemplate(node) -- 309
	end -- 309
	saveScriptFile(state, node) -- 311
	local title = Path:getFilename(scriptPath) or scriptPath -- 312
	local root = workspaceRoot() -- 313
	local rootTitle = Path:getFilename(root) or "Workspace" -- 314
	local fullScriptPath = workspacePath(scriptPath) -- 315
	local openWorkspaceMessage = { -- 316
		name = "OpenFile", -- 317
		file = root, -- 318
		title = rootTitle, -- 319
		folder = true, -- 320
		workspaceView = "agent" -- 321
	} -- 321
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 323
	local openScriptMessage = { -- 329
		name = "OpenFile", -- 330
		file = fullScriptPath, -- 331
		title = title, -- 332
		folder = false, -- 333
		position = {lineNumber = 1, column = 1} -- 334
	} -- 334
	local function sendOpenMessages() -- 336
		sendWebIDEMessage(openWorkspaceMessage) -- 337
		sendWebIDEMessage(updateScriptMessage) -- 338
		sendWebIDEMessage(openScriptMessage) -- 339
	end -- 336
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 341
	local editingText = json.encode(editingInfo) -- 358
	if editingText ~= nil then -- 358
		Content:mkdir(workspacePath(".dora")) -- 360
		Content:save( -- 361
			workspacePath(Path(".dora", "open-script.editing.json")), -- 361
			editingText -- 361
		) -- 361
		pcall(function() -- 362
			local Entry = require("Script.Dev.Entry") -- 363
			local config = Entry.getConfig() -- 364
			if config ~= nil then -- 364
				config.editingInfo = editingText -- 365
			end -- 365
		end) -- 362
	end -- 362
	App:openURL("http://127.0.0.1:8866/") -- 368
	sendOpenMessages() -- 369
	thread(function() -- 370
		do -- 370
			local i = 0 -- 371
			while i < 4 do -- 371
				sleep(0.5) -- 372
				sendOpenMessages() -- 373
				i = i + 1 -- 371
			end -- 371
		end -- 371
	end) -- 370
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 376
	pushConsole(state, state.status) -- 377
end -- 305
local function drawScriptAssetList(state, node) -- 380
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 381
	for ____, asset in ipairs(state.assets) do -- 382
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 382
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 382
				state.selectedAsset = asset -- 385
				loadScriptIntoEditor(state, node, asset) -- 386
			end -- 386
		end -- 386
	end -- 386
end -- 380
local function drawScriptPanel(state) -- 392
	local activeId = state.activeScriptNodeId or state.selectedId -- 393
	local node = state.nodes[activeId] -- 394
	ImGui.TextColored(themeColor, "Script Workspace") -- 395
	ImGui.SameLine() -- 396
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 397
	ImGui.Separator() -- 398
	ImGui.BeginChild( -- 399
		"ScriptSidebar", -- 399
		Vec2(220, 0), -- 399
		{}, -- 399
		noScrollFlags, -- 399
		function() -- 399
			drawScriptAssetList(state, node) -- 400
			ImGui.Separator() -- 401
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 401
				local scriptName = node ~= nil and node.name or "NewScript" -- 403
				local path = ("Script/" .. scriptName) .. ".lua" -- 404
				state.scriptPathBuffer.text = path -- 405
				state.scriptContentBuffer.text = scriptTemplate(node) -- 406
				if node ~= nil then -- 406
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 408
				end -- 408
			end -- 408
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 408
				importFileDialog(state) -- 411
			end -- 411
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 411
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 411
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 414
				end -- 414
			end -- 414
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 414
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 418
			end -- 418
		end -- 399
	) -- 399
	ImGui.SameLine() -- 421
	ImGui.PushStyleColor( -- 422
		"ChildBg", -- 422
		scriptPanelBg, -- 422
		function() -- 422
			ImGui.BeginChild( -- 423
				"ScriptEditorPane", -- 423
				Vec2(0, 0), -- 423
				{}, -- 423
				noScrollFlags, -- 423
				function() -- 423
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 424
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 425
					ImGui.SameLine() -- 426
					if ImGui.Button(zh and "保存" or "Save") then -- 426
						saveScriptFile(state, node) -- 427
					end -- 427
					ImGui.SameLine() -- 428
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 428
						openScriptInWebIDE(state, node) -- 429
					end -- 429
					if node ~= nil then -- 429
						ImGui.SameLine() -- 431
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 431
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 433
						end -- 433
					end -- 433
					ImGui.Separator() -- 436
					ImGui.InputTextMultiline( -- 437
						"##ScriptEditor", -- 437
						state.scriptContentBuffer, -- 437
						Vec2(0, -4), -- 437
						{} -- 437
					) -- 437
				end -- 423
			) -- 423
		end -- 422
	) -- 422
end -- 392
local function viewportScale(state) -- 442
	return math.max(0.25, state.zoom / 100) -- 443
end -- 442
local function clampZoom(value) -- 446
	return math.max( -- 447
		25, -- 447
		math.min(400, value) -- 447
	) -- 447
end -- 446
local function zoomViewportAt(state, delta, screenX, screenY) -- 450
	if delta == 0 then -- 450
		return -- 451
	end -- 451
	local before = state.zoom -- 452
	local beforeScale = viewportScale(state) -- 453
	local p = state.preview -- 454
	local centerX = p.x + p.width / 2 -- 455
	local centerY = p.y + p.height / 2 -- 456
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 457
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 458
	state.zoom = clampZoom(state.zoom + delta) -- 459
	if state.zoom ~= before then -- 459
		local afterScale = viewportScale(state) -- 461
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 462
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 463
		state.previewDirty = true -- 464
	end -- 464
end -- 450
local function zoomViewportFromCenter(state, delta) -- 468
	local p = state.preview -- 469
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 470
end -- 468
local function screenToScene(state, screenX, screenY) -- 473
	local p = state.preview -- 474
	local scale = viewportScale(state) -- 475
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 476
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 477
	return {localX / scale, localY / scale} -- 478
end -- 473
local function pickNodeAt(state, screenX, screenY) -- 481
	local sceneX, sceneY = table.unpack( -- 482
		screenToScene(state, screenX, screenY), -- 482
		1, -- 482
		2 -- 482
	) -- 482
	do -- 482
		local i = #state.order -- 483
		while i >= 1 do -- 483
			local id = state.order[i] -- 484
			local node = state.nodes[id] -- 485
			if node ~= nil and id ~= "root" and node.visible then -- 485
				local dx = sceneX - node.x -- 487
				local dy = sceneY - node.y -- 488
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 489
				if dx * dx + dy * dy <= radius * radius then -- 489
					return id -- 490
				end -- 490
			end -- 490
			i = i - 1 -- 483
		end -- 483
	end -- 483
	return nil -- 493
end -- 481
local function handleViewportMouse(state, hovered) -- 496
	if not hovered then -- 496
		return -- 497
	end -- 497
	local spacePressed = Keyboard:isKeyPressed("Space") -- 498
	local wheel = Mouse.wheel -- 499
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 500
	if wheelDelta ~= 0 then -- 500
		local mouse = ImGui.GetMousePos() -- 502
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 503
	end -- 503
	if ImGui.IsMouseClicked(2) then -- 503
		state.draggingNodeId = nil -- 506
		state.draggingViewport = true -- 507
		ImGui.ResetMouseDragDelta(2) -- 508
	end -- 508
	if ImGui.IsMouseClicked(0) then -- 508
		if spacePressed then -- 508
			state.draggingNodeId = nil -- 512
			state.draggingViewport = true -- 513
		else -- 513
			local mouse = ImGui.GetMousePos() -- 515
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 516
			if picked ~= nil then -- 516
				state.selectedId = picked -- 518
				state.previewDirty = true -- 519
				state.draggingNodeId = picked -- 520
				state.draggingViewport = false -- 521
			else -- 521
				state.draggingNodeId = nil -- 523
				state.draggingViewport = true -- 524
			end -- 524
		end -- 524
		ImGui.ResetMouseDragDelta(0) -- 527
	end -- 527
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 527
		state.draggingNodeId = nil -- 530
		state.draggingViewport = false -- 531
	end -- 531
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 531
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 534
		local delta = ImGui.GetMouseDragDelta(panButton) -- 535
		if delta.x ~= 0 or delta.y ~= 0 then -- 535
			if state.draggingNodeId ~= nil and panButton == 0 then -- 535
				local node = state.nodes[state.draggingNodeId] -- 538
				if node ~= nil then -- 538
					local scale = viewportScale(state) -- 540
					node.x = node.x + delta.x / scale -- 541
					node.y = node.y - delta.y / scale -- 542
					if state.snapEnabled then -- 542
						local step = 16 -- 544
						node.x = math.floor(node.x / step + 0.5) * step -- 545
						node.y = math.floor(node.y / step + 0.5) * step -- 546
					end -- 546
				end -- 546
			elseif state.draggingViewport then -- 546
				state.viewportPanX = state.viewportPanX + delta.x -- 550
				state.viewportPanY = state.viewportPanY - delta.y -- 551
			end -- 551
			ImGui.ResetMouseDragDelta(panButton) -- 553
		end -- 553
	end -- 553
end -- 496
local function drawViewportToolButton(state, tool, label) -- 558
	local active = state.viewportTool == tool -- 559
	if active then -- 559
		ImGui.PushStyleColor( -- 561
			"Button", -- 561
			Color(4281349698), -- 561
			function() -- 561
				ImGui.PushStyleColor( -- 562
					"Text", -- 562
					themeColor, -- 562
					function() -- 562
						if ImGui.Button(label) then -- 562
							state.viewportTool = tool -- 563
						end -- 563
					end -- 562
				) -- 562
			end -- 561
		) -- 561
	elseif ImGui.Button(label) then -- 561
		state.viewportTool = tool -- 567
	end -- 567
end -- 558
local function drawViewport(state) -- 571
	ImGui.TextColored(themeColor, "2D") -- 572
	ImGui.SameLine() -- 573
	drawViewportToolButton(state, "Select", "Select") -- 574
	ImGui.SameLine() -- 575
	drawViewportToolButton(state, "Move", "Move") -- 576
	ImGui.SameLine() -- 577
	drawViewportToolButton(state, "Rotate", "Rotate") -- 578
	ImGui.SameLine() -- 579
	drawViewportToolButton(state, "Scale", "Scale") -- 580
	ImGui.SameLine() -- 581
	ImGui.TextDisabled("|") -- 582
	ImGui.SameLine() -- 583
	local snapChanged, snap = ImGui.Checkbox("Snap", state.snapEnabled) -- 584
	if snapChanged then -- 584
		state.snapEnabled = snap -- 585
	end -- 585
	ImGui.SameLine() -- 586
	local gridChanged, grid = ImGui.Checkbox("Grid", state.showGrid) -- 587
	if gridChanged then -- 587
		state.showGrid = grid -- 588
		state.previewDirty = true -- 588
	end -- 588
	ImGui.SameLine() -- 589
	if ImGui.Button("Center") then -- 589
		state.viewportPanX = 0 -- 591
		state.viewportPanY = 0 -- 592
		state.zoom = 100 -- 593
		state.previewDirty = true -- 594
	end -- 594
	ImGui.SameLine() -- 596
	ImGui.TextDisabled("Main.scene") -- 597
	ImGui.Separator() -- 598
	local cursor = ImGui.GetCursorScreenPos() -- 599
	local avail = ImGui.GetContentRegionAvail() -- 600
	local viewportWidth = math.max(360, avail.x - 8) -- 601
	local viewportHeight = math.max(300, avail.y - 38) -- 602
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 602
		state.previewDirty = true -- 604
	end -- 604
	state.preview.x = cursor.x -- 606
	state.preview.y = cursor.y -- 607
	state.preview.width = viewportWidth -- 608
	state.preview.height = viewportHeight -- 609
	updatePreviewRuntime(state) -- 610
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 611
	local hovered = ImGui.IsItemHovered() -- 612
	handleViewportMouse(state, hovered) -- 613
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 614
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 614
		zoomViewportFromCenter(state, -10) -- 615
	end -- 615
	ImGui.SameLine() -- 616
	ImGui.PushStyleColor( -- 617
		"Text", -- 617
		themeColor, -- 617
		function() -- 617
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 617
				state.zoom = 100 -- 619
				state.viewportPanX = 0 -- 620
				state.viewportPanY = 0 -- 621
				state.previewDirty = true -- 622
			end -- 622
		end -- 617
	) -- 617
	ImGui.SameLine() -- 625
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 625
		zoomViewportFromCenter(state, 10) -- 626
	end -- 626
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 627
	ImGui.Separator() -- 628
	ImGui.TextColored(okColor, "Dora 2D Viewport") -- 629
	ImGui.SameLine() -- 630
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 631
end -- 571
local function drawInspector(state) -- 634
	ImGui.TextColored(themeColor, "Inspector") -- 635
	ImGui.Separator() -- 636
	local node = state.nodes[state.selectedId] -- 637
	if node == nil then -- 637
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 639
		return -- 640
	end -- 640
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 642
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 642
		node.name = node.nameBuffer.text -- 643
	end -- 643
	local changed, x, y = ImGui.DragFloat2( -- 644
		"Position", -- 644
		node.x, -- 644
		node.y, -- 644
		1, -- 644
		-10000, -- 644
		10000, -- 644
		"%.1f" -- 644
	) -- 644
	if changed then -- 644
		node.x = x -- 645
		node.y = y -- 645
	end -- 645
	changed, x, y = ImGui.DragFloat2( -- 646
		"Scale", -- 646
		node.scaleX, -- 646
		node.scaleY, -- 646
		0.01, -- 646
		-100, -- 646
		100, -- 646
		"%.2f" -- 646
	) -- 646
	if changed then -- 646
		node.scaleX = x -- 647
		node.scaleY = y -- 647
	end -- 647
	local angleChanged, angle = ImGui.DragFloat( -- 648
		"Rotation", -- 648
		node.rotation, -- 648
		1, -- 648
		-360, -- 648
		360, -- 648
		"%.1f" -- 648
	) -- 648
	if angleChanged then -- 648
		node.rotation = angle -- 649
	end -- 649
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 650
	if visibleChanged then -- 650
		node.visible = visible -- 651
	end -- 651
	ImGui.Separator() -- 652
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 652
		node.script = node.scriptBuffer.text -- 653
	end -- 653
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 653
		openScriptForNode(state, node) -- 654
	end -- 654
	if node.kind == "Sprite" then -- 654
		ImGui.Separator() -- 656
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 656
			node.texture = node.textureBuffer.text -- 658
			state.previewDirty = true -- 659
		end -- 659
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 659
			App:openFileDialog( -- 662
				false, -- 662
				function(path) -- 662
					local asset = addAssetPath(state, path) -- 663
					if asset ~= nil and isTextureAsset(asset) then -- 663
						bindTextureToSprite(state, node, asset) -- 664
					end -- 664
				end -- 662
			) -- 662
		end -- 662
		ImGui.SameLine() -- 667
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 667
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 667
				bindTextureToSprite(state, node, state.selectedAsset) -- 669
			end -- 669
		end -- 669
	elseif node.kind == "Label" then -- 669
		ImGui.Separator() -- 672
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 672
			node.text = node.textBuffer.text -- 673
		end -- 673
	elseif node.kind == "Camera" then -- 673
		ImGui.Separator() -- 675
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 676
	end -- 676
end -- 634
local function drawConsole(state) -- 680
	ImGui.TextColored(themeColor, "Console") -- 681
	ImGui.SameLine() -- 682
	ImGui.TextColored(okColor, state.status) -- 683
	ImGui.Separator() -- 684
	for ____, line in ipairs(state.console) do -- 685
		ImGui.TextDisabled(line) -- 685
	end -- 685
end -- 680
local function drawVerticalSplitter(id, height, onDrag) -- 688
	ImGui.PushStyleColor( -- 689
		"Button", -- 689
		Color(4281612868), -- 689
		function() -- 689
			ImGui.PushStyleColor( -- 690
				"ButtonHovered", -- 690
				Color(4283259240), -- 690
				function() -- 690
					ImGui.PushStyleColor( -- 691
						"ButtonActive", -- 691
						Color(4294954035), -- 691
						function() -- 691
							ImGui.Button( -- 692
								"##" .. id, -- 692
								Vec2(12, height) -- 692
							) -- 692
						end -- 691
					) -- 691
				end -- 690
			) -- 690
		end -- 689
	) -- 689
	if ImGui.IsItemHovered() then -- 689
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 697
	end -- 697
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 697
		local delta = ImGui.GetMouseDragDelta(0) -- 700
		if delta.x ~= 0 then -- 700
			onDrag(delta.x) -- 702
			ImGui.ResetMouseDragDelta(0) -- 703
		end -- 703
	end -- 703
end -- 688
function ____exports.drawEditor(state) -- 708
	local size = App.visualSize -- 709
	local margin = 10 -- 710
	local nativeFooterSafeArea = 60 -- 711
	local windowWidth = math.max(360, size.width - margin * 2) -- 712
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 713
	ImGui.SetNextWindowPos( -- 714
		Vec2(margin, margin), -- 714
		"Always" -- 714
	) -- 714
	ImGui.SetNextWindowSize( -- 715
		Vec2(windowWidth, windowHeight), -- 715
		"Always" -- 715
	) -- 715
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 716
	ImGui.Begin( -- 717
		"Dora Visual Editor", -- 717
		mainWindowFlags, -- 717
		function() -- 717
			drawHeader(state) -- 718
			local avail = ImGui.GetContentRegionAvail() -- 719
			local bottomHeight = math.max( -- 720
				72, -- 720
				math.min( -- 720
					state.bottomHeight, -- 720
					math.floor(avail.y * 0.28) -- 720
				) -- 720
			) -- 720
			if state.mode == "Script" then -- 720
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 722
				ImGui.PushStyleColor( -- 723
					"ChildBg", -- 723
					panelBg, -- 723
					function() -- 723
						ImGui.BeginChild( -- 724
							"ScriptWorkspaceRoot", -- 724
							Vec2(0, scriptHeight), -- 724
							{}, -- 724
							noScrollFlags, -- 724
							function() return drawScriptPanel(state) end -- 724
						) -- 724
					end -- 723
				) -- 723
				ImGui.BeginChild( -- 726
					"ScriptConsoleDock", -- 726
					Vec2(0, bottomHeight), -- 726
					{}, -- 726
					noScrollFlags, -- 726
					function() return drawConsole(state) end -- 726
				) -- 726
				return -- 727
			end -- 727
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 729
			local availableWidth = math.max(520, avail.x - 4) -- 730
			state.leftWidth = math.max( -- 731
				190, -- 731
				math.min(state.leftWidth, availableWidth - state.rightWidth - 320) -- 731
			) -- 731
			state.rightWidth = math.max( -- 732
				250, -- 732
				math.min(state.rightWidth, availableWidth - state.leftWidth - 320) -- 732
			) -- 732
			local centerWidth = math.max(220, availableWidth - state.leftWidth - state.rightWidth - 24) -- 733
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 734
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 735
			ImGui.BeginChild( -- 737
				"LeftDock", -- 737
				Vec2(state.leftWidth, mainHeight), -- 737
				{}, -- 737
				noScrollFlags, -- 737
				function() -- 737
					ImGui.BeginChild( -- 738
						"SceneDock", -- 738
						Vec2(0, leftTopHeight), -- 738
						{}, -- 738
						noScrollFlags, -- 738
						function() return drawScenePanel(state) end -- 738
					) -- 738
					ImGui.BeginChild( -- 739
						"AssetDock", -- 739
						Vec2(0, leftBottomHeight), -- 739
						{}, -- 739
						noScrollFlags, -- 739
						function() return drawAssetsPanel(state) end -- 739
					) -- 739
				end -- 737
			) -- 737
			ImGui.SameLine() -- 741
			drawVerticalSplitter( -- 742
				"LeftSplitter", -- 742
				mainHeight, -- 742
				function(deltaX) -- 742
					state.leftWidth = math.max( -- 743
						190, -- 743
						math.min(state.leftWidth + deltaX, availableWidth - state.rightWidth - 320) -- 743
					) -- 743
				end -- 742
			) -- 742
			ImGui.SameLine() -- 745
			ImGui.PushStyleColor( -- 746
				"ChildBg", -- 746
				transparent, -- 746
				function() -- 746
					ImGui.BeginChild( -- 747
						"CenterDock", -- 747
						Vec2(centerWidth, mainHeight), -- 747
						{}, -- 747
						noScrollFlags, -- 747
						function() -- 747
							if state.mode == "Script" then -- 747
								drawScriptPanel(state) -- 748
							else -- 748
								drawViewport(state) -- 748
							end -- 748
						end -- 747
					) -- 747
				end -- 746
			) -- 746
			ImGui.SameLine() -- 751
			drawVerticalSplitter( -- 752
				"RightSplitter", -- 752
				mainHeight, -- 752
				function(deltaX) -- 752
					state.rightWidth = math.max( -- 753
						250, -- 753
						math.min(state.rightWidth - deltaX, availableWidth - state.leftWidth - 320) -- 753
					) -- 753
				end -- 752
			) -- 752
			ImGui.SameLine() -- 755
			ImGui.BeginChild( -- 756
				"RightDock", -- 756
				Vec2(state.rightWidth, mainHeight), -- 756
				{}, -- 756
				noScrollFlags, -- 756
				function() return drawInspector(state) end -- 756
			) -- 756
			ImGui.BeginChild( -- 757
				"BottomConsoleDock", -- 757
				Vec2(0, bottomHeight), -- 757
				{}, -- 757
				noScrollFlags, -- 757
				function() return drawConsole(state) end -- 757
			) -- 757
		end -- 717
	) -- 717
	drawGamePreviewWindow(state) -- 759
end -- 708
function ____exports.drawRuntimeError(message) -- 762
	local size = App.visualSize -- 763
	ImGui.SetNextWindowPos( -- 764
		Vec2(10, 10), -- 764
		"Always" -- 764
	) -- 764
	ImGui.SetNextWindowSize( -- 765
		Vec2( -- 765
			math.max(320, size.width - 20), -- 765
			math.max(220, size.height - 20) -- 765
		), -- 765
		"Always" -- 765
	) -- 765
	ImGui.Begin( -- 766
		"Dora Visual Editor Error", -- 766
		mainWindowFlags, -- 766
		function() -- 766
			ImGui.TextColored(warnColor, "SceneImGuiEditor runtime error") -- 767
			ImGui.Separator() -- 768
			ImGui.TextWrapped(message or "unknown error") -- 769
		end -- 766
	) -- 766
end -- 762
return ____exports -- 762