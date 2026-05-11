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
local addChildNode = ____Model.addChildNode -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local isFolderAsset = ____Model.isFolderAsset -- 6
local isScriptAsset = ____Model.isScriptAsset -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____Player = require("Script.Tools.SceneEditor.Player") -- 8
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 8
local ____HeaderPanel = require("Script.Tools.SceneEditor.Panels.HeaderPanel") -- 9
local drawHeaderPanel = ____HeaderPanel.drawHeaderPanel -- 9
local ____ConsolePanel = require("Script.Tools.SceneEditor.Panels.ConsolePanel") -- 10
local drawConsolePanel = ____ConsolePanel.drawConsolePanel -- 10
local ____SceneTreePanel = require("Script.Tools.SceneEditor.Panels.SceneTreePanel") -- 11
local drawSceneTreePanel = ____SceneTreePanel.drawSceneTreePanel -- 11
local ____AssetsPanel = require("Script.Tools.SceneEditor.Panels.AssetsPanel") -- 12
local drawAssetsPanel = ____AssetsPanel.drawAssetsPanel -- 12
local ____InspectorPanel = require("Script.Tools.SceneEditor.Panels.InspectorPanel") -- 13
local drawInspectorPanel = ____InspectorPanel.drawInspectorPanel -- 13
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 18
local function workspacePath(path) -- 19
	return SceneModel.workspacePath(path) -- 19
end -- 19
local function workspaceRoot() -- 20
	return SceneModel.workspaceRoot() -- 20
end -- 20
local function sceneSaveFile() -- 22
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 23
end -- 22
local function writeSceneFile(state) -- 26
	Content:mkdir(workspacePath(".dora")) -- 27
	local data = {version = 1, nodes = {}} -- 28
	for ____, id in ipairs(state.order) do -- 29
		local node = state.nodes[id] -- 30
		if node ~= nil then -- 30
			local ____data_nodes_0 = data.nodes -- 30
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 32
				id = node.id, -- 33
				kind = node.kind, -- 34
				name = node.name, -- 35
				parentId = node.parentId, -- 36
				x = node.x, -- 37
				y = node.y, -- 38
				scaleX = node.scaleX, -- 39
				scaleY = node.scaleY, -- 40
				rotation = node.rotation, -- 41
				visible = node.visible, -- 42
				texture = node.texture, -- 43
				text = node.text, -- 44
				script = node.script -- 45
			} -- 45
		end -- 45
	end -- 45
	local text = json.encode(data) -- 49
	local file = sceneSaveFile() -- 50
	if text ~= nil and Content:save(file, text) then -- 50
		return file -- 51
	end -- 51
	return nil -- 52
end -- 26
local function saveScene(state) -- 55
	local file = writeSceneFile(state) -- 56
	if file ~= nil then -- 56
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 58
	else -- 58
		state.status = zh and "保存失败" or "Save failed" -- 60
	end -- 60
	pushConsole(state, state.status) -- 62
end -- 55
local function attachScriptToNode(state, node, scriptPath, message) -- 65
	node.script = scriptPath -- 66
	node.scriptBuffer.text = scriptPath -- 67
	state.activeScriptNodeId = node.id -- 68
	local sceneFile = writeSceneFile(state) -- 69
	if sceneFile == nil then -- 69
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 71
	else -- 71
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 73
	end -- 73
	pushConsole(state, state.status) -- 75
end -- 65
local function bindTextureToSprite(state, node, texture) -- 78
	node.texture = texture -- 79
	node.textureBuffer.text = texture -- 80
	state.selectedAsset = texture -- 81
	state.previewDirty = true -- 82
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 83
	pushConsole(state, state.status) -- 84
end -- 78
local function createSpriteFromTexture(state, texture) -- 87
	addChildNode(state, "Sprite") -- 88
	local node = state.nodes[state.selectedId] -- 89
	if node ~= nil and node.kind == "Sprite" then -- 89
		bindTextureToSprite(state, node, texture) -- 91
	end -- 91
