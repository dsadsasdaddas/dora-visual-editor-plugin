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
		gameWidth = math.floor(state.gameWidth), -- 29
		gameHeight = math.floor(state.gameHeight), -- 30
		gameScript = state.gameScript, -- 31
		nodes = {} -- 32
	} -- 32
	for ____, id in ipairs(state.order) do -- 34
		local node = state.nodes[id] -- 35
		if node ~= nil then -- 35
			local ____data_nodes_0 = data.nodes -- 35
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 37
				id = node.id, -- 38
				kind = node.kind, -- 39
				name = node.name, -- 40
				parentId = node.parentId, -- 41
				x = node.x, -- 42
				y = node.y, -- 43
				scaleX = node.scaleX, -- 44
				scaleY = node.scaleY, -- 45
				rotation = node.rotation, -- 46
				visible = node.visible, -- 47
				texture = node.texture, -- 48
				text = node.text, -- 49
				script = node.script, -- 50
				followTargetId = node.followTargetId, -- 51
				followOffsetX = node.followOffsetX, -- 52
				followOffsetY = node.followOffsetY -- 53
			} -- 53
		end -- 53
	end -- 53
	local text = json.encode(data) -- 57
	local file = sceneSaveFile() -- 58
	if text ~= nil and Content:save(file, text) then -- 58
		return file -- 59
	end -- 59
	return nil -- 60
end -- 25
local function saveScene(state) -- 63
	local file = writeSceneFile(state) -- 64
	if file ~= nil then -- 64
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 66
	else -- 66
		state.status = zh and "保存失败" or "Save failed" -- 68
	end -- 68
	pushConsole(state, state.status) -- 70
end -- 63
local function attachScriptToNode(state, node, scriptPath, message) -- 73
	node.script = scriptPath -- 74
	node.scriptBuffer.text = scriptPath -- 75
	state.activeScriptNodeId = node.id -- 76
	state.previewDirty = true -- 77
	state.playDirty = true -- 78
	local sceneFile = writeSceneFile(state) -- 79
	if sceneFile == nil then -- 79
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 81
	else -- 81
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 83
	end -- 83
	pushConsole(state, state.status) -- 85
end -- 73
local function bindTextureToSprite(state, node, texture) -- 88
	node.texture = texture -- 89
	node.textureBuffer.text = texture -- 90
	state.selectedAsset = texture -- 91
	state.previewDirty = true -- 92
	state.playDirty = true -- 93
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 94
	pushConsole(state, state.status) -- 95
end -- 88
local function createSpriteFromTexture(state, texture) -- 98
	addChildNode(state, "Sprite") -- 99
	local node = state.nodes[state.selectedId] -- 100
	if node ~= nil and node.kind == "Sprite" then -- 100
		bindTextureToSprite(state, node, texture) -- 102
	end -- 102
end -- 98
local function openNodeScriptInEditor(state, node) -- 106
	openScriptForNode(state, node, attachScriptToNode) -- 107
end -- 106
local function drawVerticalSplitter(id, height, onDrag) -- 110
	ImGui.PushStyleColor( -- 111
		"Button", -- 111
		Color(4281612868), -- 111
		function() -- 111
			ImGui.PushStyleColor( -- 112
				"ButtonHovered", -- 112
				Color(4283259240), -- 112
				function() -- 112
					ImGui.PushStyleColor( -- 113
						"ButtonActive", -- 113
						Color(4294954035), -- 113
						function() -- 113
							ImGui.Button( -- 114
								"##" .. id, -- 114
								Vec2(8, height) -- 114
							) -- 114
						end -- 113
					) -- 113
				end -- 112
			) -- 112
		end -- 111
	) -- 111
	if ImGui.IsItemHovered() then -- 111
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 119
	end -- 119
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 119
		local delta = ImGui.GetMouseDragDelta(0) -- 122
		if delta.x ~= 0 then -- 122
			onDrag(delta.x) -- 124
			ImGui.ResetMouseDragDelta(0) -- 125
		end -- 125
	end -- 125
