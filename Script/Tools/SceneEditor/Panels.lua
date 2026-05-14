-- [ts]: Panels.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local json = ____Dora.json -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local mainWindowFlags = ____Theme.mainWindowFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local panelBg = ____Theme.panelBg -- 5
local transparent = ____Theme.transparent -- 5
local verticalScrollFlags = ____Theme.verticalScrollFlags -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addChildNode = ____Model.addChildNode -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local ____HeaderPanel = require("Script.Tools.SceneEditor.Panels.HeaderPanel") -- 7
local drawHeaderPanel = ____HeaderPanel.drawHeaderPanel -- 7
local ____ConsolePanel = require("Script.Tools.SceneEditor.Panels.ConsolePanel") -- 8
local drawConsolePanel = ____ConsolePanel.drawConsolePanel -- 8
local ____SceneTreePanel = require("Script.Tools.SceneEditor.Panels.SceneTreePanel") -- 9
local drawSceneTreePanel = ____SceneTreePanel.drawSceneTreePanel -- 9
local ____AssetsPanel = require("Script.Tools.SceneEditor.Panels.AssetsPanel") -- 10
local drawAssetsPanel = ____AssetsPanel.drawAssetsPanel -- 10
local ____InspectorPanel = require("Script.Tools.SceneEditor.Panels.InspectorPanel") -- 11
local drawInspectorPanel = ____InspectorPanel.drawInspectorPanel -- 11
local ____ScriptPanel = require("Script.Tools.SceneEditor.Panels.ScriptPanel") -- 12
local drawScriptPanel = ____ScriptPanel.drawScriptPanel -- 12
local openScriptForNode = ____ScriptPanel.openScriptForNode -- 12
local ____ViewportPanel = require("Script.Tools.SceneEditor.Panels.ViewportPanel") -- 13
local drawViewportPanel = ____ViewportPanel.drawViewportPanel -- 13
local ____Player = require("Script.Tools.SceneEditor.Player") -- 14
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 14
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 22
local function workspacePath(path) -- 23
	return SceneModel.workspacePath(path) -- 23
end -- 23
local function sceneSaveFile() -- 25
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 26
end -- 25
local function writeSceneFile(state) -- 29
	Content:mkdir(workspacePath(".dora")) -- 30
	local data = { -- 31
		version = 1, -- 32
		gameWidth = math.floor(state.gameWidth), -- 33
		gameHeight = math.floor(state.gameHeight), -- 34
		gameScript = state.gameScript, -- 35
		nodes = {} -- 36
	} -- 36
	for ____, id in ipairs(state.order) do -- 38
		local node = state.nodes[id] -- 39
		if node ~= nil then -- 39
			local ____data_nodes_0 = data.nodes -- 39
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 41
				id = node.id, -- 42
				kind = node.kind, -- 43
				name = node.name, -- 44
				parentId = node.parentId, -- 45
				x = node.x, -- 46
				y = node.y, -- 47
				scaleX = node.scaleX, -- 48
				scaleY = node.scaleY, -- 49
				rotation = node.rotation, -- 50
				visible = node.visible, -- 51
				texture = node.texture, -- 52
				text = node.text, -- 53
				script = node.script, -- 54
				followTargetId = node.followTargetId, -- 55
				followOffsetX = node.followOffsetX, -- 56
				followOffsetY = node.followOffsetY -- 57
			} -- 57
		end -- 57
	end -- 57
	local text = json.encode(data) -- 61
	local file = sceneSaveFile() -- 62
	if text ~= nil and Content:save(file, text) then -- 62
		return file -- 63
	end -- 63
	return nil -- 64
end -- 29
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
	state.previewDirty = true -- 81
	state.playDirty = true -- 82
	local sceneFile = writeSceneFile(state) -- 83
	if sceneFile == nil then -- 83
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 85
	else -- 85
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 87
	end -- 87
	pushConsole(state, state.status) -- 89
end -- 77
local function bindTextureToSprite(state, node, texture) -- 92
	node.texture = texture -- 93
	node.textureBuffer.text = texture -- 94
	state.selectedAsset = texture -- 95
	state.previewDirty = true -- 96
	state.playDirty = true -- 97
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 98
	pushConsole(state, state.status) -- 99
end -- 92
local function createSpriteFromTexture(state, texture) -- 102
	addChildNode(state, "Sprite") -- 103
	local node = state.nodes[state.selectedId] -- 104
	if node ~= nil and node.kind == "Sprite" then -- 104
		bindTextureToSprite(state, node, texture) -- 106
	end -- 106
