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
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addChildNode = ____Model.addChildNode -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local ____Player = require("Script.Tools.SceneEditor.Player") -- 7
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 7
local ____HeaderPanel = require("Script.Tools.SceneEditor.Panels.HeaderPanel") -- 8
local drawHeaderPanel = ____HeaderPanel.drawHeaderPanel -- 8
local ____ConsolePanel = require("Script.Tools.SceneEditor.Panels.ConsolePanel") -- 9
local drawConsolePanel = ____ConsolePanel.drawConsolePanel -- 9
local ____SceneTreePanel = require("Script.Tools.SceneEditor.Panels.SceneTreePanel") -- 10
local drawSceneTreePanel = ____SceneTreePanel.drawSceneTreePanel -- 10
local ____AssetsPanel = require("Script.Tools.SceneEditor.Panels.AssetsPanel") -- 11
local drawAssetsPanel = ____AssetsPanel.drawAssetsPanel -- 11
local ____InspectorPanel = require("Script.Tools.SceneEditor.Panels.InspectorPanel") -- 12
local drawInspectorPanel = ____InspectorPanel.drawInspectorPanel -- 12
local ____ScriptPanel = require("Script.Tools.SceneEditor.Panels.ScriptPanel") -- 13
local drawScriptPanel = ____ScriptPanel.drawScriptPanel -- 13
local openScriptForNode = ____ScriptPanel.openScriptForNode -- 13
local ____ViewportPanel = require("Script.Tools.SceneEditor.Panels.ViewportPanel") -- 14
local drawViewportPanel = ____ViewportPanel.drawViewportPanel -- 14
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 18
local function workspacePath(path) -- 19
	return SceneModel.workspacePath(path) -- 19
end -- 19
local function sceneSaveFile() -- 21
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 22
end -- 21
local function writeSceneFile(state) -- 25
	Content:mkdir(workspacePath(".dora")) -- 26
	local data = { -- 27
		version = 1, -- 28
		gameWidth = math.floor(state.gameWidth or 960), -- 29
		gameHeight = math.floor(state.gameHeight or 540), -- 30
		nodes = {} -- 31
	} -- 31
	for ____, id in ipairs(state.order) do -- 33
		local node = state.nodes[id] -- 34
		if node ~= nil then -- 34
			local ____data_nodes_0 = data.nodes -- 34
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 36
				id = node.id, -- 37
				kind = node.kind, -- 38
				name = node.name, -- 39
				parentId = node.parentId, -- 40
				x = node.x, -- 41
				y = node.y, -- 42
				scaleX = node.scaleX, -- 43
				scaleY = node.scaleY, -- 44
				rotation = node.rotation, -- 45
				visible = node.visible, -- 46
				texture = node.texture, -- 47
				text = node.text, -- 48
				script = node.script -- 49
			} -- 49
		end -- 49
	end -- 49
	local text = json.encode(data) -- 53
	local file = sceneSaveFile() -- 54
	if text ~= nil and Content:save(file, text) then -- 54
		return file -- 55
	end -- 55
	return nil -- 56
end -- 25
local function saveScene(state) -- 59
	local file = writeSceneFile(state) -- 60
	if file ~= nil then -- 60
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 62
	else -- 62
		state.status = zh and "保存失败" or "Save failed" -- 64
	end -- 64
	pushConsole(state, state.status) -- 66
end -- 59
local function attachScriptToNode(state, node, scriptPath, message) -- 69
	node.script = scriptPath -- 70
	node.scriptBuffer.text = scriptPath -- 71
	state.activeScriptNodeId = node.id -- 72
	state.previewDirty = true -- 73
	state.playDirty = true -- 74
	local sceneFile = writeSceneFile(state) -- 75
	if sceneFile == nil then -- 75
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 77
	else -- 77
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 79
	end -- 79
	pushConsole(state, state.status) -- 81
end -- 69
local function bindTextureToSprite(state, node, texture) -- 84
	node.texture = texture -- 85
	node.textureBuffer.text = texture -- 86
	state.selectedAsset = texture -- 87
	state.previewDirty = true -- 88
	state.playDirty = true -- 89
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 90
	pushConsole(state, state.status) -- 91
