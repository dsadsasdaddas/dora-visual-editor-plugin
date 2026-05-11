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
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____Player = require("Script.Tools.SceneEditor.Player") -- 8
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 8
local startPlay = ____Player.startPlay -- 8
local stopPlay = ____Player.stopPlay -- 8
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 13
local function workspacePath(path) -- 14
	return SceneModel.workspacePath(path) -- 14
end -- 14
local function workspaceRoot() -- 15
	return SceneModel.workspaceRoot() -- 15
end -- 15
local function sceneSaveFile() -- 17
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 18
end -- 17
local function drawNodeRow(state, id, depth) -- 21
	local node = state.nodes[id] -- 22
	if node == nil then -- 22
		return -- 23
	end -- 23
	local indent = string.rep("  ", depth) -- 24
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 25
	if ImGui.Selectable(label, state.selectedId == id) then -- 25
		state.selectedId = id -- 27
		state.previewDirty = true -- 28
	end -- 28
	for ____, childId in ipairs(node.children) do -- 30
		drawNodeRow(state, childId, depth + 1) -- 31
	end -- 31
end -- 21
local function drawAddNodePopup(state) -- 35
	ImGui.BeginPopup( -- 36
		"AddNodePopup", -- 36
		function() -- 36
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 37
			ImGui.Separator() -- 38
			if ImGui.Selectable("○  Node", false) then -- 38
				addChildNode(state, "Node") -- 39
				ImGui.CloseCurrentPopup() -- 39
			end -- 39
			if ImGui.Selectable("▣  Sprite", false) then -- 39
				addChildNode(state, "Sprite") -- 40
				ImGui.CloseCurrentPopup() -- 40
			end -- 40
			if ImGui.Selectable("T  Label", false) then -- 40
				addChildNode(state, "Label") -- 41
				ImGui.CloseCurrentPopup() -- 41
			end -- 41
			if ImGui.Selectable("◉  Camera", false) then -- 41
				addChildNode(state, "Camera") -- 42
				ImGui.CloseCurrentPopup() -- 42
			end -- 42
		end -- 36
	) -- 36
end -- 35
local function writeSceneFile(state) -- 46
	Content:mkdir(workspacePath(".dora")) -- 47
	local data = {version = 1, nodes = {}} -- 48
	for ____, id in ipairs(state.order) do -- 49
		local node = state.nodes[id] -- 50
		if node ~= nil then -- 50
			local ____data_nodes_0 = data.nodes -- 50
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 52
				id = node.id, -- 53
				kind = node.kind, -- 54
				name = node.name, -- 55
				parentId = node.parentId, -- 56
				x = node.x, -- 57
				y = node.y, -- 58
				scaleX = node.scaleX, -- 59
				scaleY = node.scaleY, -- 60
				rotation = node.rotation, -- 61
				visible = node.visible, -- 62
				texture = node.texture, -- 63
				text = node.text, -- 64
				script = node.script -- 65
			} -- 65
		end -- 65
	end -- 65
	local text = json.encode(data) -- 69
	local file = sceneSaveFile() -- 70
	if text ~= nil and Content:save(file, text) then -- 70
		return file -- 71
	end -- 71
	return nil -- 72
end -- 46
local function saveScene(state) -- 75
	local file = writeSceneFile(state) -- 76
	if file ~= nil then -- 76
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 78
	else -- 78
		state.status = zh and "保存失败" or "Save failed" -- 80
	end -- 80
	pushConsole(state, state.status) -- 82
end -- 75
local function attachScriptToNode(state, node, scriptPath, message) -- 85
	node.script = scriptPath -- 86
	node.scriptBuffer.text = scriptPath -- 87
	state.activeScriptNodeId = node.id -- 88
	local sceneFile = writeSceneFile(state) -- 89
	if sceneFile == nil then -- 89
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 91
	else -- 91
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 93
	end -- 93
	pushConsole(state, state.status) -- 95
