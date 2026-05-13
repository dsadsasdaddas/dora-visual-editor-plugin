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
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 17
local function workspacePath(path) -- 18
	return SceneModel.workspacePath(path) -- 18
end -- 18
local function sceneSaveFile() -- 20
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 21
end -- 20
local function writeSceneFile(state) -- 24
	Content:mkdir(workspacePath(".dora")) -- 25
	local data = { -- 26
		version = 1, -- 27
		gameWidth = math.floor(state.gameWidth), -- 28
		gameHeight = math.floor(state.gameHeight), -- 29
		nodes = {} -- 30
	} -- 30
	for ____, id in ipairs(state.order) do -- 32
		local node = state.nodes[id] -- 33
		if node ~= nil then -- 33
			local ____data_nodes_0 = data.nodes -- 33
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 35
				id = node.id, -- 36
				kind = node.kind, -- 37
				name = node.name, -- 38
				parentId = node.parentId, -- 39
				x = node.x, -- 40
				y = node.y, -- 41
				scaleX = node.scaleX, -- 42
				scaleY = node.scaleY, -- 43
				rotation = node.rotation, -- 44
				visible = node.visible, -- 45
				texture = node.texture, -- 46
				text = node.text, -- 47
				script = node.script -- 48
			} -- 48
		end -- 48
	end -- 48
	local text = json.encode(data) -- 52
	local file = sceneSaveFile() -- 53
	if text ~= nil and Content:save(file, text) then -- 53
		return file -- 54
	end -- 54
	return nil -- 55
end -- 24
local function saveScene(state) -- 58
	local file = writeSceneFile(state) -- 59
	if file ~= nil then -- 59
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 61
	else -- 61
		state.status = zh and "保存失败" or "Save failed" -- 63
	end -- 63
	pushConsole(state, state.status) -- 65
end -- 58
local function attachScriptToNode(state, node, scriptPath, message) -- 68
	node.script = scriptPath -- 69
	node.scriptBuffer.text = scriptPath -- 70
	state.activeScriptNodeId = node.id -- 71
	state.previewDirty = true -- 72
	state.playDirty = true -- 73
	local sceneFile = writeSceneFile(state) -- 74
	if sceneFile == nil then -- 74
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 76
	else -- 76
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 78
	end -- 78
	pushConsole(state, state.status) -- 80
end -- 68
local function bindTextureToSprite(state, node, texture) -- 83
	node.texture = texture -- 84
	node.textureBuffer.text = texture -- 85
	state.selectedAsset = texture -- 86
	state.previewDirty = true -- 87
	state.playDirty = true -- 88
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 89
	pushConsole(state, state.status) -- 90
end -- 83
local function createSpriteFromTexture(state, texture) -- 93
	addChildNode(state, "Sprite") -- 94
	local node = state.nodes[state.selectedId] -- 95
	if node ~= nil and node.kind == "Sprite" then -- 95
		bindTextureToSprite(state, node, texture) -- 97
	end -- 97
end -- 93
local function openNodeScriptInEditor(state, node) -- 101
	openScriptForNode(state, node, attachScriptToNode) -- 102
end -- 101
local function drawVerticalSplitter(id, height, onDrag) -- 105
	ImGui.PushStyleColor( -- 106
		"Button", -- 106
		Color(4281612868), -- 106
		function() -- 106
			ImGui.PushStyleColor( -- 107
				"ButtonHovered", -- 107
				Color(4283259240), -- 107
				function() -- 107
					ImGui.PushStyleColor( -- 108
						"ButtonActive", -- 108
						Color(4294954035), -- 108
						function() -- 108
							ImGui.Button( -- 109
								"##" .. id, -- 109
								Vec2(8, height) -- 109
							) -- 109
						end -- 108
					) -- 108
				end -- 107
			) -- 107
		end -- 106
	) -- 106
	if ImGui.IsItemHovered() then -- 106
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 114
	end -- 114
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 114
		local delta = ImGui.GetMouseDragDelta(0) -- 117
		if delta.x ~= 0 then -- 117
			onDrag(delta.x) -- 119
			ImGui.ResetMouseDragDelta(0) -- 120
		end -- 120
	end -- 120