end -- 84
local function createSpriteFromTexture(state, texture) -- 94
	addChildNode(state, "Sprite") -- 95
	local node = state.nodes[state.selectedId] -- 96
	if node ~= nil and node.kind == "Sprite" then -- 96
		bindTextureToSprite(state, node, texture) -- 98
	end -- 98
end -- 94
local function openNodeScriptInEditor(state, node) -- 102
	openScriptForNode(state, node, attachScriptToNode) -- 103
end -- 102
local function drawVerticalSplitter(id, height, onDrag) -- 106
	ImGui.PushStyleColor( -- 107
		"Button", -- 107
		Color(4281612868), -- 107
		function() -- 107
			ImGui.PushStyleColor( -- 108
				"ButtonHovered", -- 108
				Color(4283259240), -- 108
				function() -- 108
					ImGui.PushStyleColor( -- 109
						"ButtonActive", -- 109
						Color(4294954035), -- 109
						function() -- 109
							ImGui.Button( -- 110
								"##" .. id, -- 110
								Vec2(8, height) -- 110
							) -- 110
						end -- 109
					) -- 109
				end -- 108
			) -- 108
		end -- 107
	) -- 107
	if ImGui.IsItemHovered() then -- 107
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 115
	end -- 115
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 115
		local delta = ImGui.GetMouseDragDelta(0) -- 118
		if delta.x ~= 0 then -- 118
			onDrag(delta.x) -- 120
			ImGui.ResetMouseDragDelta(0) -- 121
		end -- 121
	end -- 121
