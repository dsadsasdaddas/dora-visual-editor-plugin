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
local workspacePath = ____Model.workspacePath -- 6
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
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 15
local canNodeKindBindTexture = ____NodeCapabilities.canNodeKindBindTexture -- 15
local function sceneSaveFile() -- 17
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 18
end -- 17
local function writeSceneFile(state) -- 21
	Content:mkdir(workspacePath(".dora")) -- 22
	local data = { -- 23
		version = 1, -- 24
		gameWidth = math.floor(state.gameWidth), -- 25
		gameHeight = math.floor(state.gameHeight), -- 26
		gameScript = state.gameScript, -- 27
		nodes = {} -- 28
	} -- 28
	for ____, id in ipairs(state.order) do -- 30
		local node = state.nodes[id] -- 31
		if node ~= nil then -- 31
			local ____data_nodes_4 = data.nodes -- 33
			local ____node_id_1 = node.id -- 34
			local ____node_kind_2 = node.kind -- 35
			local ____node_name_3 = node.name -- 36
			local ____temp_0 -- 37
			if node.id == "root" then -- 37
				____temp_0 = nil -- 37
			else -- 37
				____temp_0 = node.parentId -- 37
			end -- 37
			____data_nodes_4[#____data_nodes_4 + 1] = { -- 33
				id = ____node_id_1, -- 34
				kind = ____node_kind_2, -- 35
				name = ____node_name_3, -- 36
				parentId = ____temp_0, -- 37
				x = node.x, -- 38
				y = node.y, -- 39
				scaleX = node.scaleX, -- 40
				scaleY = node.scaleY, -- 41
				rotation = node.rotation, -- 42
				visible = node.visible, -- 43
				texture = node.texture, -- 44
				text = node.text, -- 45
				script = node.script, -- 46
				followTargetId = node.followTargetId, -- 47
				followOffsetX = node.followOffsetX, -- 48
				followOffsetY = node.followOffsetY -- 49
			} -- 49
		end -- 49
	end -- 49
	local text = json.encode(data) -- 53
	local file = sceneSaveFile() -- 54
	if text ~= nil and Content:save(file, text) then -- 54
		local legacyDir = Path(Content.writablePath, ".dora") -- 57
		Content:mkdir(legacyDir) -- 58
		Content:save( -- 59
			Path(legacyDir, "imgui-editor.scene.json"), -- 59
			text -- 59
		) -- 59
		return file -- 60
	end -- 60
	return nil -- 62
end -- 21
local function saveScene(state) -- 65
	local file = writeSceneFile(state) -- 66
	if file ~= nil then -- 66
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 68
	else -- 68
		state.status = zh and "保存失败" or "Save failed" -- 70
	end -- 70
	pushConsole(state, state.status) -- 72
end -- 65
local function attachScriptToNode(state, node, scriptPath, message) -- 75
	node.script = scriptPath -- 76
	node.scriptBuffer.text = scriptPath -- 77
	state.activeScriptNodeId = node.id -- 78
	state.previewDirty = true -- 79
	state.playDirty = true -- 80
	local sceneFile = writeSceneFile(state) -- 81
	if sceneFile == nil then -- 81
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 83
	else -- 83
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 85
	end -- 85
	pushConsole(state, state.status) -- 87
end -- 75
local function bindTextureToSprite(state, node, texture) -- 90
	node.texture = texture -- 91
	node.textureBuffer.text = texture -- 92
	state.selectedAsset = texture -- 93
	state.previewDirty = true -- 94
	state.playDirty = true -- 95
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 96
	pushConsole(state, state.status) -- 97
end -- 90
local function createSpriteFromTexture(state, texture) -- 100
	addChildNode(state, "Sprite") -- 101
	local node = state.nodes[state.selectedId] -- 102
	if node ~= nil and canNodeKindBindTexture(node.kind) then -- 102
		bindTextureToSprite(state, node, texture) -- 104
	end -- 104
end -- 100
local function openNodeScriptInEditor(state, node) -- 108
	openScriptForNode(state, node, attachScriptToNode) -- 109
