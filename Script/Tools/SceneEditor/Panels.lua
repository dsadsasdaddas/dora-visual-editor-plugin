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
	state.previewDirty = true -- 68
	state.playDirty = true -- 69
	local sceneFile = writeSceneFile(state) -- 70
	if sceneFile == nil then -- 70
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 72
	else -- 72
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 74
	end -- 74
	pushConsole(state, state.status) -- 76
end -- 64
local function bindTextureToSprite(state, node, texture) -- 79
	node.texture = texture -- 80
	node.textureBuffer.text = texture -- 81
	state.selectedAsset = texture -- 82
	state.previewDirty = true -- 83
	state.playDirty = true -- 84
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 85
	pushConsole(state, state.status) -- 86
end -- 79
local function createSpriteFromTexture(state, texture) -- 89
	addChildNode(state, "Sprite") -- 90
	local node = state.nodes[state.selectedId] -- 91
	if node ~= nil and node.kind == "Sprite" then -- 91
		bindTextureToSprite(state, node, texture) -- 93
	end -- 93
end -- 89
local function openNodeScriptInEditor(state, node) -- 97
	openScriptForNode(state, node, attachScriptToNode) -- 98
end -- 97
local function drawVerticalSplitter(id, height, onDrag) -- 101
	ImGui.PushStyleColor( -- 102
		"Button", -- 102
		Color(4281612868), -- 102
		function() -- 102
			ImGui.PushStyleColor( -- 103
				"ButtonHovered", -- 103
				Color(4283259240), -- 103
				function() -- 103
					ImGui.PushStyleColor( -- 104
						"ButtonActive", -- 104
						Color(4294954035), -- 104
						function() -- 104
							ImGui.Button( -- 105
								"##" .. id, -- 105
								Vec2(8, height) -- 105
							) -- 105
						end -- 104
					) -- 104
				end -- 103
			) -- 103
		end -- 102
	) -- 102
	if ImGui.IsItemHovered() then -- 102
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 110
	end -- 110
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 110
		local delta = ImGui.GetMouseDragDelta(0) -- 113
		if delta.x ~= 0 then -- 113
			onDrag(delta.x) -- 115
			ImGui.ResetMouseDragDelta(0) -- 116
		end -- 116
	end -- 116
