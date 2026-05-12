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
local json = ____Dora.json -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local mainWindowFlags = ____Theme.mainWindowFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local okColor = ____Theme.okColor -- 5
local panelBg = ____Theme.panelBg -- 5
local themeColor = ____Theme.themeColor -- 5
local transparent = ____Theme.transparent -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addChildNode = ____Model.addChildNode -- 6
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
local ____ScriptPanel = require("Script.Tools.SceneEditor.Panels.ScriptPanel") -- 14
local drawScriptPanel = ____ScriptPanel.drawScriptPanel -- 14
local openScriptForNode = ____ScriptPanel.openScriptForNode -- 14
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 18
local function workspacePath(path) -- 19
	return SceneModel.workspacePath(path) -- 19
end -- 19
local function sceneSaveFile() -- 21
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 22
end -- 21
local function writeSceneFile(state) -- 25
	Content:mkdir(workspacePath(".dora")) -- 26
	local data = {version = 1, nodes = {}} -- 27
	for ____, id in ipairs(state.order) do -- 28
		local node = state.nodes[id] -- 29
		if node ~= nil then -- 29
			local ____data_nodes_0 = data.nodes -- 29
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 31
				id = node.id, -- 32
				kind = node.kind, -- 33
				name = node.name, -- 34
				parentId = node.parentId, -- 35
				x = node.x, -- 36
				y = node.y, -- 37
				scaleX = node.scaleX, -- 38
				scaleY = node.scaleY, -- 39
				rotation = node.rotation, -- 40
				visible = node.visible, -- 41
				texture = node.texture, -- 42
				text = node.text, -- 43
				script = node.script -- 44
			} -- 44
		end -- 44
	end -- 44
	local text = json.encode(data) -- 48
	local file = sceneSaveFile() -- 49
	if text ~= nil and Content:save(file, text) then -- 49
		return file -- 50
	end -- 50
	return nil -- 51
end -- 25
local function saveScene(state) -- 54
	local file = writeSceneFile(state) -- 55
	if file ~= nil then -- 55
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 57
	else -- 57
		state.status = zh and "保存失败" or "Save failed" -- 59
	end -- 59
	pushConsole(state, state.status) -- 61
end -- 54
local function attachScriptToNode(state, node, scriptPath, message) -- 64
	node.script = scriptPath -- 65
	node.scriptBuffer.text = scriptPath -- 66
	state.activeScriptNodeId = node.id -- 67
	local sceneFile = writeSceneFile(state) -- 68
	if sceneFile == nil then -- 68
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 70
	else -- 70
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 72
	end -- 72
	pushConsole(state, state.status) -- 74
end -- 64
local function bindTextureToSprite(state, node, texture) -- 77
	node.texture = texture -- 78
	node.textureBuffer.text = texture -- 79
	state.selectedAsset = texture -- 80
	state.previewDirty = true -- 81
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 82
	pushConsole(state, state.status) -- 83
end -- 77
local function createSpriteFromTexture(state, texture) -- 86
	addChildNode(state, "Sprite") -- 87
	local node = state.nodes[state.selectedId] -- 88
	if node ~= nil and node.kind == "Sprite" then -- 88
		bindTextureToSprite(state, node, texture) -- 90
	end -- 90
end -- 86
local function openNodeScriptInEditor(state, node) -- 94
	openScriptForNode(state, node, attachScriptToNode) -- 95
end -- 94
local function viewportScale(state) -- 98
	return math.max(0.25, state.zoom / 100) -- 99
end -- 98
local function clampZoom(value) -- 102
	return math.max( -- 103
		25, -- 103
		math.min(400, value) -- 103
	) -- 103
end -- 102
local function zoomViewportAt(state, delta, screenX, screenY) -- 106
	if delta == 0 then -- 106
		return -- 107
	end -- 107
	local before = state.zoom -- 108
	local beforeScale = viewportScale(state) -- 109
	local p = state.preview -- 110
	local centerX = p.x + p.width / 2 -- 111
	local centerY = p.y + p.height / 2 -- 112
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 113
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 114
	state.zoom = clampZoom(state.zoom + delta) -- 115
	if state.zoom ~= before then -- 115
		local afterScale = viewportScale(state) -- 117
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 118
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 119
		state.previewDirty = true -- 120
	end -- 120
end -- 106
local function zoomViewportFromCenter(state, delta) -- 124
	local p = state.preview -- 125
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 126
end -- 124
local function screenToScene(state, screenX, screenY) -- 129
	local p = state.preview -- 130
	local scale = viewportScale(state) -- 131
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 132
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 133
	return {localX / scale, localY / scale} -- 134