end -- 108
local function drawVerticalSplitter(id, height, onDrag) -- 112
	local hitWidth = 14 -- 113
	ImGui.PushStyleColor( -- 114
		"Button", -- 114
		Color(1714698820), -- 114
		function() -- 114
			ImGui.PushStyleColor( -- 115
				"ButtonHovered", -- 115
				Color(2857195880), -- 115
				function() -- 115
					ImGui.PushStyleColor( -- 116
						"ButtonActive", -- 116
						Color(4294954035), -- 116
						function() -- 116
							ImGui.Button( -- 117
								"##" .. id, -- 117
								Vec2(hitWidth, height) -- 117
							) -- 117
						end -- 116
					) -- 116
				end -- 115
			) -- 115
		end -- 114
	) -- 114
	if ImGui.IsItemHovered() then -- 114
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 122
	end -- 122
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 122
		local delta = ImGui.GetMouseDragDelta(0) -- 125
		if math.abs(delta.x) >= 1 then -- 125
			onDrag(delta.x) -- 127
			ImGui.ResetMouseDragDelta(0) -- 128
		end -- 128
	end -- 128
end -- 112
function ____exports.drawEditor(state) -- 133
	local size = App.visualSize -- 134
	local margin = 10 -- 135
	local nativeFooterSafeArea = 60 -- 136
	local windowWidth = math.max(360, size.width - margin * 2) -- 137
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 138
	ImGui.SetNextWindowPos( -- 139
		Vec2(margin, margin), -- 139
		"Always" -- 139
	) -- 139
	ImGui.SetNextWindowSize( -- 140
		Vec2(windowWidth, windowHeight), -- 140
		"Always" -- 140
	) -- 140
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 143
	ImGui.Begin( -- 144
		"Dora Visual Editor", -- 144
		mainWindowFlags, -- 144
		function() -- 144
			drawHeaderPanel(state, saveScene) -- 145
			local avail = ImGui.GetContentRegionAvail() -- 146
			local bottomHeight = math.max( -- 147
				72, -- 147
				math.min( -- 147
					state.bottomHeight, -- 147
					math.floor(avail.y * 0.28) -- 147
				) -- 147
			) -- 147
			if state.mode == "Script" then -- 147
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 149
				ImGui.PushStyleColor( -- 150
					"ChildBg", -- 150
					panelBg, -- 150
					function() -- 150
						ImGui.BeginChild( -- 151
							"ScriptWorkspaceRoot", -- 151
							Vec2(0, scriptHeight), -- 151
							{}, -- 151
							noScrollFlags, -- 151
							function() return drawScriptPanel(state, attachScriptToNode) end -- 151
						) -- 151
					end -- 150
				) -- 150
				ImGui.BeginChild( -- 153
					"ScriptConsoleDock", -- 153
					Vec2(0, bottomHeight), -- 153
					{}, -- 153
					noScrollFlags, -- 153
					function() return drawConsolePanel(state) end -- 153
				) -- 153
				return -- 154
			end -- 154
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 156
			local availableWidth = math.max(320, avail.x) -- 157
			local splitterWidth = 14 -- 158
			local compactLayout = availableWidth < 760 -- 159
			local minLeftWidth = compactLayout and 92 or 132 -- 160
			local minRightWidth = compactLayout and 120 or 180 -- 161
			local minCenterWidth = compactLayout and 80 or 120 -- 162
			local sideBudget = math.max(0, availableWidth - minCenterWidth) -- 163
			if sideBudget <= minLeftWidth + minRightWidth then -- 163
				state.leftWidth = math.max( -- 165
					1, -- 165
					math.floor(sideBudget * 0.45) -- 165
				) -- 165
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 166
			else -- 166
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 168
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 169
				if state.leftWidth + state.rightWidth > sideBudget then -- 169
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 171
					state.leftWidth = math.max( -- 172
						minLeftWidth, -- 172
						math.floor(sideBudget * ratio) -- 172
					) -- 172
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 173
				end -- 173
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 175
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 176
			end -- 176
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth) -- 178
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 179
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 180
			local function clampPanelWidth(value, minValue, maxValue) -- 181
				local safeMax = math.max(1, maxValue) -- 182
				local safeMin = math.min(minValue, safeMax) -- 183
				return math.max( -- 184
					safeMin, -- 184
					math.min(value, safeMax) -- 184
				) -- 184
			end -- 181
			local function resizeSidePanels(deltaX, side) -- 186
				if side == "left" then -- 186
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - minCenterWidth) -- 188
				else -- 188
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - minCenterWidth) -- 190
				end -- 190
			end -- 186
			ImGui.PushStyleColor( -- 194
				"ChildBg", -- 194
				panelBg, -- 194
				function() -- 194
					ImGui.BeginChild( -- 195
						"LeftDock", -- 195
						Vec2(state.leftWidth, mainHeight), -- 195
						{}, -- 195
						noScrollFlags, -- 195
						function() -- 195
							local contentWidth = math.max(1, state.leftWidth - splitterWidth) -- 196
							ImGui.BeginChild( -- 197
								"LeftDockContent", -- 197
								Vec2(contentWidth, mainHeight), -- 197
								{}, -- 197
								noScrollFlags, -- 197
								function() -- 197
									ImGui.BeginChild( -- 198
										"SceneDock", -- 198
										Vec2(0, leftTopHeight), -- 198
										{}, -- 198
										noScrollFlags, -- 198
										function() return drawSceneTreePanel(state) end -- 198
									) -- 198
									ImGui.BeginChild( -- 199
										"AssetDock", -- 199
										Vec2(0, leftBottomHeight), -- 199
										{}, -- 199
										noScrollFlags, -- 199
										function() return drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) end -- 199
									) -- 199
								end -- 197
							) -- 197
							ImGui.SameLine(0, 0) -- 201
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 202
							drawVerticalSplitter( -- 203
								"LeftSplitter", -- 203
								mainHeight, -- 203
								function(deltaX) return resizeSidePanels(deltaX, "left") end -- 203
							) -- 203
						end -- 195
					) -- 195
				end -- 194
			) -- 194
			ImGui.SameLine(0, 0) -- 206
			ImGui.PushStyleColor( -- 207
				"ChildBg", -- 207
				transparent, -- 207
				function() -- 207
					ImGui.BeginChild( -- 208
						"CenterDock", -- 208
						Vec2(centerWidth, mainHeight), -- 208
						{}, -- 208
						noScrollFlags, -- 208
						function() -- 208
							if state.mode == "Script" then -- 208
								drawScriptPanel(state, attachScriptToNode) -- 209
							else -- 209
								drawViewportPanel(state) -- 209
							end -- 209
						end -- 208
					) -- 208
				end -- 207
			) -- 207
			ImGui.SameLine(0, 0) -- 212
			ImGui.PushStyleColor( -- 213
				"ChildBg", -- 213
				panelBg, -- 213
				function() -- 213
					ImGui.BeginChild( -- 214
						"RightDock", -- 214
						Vec2(state.rightWidth, mainHeight), -- 214
						{}, -- 214
						verticalScrollFlags, -- 214
						function() -- 214
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 215
							drawVerticalSplitter( -- 216
								"RightSplitter", -- 216
								mainHeight, -- 216
								function(deltaX) return resizeSidePanels(deltaX, "right") end -- 216
							) -- 216
							ImGui.SameLine(0, 0) -- 217
							ImGui.BeginChild( -- 218
								"RightDockContent", -- 218
								Vec2( -- 218
									math.max(1, state.rightWidth - splitterWidth), -- 218
									mainHeight -- 218
								), -- 218
								{}, -- 218
								verticalScrollFlags, -- 218
								function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 218
							) -- 218
						end -- 214
					) -- 214
				end -- 213
			) -- 213
			ImGui.PushStyleColor( -- 221
				"ChildBg", -- 221
				panelBg, -- 221
				function() -- 221
					ImGui.BeginChild( -- 222
						"BottomConsoleDock", -- 222
						Vec2(0, bottomHeight), -- 222
						{}, -- 222
						noScrollFlags, -- 222
						function() return drawConsolePanel(state) end -- 222
					) -- 222
				end -- 221
			) -- 221
		end -- 144
	) -- 144
	drawGamePreviewWindow(state) -- 225
end -- 133
function ____exports.drawRuntimeError(message) -- 228
	local size = App.visualSize -- 229
	ImGui.SetNextWindowPos( -- 230
		Vec2(10, 10), -- 230
		"Always" -- 230
	) -- 230
	ImGui.SetNextWindowSize( -- 231
		Vec2( -- 231
			math.max(320, size.width - 20), -- 231
			math.max(220, size.height - 20) -- 231
		), -- 231
		"Always" -- 231
	) -- 231
	ImGui.Begin( -- 232
		"Dora Visual Editor Error", -- 232
		mainWindowFlags, -- 232
		function() -- 232
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 233
			ImGui.Separator() -- 234
			ImGui.TextWrapped(message or "unknown error") -- 235
		end -- 232
	) -- 232
end -- 228
return ____exports -- 228