end -- 85
local function drawHeader(state) -- 98
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 99
	ImGui.SameLine() -- 100
	if ImGui.Button(zh and "场景" or "Scene") then -- 100
		state.mode = "2D" -- 101
	end -- 101
	ImGui.SameLine() -- 102
	if ImGui.Button(zh and "脚本" or "Scripts") then -- 102
		state.mode = "Script" -- 103
	end -- 103
	ImGui.SameLine() -- 104
	ImGui.TextDisabled(zh and "Dora 原生 2D 场景编辑器" or "Dora Native 2D Scene Editor") -- 105
	ImGui.Separator() -- 106
	if state.isPlaying then -- 106
		if ImGui.Button(zh and "■ 停止" or "■ Stop") then -- 106
			stopPlay(state) -- 108
		end -- 108
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then -- 108
		startPlay(state) -- 110
	end -- 110
	ImGui.SameLine() -- 112
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 112
		saveScene(state) -- 113
	end -- 113
	ImGui.SameLine() -- 114
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 114
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 116
		pushConsole(state, state.status) -- 117
	end -- 117
	ImGui.SameLine() -- 119
	ImGui.TextDisabled("|") -- 120
	ImGui.SameLine() -- 121
	if ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 121
		ImGui.OpenPopup("AddNodePopup") -- 122
	end -- 122
	drawAddNodePopup(state) -- 123
	ImGui.SameLine() -- 124
	if ImGui.Button(zh and "删除" or "Delete") then -- 124
		deleteNode(state, state.selectedId) -- 125
	end -- 125
	ImGui.Separator() -- 126
end -- 98
local function drawScenePanel(state) -- 129
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 130
	ImGui.SameLine() -- 131
	if ImGui.SmallButton("＋##scene_add") then -- 131
		ImGui.OpenPopup("AddNodePopup") -- 132
	end -- 132
	drawAddNodePopup(state) -- 133
	ImGui.Separator() -- 134
	drawNodeRow(state, "root", 0) -- 135
	ImGui.Separator() -- 136
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 137
end -- 129
local function bindTextureToSprite(state, node, texture) -- 140
	node.texture = texture -- 141
	node.textureBuffer.text = texture -- 142
	state.selectedAsset = texture -- 143
	state.previewDirty = true -- 144
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 145
	pushConsole(state, state.status) -- 146
end -- 140
local function createSpriteFromTexture(state, texture) -- 149
	addChildNode(state, "Sprite") -- 150
	local node = state.nodes[state.selectedId] -- 151
	if node ~= nil and node.kind == "Sprite" then -- 151
		bindTextureToSprite(state, node, texture) -- 153
	end -- 153
end -- 149
local function assetIcon(asset) -- 157
	if isFolderAsset(asset) then -- 157
		return "📁" -- 158
	end -- 158
	if isTextureAsset(asset) then -- 158
		return "🖼" -- 159
	end -- 159
	if isScriptAsset(asset) then -- 159
		return "◇" -- 160
	end -- 160
	local ext = lowerExt(asset) -- 161
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 161
		return "♪" -- 162
	end -- 162
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 162
		return "F" -- 163
	end -- 163
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 163
		return "{}" -- 164
	end -- 164
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 164
		return "◆" -- 165
	end -- 165
	return "·" -- 166
end -- 157
local function startsWith(text, prefix) -- 169
	return string.sub( -- 170
		text, -- 170
		1, -- 170
		string.len(prefix) -- 170
	) == prefix -- 170
end -- 169
local function drawAssetRow(state, asset) -- 173
	if isFolderAsset(asset) then -- 173
		ImGui.TreeNode( -- 175
			(assetIcon(asset) .. "  ") .. asset, -- 175
			function() -- 175
				for ____, child in ipairs(state.assets) do -- 176
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 176
						drawAssetRow(state, child) -- 178
					end -- 178
				end -- 178
			end -- 175
		) -- 175
		return -- 182
	end -- 182
	if ImGui.Selectable( -- 182
		(assetIcon(asset) .. "  ") .. asset, -- 184
		state.selectedAsset == asset -- 184
	) then -- 184
		state.selectedAsset = asset -- 185
		local node = state.nodes[state.selectedId] -- 186
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 186
			bindTextureToSprite(state, node, asset) -- 188
			return -- 189
		elseif node ~= nil and isScriptAsset(asset) then -- 189
			attachScriptToNode(state, node, asset, (zh and "已绑定脚本并保存：" or "Script assigned and saved: ") .. asset) -- 191
			return -- 192
		else -- 192
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 194
		end -- 194
		pushConsole(state, state.status) -- 196
	end -- 196