end -- 129
local function pickNodeAt(state, screenX, screenY) -- 137
	local sceneX, sceneY = table.unpack( -- 138
		screenToScene(state, screenX, screenY), -- 138
		1, -- 138
		2 -- 138
	) -- 138
	do -- 138
		local i = #state.order -- 139
		while i >= 1 do -- 139
			local id = state.order[i] -- 140
			local node = state.nodes[id] -- 141
			if node ~= nil and id ~= "root" and node.visible then -- 141
				local dx = sceneX - node.x -- 143
				local dy = sceneY - node.y -- 144
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 145
				if dx * dx + dy * dy <= radius * radius then -- 145
					return id -- 146
				end -- 146
			end -- 146
			i = i - 1 -- 139
		end -- 139
	end -- 139
	return nil -- 149
end -- 137
local function handleViewportMouse(state, hovered) -- 152
	if not hovered then -- 152
		return -- 153
	end -- 153
	local spacePressed = Keyboard:isKeyPressed("Space") -- 154
	local wheel = Mouse.wheel -- 155
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 156
	if wheelDelta ~= 0 then -- 156
		local mouse = ImGui.GetMousePos() -- 158
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 159
	end -- 159
	if ImGui.IsMouseClicked(2) then -- 159
		state.draggingNodeId = nil -- 162
		state.draggingViewport = true -- 163
		ImGui.ResetMouseDragDelta(2) -- 164
	end -- 164
	if ImGui.IsMouseClicked(0) then -- 164
		if spacePressed then -- 164
			state.draggingNodeId = nil -- 168
			state.draggingViewport = true -- 169
		else -- 169
			local mouse = ImGui.GetMousePos() -- 171
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 172
			if picked ~= nil then -- 172
				state.selectedId = picked -- 174
				state.previewDirty = true -- 175
				state.draggingNodeId = picked -- 176
				state.draggingViewport = false -- 177
			else -- 177
				state.draggingNodeId = nil -- 179
				state.draggingViewport = true -- 180
			end -- 180
		end -- 180
		ImGui.ResetMouseDragDelta(0) -- 183
	end -- 183
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 183
		state.draggingNodeId = nil -- 186
		state.draggingViewport = false -- 187
	end -- 187
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 187
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 190
		local delta = ImGui.GetMouseDragDelta(panButton) -- 191
		if delta.x ~= 0 or delta.y ~= 0 then -- 191
			if state.draggingNodeId ~= nil and panButton == 0 then -- 191
				local node = state.nodes[state.draggingNodeId] -- 194
				if node ~= nil then -- 194
					local scale = viewportScale(state) -- 196
					node.x = node.x + delta.x / scale -- 197
					node.y = node.y - delta.y / scale -- 198
					if state.snapEnabled then -- 198
						local step = 16 -- 200
						node.x = math.floor(node.x / step + 0.5) * step -- 201
						node.y = math.floor(node.y / step + 0.5) * step -- 202
					end -- 202
				end -- 202
			elseif state.draggingViewport then -- 202
				state.viewportPanX = state.viewportPanX + delta.x -- 206
				state.viewportPanY = state.viewportPanY - delta.y -- 207
			end -- 207
			ImGui.ResetMouseDragDelta(panButton) -- 209
		end -- 209
	end -- 209
end -- 152
local function drawViewportToolButton(state, tool, label) -- 214
	local active = state.viewportTool == tool -- 215
	if active then -- 215
		ImGui.PushStyleColor( -- 217
			"Button", -- 217
			Color(4281349698), -- 217
			function() -- 217
				ImGui.PushStyleColor( -- 218
					"Text", -- 218
					themeColor, -- 218
					function() -- 218
						if ImGui.Button(label) then -- 218
							state.viewportTool = tool -- 219
						end -- 219
					end -- 218
				) -- 218
			end -- 217
		) -- 217
	elseif ImGui.Button(label) then -- 217
		state.viewportTool = tool -- 223
	end -- 223