end -- 87
local function scriptTemplate(node) -- 95
	local name = node ~= nil and node.name or "Script" -- 96
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 95
local function loadScriptIntoEditor(state, node, scriptPath) -- 107
	if node ~= nil then -- 107
		attachScriptToNode(state, node, scriptPath) -- 109
	else -- 109
		state.activeScriptNodeId = nil -- 111
	end -- 111
	state.scriptPathBuffer.text = scriptPath -- 113
	local scriptFile = workspacePath(scriptPath) -- 114
	if Content:exist(scriptFile) then -- 114
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 116
	elseif Content:exist(scriptPath) then -- 116
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 118
	else -- 118
		state.scriptContentBuffer.text = scriptTemplate(node) -- 120
	end -- 120
	state.mode = "Script" -- 122
end -- 107
local function openScriptForNode(state, node) -- 125
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 126
	loadScriptIntoEditor(state, node, path) -- 127
end -- 125
local function saveScriptFile(state, node) -- 130
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 131
	state.scriptPathBuffer.text = path -- 132
	local scriptFile = workspacePath(path) -- 133
	Content:mkdir(Path:getPath(scriptFile)) -- 134
	local statusAlreadyLogged = false -- 135
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 135
		if node ~= nil then -- 135
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 138
			statusAlreadyLogged = true -- 139
		else -- 139
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 141
		end -- 141
		if state.selectedAsset ~= path then -- 141
			state.selectedAsset = path -- 143
		end -- 143
		local exists = false -- 144
		for ____, asset in ipairs(state.assets) do -- 145
			if asset == path then -- 145
				exists = true -- 145
			end -- 145
		end -- 145
		if not exists then -- 145
			local ____state_assets_1 = state.assets -- 145
			____state_assets_1[#____state_assets_1 + 1] = path -- 146
		end -- 146
	else -- 146
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 148
	end -- 148
	if not statusAlreadyLogged then -- 148
		pushConsole(state, state.status) -- 150
	end -- 150
end -- 130
local function currentScriptPath(state, node) -- 153
	if state.scriptPathBuffer.text ~= "" then -- 153
		return state.scriptPathBuffer.text -- 154
	end -- 154
	if node ~= nil and node.script ~= "" then -- 154
		return node.script -- 155
	end -- 155
	if node ~= nil then -- 155
		return ("Script/" .. node.name) .. ".lua" -- 156
	end -- 156
	return "Script/NewScript.lua" -- 157
end -- 153
local function sendWebIDEMessage(payload) -- 160
	local text = json.encode(payload) -- 161
	if text ~= nil then -- 161
		emit("AppWS", "Send", text) -- 162
	end -- 162
end -- 160
local function openScriptInWebIDE(state, node) -- 165
	local scriptPath = currentScriptPath(state, node) -- 166
	state.scriptPathBuffer.text = scriptPath -- 167
	if state.scriptContentBuffer.text == "" then -- 167
		state.scriptContentBuffer.text = scriptTemplate(node) -- 169
	end -- 169
	saveScriptFile(state, node) -- 171
	local title = Path:getFilename(scriptPath) or scriptPath -- 172
	local root = workspaceRoot() -- 173
	local rootTitle = Path:getFilename(root) or "Workspace" -- 174
	local fullScriptPath = workspacePath(scriptPath) -- 175
	local openWorkspaceMessage = { -- 176
		name = "OpenFile", -- 177
		file = root, -- 178
		title = rootTitle, -- 179
		folder = true, -- 180
		workspaceView = "agent" -- 181
	} -- 181
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 183
	local openScriptMessage = { -- 189
		name = "OpenFile", -- 190
		file = fullScriptPath, -- 191
		title = title, -- 192
		folder = false, -- 193
		position = {lineNumber = 1, column = 1} -- 194
	} -- 194
	local function sendOpenMessages() -- 196
		sendWebIDEMessage(openWorkspaceMessage) -- 197
		sendWebIDEMessage(updateScriptMessage) -- 198
		sendWebIDEMessage(openScriptMessage) -- 199
	end -- 196
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 201
	local editingText = json.encode(editingInfo) -- 218
	if editingText ~= nil then -- 218
		Content:mkdir(workspacePath(".dora")) -- 220
		Content:save( -- 221
			workspacePath(Path(".dora", "open-script.editing.json")), -- 221
			editingText -- 221
		) -- 221
		pcall(function() -- 222
			local Entry = require("Script.Dev.Entry") -- 223
			local config = Entry.getConfig() -- 224
			if config ~= nil then -- 224
				config.editingInfo = editingText -- 225
			end -- 225
		end) -- 222
	end -- 222
	App:openURL("http://127.0.0.1:8866/") -- 228
	sendOpenMessages() -- 229
	thread(function() -- 230
		do -- 230
			local i = 0 -- 231
			while i < 4 do -- 231
				sleep(0.5) -- 232
				sendOpenMessages() -- 233
				i = i + 1 -- 231
			end -- 231
		end -- 231
	end) -- 230
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 236
	pushConsole(state, state.status) -- 237
end -- 165
local function drawScriptAssetList(state, node) -- 240
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 241
	for ____, asset in ipairs(state.assets) do -- 242
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 242
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 242
				state.selectedAsset = asset -- 245
				loadScriptIntoEditor(state, node, asset) -- 246
			end -- 246
		end -- 246
	end -- 246
end -- 240
local function drawScriptPanel(state) -- 252
	local activeId = state.activeScriptNodeId or state.selectedId -- 253
	local node = state.nodes[activeId] -- 254
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 255
	ImGui.SameLine() -- 256
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 257
	ImGui.Separator() -- 258
	ImGui.BeginChild( -- 259
		"ScriptSidebar", -- 259
		Vec2(220, 0), -- 259
		{}, -- 259
		noScrollFlags, -- 259
		function() -- 259
			drawScriptAssetList(state, node) -- 260
			ImGui.Separator() -- 261
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 261
				local scriptName = node ~= nil and node.name or "NewScript" -- 263
				local path = ("Script/" .. scriptName) .. ".lua" -- 264
				state.scriptPathBuffer.text = path -- 265
				state.scriptContentBuffer.text = scriptTemplate(node) -- 266
				if node ~= nil then -- 266
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 268
				end -- 268
			end -- 268
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 268
				importFileDialog(state) -- 271
			end -- 271
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 271
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 271
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 274
				end -- 274
			end -- 274
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 274
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 278
			end -- 278
		end -- 259
	) -- 259
	ImGui.SameLine() -- 281
	ImGui.PushStyleColor( -- 282
		"ChildBg", -- 282
		scriptPanelBg, -- 282
		function() -- 282
			ImGui.BeginChild( -- 283
				"ScriptEditorPane", -- 283
				Vec2(0, 0), -- 283
				{}, -- 283
				noScrollFlags, -- 283
				function() -- 283
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 284
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 285
					ImGui.SameLine() -- 286
					if ImGui.Button(zh and "保存" or "Save") then -- 286
						saveScriptFile(state, node) -- 287
					end -- 287
					ImGui.SameLine() -- 288
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 288
						openScriptInWebIDE(state, node) -- 289
					end -- 289
					if node ~= nil then -- 289
						ImGui.SameLine() -- 291
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 291
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 293
						end -- 293
					end -- 293
					ImGui.Separator() -- 296
					ImGui.InputTextMultiline( -- 297
						"##ScriptEditor", -- 297
						state.scriptContentBuffer, -- 297
						Vec2(0, -4), -- 297
						{} -- 297
					) -- 297
				end -- 283
			) -- 283
		end -- 282
	) -- 282
end -- 252
local function viewportScale(state) -- 302
	return math.max(0.25, state.zoom / 100) -- 303
end -- 302
local function clampZoom(value) -- 306
	return math.max( -- 307
		25, -- 307
		math.min(400, value) -- 307
	) -- 307
end -- 306
local function zoomViewportAt(state, delta, screenX, screenY) -- 310
	if delta == 0 then -- 310
		return -- 311
	end -- 311
	local before = state.zoom -- 312
	local beforeScale = viewportScale(state) -- 313
	local p = state.preview -- 314
	local centerX = p.x + p.width / 2 -- 315
	local centerY = p.y + p.height / 2 -- 316
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 317
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 318
	state.zoom = clampZoom(state.zoom + delta) -- 319
	if state.zoom ~= before then -- 319
		local afterScale = viewportScale(state) -- 321
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 322
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 323
		state.previewDirty = true -- 324
	end -- 324
end -- 310
local function zoomViewportFromCenter(state, delta) -- 328
	local p = state.preview -- 329
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 330
end -- 328
local function screenToScene(state, screenX, screenY) -- 333
	local p = state.preview -- 334
	local scale = viewportScale(state) -- 335
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 336
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 337
	return {localX / scale, localY / scale} -- 338
end -- 333
local function pickNodeAt(state, screenX, screenY) -- 341
	local sceneX, sceneY = table.unpack( -- 342
		screenToScene(state, screenX, screenY), -- 342
		1, -- 342
		2 -- 342
	) -- 342
	do -- 342
		local i = #state.order -- 343
		while i >= 1 do -- 343
			local id = state.order[i] -- 344
			local node = state.nodes[id] -- 345
			if node ~= nil and id ~= "root" and node.visible then -- 345
				local dx = sceneX - node.x -- 347
				local dy = sceneY - node.y -- 348
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 349
				if dx * dx + dy * dy <= radius * radius then -- 349
					return id -- 350
				end -- 350
			end -- 350
			i = i - 1 -- 343
		end -- 343
	end -- 343
	return nil -- 353
end -- 341
local function handleViewportMouse(state, hovered) -- 356
	if not hovered then -- 356
		return -- 357
	end -- 357
	local spacePressed = Keyboard:isKeyPressed("Space") -- 358
	local wheel = Mouse.wheel -- 359
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 360
	if wheelDelta ~= 0 then -- 360
		local mouse = ImGui.GetMousePos() -- 362
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 363
	end -- 363
	if ImGui.IsMouseClicked(2) then -- 363
		state.draggingNodeId = nil -- 366
		state.draggingViewport = true -- 367
		ImGui.ResetMouseDragDelta(2) -- 368
	end -- 368
	if ImGui.IsMouseClicked(0) then -- 368
		if spacePressed then -- 368
			state.draggingNodeId = nil -- 372
			state.draggingViewport = true -- 373
		else -- 373
			local mouse = ImGui.GetMousePos() -- 375
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 376
			if picked ~= nil then -- 376
				state.selectedId = picked -- 378
				state.previewDirty = true -- 379
				state.draggingNodeId = picked -- 380
				state.draggingViewport = false -- 381
			else -- 381
				state.draggingNodeId = nil -- 383
				state.draggingViewport = true -- 384
			end -- 384
		end -- 384
		ImGui.ResetMouseDragDelta(0) -- 387
	end -- 387
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 387
		state.draggingNodeId = nil -- 390
		state.draggingViewport = false -- 391
	end -- 391
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 391
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 394
		local delta = ImGui.GetMouseDragDelta(panButton) -- 395
		if delta.x ~= 0 or delta.y ~= 0 then -- 395
			if state.draggingNodeId ~= nil and panButton == 0 then -- 395
				local node = state.nodes[state.draggingNodeId] -- 398
				if node ~= nil then -- 398
					local scale = viewportScale(state) -- 400
					node.x = node.x + delta.x / scale -- 401
					node.y = node.y - delta.y / scale -- 402
					if state.snapEnabled then -- 402
						local step = 16 -- 404
						node.x = math.floor(node.x / step + 0.5) * step -- 405
						node.y = math.floor(node.y / step + 0.5) * step -- 406
					end -- 406
				end -- 406
			elseif state.draggingViewport then -- 406
				state.viewportPanX = state.viewportPanX + delta.x -- 410
				state.viewportPanY = state.viewportPanY - delta.y -- 411
			end -- 411
			ImGui.ResetMouseDragDelta(panButton) -- 413
		end -- 413
	end -- 413
end -- 356
local function drawViewportToolButton(state, tool, label) -- 418
	local active = state.viewportTool == tool -- 419
	if active then -- 419
		ImGui.PushStyleColor( -- 421
			"Button", -- 421
			Color(4281349698), -- 421
			function() -- 421
				ImGui.PushStyleColor( -- 422
					"Text", -- 422
					themeColor, -- 422
					function() -- 422
						if ImGui.Button(label) then -- 422
							state.viewportTool = tool -- 423
						end -- 423
					end -- 422
				) -- 422
			end -- 421
		) -- 421
	elseif ImGui.Button(label) then -- 421
		state.viewportTool = tool -- 427
	end -- 427
end -- 418
local function drawViewport(state) -- 431
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 432
	ImGui.SameLine() -- 433
	drawViewportToolButton(state, "Select", "Select") -- 434
	ImGui.SameLine() -- 435
	drawViewportToolButton(state, "Move", "Move") -- 436
	ImGui.SameLine() -- 437
	drawViewportToolButton(state, "Rotate", "Rotate") -- 438
	ImGui.SameLine() -- 439
	drawViewportToolButton(state, "Scale", "Scale") -- 440
	ImGui.SameLine() -- 441
	ImGui.TextDisabled("|") -- 442
	ImGui.SameLine() -- 443
	local snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 444
	if snapChanged then -- 444
		state.snapEnabled = snap -- 445
	end -- 445
	ImGui.SameLine() -- 446
	local gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 447
	if gridChanged then -- 447
		state.showGrid = grid -- 448
		state.previewDirty = true -- 448
	end -- 448
	ImGui.SameLine() -- 449
	if ImGui.Button(zh and "居中" or "Center") then -- 449
		state.viewportPanX = 0 -- 451
		state.viewportPanY = 0 -- 452
		state.zoom = 100 -- 453
		state.previewDirty = true -- 454
	end -- 454
	ImGui.SameLine() -- 456
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 457
	ImGui.Separator() -- 458
	local cursor = ImGui.GetCursorScreenPos() -- 459
	local avail = ImGui.GetContentRegionAvail() -- 460
	local viewportWidth = math.max(360, avail.x - 8) -- 461
	local viewportHeight = math.max(300, avail.y - 38) -- 462
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 462
		state.previewDirty = true -- 464
	end -- 464
	state.preview.x = cursor.x -- 466
	state.preview.y = cursor.y -- 467
	state.preview.width = viewportWidth -- 468
	state.preview.height = viewportHeight -- 469
	updatePreviewRuntime(state) -- 470
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 471
	local hovered = ImGui.IsItemHovered() -- 472
	handleViewportMouse(state, hovered) -- 473
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 474
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 474
		zoomViewportFromCenter(state, -10) -- 475
	end -- 475
	ImGui.SameLine() -- 476
	ImGui.PushStyleColor( -- 477
		"Text", -- 477
		themeColor, -- 477
		function() -- 477
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 477
				state.zoom = 100 -- 479
				state.viewportPanX = 0 -- 480
				state.viewportPanY = 0 -- 481
				state.previewDirty = true -- 482
			end -- 482
		end -- 477
	) -- 477
	ImGui.SameLine() -- 485
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 485
		zoomViewportFromCenter(state, 10) -- 486
	end -- 486
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 487
	ImGui.Separator() -- 488
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 489
	ImGui.SameLine() -- 490
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 491
end -- 431
local function drawVerticalSplitter(id, height, onDrag) -- 494
	ImGui.PushStyleColor( -- 495
		"Button", -- 495
		Color(4281612868), -- 495
		function() -- 495
			ImGui.PushStyleColor( -- 496
				"ButtonHovered", -- 496
				Color(4283259240), -- 496
				function() -- 496
					ImGui.PushStyleColor( -- 497
						"ButtonActive", -- 497
						Color(4294954035), -- 497
						function() -- 497
							ImGui.Button( -- 498
								"##" .. id, -- 498
								Vec2(8, height) -- 498
							) -- 498
						end -- 497
					) -- 497
				end -- 496
			) -- 496
		end -- 495
	) -- 495
	if ImGui.IsItemHovered() then -- 495
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 503
	end -- 503
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 503
		local delta = ImGui.GetMouseDragDelta(0) -- 506
		if delta.x ~= 0 then -- 506
			onDrag(delta.x) -- 508
			ImGui.ResetMouseDragDelta(0) -- 509
		end -- 509
	end -- 509
end -- 494
function ____exports.drawEditor(state) -- 514
	local size = App.visualSize -- 515
	local margin = 10 -- 516
	local nativeFooterSafeArea = 60 -- 517
	local windowWidth = math.max(360, size.width - margin * 2) -- 518
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 519
	ImGui.SetNextWindowPos( -- 520
		Vec2(margin, margin), -- 520
		"Always" -- 520
	) -- 520
	ImGui.SetNextWindowSize( -- 521
		Vec2(windowWidth, windowHeight), -- 521
		"Always" -- 521
	) -- 521
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 522
	ImGui.Begin( -- 523
		"Dora Visual Editor", -- 523
		mainWindowFlags, -- 523
		function() -- 523
			drawHeaderPanel(state, saveScene) -- 524
			local avail = ImGui.GetContentRegionAvail() -- 525
			local bottomHeight = math.max( -- 526
				72, -- 526
				math.min( -- 526
					state.bottomHeight, -- 526
					math.floor(avail.y * 0.28) -- 526
				) -- 526
			) -- 526
			if state.mode == "Script" then -- 526
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 528
				ImGui.PushStyleColor( -- 529
					"ChildBg", -- 529
					panelBg, -- 529
					function() -- 529
						ImGui.BeginChild( -- 530
							"ScriptWorkspaceRoot", -- 530
							Vec2(0, scriptHeight), -- 530
							{}, -- 530
							noScrollFlags, -- 530
							function() return drawScriptPanel(state) end -- 530
						) -- 530
					end -- 529
				) -- 529
				ImGui.BeginChild( -- 532
					"ScriptConsoleDock", -- 532
					Vec2(0, bottomHeight), -- 532
					{}, -- 532
					noScrollFlags, -- 532
					function() return drawConsolePanel(state) end -- 532
				) -- 532
				return -- 533
			end -- 533
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 535
			local availableWidth = math.max(320, avail.x) -- 536
			local splitterWidth = 8 -- 537
			local compactLayout = availableWidth < 760 -- 538
			local minLeftWidth = compactLayout and 110 or 170 -- 539
			local minRightWidth = compactLayout and 130 or 220 -- 540
			local minCenterWidth = compactLayout and 80 or 180 -- 541
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 542
			if sideBudget <= minLeftWidth + minRightWidth then -- 542
				state.leftWidth = math.max( -- 544
					1, -- 544
					math.floor(sideBudget * 0.45) -- 544
				) -- 544
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 545
			else -- 545
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 547
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 548
				if state.leftWidth + state.rightWidth > sideBudget then -- 548
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 550
					state.leftWidth = math.max( -- 551
						minLeftWidth, -- 551
						math.floor(sideBudget * ratio) -- 551
					) -- 551
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 552
				end -- 552
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 554
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 555
			end -- 555
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 557
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 558
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 559
			local function clampPanelWidth(value, minValue, maxValue) -- 560
				local safeMax = math.max(1, maxValue) -- 561
				local safeMin = math.min(minValue, safeMax) -- 562
				return math.max( -- 563
					safeMin, -- 563
					math.min(value, safeMax) -- 563
				) -- 563
			end -- 560
			local function resizeSidePanels(deltaX, side) -- 565
				if side == "left" then -- 565
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 567
				else -- 567
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 569
				end -- 569
			end -- 565
			ImGui.BeginChild( -- 573
				"LeftDock", -- 573
				Vec2(state.leftWidth, mainHeight), -- 573
				{}, -- 573
				noScrollFlags, -- 573
				function() -- 573
					ImGui.BeginChild( -- 574
						"SceneDock", -- 574
						Vec2(0, leftTopHeight), -- 574
						{}, -- 574
						noScrollFlags, -- 574
						function() return drawSceneTreePanel(state) end -- 574
					) -- 574
					ImGui.BeginChild( -- 575
						"AssetDock", -- 575
						Vec2(0, leftBottomHeight), -- 575
						{}, -- 575
						noScrollFlags, -- 575
						function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 575
					) -- 575
				end -- 573
			) -- 573
			ImGui.SameLine(0, 0) -- 577
			drawVerticalSplitter( -- 578
				"LeftSplitter", -- 578
				mainHeight, -- 578
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 578
			) -- 578
			ImGui.SameLine(0, 0) -- 579
			ImGui.PushStyleColor( -- 580
				"ChildBg", -- 580
				transparent, -- 580
				function() -- 580
					ImGui.BeginChild( -- 581
						"CenterDock", -- 581
						Vec2(centerWidth, mainHeight), -- 581
						{}, -- 581
						noScrollFlags, -- 581
						function() -- 581
							if state.mode == "Script" then -- 581
								drawScriptPanel(state) -- 582
							else -- 582
								drawViewport(state) -- 582
							end -- 582
						end -- 581
					) -- 581
				end -- 580
			) -- 580
			ImGui.SameLine(0, 0) -- 585
			drawVerticalSplitter( -- 586
				"RightSplitter", -- 586
				mainHeight, -- 586
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 586
			) -- 586
			ImGui.SameLine(0, 0) -- 587
			ImGui.BeginChild( -- 588
				"RightDock", -- 588
				Vec2(state.rightWidth, mainHeight), -- 588
				{}, -- 588
				noScrollFlags, -- 588
				function() return drawInspectorPanel(state, bindTextureToSprite, openScriptForNode) end -- 588
			) -- 588
			ImGui.BeginChild( -- 589
				"BottomConsoleDock", -- 589
				Vec2(0, bottomHeight), -- 589
				{}, -- 589
				noScrollFlags, -- 589
				function() return drawConsolePanel(state) end -- 589
			) -- 589
		end -- 523
	) -- 523
	drawGamePreviewWindow(state) -- 591
end -- 514
function ____exports.drawRuntimeError(message) -- 594
	local size = App.visualSize -- 595
	ImGui.SetNextWindowPos( -- 596
		Vec2(10, 10), -- 596
		"Always" -- 596
	) -- 596
	ImGui.SetNextWindowSize( -- 597
		Vec2( -- 597
			math.max(320, size.width - 20), -- 597
			math.max(220, size.height - 20) -- 597
		), -- 597
		"Always" -- 597
	) -- 597
	ImGui.Begin( -- 598
		"Dora Visual Editor Error", -- 598
		mainWindowFlags, -- 598
		function() -- 598
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 599
			ImGui.Separator() -- 600
			ImGui.TextWrapped(message or "unknown error") -- 601
		end -- 598
	) -- 598
end -- 594
return ____exports -- 594