end -- 101
function ____exports.drawEditor(state) -- 121
	local size = App.visualSize -- 122
	local margin = 10 -- 123
	local nativeFooterSafeArea = 60 -- 124
	local windowWidth = math.max(360, size.width - margin * 2) -- 125
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 126
	ImGui.SetNextWindowPos( -- 127
		Vec2(margin, margin), -- 127
		"Always" -- 127
	) -- 127
	ImGui.SetNextWindowSize( -- 128
		Vec2(windowWidth, windowHeight), -- 128
		"Always" -- 128
	) -- 128
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 131
	ImGui.Begin( -- 132
		"Dora Visual Editor", -- 132
		mainWindowFlags, -- 132
		function() -- 132
			drawHeaderPanel(state, saveScene) -- 133
			local avail = ImGui.GetContentRegionAvail() -- 134
			local bottomHeight = math.max( -- 135
				72, -- 135
				math.min( -- 135
					state.bottomHeight, -- 135
					math.floor(avail.y * 0.28) -- 135
				) -- 135
			) -- 135
			if state.mode == "Script" then -- 135
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 137
				ImGui.PushStyleColor( -- 138
					"ChildBg", -- 138
					panelBg, -- 138
					function() -- 138
						ImGui.BeginChild( -- 139
							"ScriptWorkspaceRoot", -- 139
							Vec2(0, scriptHeight), -- 139
							{}, -- 139
							noScrollFlags, -- 139
							function() return drawScriptPanel(state, attachScriptToNode) end -- 139
						) -- 139
					end -- 138
				) -- 138
				ImGui.BeginChild( -- 141
					"ScriptConsoleDock", -- 141
					Vec2(0, bottomHeight), -- 141
					{}, -- 141
					noScrollFlags, -- 141
					function() return drawConsolePanel(state) end -- 141
				) -- 141
				return -- 142
			end -- 142
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 144
			local availableWidth = math.max(320, avail.x) -- 145
			local splitterWidth = 8 -- 146
			local compactLayout = availableWidth < 760 -- 147
			local minLeftWidth = compactLayout and 110 or 170 -- 148
			local minRightWidth = compactLayout and 130 or 220 -- 149
			local minCenterWidth = compactLayout and 80 or 180 -- 150
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 151
			if sideBudget <= minLeftWidth + minRightWidth then -- 151
				state.leftWidth = math.max( -- 153
					1, -- 153
					math.floor(sideBudget * 0.45) -- 153
				) -- 153
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 154
			else -- 154
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 156
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 157
				if state.leftWidth + state.rightWidth > sideBudget then -- 157
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 159
					state.leftWidth = math.max( -- 160
						minLeftWidth, -- 160
						math.floor(sideBudget * ratio) -- 160
					) -- 160
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 161
				end -- 161
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 163
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 164
			end -- 164
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 166
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 167
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 168
			local function clampPanelWidth(value, minValue, maxValue) -- 169
				local safeMax = math.max(1, maxValue) -- 170
				local safeMin = math.min(minValue, safeMax) -- 171
				return math.max( -- 172
					safeMin, -- 172
					math.min(value, safeMax) -- 172
				) -- 172
			end -- 169
			local function resizeSidePanels(deltaX, side) -- 174
				if side == "left" then -- 174
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 176
				else -- 176
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 178
				end -- 178
			end -- 174
			ImGui.PushStyleColor( -- 182
				"ChildBg", -- 182
				panelBg, -- 182
				function() -- 182
					ImGui.BeginChild( -- 183
						"LeftDock", -- 183
						Vec2(state.leftWidth, mainHeight), -- 183
						{}, -- 183
						noScrollFlags, -- 183
						function() -- 183
							ImGui.BeginChild( -- 184
								"SceneDock", -- 184
								Vec2(0, leftTopHeight), -- 184
								{}, -- 184
								noScrollFlags, -- 184
								function() return drawSceneTreePanel(state) end -- 184
							) -- 184
							ImGui.BeginChild( -- 185
								"AssetDock", -- 185
								Vec2(0, leftBottomHeight), -- 185
								{}, -- 185
								noScrollFlags, -- 185
								function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 185
							) -- 185
						end -- 183
					) -- 183
				end -- 182
			) -- 182
			ImGui.SameLine(0, 0) -- 188
			drawVerticalSplitter( -- 189
				"LeftSplitter", -- 189
				mainHeight, -- 189
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 189
			) -- 189
			ImGui.SameLine(0, 0) -- 190
			ImGui.PushStyleColor( -- 191
				"ChildBg", -- 191
				transparent, -- 191
				function() -- 191
					ImGui.BeginChild( -- 192
						"CenterDock", -- 192
						Vec2(centerWidth, mainHeight), -- 192
						{}, -- 192
						noScrollFlags, -- 192
						function() -- 192
							if state.mode == "Script" then -- 192
								drawScriptPanel(state, attachScriptToNode) -- 193
							else -- 193
								drawViewportPanel(state) -- 193
							end -- 193
						end -- 192
					) -- 192
				end -- 191
			) -- 191
			ImGui.SameLine(0, 0) -- 196
			drawVerticalSplitter( -- 197
				"RightSplitter", -- 197
				mainHeight, -- 197
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 197
			) -- 197
			ImGui.SameLine(0, 0) -- 198
			ImGui.PushStyleColor( -- 199
				"ChildBg", -- 199
				panelBg, -- 199
				function() -- 199
					ImGui.BeginChild( -- 200
						"RightDock", -- 200
						Vec2(state.rightWidth, mainHeight), -- 200
						{}, -- 200
						noScrollFlags, -- 200
						function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 200
					) -- 200
				end -- 199
			) -- 199
			ImGui.PushStyleColor( -- 202
				"ChildBg", -- 202
				panelBg, -- 202
				function() -- 202
					ImGui.BeginChild( -- 203
						"BottomConsoleDock", -- 203
						Vec2(0, bottomHeight), -- 203
						{}, -- 203
						noScrollFlags, -- 203
						function() return drawConsolePanel(state) end -- 203
					) -- 203
				end -- 202
			) -- 202
		end -- 132
	) -- 132
	drawGamePreviewWindow(state) -- 206
end -- 121
function ____exports.drawRuntimeError(message) -- 209
	local size = App.visualSize -- 210
	ImGui.SetNextWindowPos( -- 211
		Vec2(10, 10), -- 211
		"Always" -- 211
	) -- 211
	ImGui.SetNextWindowSize( -- 212
		Vec2( -- 212
			math.max(320, size.width - 20), -- 212
			math.max(220, size.height - 20) -- 212
		), -- 212
		"Always" -- 212
	) -- 212
	ImGui.Begin( -- 213
		"Dora Visual Editor Error", -- 213
		mainWindowFlags, -- 213
		function() -- 213
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 214
			ImGui.Separator() -- 215
			ImGui.TextWrapped(message or "unknown error") -- 216
		end -- 213
	) -- 213
end -- 209
return ____exports -- 209