end -- 105
function ____exports.drawEditor(state) -- 125
	local size = App.visualSize -- 126
	local margin = 10 -- 127
	local nativeFooterSafeArea = 60 -- 128
	local windowWidth = math.max(360, size.width - margin * 2) -- 129
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 130
	ImGui.SetNextWindowPos( -- 131
		Vec2(margin, margin), -- 131
		"Always" -- 131
	) -- 131
	ImGui.SetNextWindowSize( -- 132
		Vec2(windowWidth, windowHeight), -- 132
		"Always" -- 132
	) -- 132
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 135
	ImGui.Begin( -- 136
		"Dora Visual Editor", -- 136
		mainWindowFlags, -- 136
		function() -- 136
			drawHeaderPanel(state, saveScene) -- 137
			local avail = ImGui.GetContentRegionAvail() -- 138
			local bottomHeight = math.max( -- 139
				72, -- 139
				math.min( -- 139
					state.bottomHeight, -- 139
					math.floor(avail.y * 0.28) -- 139
				) -- 139
			) -- 139
			if state.mode == "Script" then -- 139
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 141
				ImGui.PushStyleColor( -- 142
					"ChildBg", -- 142
					panelBg, -- 142
					function() -- 142
						ImGui.BeginChild( -- 143
							"ScriptWorkspaceRoot", -- 143
							Vec2(0, scriptHeight), -- 143
							{}, -- 143
							noScrollFlags, -- 143
							function() return drawScriptPanel(state, attachScriptToNode) end -- 143
						) -- 143
					end -- 142
				) -- 142
				ImGui.BeginChild( -- 145
					"ScriptConsoleDock", -- 145
					Vec2(0, bottomHeight), -- 145
					{}, -- 145
					noScrollFlags, -- 145
					function() return drawConsolePanel(state) end -- 145
				) -- 145
				return -- 146
			end -- 146
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 148
			local availableWidth = math.max(320, avail.x) -- 149
			local splitterWidth = 8 -- 150
			local compactLayout = availableWidth < 760 -- 151
			local minLeftWidth = compactLayout and 110 or 170 -- 152
			local minRightWidth = compactLayout and 130 or 220 -- 153
			local minCenterWidth = compactLayout and 80 or 180 -- 154
			local sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth) -- 155
			if sideBudget <= minLeftWidth + minRightWidth then -- 155
				state.leftWidth = math.max( -- 157
					1, -- 157
					math.floor(sideBudget * 0.45) -- 157
				) -- 157
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 158
			else -- 158
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 160
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 161
				if state.leftWidth + state.rightWidth > sideBudget then -- 161
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 163
					state.leftWidth = math.max( -- 164
						minLeftWidth, -- 164
						math.floor(sideBudget * ratio) -- 164
					) -- 164
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 165
				end -- 165
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 167
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 168
			end -- 168
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2) -- 170
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 171
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 172
			local function clampPanelWidth(value, minValue, maxValue) -- 173
				local safeMax = math.max(1, maxValue) -- 174
				local safeMin = math.min(minValue, safeMax) -- 175
				return math.max( -- 176
					safeMin, -- 176
					math.min(value, safeMax) -- 176
				) -- 176
			end -- 173
			local function resizeSidePanels(deltaX, side) -- 178
				if side == "left" then -- 178
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth) -- 180
				else -- 180
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth) -- 182
				end -- 182
			end -- 178
			ImGui.PushStyleColor( -- 186
				"ChildBg", -- 186
				panelBg, -- 186
				function() -- 186
					ImGui.BeginChild( -- 187
						"LeftDock", -- 187
						Vec2(state.leftWidth, mainHeight), -- 187
						{}, -- 187
						noScrollFlags, -- 187
						function() -- 187
							ImGui.BeginChild( -- 188
								"SceneDock", -- 188
								Vec2(0, leftTopHeight), -- 188
								{}, -- 188
								noScrollFlags, -- 188
								function() return drawSceneTreePanel(state) end -- 188
							) -- 188
							ImGui.BeginChild( -- 189
								"AssetDock", -- 189
								Vec2(0, leftBottomHeight), -- 189
								{}, -- 189
								noScrollFlags, -- 189
								function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 189
							) -- 189
						end -- 187
					) -- 187
				end -- 186
			) -- 186
			ImGui.SameLine(0, 0) -- 192
			drawVerticalSplitter( -- 193
				"LeftSplitter", -- 193
				mainHeight, -- 193
				function(deltaX) return resizeSidePanels(deltaX, "left") end -- 193
			) -- 193
			ImGui.SameLine(0, 0) -- 194
			ImGui.PushStyleColor( -- 195
				"ChildBg", -- 195
				transparent, -- 195
				function() -- 195
					ImGui.BeginChild( -- 196
						"CenterDock", -- 196
						Vec2(centerWidth, mainHeight), -- 196
						{}, -- 196
						noScrollFlags, -- 196
						function() -- 196
							if state.mode == "Script" then -- 196
								drawScriptPanel(state, attachScriptToNode) -- 197
							else -- 197
								drawViewportPanel(state) -- 197
							end -- 197
						end -- 196
					) -- 196
				end -- 195
			) -- 195
			ImGui.SameLine(0, 0) -- 200
			drawVerticalSplitter( -- 201
				"RightSplitter", -- 201
				mainHeight, -- 201
				function(deltaX) return resizeSidePanels(deltaX, "right") end -- 201
			) -- 201
			ImGui.SameLine(0, 0) -- 202
			ImGui.PushStyleColor( -- 203
				"ChildBg", -- 203
				panelBg, -- 203
				function() -- 203
					ImGui.BeginChild( -- 204
						"RightDock", -- 204
						Vec2(state.rightWidth, mainHeight), -- 204
						{}, -- 204
						noScrollFlags, -- 204
						function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 204
					) -- 204
				end -- 203
			) -- 203
			ImGui.PushStyleColor( -- 206
				"ChildBg", -- 206
				panelBg, -- 206
				function() -- 206
					ImGui.BeginChild( -- 207
						"BottomConsoleDock", -- 207
						Vec2(0, bottomHeight), -- 207
						{}, -- 207
						noScrollFlags, -- 207
						function() return drawConsolePanel(state) end -- 207
					) -- 207
				end -- 206
			) -- 206
		end -- 136
	) -- 136
end -- 125
function ____exports.drawRuntimeError(message) -- 212
	local size = App.visualSize -- 213
	ImGui.SetNextWindowPos( -- 214
		Vec2(10, 10), -- 214
		"Always" -- 214
	) -- 214
	ImGui.SetNextWindowSize( -- 215
		Vec2( -- 215
			math.max(320, size.width - 20), -- 215
			math.max(220, size.height - 20) -- 215
		), -- 215
		"Always" -- 215
	) -- 215
	ImGui.Begin( -- 216
		"Dora Visual Editor Error", -- 216
		mainWindowFlags, -- 216
		function() -- 216
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 217
			ImGui.Separator() -- 218
			ImGui.TextWrapped(message or "unknown error") -- 219
		end -- 216
	) -- 216
end -- 212
return ____exports -- 212