end -- 110
function ____exports.drawEditor(state) -- 130
	local size = App.visualSize -- 131
	local margin = 10 -- 132
	local nativeFooterSafeArea = 60 -- 133
	local windowWidth = math.max(360, size.width - margin * 2) -- 134
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 135
	ImGui.SetNextWindowPos( -- 136
		Vec2(margin, margin), -- 136
		"Always" -- 136
	) -- 136
	ImGui.SetNextWindowSize( -- 137
		Vec2(windowWidth, windowHeight), -- 137
		"Always" -- 137
	) -- 137
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 140
	ImGui.Begin( -- 141
		"Dora Visual Editor", -- 141
		mainWindowFlags, -- 141
		function() -- 141
			drawHeaderPanel(state, saveScene) -- 142
			local avail = ImGui.GetContentRegionAvail() -- 143
			local bottomHeight = math.max( -- 144
				72, -- 144
				math.min( -- 144
					state.bottomHeight, -- 144
					math.floor(avail.y * 0.28) -- 144
				) -- 144
			) -- 144
			if state.mode == "Script" then -- 144
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 146
				ImGui.PushStyleColor( -- 147
					"ChildBg", -- 147
					panelBg, -- 147
					function() -- 147
						ImGui.BeginChild( -- 148
							"ScriptWorkspaceRoot", -- 148
							Vec2(0, scriptHeight), -- 148
							{}, -- 148
							noScrollFlags, -- 148
							function() return drawScriptPanel(state, attachScriptToNode) end -- 148
						) -- 148
					end -- 147
				) -- 147
				ImGui.BeginChild( -- 150
					"ScriptConsoleDock", -- 150
					Vec2(0, bottomHeight), -- 150
					{}, -- 150
					noScrollFlags, -- 150
					function() return drawConsolePanel(state) end -- 150
				) -- 150
				return -- 151
			end -- 151
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 153
			local availableWidth = math.max(320, avail.x) -- 154
			local splitterWidth = 8 -- 155
			local compactLayout = availableWidth < 760 -- 156
			local minLeftWidth = compactLayout and 110 or 170 -- 157
			local minRightWidth = compactLayout and 130 or 220 -- 158
			local minCenterWidth = compactLayout and 80 or 180 -- 159
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 160
			if sideBudget <= minLeftWidth + minRightWidth then -- 160
				state.leftWidth = math.max( -- 162
					1, -- 162
					math.floor(sideBudget * 0.45) -- 162
				) -- 162
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 163
			else -- 163
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 165
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 166
				if state.leftWidth + state.rightWidth > sideBudget then -- 166
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 168
					state.leftWidth = math.max( -- 169
						minLeftWidth, -- 169
						math.floor(sideBudget * ratio) -- 169
					) -- 169
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 170
				end -- 170
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 172
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 173
			end -- 173
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 175
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 176
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 177
			local function clampPanelWidth(value, minValue, maxValue) -- 178
				local safeMax = math.max(1, maxValue) -- 179
				local safeMin = math.min(minValue, safeMax) -- 180
				return math.max( -- 181
					safeMin, -- 181
					math.min(value, safeMax) -- 181
				) -- 181
			end -- 178
			local function resizeSidePanels(deltaX, side) -- 183
				if side == "left" then -- 183
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 185
				else -- 185
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 187
				end -- 187
			end -- 183
			ImGui.PushStyleColor( -- 191
				"ChildBg", -- 191
				panelBg, -- 191
				function() -- 191
					ImGui.BeginChild( -- 192
						"LeftDock", -- 192
						Vec2(state.leftWidth, mainHeight), -- 192
						{}, -- 192
						noScrollFlags, -- 192
						function() -- 192
							ImGui.BeginChild( -- 193
								"SceneDock", -- 193
								Vec2(0, leftTopHeight), -- 193
								{}, -- 193
								noScrollFlags, -- 193
								function() return drawSceneTreePanel(state) end -- 193
							) -- 193
							ImGui.BeginChild( -- 194
								"AssetDock", -- 194
								Vec2(0, leftBottomHeight), -- 194
								{}, -- 194
								noScrollFlags, -- 194
								function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 194
							) -- 194
						end -- 192
					) -- 192
				end -- 191
			) -- 191
			ImGui.SameLine(0, 0) -- 197
			drawVerticalSplitter( -- 198
				"LeftSplitter", -- 198
				mainHeight, -- 198
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 198
			) -- 198
			ImGui.SameLine(0, 0) -- 199
			ImGui.PushStyleColor( -- 200
				"ChildBg", -- 200
				transparent, -- 200
				function() -- 200
					ImGui.BeginChild( -- 201
						"CenterDock", -- 201
						Vec2(centerWidth, mainHeight), -- 201
						{}, -- 201
						noScrollFlags, -- 201
						function() -- 201
							if state.mode == "Script" then -- 201
								drawScriptPanel(state, attachScriptToNode) -- 202
							else -- 202
								drawViewportPanel(state) -- 202
							end -- 202
						end -- 201
					) -- 201
				end -- 200
			) -- 200
			ImGui.SameLine(0, 0) -- 205
			drawVerticalSplitter( -- 206
				"RightSplitter", -- 206
				mainHeight, -- 206
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 206
			) -- 206
			ImGui.SameLine(0, 0) -- 207
			ImGui.PushStyleColor( -- 208
				"ChildBg", -- 208
				panelBg, -- 208
				function() -- 208
					ImGui.BeginChild( -- 209
						"RightDock", -- 209
						Vec2(state.rightWidth, mainHeight), -- 209
						{}, -- 209
						noScrollFlags, -- 209
						function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 209
					) -- 209
				end -- 208
			) -- 208
			ImGui.PushStyleColor( -- 211
				"ChildBg", -- 211
				panelBg, -- 211
				function() -- 211
					ImGui.BeginChild( -- 212
						"BottomConsoleDock", -- 212
						Vec2(0, bottomHeight), -- 212
						{}, -- 212
						noScrollFlags, -- 212
						function() return drawConsolePanel(state) end -- 212
					) -- 212
				end -- 211
			) -- 211
		end -- 141
	) -- 141
	drawGamePreviewWindow(state) -- 215
end -- 130
function ____exports.drawRuntimeError(message) -- 218
	local size = App.visualSize -- 219
	ImGui.SetNextWindowPos( -- 220
		Vec2(10, 10), -- 220
		"Always" -- 220
	) -- 220
	ImGui.SetNextWindowSize( -- 221
		Vec2( -- 221
			math.max(320, size.width - 20), -- 221
			math.max(220, size.height - 20) -- 221
		), -- 221
		"Always" -- 221
	) -- 221
	ImGui.Begin( -- 222
		"Dora Visual Editor Error", -- 222
		mainWindowFlags, -- 222
		function() -- 222
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 223
			ImGui.Separator() -- 224
			ImGui.TextWrapped(message or "unknown error") -- 225
		end -- 222
	) -- 222
end -- 218
return ____exports -- 218