end -- 173
local function drawAssetsPanel(state) -- 200
	ImGui.TextColored(themeColor, zh and "资源" or "Assets") -- 201
	ImGui.SameLine() -- 202
	if ImGui.SmallButton(zh and "＋ 文件" or "＋ File") then -- 202
		importFileDialog(state) -- 203
	end -- 203
	ImGui.SameLine() -- 204
	if ImGui.SmallButton(zh and "＋ 文件夹" or "＋ Folder") then -- 204
		importFolderDialog(state) -- 205
	end -- 205
	ImGui.Separator() -- 206
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 207
	ImGui.Separator() -- 208
	if #state.assets == 0 then -- 208
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 210
		return -- 211
	end -- 211
	for ____, asset in ipairs(state.assets) do -- 213
		if isFolderAsset(asset) then -- 213
			drawAssetRow(state, asset) -- 215
		end -- 215
	end -- 215
	for ____, asset in ipairs(state.assets) do -- 218
		local insideFolder = false -- 219
		for ____, folder in ipairs(state.assets) do -- 220
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 220
				insideFolder = true -- 221
			end -- 221
		end -- 221
		if not insideFolder and not isFolderAsset(asset) then -- 221
			drawAssetRow(state, asset) -- 223
		end -- 223
	end -- 223
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 223
		ImGui.Separator() -- 226
		ImGui.TextColored(themeColor, zh and "贴图预览" or "Texture Preview") -- 227
		local ok = pcall(function() return ImGui.Image( -- 228
			state.selectedAsset, -- 228
			Vec2(160, 120) -- 228
		) end) -- 228
		if not ok then -- 228
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 229
		end -- 229
		local selectedNode = state.nodes[state.selectedId] -- 230
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 230
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 230
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 232
			end -- 232
			ImGui.SameLine() -- 233
		end -- 233
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 233
			createSpriteFromTexture(state, state.selectedAsset) -- 235
		end -- 235
	end -- 235
end -- 200
local function scriptTemplate(node) -- 239
	local name = node ~= nil and node.name or "Script" -- 240
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 239
local function loadScriptIntoEditor(state, node, scriptPath) -- 251
	if node ~= nil then -- 251
		attachScriptToNode(state, node, scriptPath) -- 253
	else -- 253
		state.activeScriptNodeId = nil -- 255
	end -- 255
	state.scriptPathBuffer.text = scriptPath -- 257
	local scriptFile = workspacePath(scriptPath) -- 258
	if Content:exist(scriptFile) then -- 258
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 260
	elseif Content:exist(scriptPath) then -- 260
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 262
	else -- 262
		state.scriptContentBuffer.text = scriptTemplate(node) -- 264
	end -- 264
	state.mode = "Script" -- 266
end -- 251
local function openScriptForNode(state, node) -- 269
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 270
	loadScriptIntoEditor(state, node, path) -- 271