end -- 214
local function drawViewport(state) -- 227
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 228
	ImGui.SameLine() -- 229
	drawViewportToolButton(state, "Select", "Select") -- 230
	ImGui.SameLine() -- 231
	drawViewportToolButton(state, "Move", "Move") -- 232
	ImGui.SameLine() -- 233
	drawViewportToolButton(state, "Rotate", "Rotate") -- 234
	ImGui.SameLine() -- 235
	drawViewportToolButton(state, "Scale", "Scale") -- 236
	ImGui.SameLine() -- 237
	ImGui.TextDisabled("|") -- 238
	ImGui.SameLine() -- 239
	local snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 240
	if snapChanged then -- 240
		state.snapEnabled = snap -- 241
	end -- 241
	ImGui.SameLine() -- 242
	local gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 243
	if gridChanged then -- 243
		state.showGrid = grid -- 244
		state.previewDirty = true -- 244
	end -- 244
	ImGui.SameLine() -- 245
	if ImGui.Button(zh and "居中" or "Center") then -- 245
		state.viewportPanX = 0 -- 247
		state.viewportPanY = 0 -- 248
		state.zoom = 100 -- 249
		state.previewDirty = true -- 250
	end -- 250
	ImGui.SameLine() -- 252
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 253
	ImGui.Separator() -- 254
	local cursor = ImGui.GetCursorScreenPos() -- 255
	local avail = ImGui.GetContentRegionAvail() -- 256
	local viewportWidth = math.max(360, avail.x - 8) -- 257
	local viewportHeight = math.max(300, avail.y - 38) -- 258
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 258
		state.previewDirty = true -- 260
	end -- 260
	state.preview.x = cursor.x -- 262
	state.preview.y = cursor.y -- 263
	state.preview.width = viewportWidth -- 264
	state.preview.height = viewportHeight -- 265
	updatePreviewRuntime(state) -- 266
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 267
	local hovered = ImGui.IsItemHovered() -- 268
	handleViewportMouse(state, hovered) -- 269
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 270
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 270
		zoomViewportFromCenter(state, -10) -- 271
	end -- 271
	ImGui.SameLine() -- 272
	ImGui.PushStyleColor( -- 273
		"Text", -- 273
		themeColor, -- 273
		function() -- 273
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 273
				state.zoom = 100 -- 275
				state.viewportPanX = 0 -- 276
				state.viewportPanY = 0 -- 277
				state.previewDirty = true -- 278
			end -- 278
		end -- 273
	) -- 273
	ImGui.SameLine() -- 281
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 281
		zoomViewportFromCenter(state, 10) -- 282
	end -- 282
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 283
	ImGui.Separator() -- 284
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 285
	ImGui.SameLine() -- 286
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 287
end -- 227
local function drawVerticalSplitter(id, height, onDrag) -- 290
	ImGui.PushStyleColor( -- 291
		"Button", -- 291
		Color(4281612868), -- 291
		function() -- 291
			ImGui.PushStyleColor( -- 292
				"ButtonHovered", -- 292
				Color(4283259240), -- 292
				function() -- 292
					ImGui.PushStyleColor( -- 293
						"ButtonActive", -- 293
						Color(4294954035), -- 293
						function() -- 293
							ImGui.Button( -- 294
								"##" .. id, -- 294
								Vec2(8, height) -- 294
							) -- 294
						end -- 293
					) -- 293
				end -- 292
			) -- 292
		end -- 291
	) -- 291
	if ImGui.IsItemHovered() then -- 291
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 299
	end -- 299
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 299
		local delta = ImGui.GetMouseDragDelta(0) -- 302
		if delta.x ~= 0 then -- 302
			onDrag(delta.x) -- 304
			ImGui.ResetMouseDragDelta(0) -- 305
		end -- 305
	end -- 305
