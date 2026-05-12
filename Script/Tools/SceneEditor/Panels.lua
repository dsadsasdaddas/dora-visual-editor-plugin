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
local function drawVerticalSplitter(id, height, onDrag) -- 98
	ImGui.PushStyleColor( -- 99
		"Button", -- 99
		Color(4281612868), -- 99
		function() -- 99
			ImGui.PushStyleColor( -- 100
				"ButtonHovered", -- 100
				Color(4283259240), -- 100
				function() -- 100
					ImGui.PushStyleColor( -- 101
						"ButtonActive", -- 101
						Color(4294954035), -- 101
						function() -- 101
							ImGui.Button( -- 102
								"##" .. id, -- 102
								Vec2(8, height) -- 102
							) -- 102
						end -- 101
					) -- 101
				end -- 100
			) -- 100
		end -- 99
	) -- 99
	if ImGui.IsItemHovered() then -- 99
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 107
	end -- 107
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 107
		local delta = ImGui.GetMouseDragDelta(0) -- 110
		if delta.x ~= 0 then -- 110
			onDrag(delta.x) -- 112
			ImGui.ResetMouseDragDelta(0) -- 113
		end -- 113
	end -- 113
end -- 98
function ____exports.drawEditor(state) -- 118
	local size = App.visualSize -- 119
	local margin = 10 -- 120
	local nativeFooterSafeArea = 60 -- 121
	local windowWidth = math.max(360, size.width - margin * 2) -- 122
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 123
	ImGui.SetNextWindowPos( -- 124
		Vec2(margin, margin), -- 124
		"Always" -- 124
	) -- 124
	ImGui.SetNextWindowSize( -- 125
		Vec2(windowWidth, windowHeight), -- 125
		"Always" -- 125
	) -- 125
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 126
	ImGui.Begin( -- 127
		"Dora Visual Editor", -- 127
		mainWindowFlags, -- 127
		function() -- 127
			drawHeaderPanel(state, saveScene) -- 128
			local avail = ImGui.GetContentRegionAvail() -- 129
			local bottomHeight = math.max( -- 130
				72, -- 130
				math.min( -- 130
					state.bottomHeight, -- 130
					math.floor(avail.y * 0.28) -- 130
				) -- 130
			) -- 130
			if state.mode == "Script" then -- 130
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 132
				ImGui.PushStyleColor( -- 133
					"ChildBg", -- 133
					panelBg, -- 133
					function() -- 133
						ImGui.BeginChild( -- 134
							"ScriptWorkspaceRoot", -- 134
							Vec2(0, scriptHeight), -- 134
							{}, -- 134
							noScrollFlags, -- 134
							function() return drawScriptPanel(state, attachScriptToNode) end -- 134
						) -- 134
					end -- 133
				) -- 133
				ImGui.BeginChild( -- 136
					"ScriptConsoleDock", -- 136
					Vec2(0, bottomHeight), -- 136
					{}, -- 136
					noScrollFlags, -- 136
					function() return drawConsolePanel(state) end -- 136
				) -- 136
				return -- 137
			end -- 137
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 139
			local availableWidth = math.max(320, avail.x) -- 140
			local splitterWidth = 8 -- 141
			local compactLayout = availableWidth < 760 -- 142
			local minLeftWidth = compactLayout and 110 or 170 -- 143
			local minRightWidth = compactLayout and 130 or 220 -- 144
			local minCenterWidth = compactLayout and 80 or 180 -- 145
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 146
			if sideBudget <= minLeftWidth + minRightWidth then -- 146
				state.leftWidth = math.max( -- 148
					1, -- 148
					math.floor(sideBudget * 0.45) -- 148
				) -- 148
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 149
			else -- 149
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 151
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 152
				if state.leftWidth + state.rightWidth > sideBudget then -- 152
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 154
					state.leftWidth = math.max( -- 155
						minLeftWidth, -- 155
						math.floor(sideBudget * ratio) -- 155
					) -- 155
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 156
				end -- 156
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 158
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 159
			end -- 159
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 161
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 162
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 163
			local function clampPanelWidth(value, minValue, maxValue) -- 164
				local safeMax = math.max(1, maxValue) -- 165
				local safeMin = math.min(minValue, safeMax) -- 166
				return math.max( -- 167
					safeMin, -- 167
					math.min(value, safeMax) -- 167
				) -- 167
			end -- 164
			local function resizeSidePanels(deltaX, side) -- 169
				if side == "left" then -- 169
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 171
				else -- 171
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 173
				end -- 173
			end -- 169
			ImGui.BeginChild( -- 177
				"LeftDock", -- 177
				Vec2(state.leftWidth, mainHeight), -- 177
				{}, -- 177
				noScrollFlags, -- 177
				function() -- 177
					ImGui.BeginChild( -- 178
						"SceneDock", -- 178
						Vec2(0, leftTopHeight), -- 178
						{}, -- 178
						noScrollFlags, -- 178
						function() return drawSceneTreePanel(state) end -- 178
					) -- 178
					ImGui.BeginChild( -- 179
						"AssetDock", -- 179
						Vec2(0, leftBottomHeight), -- 179
						{}, -- 179
						noScrollFlags, -- 179
						function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 179
					) -- 179
				end -- 177
			) -- 177
			ImGui.SameLine(0, 0) -- 181
			drawVerticalSplitter( -- 182
				"LeftSplitter", -- 182
				mainHeight, -- 182
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 182
			) -- 182
			ImGui.SameLine(0, 0) -- 183
			ImGui.PushStyleColor( -- 184
				"ChildBg", -- 184
				transparent, -- 184
				function() -- 184
					ImGui.BeginChild( -- 185
						"CenterDock", -- 185
						Vec2(centerWidth, mainHeight), -- 185
						{}, -- 185
						noScrollFlags, -- 185
						function() -- 185
							if state.mode == "Script" then -- 185
								drawScriptPanel(state, attachScriptToNode) -- 186
							else -- 186
								drawViewportPanel(state) -- 186
							end -- 186
						end -- 185
					) -- 185
				end -- 184
			) -- 184
			ImGui.SameLine(0, 0) -- 189
			drawVerticalSplitter( -- 190
				"RightSplitter", -- 190
				mainHeight, -- 190
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 190
			) -- 190
			ImGui.SameLine(0, 0) -- 191
			ImGui.BeginChild( -- 192
				"RightDock", -- 192
				Vec2(state.rightWidth, mainHeight), -- 192
				{}, -- 192
				noScrollFlags, -- 192
				function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 192
			) -- 192
			ImGui.BeginChild( -- 193
				"BottomConsoleDock", -- 193
				Vec2(0, bottomHeight), -- 193
				{}, -- 193
				noScrollFlags, -- 193
				function() return drawConsolePanel(state) end -- 193
			) -- 193
		end -- 127
	) -- 127
	drawGamePreviewWindow(state) -- 195
end -- 118
function ____exports.drawRuntimeError(message) -- 198
	local size = App.visualSize -- 199
	ImGui.SetNextWindowPos( -- 200
		Vec2(10, 10), -- 200
		"Always" -- 200
	) -- 200
	ImGui.SetNextWindowSize( -- 201
		Vec2( -- 201
			math.max(320, size.width - 20), -- 201
			math.max(220, size.height - 20) -- 201
		), -- 201
		"Always" -- 201
	) -- 201
	ImGui.Begin( -- 202
		"Dora Visual Editor Error", -- 202
		mainWindowFlags, -- 202
		function() -- 202
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 203
			ImGui.Separator() -- 204
			ImGui.TextWrapped(message or "unknown error") -- 205
		end -- 202
	) -- 202
end -- 198
return ____exports -- 198