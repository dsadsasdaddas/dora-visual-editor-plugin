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
	return SceneModel:workspacePath(path) -- 23
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
	ImGui.PushStyleColor( -- 115
		"Button", -- 115
		Color(4281612868), -- 115
		function() -- 115
			ImGui.PushStyleColor( -- 116
				"ButtonHovered", -- 116
				Color(4283259240), -- 116
				function() -- 116
					ImGui.PushStyleColor( -- 117
						"ButtonActive", -- 117
						Color(4294954035), -- 117
						function() -- 117
							ImGui.Button( -- 118
								"##" .. id, -- 118
								Vec2(8, height) -- 118
							) -- 118
						end -- 117
					) -- 117
				end -- 116
			) -- 116
		end -- 115
	) -- 115
	if ImGui.IsItemHovered() then -- 115
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 123
	end -- 123
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 123
		local delta = ImGui.GetMouseDragDelta(0) -- 126
		if delta.x ~= 0 then -- 126
			onDrag(delta.x) -- 128
			ImGui.ResetMouseDragDelta(0) -- 129
		end -- 129
	end -- 129
end -- 114
function ____exports.drawEditor(state) -- 134
	local size = App.visualSize -- 135
	local margin = 10 -- 136
	local nativeFooterSafeArea = 60 -- 137
	local windowWidth = math.max(360, size.width - margin * 2) -- 138
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 139
	ImGui.SetNextWindowPos( -- 140
		Vec2(margin, margin), -- 140
		"Always" -- 140
	) -- 140
	ImGui.SetNextWindowSize( -- 141
		Vec2(windowWidth, windowHeight), -- 141
		"Always" -- 141
	) -- 141
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 144
	ImGui.Begin( -- 145
		"Dora Visual Editor", -- 145
		mainWindowFlags, -- 145
		function() -- 145
			drawHeaderPanel(state, saveScene) -- 146
			local avail = ImGui.GetContentRegionAvail() -- 147
			local bottomHeight = math.max( -- 148
				72, -- 148
				math.min( -- 148
					state.bottomHeight, -- 148
					math.floor(avail.y * 0.28) -- 148
				) -- 148
			) -- 148
			if state.mode == "Script" then -- 148
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 150
				ImGui.PushStyleColor( -- 151
					"ChildBg", -- 151
					panelBg, -- 151
					function() -- 151
						ImGui.BeginChild( -- 152
							"ScriptWorkspaceRoot", -- 152
							Vec2(0, scriptHeight), -- 152
							{}, -- 152
							noScrollFlags, -- 152
							function() return drawScriptPanel(state, attachScriptToNode) end -- 152
						) -- 152
					end -- 151
				) -- 151
				ImGui.BeginChild( -- 154
					"ScriptConsoleDock", -- 154
					Vec2(0, bottomHeight), -- 154
					{}, -- 154
					noScrollFlags, -- 154
					function() return drawConsolePanel(state) end -- 154
				) -- 154
				return -- 155
			end -- 155
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 157
			local availableWidth = math.max(320, avail.x) -- 158
			local splitterWidth = 8 -- 159
			local compactLayout = availableWidth < 760 -- 160
			local minLeftWidth = compactLayout and 110 or 170 -- 161
			local minRightWidth = compactLayout and 130 or 220 -- 162
			local minCenterWidth = compactLayout and 80 or 180 -- 163
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 164
			if sideBudget <= minLeftWidth + minRightWidth then -- 164
				state.leftWidth = math.max( -- 166
					1, -- 166
					math.floor(sideBudget * 0.45) -- 166
				) -- 166
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 167
			else -- 167
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 169
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 170
				if state.leftWidth + state.rightWidth > sideBudget then -- 170
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 172
					state.leftWidth = math.max( -- 173
						minLeftWidth, -- 173
						math.floor(sideBudget * ratio) -- 173
					) -- 173
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 174
				end -- 174
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 176
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 177
			end -- 177
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 179
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 180
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 181
			local function clampPanelWidth(value, minValue, maxValue) -- 182
				local safeMax = math.max(1, maxValue) -- 183
				local safeMin = math.min(minValue, safeMax) -- 184
				return math.max( -- 185
					safeMin, -- 185
					math.min(value, safeMax) -- 185
				) -- 185
			end -- 182
			local function resizeSidePanels(deltaX, side) -- 187
				if side == "left" then -- 187
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 189
				else -- 189
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 191
				end -- 191
			end -- 187
			ImGui.PushStyleColor( -- 195
				"ChildBg", -- 195
				panelBg, -- 195
				function() -- 195
					ImGui.BeginChild( -- 196
						"LeftDock", -- 196
						Vec2(state.leftWidth, mainHeight), -- 196
						{}, -- 196
						noScrollFlags, -- 196
						function() -- 196
							ImGui.BeginChild( -- 197
								"SceneDock", -- 197
								Vec2(0, leftTopHeight), -- 197
								{}, -- 197
								noScrollFlags, -- 197
								function() return drawSceneTreePanel(state) end -- 197
							) -- 197
							ImGui.BeginChild( -- 198
								"AssetDock", -- 198
								Vec2(0, leftBottomHeight), -- 198
								{}, -- 198
								noScrollFlags, -- 198
								function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 198
							) -- 198
						end -- 196
					) -- 196
				end -- 195
			) -- 195
			ImGui.SameLine(0, 0) -- 201
			drawVerticalSplitter( -- 202
				"LeftSplitter", -- 202
				mainHeight, -- 202
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 202
			) -- 202
			ImGui.SameLine(0, 0) -- 203
			ImGui.PushStyleColor( -- 204
				"ChildBg", -- 204
				transparent, -- 204
				function() -- 204
					ImGui.BeginChild( -- 205
						"CenterDock", -- 205
						Vec2(centerWidth, mainHeight), -- 205
						{}, -- 205
						noScrollFlags, -- 205
						function() -- 205
							if state.mode == "Script" then -- 205
								drawScriptPanel(state, attachScriptToNode) -- 206
							else -- 206
								drawViewportPanel(state) -- 206
							end -- 206
						end -- 205
					) -- 205
				end -- 204
			) -- 204
			ImGui.SameLine(0, 0) -- 209
			drawVerticalSplitter( -- 210
				"RightSplitter", -- 210
				mainHeight, -- 210
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 210
			) -- 210
			ImGui.SameLine(0, 0) -- 211
			ImGui.PushStyleColor( -- 212
				"ChildBg", -- 212
				panelBg, -- 212
				function() -- 212
					ImGui.BeginChild( -- 213
						"RightDock", -- 213
						Vec2(state.rightWidth, mainHeight), -- 213
						{}, -- 213
						verticalScrollFlags, -- 213
						function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 213
					) -- 213
				end -- 212
			) -- 212
			ImGui.PushStyleColor( -- 215
				"ChildBg", -- 215
				panelBg, -- 215
				function() -- 215
					ImGui.BeginChild( -- 216
						"BottomConsoleDock", -- 216
						Vec2(0, bottomHeight), -- 216
						{}, -- 216
						noScrollFlags, -- 216
						function() return drawConsolePanel(state) end -- 216
					) -- 216
				end -- 215
			) -- 215
		end -- 145
	) -- 145
	drawGamePreviewWindow(state) -- 219
end -- 134
function ____exports.drawRuntimeError(message) -- 222
	local size = App.visualSize -- 223
	ImGui.SetNextWindowPos( -- 224
		Vec2(10, 10), -- 224
		"Always" -- 224
	) -- 224
	ImGui.SetNextWindowSize( -- 225
		Vec2( -- 225
			math.max(320, size.width - 20), -- 225
			math.max(220, size.height - 20) -- 225
		), -- 225
		"Always" -- 225
	) -- 225
	ImGui.Begin( -- 226
		"Dora Visual Editor Error", -- 226
		mainWindowFlags, -- 226
		function() -- 226
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 227
			ImGui.Separator() -- 228
			ImGui.TextWrapped(message or "unknown error") -- 229
		end -- 226
	) -- 226
end -- 222
return ____exports -- 222