end -- 290
function ____exports.drawEditor(state) -- 310
	local size = App.visualSize -- 311
	local margin = 10 -- 312
	local nativeFooterSafeArea = 60 -- 313
	local windowWidth = math.max(360, size.width - margin * 2) -- 314
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 315
	ImGui.SetNextWindowPos( -- 316
		Vec2(margin, margin), -- 316
		"Always" -- 316
	) -- 316
	ImGui.SetNextWindowSize( -- 317
		Vec2(windowWidth, windowHeight), -- 317
		"Always" -- 317
	) -- 317
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 318
	ImGui.Begin( -- 319
		"Dora Visual Editor", -- 319
		mainWindowFlags, -- 319
		function() -- 319
			drawHeaderPanel(state, saveScene) -- 320
			local avail = ImGui.GetContentRegionAvail() -- 321
			local bottomHeight = math.max( -- 322
				72, -- 322
				math.min( -- 322
					state.bottomHeight, -- 322
					math.floor(avail.y * 0.28) -- 322
				) -- 322
			) -- 322
			if state.mode == "Script" then -- 322
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 324
				ImGui.PushStyleColor( -- 325
					"ChildBg", -- 325
					panelBg, -- 325
					function() -- 325
						ImGui.BeginChild( -- 326
							"ScriptWorkspaceRoot", -- 326
							Vec2(0, scriptHeight), -- 326
							{}, -- 326
							noScrollFlags, -- 326
							function() return drawScriptPanel(state, attachScriptToNode) end -- 326
						) -- 326
					end -- 325
				) -- 325
				ImGui.BeginChild( -- 328
					"ScriptConsoleDock", -- 328
					Vec2(0, bottomHeight), -- 328
					{}, -- 328
					noScrollFlags, -- 328
					function() return drawConsolePanel(state) end -- 328
				) -- 328
				return -- 329
			end -- 329
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 331
			local availableWidth = math.max(320, avail.x) -- 332
			local splitterWidth = 8 -- 333
			local compactLayout = availableWidth < 760 -- 334
			local minLeftWidth = compactLayout and 110 or 170 -- 335
			local minRightWidth = compactLayout and 130 or 220 -- 336
			local minCenterWidth = compactLayout and 80 or 180 -- 337
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 338
			if sideBudget <= minLeftWidth + minRightWidth then -- 338
				state.leftWidth = math.max( -- 340
					1, -- 340
					math.floor(sideBudget * 0.45) -- 340
				) -- 340
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 341
			else -- 341
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 343
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 344
				if state.leftWidth + state.rightWidth > sideBudget then -- 344
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 346
					state.leftWidth = math.max( -- 347
						minLeftWidth, -- 347
						math.floor(sideBudget * ratio) -- 347
					) -- 347
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 348
				end -- 348
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 350
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 351
			end -- 351
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 353
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 354
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 355
			local function clampPanelWidth(value, minValue, maxValue) -- 356
				local safeMax = math.max(1, maxValue) -- 357
				local safeMin = math.min(minValue, safeMax) -- 358
				return math.max( -- 359
					safeMin, -- 359
					math.min(value, safeMax) -- 359
				) -- 359
			end -- 356
			local function resizeSidePanels(deltaX, side) -- 361
				if side == "left" then -- 361
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 363
				else -- 363
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 365
				end -- 365
			end -- 361
			ImGui.BeginChild( -- 369
				"LeftDock", -- 369
				Vec2(state.leftWidth, mainHeight), -- 369
				{}, -- 369
				noScrollFlags, -- 369
				function() -- 369
					ImGui.BeginChild( -- 370
						"SceneDock", -- 370
						Vec2(0, leftTopHeight), -- 370
						{}, -- 370
						noScrollFlags, -- 370
						function() return drawSceneTreePanel(state) end -- 370
					) -- 370
					ImGui.BeginChild( -- 371
						"AssetDock", -- 371
						Vec2(0, leftBottomHeight), -- 371
						{}, -- 371
						noScrollFlags, -- 371
						function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 371
					) -- 371
				end -- 369
			) -- 369
			ImGui.SameLine(0, 0) -- 373
			drawVerticalSplitter( -- 374
				"LeftSplitter", -- 374
				mainHeight, -- 374
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 374
			) -- 374
			ImGui.SameLine(0, 0) -- 375
			ImGui.PushStyleColor( -- 376
				"ChildBg", -- 376
				transparent, -- 376
				function() -- 376
					ImGui.BeginChild( -- 377
						"CenterDock", -- 377
						Vec2(centerWidth, mainHeight), -- 377
						{}, -- 377
						noScrollFlags, -- 377
						function() -- 377
							if state.mode == "Script" then -- 377
								drawScriptPanel(state, attachScriptToNode) -- 378
							else -- 378
								drawViewport(state) -- 378
							end -- 378
						end -- 377
					) -- 377
				end -- 376
			) -- 376
			ImGui.SameLine(0, 0) -- 381
			drawVerticalSplitter( -- 382
				"RightSplitter", -- 382
				mainHeight, -- 382
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 382
			) -- 382
			ImGui.SameLine(0, 0) -- 383
			ImGui.BeginChild( -- 384
				"RightDock", -- 384
				Vec2(state.rightWidth, mainHeight), -- 384
				{}, -- 384
				noScrollFlags, -- 384
				function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 384
			) -- 384
			ImGui.BeginChild( -- 385
				"BottomConsoleDock", -- 385
				Vec2(0, bottomHeight), -- 385
				{}, -- 385
				noScrollFlags, -- 385
				function() return drawConsolePanel(state) end -- 385
			) -- 385
		end -- 319
	) -- 319
	drawGamePreviewWindow(state) -- 387
end -- 310
function ____exports.drawRuntimeError(message) -- 390
	local size = App.visualSize -- 391
	ImGui.SetNextWindowPos( -- 392
		Vec2(10, 10), -- 392
		"Always" -- 392
	) -- 392
	ImGui.SetNextWindowSize( -- 393
		Vec2( -- 393
			math.max(320, size.width - 20), -- 393
			math.max(220, size.height - 20) -- 393
		), -- 393
		"Always" -- 393
	) -- 393
	ImGui.Begin( -- 394
		"Dora Visual Editor Error", -- 394
		mainWindowFlags, -- 394
		function() -- 394
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 395
			ImGui.Separator() -- 396
			ImGui.TextWrapped(message or "unknown error") -- 397
		end -- 394
	) -- 394
end -- 390
return ____exports -- 390