end -- 106
function ____exports.drawEditor(state) -- 126
	local size = App.visualSize -- 127
	local margin = 10 -- 128
	local nativeFooterSafeArea = 60 -- 129
	local windowWidth = math.max(360, size.width - margin * 2) -- 130
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 131
	ImGui.SetNextWindowPos( -- 132
		Vec2(margin, margin), -- 132
		"Always" -- 132
	) -- 132
	ImGui.SetNextWindowSize( -- 133
		Vec2(windowWidth, windowHeight), -- 133
		"Always" -- 133
	) -- 133
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 136
	ImGui.Begin( -- 137
		"Dora Visual Editor", -- 137
		mainWindowFlags, -- 137
		function() -- 137
			drawHeaderPanel(state, saveScene) -- 138
			local avail = ImGui.GetContentRegionAvail() -- 139
			local bottomHeight = math.max( -- 140
				72, -- 140
				math.min( -- 140
					state.bottomHeight, -- 140
					math.floor(avail.y * 0.28) -- 140
				) -- 140
			) -- 140
			if state.mode == "Script" then -- 140
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 142
				ImGui.PushStyleColor( -- 143
					"ChildBg", -- 143
					panelBg, -- 143
					function() -- 143
						ImGui.BeginChild( -- 144
							"ScriptWorkspaceRoot", -- 144
							Vec2(0, scriptHeight), -- 144
							{}, -- 144
							noScrollFlags, -- 144
							function() return drawScriptPanel(state, attachScriptToNode) end -- 144
						) -- 144
					end -- 143
				) -- 143
				ImGui.BeginChild( -- 146
					"ScriptConsoleDock", -- 146
					Vec2(0, bottomHeight), -- 146
					{}, -- 146
					noScrollFlags, -- 146
					function() return drawConsolePanel(state) end -- 146
				) -- 146
				return -- 147
			end -- 147
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 149
			local availableWidth = math.max(320, avail.x) -- 150
			local splitterWidth = 8 -- 151
			local compactLayout = availableWidth < 760 -- 152
			local minLeftWidth = compactLayout and 110 or 170 -- 153
			local minRightWidth = compactLayout and 130 or 220 -- 154
			local minCenterWidth = compactLayout and 80 or 180 -- 155
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 156
			if sideBudget <= minLeftWidth + minRightWidth then -- 156
				state.leftWidth = math.max( -- 158
					1, -- 158
					math.floor(sideBudget * 0.45) -- 158
				) -- 158
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 159
			else -- 159
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 161
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 162
				if state.leftWidth + state.rightWidth > sideBudget then -- 162
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 164
					state.leftWidth = math.max( -- 165
						minLeftWidth, -- 165
						math.floor(sideBudget * ratio) -- 165
					) -- 165
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 166
				end -- 166
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 168
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 169
			end -- 169
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 171
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 172
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 173
			local function clampPanelWidth(value, minValue, maxValue) -- 174
				local safeMax = math.max(1, maxValue) -- 175
				local safeMin = math.min(minValue, safeMax) -- 176
				return math.max( -- 177
					safeMin, -- 177
					math.min(value, safeMax) -- 177
				) -- 177
			end -- 174
			local function resizeSidePanels(deltaX, side) -- 179
				if side == "left" then -- 179
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 181
				else -- 181
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 183
				end -- 183
			end -- 179
			ImGui.PushStyleColor( -- 187
				"ChildBg", -- 187
				panelBg, -- 187
				function() -- 187
					ImGui.BeginChild( -- 188
						"LeftDock", -- 188
						Vec2(state.leftWidth, mainHeight), -- 188
						{}, -- 188
						noScrollFlags, -- 188
						function() -- 188
							ImGui.BeginChild( -- 189
								"SceneDock", -- 189
								Vec2(0, leftTopHeight), -- 189
								{}, -- 189
								noScrollFlags, -- 189
								function() return drawSceneTreePanel(state) end -- 189
							) -- 189
							ImGui.BeginChild( -- 190
								"AssetDock", -- 190
								Vec2(0, leftBottomHeight), -- 190
								{}, -- 190
								noScrollFlags, -- 190
								function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 190
							) -- 190
						end -- 188
					) -- 188
				end -- 187
			) -- 187
			ImGui.SameLine(0, 0) -- 193
			drawVerticalSplitter( -- 194
				"LeftSplitter", -- 194
				mainHeight, -- 194
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 194
			) -- 194
			ImGui.SameLine(0, 0) -- 195
			ImGui.PushStyleColor( -- 196
				"ChildBg", -- 196
				transparent, -- 196
				function() -- 196
					ImGui.BeginChild( -- 197
						"CenterDock", -- 197
						Vec2(centerWidth, mainHeight), -- 197
						{}, -- 197
						noScrollFlags, -- 197
						function() -- 197
							if state.mode == "Script" then -- 197
								drawScriptPanel(state, attachScriptToNode) -- 198
							else -- 198
								drawViewportPanel(state) -- 198
							end -- 198
						end -- 197
					) -- 197
				end -- 196
			) -- 196
			ImGui.SameLine(0, 0) -- 201
			drawVerticalSplitter( -- 202
				"RightSplitter", -- 202
				mainHeight, -- 202
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 202
			) -- 202
			ImGui.SameLine(0, 0) -- 203
			ImGui.PushStyleColor( -- 204
				"ChildBg", -- 204
				panelBg, -- 204
				function() -- 204
					ImGui.BeginChild( -- 205
						"RightDock", -- 205
						Vec2(state.rightWidth, mainHeight), -- 205
						{}, -- 205
						noScrollFlags, -- 205
						function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 205
					) -- 205
				end -- 204
			) -- 204
			ImGui.PushStyleColor( -- 207
				"ChildBg", -- 207
				panelBg, -- 207
				function() -- 207
					ImGui.BeginChild( -- 208
						"BottomConsoleDock", -- 208
						Vec2(0, bottomHeight), -- 208
						{}, -- 208
						noScrollFlags, -- 208
						function() return drawConsolePanel(state) end -- 208
					) -- 208
				end -- 207
			) -- 207
		end -- 137
	) -- 137
	drawGamePreviewWindow(state) -- 211
end -- 126
function ____exports.drawRuntimeError(message) -- 214
	local size = App.visualSize -- 215
	ImGui.SetNextWindowPos( -- 216
		Vec2(10, 10), -- 216
		"Always" -- 216
	) -- 216
	ImGui.SetNextWindowSize( -- 217
		Vec2( -- 217
			math.max(320, size.width - 20), -- 217
			math.max(220, size.height - 20) -- 217
		), -- 217
		"Always" -- 217
	) -- 217
	ImGui.Begin( -- 218
		"Dora Visual Editor Error", -- 218
		mainWindowFlags, -- 218
		function() -- 218
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 219
			ImGui.Separator() -- 220
			ImGui.TextWrapped(message or "unknown error") -- 221
		end -- 218
	) -- 218
end -- 214
return ____exports -- 214