end -- 102
local function openNodeScriptInEditor(state, node) -- 110
	openScriptForNode(state, node, attachScriptToNode) -- 111
end -- 110
local function drawVerticalSplitter(id, height, onDrag) -- 114
	local hitWidth = 14 -- 115
	ImGui.PushStyleColor( -- 116
		"Button", -- 116
		Color(1714698820), -- 116
		function() -- 116
			ImGui.PushStyleColor( -- 117
				"ButtonHovered", -- 117
				Color(2857195880), -- 117
				function() -- 117
					ImGui.PushStyleColor( -- 118
						"ButtonActive", -- 118
						Color(4294954035), -- 118
						function() -- 118
							ImGui.Button( -- 119
								"##" .. id, -- 119
								Vec2(hitWidth, height) -- 119
							) -- 119
						end -- 118
					) -- 118
				end -- 117
			) -- 117
		end -- 116
	) -- 116
	if ImGui.IsItemHovered() then -- 116
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 124
	end -- 124
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 124
		local delta = ImGui.GetMouseDragDelta(0) -- 127
		if math.abs(delta.x) >= 1 then -- 127
			onDrag(delta.x) -- 129
			ImGui.ResetMouseDragDelta(0) -- 130
		end -- 130
	end -- 130
end -- 114
function ____exports.drawEditor(state) -- 135
	local size = App.visualSize -- 136
	local margin = 10 -- 137
	local nativeFooterSafeArea = 60 -- 138
	local windowWidth = math.max(360, size.width - margin * 2) -- 139
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 140
	ImGui.SetNextWindowPos( -- 141
		Vec2(margin, margin), -- 141
		"Always" -- 141
	) -- 141
	ImGui.SetNextWindowSize( -- 142
		Vec2(windowWidth, windowHeight), -- 142
		"Always" -- 142
	) -- 142
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 145
	ImGui.Begin( -- 146
		"Dora Visual Editor", -- 146
		mainWindowFlags, -- 146
		function() -- 146
			drawHeaderPanel(state, saveScene) -- 147
			local avail = ImGui.GetContentRegionAvail() -- 148
			local bottomHeight = math.max( -- 149
				72, -- 149
				math.min( -- 149
					state.bottomHeight, -- 149
					math.floor(avail.y * 0.28) -- 149
				) -- 149
			) -- 149
			if state.mode == "Script" then -- 149
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 151
				ImGui.PushStyleColor( -- 152
					"ChildBg", -- 152
					panelBg, -- 152
					function() -- 152
						ImGui.BeginChild( -- 153
							"ScriptWorkspaceRoot", -- 153
							Vec2(0, scriptHeight), -- 153
							{}, -- 153
							noScrollFlags, -- 153
							function() return drawScriptPanel(state, attachScriptToNode) end -- 153
						) -- 153
					end -- 152
				) -- 152
				ImGui.BeginChild( -- 155
					"ScriptConsoleDock", -- 155
					Vec2(0, bottomHeight), -- 155
					{}, -- 155
					noScrollFlags, -- 155
					function() return drawConsolePanel(state) end -- 155
				) -- 155
				return -- 156
			end -- 156
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 158
			local availableWidth = math.max(320, avail.x) -- 159
			local splitterWidth = 14 -- 160
			local compactLayout = availableWidth < 760 -- 161
			local minLeftWidth = compactLayout and 92 or 132 -- 162
			local minRightWidth = compactLayout and 120 or 180 -- 163
			local minCenterWidth = compactLayout and 80 or 120 -- 164
			local sideBudget = math.max(0, availableWidth - minCenterWidth) -- 165
			if sideBudget <= minLeftWidth + minRightWidth then -- 165
				state.leftWidth = math.max( -- 167
					1, -- 167
					math.floor(sideBudget * 0.45) -- 167
				) -- 167
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 168
			else -- 168
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 170
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 171
				if state.leftWidth + state.rightWidth > sideBudget then -- 171
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 173
					state.leftWidth = math.max( -- 174
						minLeftWidth, -- 174
						math.floor(sideBudget * ratio) -- 174
					) -- 174
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 175
				end -- 175
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 177
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 178
			end -- 178
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth) -- 180
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 181
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 182
			local function clampPanelWidth(value, minValue, maxValue) -- 183
				local safeMax = math.max(1, maxValue) -- 184
				local safeMin = math.min(minValue, safeMax) -- 185
				return math.max( -- 186
					safeMin, -- 186
					math.min(value, safeMax) -- 186
				) -- 186
			end -- 183
			local function resizeSidePanels(deltaX, side) -- 188
				if side == "left" then -- 188
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - minCenterWidth) -- 190
				else -- 190
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - minCenterWidth) -- 192
				end -- 192
			end -- 188
			ImGui.PushStyleColor( -- 196
				"ChildBg", -- 196
				panelBg, -- 196
				function() -- 196
					ImGui.BeginChild( -- 197
						"LeftDock", -- 197
						Vec2(state.leftWidth, mainHeight), -- 197
						{}, -- 197
						noScrollFlags, -- 197
						function() -- 197
							local contentWidth = math.max(1, state.leftWidth - splitterWidth) -- 198
							ImGui.BeginChild( -- 199
								"LeftDockContent", -- 199
								Vec2(contentWidth, mainHeight), -- 199
								{}, -- 199
								noScrollFlags, -- 199
								function() -- 199
									ImGui.BeginChild( -- 200
										"SceneDock", -- 200
										Vec2(0, leftTopHeight), -- 200
										{}, -- 200
										noScrollFlags, -- 200
										function() return drawSceneTreePanel(state) end -- 200
									) -- 200
									ImGui.BeginChild( -- 201
										"AssetDock", -- 201
										Vec2(0, leftBottomHeight), -- 201
										{}, -- 201
										noScrollFlags, -- 201
										function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 201
									) -- 201
								end -- 199
							) -- 199
							ImGui.SameLine(0, 0) -- 203
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 204
							drawVerticalSplitter( -- 205
								"LeftSplitter", -- 205
								mainHeight, -- 205
								function(deltaX) return resizeSidePanels(deltaX, "left") end -- 205
							) -- 205
						end -- 197
					) -- 197
				end -- 196
			) -- 196
			ImGui.SameLine(0, 0) -- 208
			ImGui.PushStyleColor( -- 209
				"ChildBg", -- 209
				transparent, -- 209
				function() -- 209
					ImGui.BeginChild( -- 210
						"CenterDock", -- 210
						Vec2(centerWidth, mainHeight), -- 210
						{}, -- 210
						noScrollFlags, -- 210
						function() -- 210
							if state.mode == "Script" then -- 210
								drawScriptPanel(state, attachScriptToNode) -- 211
							else -- 211
								drawViewportPanel(state) -- 211
							end -- 211
						end -- 210
					) -- 210
				end -- 209
			) -- 209
			ImGui.SameLine(0, 0) -- 214
			ImGui.PushStyleColor( -- 215
				"ChildBg", -- 215
				panelBg, -- 215
				function() -- 215
					ImGui.BeginChild( -- 216
						"RightDock", -- 216
						Vec2(state.rightWidth, mainHeight), -- 216
						{}, -- 216
						verticalScrollFlags, -- 216
						function() -- 216
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 217
							drawVerticalSplitter( -- 218
								"RightSplitter", -- 218
								mainHeight, -- 218
								function(deltaX) return resizeSidePanels(deltaX, "right") end -- 218
							) -- 218
							ImGui.SameLine(0, 0) -- 219
							ImGui.BeginChild( -- 220
								"RightDockContent", -- 220
								Vec2( -- 220
									math.max(1, state.rightWidth - splitterWidth), -- 220
									mainHeight -- 220
								), -- 220
								{}, -- 220
								verticalScrollFlags, -- 220
								function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 220
							) -- 220
						end -- 216
					) -- 216
				end -- 215
			) -- 215
			ImGui.PushStyleColor( -- 223
				"ChildBg", -- 223
				panelBg, -- 223
				function() -- 223
					ImGui.BeginChild( -- 224
						"BottomConsoleDock", -- 224
						Vec2(0, bottomHeight), -- 224
						{}, -- 224
						noScrollFlags, -- 224
						function() return drawConsolePanel(state) end -- 224
					) -- 224
				end -- 223
			) -- 223
		end -- 146
	) -- 146
	drawGamePreviewWindow(state) -- 227
end -- 135
function ____exports.drawRuntimeError(message) -- 230
	local size = App.visualSize -- 231
	ImGui.SetNextWindowPos( -- 232
		Vec2(10, 10), -- 232
		"Always" -- 232
	) -- 232
	ImGui.SetNextWindowSize( -- 233
		Vec2( -- 233
			math.max(320, size.width - 20), -- 233
			math.max(220, size.height - 20) -- 233
		), -- 233
		"Always" -- 233
	) -- 233
	ImGui.Begin( -- 234
		"Dora Visual Editor Error", -- 234
		mainWindowFlags, -- 234
		function() -- 234
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 235
			ImGui.Separator() -- 236
			ImGui.TextWrapped(message or "unknown error") -- 237
		end -- 234
	) -- 234
end -- 230
return ____exports -- 230