end -- 269
local function saveScriptFile(state, node) -- 274
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 275
	state.scriptPathBuffer.text = path -- 276
	local scriptFile = workspacePath(path) -- 277
	Content:mkdir(Path:getPath(scriptFile)) -- 278
	local statusAlreadyLogged = false -- 279
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 279
		if node ~= nil then -- 279
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 282
			statusAlreadyLogged = true -- 283
		else -- 283
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 285
		end -- 285
		if state.selectedAsset ~= path then -- 285
			state.selectedAsset = path -- 287
		end -- 287
		local exists = false -- 288
		for ____, asset in ipairs(state.assets) do -- 289
			if asset == path then -- 289
				exists = true -- 289
			end -- 289
		end -- 289
		if not exists then -- 289
			local ____state_assets_1 = state.assets -- 289
			____state_assets_1[#____state_assets_1 + 1] = path -- 290
		end -- 290
	else -- 290
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 292
	end -- 292
	if not statusAlreadyLogged then -- 292
		pushConsole(state, state.status) -- 294
	end -- 294
end -- 274
local function currentScriptPath(state, node) -- 297
	if state.scriptPathBuffer.text ~= "" then -- 297
		return state.scriptPathBuffer.text -- 298
	end -- 298
	if node ~= nil and node.script ~= "" then -- 298
		return node.script -- 299
	end -- 299
	if node ~= nil then -- 299
		return ("Script/" .. node.name) .. ".lua" -- 300
	end -- 300
	return "Script/NewScript.lua" -- 301
end -- 297
local function sendWebIDEMessage(payload) -- 304
	local text = json.encode(payload) -- 305
	if text ~= nil then -- 305
		emit("AppWS", "Send", text) -- 306
	end -- 306
end -- 304
local function openScriptInWebIDE(state, node) -- 309
	local scriptPath = currentScriptPath(state, node) -- 310
	state.scriptPathBuffer.text = scriptPath -- 311
	if state.scriptContentBuffer.text == "" then -- 311
		state.scriptContentBuffer.text = scriptTemplate(node) -- 313
	end -- 313
	saveScriptFile(state, node) -- 315
	local title = Path:getFilename(scriptPath) or scriptPath -- 316
	local root = workspaceRoot() -- 317
	local rootTitle = Path:getFilename(root) or "Workspace" -- 318
	local fullScriptPath = workspacePath(scriptPath) -- 319
	local openWorkspaceMessage = { -- 320
		name = "OpenFile", -- 321
		file = root, -- 322
		title = rootTitle, -- 323
		folder = true, -- 324
		workspaceView = "agent" -- 325
	} -- 325
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 327
	local openScriptMessage = { -- 333
		name = "OpenFile", -- 334
		file = fullScriptPath, -- 335
		title = title, -- 336
		folder = false, -- 337
		position = {lineNumber = 1, column = 1} -- 338
	} -- 338
	local function sendOpenMessages() -- 340
		sendWebIDEMessage(openWorkspaceMessage) -- 341
		sendWebIDEMessage(updateScriptMessage) -- 342
		sendWebIDEMessage(openScriptMessage) -- 343
	end -- 340
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 345
	local editingText = json.encode(editingInfo) -- 362
	if editingText ~= nil then -- 362
		Content:mkdir(workspacePath(".dora")) -- 364
		Content:save( -- 365
			workspacePath(Path(".dora", "open-script.editing.json")), -- 365
			editingText -- 365
		) -- 365
		pcall(function() -- 366
			local Entry = require("Script.Dev.Entry") -- 367
			local config = Entry.getConfig() -- 368
			if config ~= nil then -- 368
				config.editingInfo = editingText -- 369
			end -- 369
		end) -- 366
	end -- 366
	App:openURL("http://127.0.0.1:8866/") -- 372
	sendOpenMessages() -- 373
	thread(function() -- 374
		do -- 374
			local i = 0 -- 375
			while i < 4 do -- 375
				sleep(0.5) -- 376
				sendOpenMessages() -- 377
				i = i + 1 -- 375
			end -- 375
		end -- 375
	end) -- 374
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 380
	pushConsole(state, state.status) -- 381
end -- 309
local function drawScriptAssetList(state, node) -- 384
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 385
	for ____, asset in ipairs(state.assets) do -- 386
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 386
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 386
				state.selectedAsset = asset -- 389
				loadScriptIntoEditor(state, node, asset) -- 390
			end -- 390
		end -- 390
	end -- 390
end -- 384
local function drawScriptPanel(state) -- 396
	local activeId = state.activeScriptNodeId or state.selectedId -- 397
	local node = state.nodes[activeId] -- 398
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 399
	ImGui.SameLine() -- 400
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 401
	ImGui.Separator() -- 402
	ImGui.BeginChild( -- 403
		"ScriptSidebar", -- 403
		Vec2(220, 0), -- 403
		{}, -- 403
		noScrollFlags, -- 403
		function() -- 403
			drawScriptAssetList(state, node) -- 404
			ImGui.Separator() -- 405
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 405
				local scriptName = node ~= nil and node.name or "NewScript" -- 407
				local path = ("Script/" .. scriptName) .. ".lua" -- 408
				state.scriptPathBuffer.text = path -- 409
				state.scriptContentBuffer.text = scriptTemplate(node) -- 410
				if node ~= nil then -- 410
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 412
				end -- 412
			end -- 412
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 412
				importFileDialog(state) -- 415
			end -- 415
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 415
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 415
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 418
				end -- 418
			end -- 418
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 418
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 422
			end -- 422
		end -- 403
	) -- 403
	ImGui.SameLine() -- 425
	ImGui.PushStyleColor( -- 426
		"ChildBg", -- 426
		scriptPanelBg, -- 426
		function() -- 426
			ImGui.BeginChild( -- 427
				"ScriptEditorPane", -- 427
				Vec2(0, 0), -- 427
				{}, -- 427
				noScrollFlags, -- 427
				function() -- 427
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 428
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 429
					ImGui.SameLine() -- 430
					if ImGui.Button(zh and "保存" or "Save") then -- 430
						saveScriptFile(state, node) -- 431
					end -- 431
					ImGui.SameLine() -- 432
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 432
						openScriptInWebIDE(state, node) -- 433
					end -- 433
					if node ~= nil then -- 433
						ImGui.SameLine() -- 435
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 435
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 437
						end -- 437
					end -- 437
					ImGui.Separator() -- 440
					ImGui.InputTextMultiline( -- 441
						"##ScriptEditor", -- 441
						state.scriptContentBuffer, -- 441
						Vec2(0, -4), -- 441
						{} -- 441
					) -- 441
				end -- 427
			) -- 427
		end -- 426
	) -- 426
end -- 396
local function viewportScale(state) -- 446
	return math.max(0.25, state.zoom / 100) -- 447
end -- 446
local function clampZoom(value) -- 450
	return math.max( -- 451
		25, -- 451
		math.min(400, value) -- 451
	) -- 451
end -- 450
local function zoomViewportAt(state, delta, screenX, screenY) -- 454
	if delta == 0 then -- 454
		return -- 455
	end -- 455
	local before = state.zoom -- 456
	local beforeScale = viewportScale(state) -- 457
	local p = state.preview -- 458
	local centerX = p.x + p.width / 2 -- 459
	local centerY = p.y + p.height / 2 -- 460
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 461
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 462
	state.zoom = clampZoom(state.zoom + delta) -- 463
	if state.zoom ~= before then -- 463
		local afterScale = viewportScale(state) -- 465
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 466
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 467
		state.previewDirty = true -- 468
	end -- 468
end -- 454
local function zoomViewportFromCenter(state, delta) -- 472
	local p = state.preview -- 473
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 474
end -- 472
local function screenToScene(state, screenX, screenY) -- 477
	local p = state.preview -- 478
	local scale = viewportScale(state) -- 479
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 480
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 481
	return {localX / scale, localY / scale} -- 482
end -- 477
local function pickNodeAt(state, screenX, screenY) -- 485
	local sceneX, sceneY = table.unpack( -- 486
		screenToScene(state, screenX, screenY), -- 486
		1, -- 486
		2 -- 486
	) -- 486
	do -- 486
		local i = #state.order -- 487
		while i >= 1 do -- 487
			local id = state.order[i] -- 488
			local node = state.nodes[id] -- 489
			if node ~= nil and id ~= "root" and node.visible then -- 489
				local dx = sceneX - node.x -- 491
				local dy = sceneY - node.y -- 492
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 493
				if dx * dx + dy * dy <= radius * radius then -- 493
					return id -- 494
				end -- 494
			end -- 494
			i = i - 1 -- 487
		end -- 487
	end -- 487
	return nil -- 497
end -- 485
local function handleViewportMouse(state, hovered) -- 500
	if not hovered then -- 500
		return -- 501
	end -- 501
	local spacePressed = Keyboard:isKeyPressed("Space") -- 502
	local wheel = Mouse.wheel -- 503
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 504
	if wheelDelta ~= 0 then -- 504
		local mouse = ImGui.GetMousePos() -- 506
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 507
	end -- 507
	if ImGui.IsMouseClicked(2) then -- 507
		state.draggingNodeId = nil -- 510
		state.draggingViewport = true -- 511
		ImGui.ResetMouseDragDelta(2) -- 512
	end -- 512
	if ImGui.IsMouseClicked(0) then -- 512
		if spacePressed then -- 512
			state.draggingNodeId = nil -- 516
			state.draggingViewport = true -- 517
		else -- 517
			local mouse = ImGui.GetMousePos() -- 519
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 520
			if picked ~= nil then -- 520
				state.selectedId = picked -- 522
				state.previewDirty = true -- 523
				state.draggingNodeId = picked -- 524
				state.draggingViewport = false -- 525
			else -- 525
				state.draggingNodeId = nil -- 527
				state.draggingViewport = true -- 528
			end -- 528
		end -- 528
		ImGui.ResetMouseDragDelta(0) -- 531
	end -- 531
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 531
		state.draggingNodeId = nil -- 534
		state.draggingViewport = false -- 535
	end -- 535
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 535
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 538
		local delta = ImGui.GetMouseDragDelta(panButton) -- 539
		if delta.x ~= 0 or delta.y ~= 0 then -- 539
			if state.draggingNodeId ~= nil and panButton == 0 then -- 539
				local node = state.nodes[state.draggingNodeId] -- 542
				if node ~= nil then -- 542
					local scale = viewportScale(state) -- 544
					node.x = node.x + delta.x / scale -- 545
					node.y = node.y - delta.y / scale -- 546
					if state.snapEnabled then -- 546
						local step = 16 -- 548
						node.x = math.floor(node.x / step + 0.5) * step -- 549
						node.y = math.floor(node.y / step + 0.5) * step -- 550
					end -- 550
				end -- 550
			elseif state.draggingViewport then -- 550
				state.viewportPanX = state.viewportPanX + delta.x -- 554
				state.viewportPanY = state.viewportPanY - delta.y -- 555
			end -- 555
			ImGui.ResetMouseDragDelta(panButton) -- 557
		end -- 557
	end -- 557
end -- 500
local function drawViewportToolButton(state, tool, label) -- 562
	local active = state.viewportTool == tool -- 563
	if active then -- 563
		ImGui.PushStyleColor( -- 565
			"Button", -- 565
			Color(4281349698), -- 565
			function() -- 565
				ImGui.PushStyleColor( -- 566
					"Text", -- 566
					themeColor, -- 566
					function() -- 566
						if ImGui.Button(label) then -- 566
							state.viewportTool = tool -- 567
						end -- 567
					end -- 566
				) -- 566
			end -- 565
		) -- 565
	elseif ImGui.Button(label) then -- 565
		state.viewportTool = tool -- 571
	end -- 571
end -- 562
local function drawViewport(state) -- 575
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 576
	ImGui.SameLine() -- 577
	drawViewportToolButton(state, "Select", "Select") -- 578
	ImGui.SameLine() -- 579
	drawViewportToolButton(state, "Move", "Move") -- 580
	ImGui.SameLine() -- 581
	drawViewportToolButton(state, "Rotate", "Rotate") -- 582
	ImGui.SameLine() -- 583
	drawViewportToolButton(state, "Scale", "Scale") -- 584
	ImGui.SameLine() -- 585
	ImGui.TextDisabled("|") -- 586
	ImGui.SameLine() -- 587
	local snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 588
	if snapChanged then -- 588
		state.snapEnabled = snap -- 589
	end -- 589
	ImGui.SameLine() -- 590
	local gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 591
	if gridChanged then -- 591
		state.showGrid = grid -- 592
		state.previewDirty = true -- 592
	end -- 592
	ImGui.SameLine() -- 593
	if ImGui.Button(zh and "居中" or "Center") then -- 593
		state.viewportPanX = 0 -- 595
		state.viewportPanY = 0 -- 596
		state.zoom = 100 -- 597
		state.previewDirty = true -- 598
	end -- 598
	ImGui.SameLine() -- 600
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 601
	ImGui.Separator() -- 602
	local cursor = ImGui.GetCursorScreenPos() -- 603
	local avail = ImGui.GetContentRegionAvail() -- 604
	local viewportWidth = math.max(360, avail.x - 8) -- 605
	local viewportHeight = math.max(300, avail.y - 38) -- 606
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 606
		state.previewDirty = true -- 608
	end -- 608
	state.preview.x = cursor.x -- 610
	state.preview.y = cursor.y -- 611
	state.preview.width = viewportWidth -- 612
	state.preview.height = viewportHeight -- 613
	updatePreviewRuntime(state) -- 614
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 615
	local hovered = ImGui.IsItemHovered() -- 616
	handleViewportMouse(state, hovered) -- 617
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 618
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 618
		zoomViewportFromCenter(state, -10) -- 619
	end -- 619
	ImGui.SameLine() -- 620
	ImGui.PushStyleColor( -- 621
		"Text", -- 621
		themeColor, -- 621
		function() -- 621
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 621
				state.zoom = 100 -- 623
				state.viewportPanX = 0 -- 624
				state.viewportPanY = 0 -- 625
				state.previewDirty = true -- 626
			end -- 626
		end -- 621
	) -- 621
	ImGui.SameLine() -- 629
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 629
		zoomViewportFromCenter(state, 10) -- 630
	end -- 630
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 631
	ImGui.Separator() -- 632
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 633
	ImGui.SameLine() -- 634
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 635
end -- 575
local function drawInspector(state) -- 638
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 639
	ImGui.Separator() -- 640
	local node = state.nodes[state.selectedId] -- 641
	if node == nil then -- 641
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 643
		return -- 644
	end -- 644
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 646
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 646
		node.name = node.nameBuffer.text -- 647
	end -- 647
	local changed, x, y = ImGui.DragFloat2( -- 648
		"Position", -- 648
		node.x, -- 648
		node.y, -- 648
		1, -- 648
		-10000, -- 648
		10000, -- 648
		"%.1f" -- 648
	) -- 648
	if changed then -- 648
		node.x = x -- 649
		node.y = y -- 649
	end -- 649
	changed, x, y = ImGui.DragFloat2( -- 650
		"Scale", -- 650
		node.scaleX, -- 650
		node.scaleY, -- 650
		0.01, -- 650
		-100, -- 650
		100, -- 650
		"%.2f" -- 650
	) -- 650
	if changed then -- 650
		node.scaleX = x -- 651
		node.scaleY = y -- 651
	end -- 651
	local angleChanged, angle = ImGui.DragFloat( -- 652
		"Rotation", -- 652
		node.rotation, -- 652
		1, -- 652
		-360, -- 652
		360, -- 652
		"%.1f" -- 652
	) -- 652
	if angleChanged then -- 652
		node.rotation = angle -- 653
	end -- 653
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 654
	if visibleChanged then -- 654
		node.visible = visible -- 655
	end -- 655
	ImGui.Separator() -- 656
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 656
		node.script = node.scriptBuffer.text -- 657
	end -- 657
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 657
		openScriptForNode(state, node) -- 658
	end -- 658
	if node.kind == "Sprite" then -- 658
		ImGui.Separator() -- 660
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 660
			node.texture = node.textureBuffer.text -- 662
			state.previewDirty = true -- 663
		end -- 663
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 663
			App:openFileDialog( -- 666
				false, -- 666
				function(path) -- 666
					local asset = addAssetPath(state, path) -- 667
					if asset ~= nil and isTextureAsset(asset) then -- 667
						bindTextureToSprite(state, node, asset) -- 668
					end -- 668
				end -- 666
			) -- 666
		end -- 666
		ImGui.SameLine() -- 671
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 671
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 671
				bindTextureToSprite(state, node, state.selectedAsset) -- 673
			end -- 673
		end -- 673
	elseif node.kind == "Label" then -- 673
		ImGui.Separator() -- 676
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 676
			node.text = node.textBuffer.text -- 677
		end -- 677
	elseif node.kind == "Camera" then -- 677
		ImGui.Separator() -- 679
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 680
	end -- 680
end -- 638
local function drawConsole(state) -- 684
	ImGui.TextColored(themeColor, zh and "控制台" or "Console") -- 685
	ImGui.SameLine() -- 686
	ImGui.TextColored(okColor, state.status) -- 687
	ImGui.Separator() -- 688
	for ____, line in ipairs(state.console) do -- 689
		ImGui.TextDisabled(line) -- 689
	end -- 689
end -- 684
local function drawVerticalSplitter(id, height, onDrag) -- 692
	ImGui.PushStyleColor( -- 693
		"Button", -- 693
		Color(4281612868), -- 693
		function() -- 693
			ImGui.PushStyleColor( -- 694
				"ButtonHovered", -- 694
				Color(4283259240), -- 694
				function() -- 694
					ImGui.PushStyleColor( -- 695
						"ButtonActive", -- 695
						Color(4294954035), -- 695
						function() -- 695
							ImGui.Button( -- 696
								"##" .. id, -- 696
								Vec2(8, height) -- 696
							) -- 696
						end -- 695
					) -- 695
				end -- 694
			) -- 694
		end -- 693
	) -- 693
	if ImGui.IsItemHovered() then -- 693
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 701
	end -- 701
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 701
		local delta = ImGui.GetMouseDragDelta(0) -- 704
		if delta.x ~= 0 then -- 704
			onDrag(delta.x) -- 706
			ImGui.ResetMouseDragDelta(0) -- 707
		end -- 707
	end -- 707
end -- 692
function ____exports.drawEditor(state) -- 712
	local size = App.visualSize -- 713
	local margin = 10 -- 714
	local nativeFooterSafeArea = 60 -- 715
	local windowWidth = math.max(360, size.width - margin * 2) -- 716
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 717
	ImGui.SetNextWindowPos( -- 718
		Vec2(margin, margin), -- 718
		"Always" -- 718
	) -- 718
	ImGui.SetNextWindowSize( -- 719
		Vec2(windowWidth, windowHeight), -- 719
		"Always" -- 719
	) -- 719
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 720
	ImGui.Begin( -- 721
		"Dora Visual Editor", -- 721
		mainWindowFlags, -- 721
		function() -- 721
			drawHeader(state) -- 722
			local avail = ImGui.GetContentRegionAvail() -- 723
			local bottomHeight = math.max( -- 724
				72, -- 724
				math.min( -- 724
					state.bottomHeight, -- 724
					math.floor(avail.y * 0.28) -- 724
				) -- 724
			) -- 724
			if state.mode == "Script" then -- 724
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 726
				ImGui.PushStyleColor( -- 727
					"ChildBg", -- 727
					panelBg, -- 727
					function() -- 727
						ImGui.BeginChild( -- 728
							"ScriptWorkspaceRoot", -- 728
							Vec2(0, scriptHeight), -- 728
							{}, -- 728
							noScrollFlags, -- 728
							function() return drawScriptPanel(state) end -- 728
						) -- 728
					end -- 727
				) -- 727
				ImGui.BeginChild( -- 730
					"ScriptConsoleDock", -- 730
					Vec2(0, bottomHeight), -- 730
					{}, -- 730
					noScrollFlags, -- 730
					function() return drawConsole(state) end -- 730
				) -- 730
				return -- 731
			end -- 731
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 733
			local availableWidth = math.max(320, avail.x) -- 734
			local splitterWidth = 8 -- 735
			local compactLayout = availableWidth < 760 -- 736
			local minLeftWidth = compactLayout and 110 or 170 -- 737
			local minRightWidth = compactLayout and 130 or 220 -- 738
			local minCenterWidth = compactLayout and 80 or 180 -- 739
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 740
			if sideBudget <= minLeftWidth + minRightWidth then -- 740
				state.leftWidth = math.max( -- 742
					1, -- 742
					math.floor(sideBudget * 0.45) -- 742
				) -- 742
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 743
			else -- 743
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 745
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 746
				if state.leftWidth + state.rightWidth > sideBudget then -- 746
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 748
					state.leftWidth = math.max( -- 749
						minLeftWidth, -- 749
						math.floor(sideBudget * ratio) -- 749
					) -- 749
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 750
				end -- 750
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 752
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 753
			end -- 753
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 755
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 756
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 757
			local function clampPanelWidth(value, minValue, maxValue) -- 758
				local safeMax = math.max(1, maxValue) -- 759
				local safeMin = math.min(minValue, safeMax) -- 760
				return math.max( -- 761
					safeMin, -- 761
					math.min(value, safeMax) -- 761
				) -- 761
			end -- 758
			local function resizeSidePanels(deltaX, side) -- 763
				if side == "left" then -- 763
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 765
				else -- 765
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 767
				end -- 767
			end -- 763
			ImGui.BeginChild( -- 771
				"LeftDock", -- 771
				Vec2(state.leftWidth, mainHeight), -- 771
				{}, -- 771
				noScrollFlags, -- 771
				function() -- 771
					ImGui.BeginChild( -- 772
						"SceneDock", -- 772
						Vec2(0, leftTopHeight), -- 772
						{}, -- 772
						noScrollFlags, -- 772
						function() return drawScenePanel(state) end -- 772
					) -- 772
					ImGui.BeginChild( -- 773
						"AssetDock", -- 773
						Vec2(0, leftBottomHeight), -- 773
						{}, -- 773
						noScrollFlags, -- 773
						function() return drawAssetsPanel(state) end -- 773
					) -- 773
				end -- 771
			) -- 771
			ImGui.SameLine(0, 0) -- 775
			drawVerticalSplitter( -- 776
				"LeftSplitter", -- 776
				mainHeight, -- 776
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 776
			) -- 776
			ImGui.SameLine(0, 0) -- 777
			ImGui.PushStyleColor( -- 778
				"ChildBg", -- 778
				transparent, -- 778
				function() -- 778
					ImGui.BeginChild( -- 779
						"CenterDock", -- 779
						Vec2(centerWidth, mainHeight), -- 779
						{}, -- 779
						noScrollFlags, -- 779
						function() -- 779
							if state.mode == "Script" then -- 779
								drawScriptPanel(state) -- 780
							else -- 780
								drawViewport(state) -- 780
							end -- 780
						end -- 779
					) -- 779
				end -- 778
			) -- 778
			ImGui.SameLine(0, 0) -- 783
			drawVerticalSplitter( -- 784
				"RightSplitter", -- 784
				mainHeight, -- 784
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 784
			) -- 784
			ImGui.SameLine(0, 0) -- 785
			ImGui.BeginChild( -- 786
				"RightDock", -- 786
				Vec2(state.rightWidth, mainHeight), -- 786
				{}, -- 786
				noScrollFlags, -- 786
				function() return drawInspector(state) end -- 786
			) -- 786
			ImGui.BeginChild( -- 787
				"BottomConsoleDock", -- 787
				Vec2(0, bottomHeight), -- 787
				{}, -- 787
				noScrollFlags, -- 787
				function() return drawConsole(state) end -- 787
			) -- 787
		end -- 721
	) -- 721
	drawGamePreviewWindow(state) -- 789
end -- 712
function ____exports.drawRuntimeError(message) -- 792
	local size = App.visualSize -- 793
	ImGui.SetNextWindowPos( -- 794
		Vec2(10, 10), -- 794
		"Always" -- 794
	) -- 794
	ImGui.SetNextWindowSize( -- 795
		Vec2( -- 795
			math.max(320, size.width - 20), -- 795
			math.max(220, size.height - 20) -- 795
		), -- 795
		"Always" -- 795
	) -- 795
	ImGui.Begin( -- 796
		"Dora Visual Editor Error", -- 796
		mainWindowFlags, -- 796
		function() -- 796
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 797
			ImGui.Separator() -- 798
			ImGui.TextWrapped(message or "unknown error") -- 799
		end -- 796
	) -- 796
end -- 792
return ____exports -- 792