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
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 129
	ImGui.Begin( -- 130
		"Dora Visual Editor", -- 130
		mainWindowFlags, -- 130
		function() -- 130
			drawHeaderPanel(state, saveScene) -- 131
			local avail = ImGui.GetContentRegionAvail() -- 132
			local bottomHeight = math.max( -- 133
				72, -- 133
				math.min( -- 133
					state.bottomHeight, -- 133
					math.floor(avail.y * 0.28) -- 133
				) -- 133
			) -- 133
			if state.mode == "Script" then -- 133
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 135
				ImGui.PushStyleColor( -- 136
					"ChildBg", -- 136
					panelBg, -- 136
					function() -- 136
						ImGui.BeginChild( -- 137
							"ScriptWorkspaceRoot", -- 137
							Vec2(0, scriptHeight), -- 137
							{}, -- 137
							noScrollFlags, -- 137
							function() return drawScriptPanel(state, attachScriptToNode) end -- 137
						) -- 137
					end -- 136
				) -- 136
				ImGui.BeginChild( -- 139
					"ScriptConsoleDock", -- 139
					Vec2(0, bottomHeight), -- 139
					{}, -- 139
					noScrollFlags, -- 139
					function() return drawConsolePanel(state) end -- 139
				) -- 139
				return -- 140
			end -- 140
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 142
			local availableWidth = math.max(320, avail.x) -- 143
			local splitterWidth = 8 -- 144
			local compactLayout = availableWidth < 760 -- 145
			local minLeftWidth = compactLayout and 110 or 170 -- 146
			local minRightWidth = compactLayout and 130 or 220 -- 147
			local minCenterWidth = compactLayout and 80 or 180 -- 148
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 149
			if sideBudget <= minLeftWidth + minRightWidth then -- 149
				state.leftWidth = math.max( -- 151
					1, -- 151
					math.floor(sideBudget * 0.45) -- 151
				) -- 151
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 152
			else -- 152
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 154
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 155
				if state.leftWidth + state.rightWidth > sideBudget then -- 155
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 157
					state.leftWidth = math.max( -- 158
						minLeftWidth, -- 158
						math.floor(sideBudget * ratio) -- 158
					) -- 158
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 159
				end -- 159
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 161
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 162
			end -- 162
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 164
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 165
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 166
			local function clampPanelWidth(value, minValue, maxValue) -- 167
				local safeMax = math.max(1, maxValue) -- 168
				local safeMin = math.min(minValue, safeMax) -- 169
				return math.max( -- 170
					safeMin, -- 170
					math.min(value, safeMax) -- 170
				) -- 170
			end -- 167
			local function resizeSidePanels(deltaX, side) -- 172
				if side == "left" then -- 172
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 174
				else -- 174
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 176
				end -- 176
			end -- 172
			ImGui.BeginChild( -- 180
				"LeftDock", -- 180
				Vec2(state.leftWidth, mainHeight), -- 180
				{}, -- 180
				noScrollFlags, -- 180
				function() -- 180
					ImGui.BeginChild( -- 181
						"SceneDock", -- 181
						Vec2(0, leftTopHeight), -- 181
						{}, -- 181
						noScrollFlags, -- 181
						function() return drawSceneTreePanel(state) end -- 181
					) -- 181
					ImGui.BeginChild( -- 182
						"AssetDock", -- 182
						Vec2(0, leftBottomHeight), -- 182
						{}, -- 182
						noScrollFlags, -- 182
						function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 182
					) -- 182
				end -- 180
			) -- 180
			ImGui.SameLine(0, 0) -- 184
			drawVerticalSplitter( -- 185
				"LeftSplitter", -- 185
				mainHeight, -- 185
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 185
			) -- 185
			ImGui.SameLine(0, 0) -- 186
			ImGui.PushStyleColor( -- 187
				"ChildBg", -- 187
				transparent, -- 187
				function() -- 187
					ImGui.BeginChild( -- 188
						"CenterDock", -- 188
						Vec2(centerWidth, mainHeight), -- 188
						{}, -- 188
						noScrollFlags, -- 188
						function() -- 188
							if state.mode == "Script" then -- 188
								drawScriptPanel(state, attachScriptToNode) -- 189
							else -- 189
								drawViewportPanel(state) -- 189
							end -- 189
						end -- 188
					) -- 188
				end -- 187
			) -- 187
			ImGui.SameLine(0, 0) -- 192
			drawVerticalSplitter( -- 193
				"RightSplitter", -- 193
				mainHeight, -- 193
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 193
			) -- 193
			ImGui.SameLine(0, 0) -- 194
			ImGui.BeginChild( -- 195
				"RightDock", -- 195
				Vec2(state.rightWidth, mainHeight), -- 195
				{}, -- 195
				noScrollFlags, -- 195
				function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 195
			) -- 195
			ImGui.BeginChild( -- 196
				"BottomConsoleDock", -- 196
				Vec2(0, bottomHeight), -- 196
				{}, -- 196
				noScrollFlags, -- 196
				function() return drawConsolePanel(state) end -- 196
			) -- 196
		end -- 130
	) -- 130
	drawGamePreviewWindow(state) -- 198
end -- 121
function ____exports.drawRuntimeError(message) -- 201
	local size = App.visualSize -- 202
	ImGui.SetNextWindowPos( -- 203
		Vec2(10, 10), -- 203
		"Always" -- 203
	) -- 203
	ImGui.SetNextWindowSize( -- 204
		Vec2( -- 204
			math.max(320, size.width - 20), -- 204
			math.max(220, size.height - 20) -- 204
		), -- 204
		"Always" -- 204
	) -- 204
	ImGui.Begin( -- 205
		"Dora Visual Editor Error", -- 205
		mainWindowFlags, -- 205
		function() -- 205
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 206
			ImGui.Separator() -- 207
			ImGui.TextWrapped(message or "unknown error") -- 208
		end -- 205
	) -- 205
end -- 201
return ____exports -- 201