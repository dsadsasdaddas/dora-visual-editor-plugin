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
local function sceneSaveFile() -- 16
	return workspacePath(Path(".dora", "imgui-editor.scene.json")) -- 17
end -- 16
local function writeSceneFile(state) -- 20
	Content:mkdir(workspacePath(".dora")) -- 21
	local data = { -- 22
		version = 1, -- 23
		gameWidth = math.floor(state.gameWidth), -- 24
		gameHeight = math.floor(state.gameHeight), -- 25
		gameScript = state.gameScript, -- 26
		nodes = {} -- 27
	} -- 27
	for ____, id in ipairs(state.order) do -- 29
		local node = state.nodes[id] -- 30
		if node ~= nil then -- 30
			local ____data_nodes_4 = data.nodes -- 32
			local ____node_id_1 = node.id -- 33
			local ____node_kind_2 = node.kind -- 34
			local ____node_name_3 = node.name -- 35
			local ____temp_0 -- 36
			if node.id == "root" then -- 36
				____temp_0 = nil -- 36
			else -- 36
				____temp_0 = node.parentId -- 36
			end -- 36
			____data_nodes_4[#____data_nodes_4 + 1] = { -- 32
				id = ____node_id_1, -- 33
				kind = ____node_kind_2, -- 34
				name = ____node_name_3, -- 35
				parentId = ____temp_0, -- 36
				x = node.x, -- 37
				y = node.y, -- 38
				scaleX = node.scaleX, -- 39
				scaleY = node.scaleY, -- 40
				rotation = node.rotation, -- 41
				visible = node.visible, -- 42
				texture = node.texture, -- 43
				text = node.text, -- 44
				script = node.script, -- 45
				followTargetId = node.followTargetId, -- 46
				followOffsetX = node.followOffsetX, -- 47
				followOffsetY = node.followOffsetY -- 48
			} -- 48
		end -- 48
	end -- 48
	local text = json.encode(data) -- 52
	local file = sceneSaveFile() -- 53
	if text ~= nil and Content:save(file, text) then -- 53
		local legacyDir = Path(Content.writablePath, ".dora") -- 56
		Content:mkdir(legacyDir) -- 57
		Content:save( -- 58
			Path(legacyDir, "imgui-editor.scene.json"), -- 58
			text -- 58
		) -- 58
		return file -- 59
	end -- 59
	return nil -- 61
end -- 20
local function saveScene(state) -- 64
	local file = writeSceneFile(state) -- 65
	if file ~= nil then -- 65
		state.status = (zh and "已保存：" or "Saved: ") .. file -- 67
	else -- 67
		state.status = zh and "保存失败" or "Save failed" -- 69
	end -- 69
	pushConsole(state, state.status) -- 71
end -- 64
local function attachScriptToNode(state, node, scriptPath, message) -- 74
	node.script = scriptPath -- 75
	node.scriptBuffer.text = scriptPath -- 76
	state.activeScriptNodeId = node.id -- 77
	state.previewDirty = true -- 78
	state.playDirty = true -- 79
	local sceneFile = writeSceneFile(state) -- 80
	if sceneFile == nil then -- 80
		state.status = zh and "脚本已挂载，但场景保存失败" or "Script attached, but scene save failed" -- 82
	else -- 82
		state.status = message or (zh and "脚本已挂载并保存：" or "Script attached and saved: ") .. scriptPath -- 84
	end -- 84
	pushConsole(state, state.status) -- 86
end -- 74
local function bindTextureToSprite(state, node, texture) -- 89
	node.texture = texture -- 90
	node.textureBuffer.text = texture -- 91
	state.selectedAsset = texture -- 92
	state.previewDirty = true -- 93
	state.playDirty = true -- 94
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 95
	pushConsole(state, state.status) -- 96
end -- 89
local function createSpriteFromTexture(state, texture) -- 99
	addChildNode(state, "Sprite") -- 100
	local node = state.nodes[state.selectedId] -- 101
	if node ~= nil and node.kind == "Sprite" then -- 101
		bindTextureToSprite(state, node, texture) -- 103
	end -- 103
end -- 99
local function openNodeScriptInEditor(state, node) -- 107
	openScriptForNode(state, node, attachScriptToNode) -- 108
end -- 107
local function drawVerticalSplitter(id, height, onDrag) -- 111
	local hitWidth = 14 -- 112
	ImGui.PushStyleColor( -- 113
		"Button", -- 113
		Color(1714698820), -- 113
		function() -- 113
			ImGui.PushStyleColor( -- 114
				"ButtonHovered", -- 114
				Color(2857195880), -- 114
				function() -- 114
					ImGui.PushStyleColor( -- 115
						"ButtonActive", -- 115
						Color(4294954035), -- 115
						function() -- 115
							ImGui.Button( -- 116
								"##" .. id, -- 116
								Vec2(hitWidth, height) -- 116
							) -- 116
						end -- 115
					) -- 115
				end -- 114
			) -- 114
		end -- 113
	) -- 113
	if ImGui.IsItemHovered() then -- 113
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 121
	end -- 121
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 121
		local delta = ImGui.GetMouseDragDelta(0) -- 124
		if math.abs(delta.x) >= 1 then -- 124
			onDrag(delta.x) -- 126
			ImGui.ResetMouseDragDelta(0) -- 127
		end -- 127
	end -- 127
end -- 111
function ____exports.drawEditor(state) -- 132
	local size = App.visualSize -- 133
	local margin = 10 -- 134
	local nativeFooterSafeArea = 60 -- 135
	local windowWidth = math.max(360, size.width - margin * 2) -- 136
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 137
	ImGui.SetNextWindowPos( -- 138
		Vec2(margin, margin), -- 138
		"Always" -- 138
	) -- 138
	ImGui.SetNextWindowSize( -- 139
		Vec2(windowWidth, windowHeight), -- 139
		"Always" -- 139
	) -- 139
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0) -- 142
	ImGui.Begin( -- 143
		"Dora Visual Editor", -- 143
		mainWindowFlags, -- 143
		function() -- 143
			drawHeaderPanel(state, saveScene) -- 144
			local avail = ImGui.GetContentRegionAvail() -- 145
			local bottomHeight = math.max( -- 146
				72, -- 146
				math.min( -- 146
					state.bottomHeight, -- 146
					math.floor(avail.y * 0.28) -- 146
				) -- 146
			) -- 146
			if state.mode == "Script" then -- 146
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 148
				ImGui.PushStyleColor( -- 149
					"ChildBg", -- 149
					panelBg, -- 149
					function() -- 149
						ImGui.BeginChild( -- 150
							"ScriptWorkspaceRoot", -- 150
							Vec2(0, scriptHeight), -- 150
							{}, -- 150
							noScrollFlags, -- 150
							function() return drawScriptPanel(state, attachScriptToNode) end -- 150
						) -- 150
					end -- 149
				) -- 149
				ImGui.BeginChild( -- 152
					"ScriptConsoleDock", -- 152
					Vec2(0, bottomHeight), -- 152
					{}, -- 152
					noScrollFlags, -- 152
					function() return drawConsolePanel(state) end -- 152
				) -- 152
				return -- 153
			end -- 153
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 155
			local availableWidth = math.max(320, avail.x) -- 156
			local splitterWidth = 14 -- 157
			local compactLayout = availableWidth < 760 -- 158
			local minLeftWidth = compactLayout and 92 or 132 -- 159
			local minRightWidth = compactLayout and 120 or 180 -- 160
			local minCenterWidth = compactLayout and 80 or 120 -- 161
			local sideBudget = math.max(0, availableWidth - minCenterWidth) -- 162
			if sideBudget <= minLeftWidth + minRightWidth then -- 162
				state.leftWidth = math.max( -- 164
					1, -- 164
					math.floor(sideBudget * 0.45) -- 164
				) -- 164
				state.rightWidth = math.max(1, sideBudget - state.leftWidth) -- 165
			else -- 165
				state.leftWidth = math.max(minLeftWidth, state.leftWidth) -- 167
				state.rightWidth = math.max(minRightWidth, state.rightWidth) -- 168
				if state.leftWidth + state.rightWidth > sideBudget then -- 168
					local ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth) -- 170
					state.leftWidth = math.max( -- 171
						minLeftWidth, -- 171
						math.floor(sideBudget * ratio) -- 171
					) -- 171
					state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth) -- 172
				end -- 172
				state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth) -- 174
				state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth) -- 175
			end -- 175
			local centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth) -- 177
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 178
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 179
			local function clampPanelWidth(value, minValue, maxValue) -- 180
				local safeMax = math.max(1, maxValue) -- 181
				local safeMin = math.min(minValue, safeMax) -- 182
				return math.max( -- 183
					safeMin, -- 183
					math.min(value, safeMax) -- 183
				) -- 183
			end -- 180
			local function resizeSidePanels(deltaX, side) -- 185
				if side == "left" then -- 185
					state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - minCenterWidth) -- 187
				else -- 187
					state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - minCenterWidth) -- 189
				end -- 189
			end -- 185
			ImGui.PushStyleColor( -- 193
				"ChildBg", -- 193
				panelBg, -- 193
				function() -- 193
					ImGui.BeginChild( -- 194
						"LeftDock", -- 194
						Vec2(state.leftWidth, mainHeight), -- 194
						{}, -- 194
						noScrollFlags, -- 194
						function() -- 194
							local contentWidth = math.max(1, state.leftWidth - splitterWidth) -- 195
							ImGui.BeginChild( -- 196
								"LeftDockContent", -- 196
								Vec2(contentWidth, mainHeight), -- 196
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
							ImGui.SameLine(0, 0) -- 200
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 201
							drawVerticalSplitter( -- 202
								"LeftSplitter", -- 202
								mainHeight, -- 202
								function(deltaX) return resizeSidePanels(deltaX, "left") end -- 202
							) -- 202
						end -- 194
					) -- 194
				end -- 193
			) -- 193
			ImGui.SameLine(0, 0) -- 205
			ImGui.PushStyleColor( -- 206
				"ChildBg", -- 206
				transparent, -- 206
				function() -- 206
					ImGui.BeginChild( -- 207
						"CenterDock", -- 207
						Vec2(centerWidth, mainHeight), -- 207
						{}, -- 207
						noScrollFlags, -- 207
						function() -- 207
							if state.mode == "Script" then -- 207
								drawScriptPanel(state, attachScriptToNode) -- 208
							else -- 208
								drawViewportPanel(state) -- 208
							end -- 208
						end -- 207
					) -- 207
				end -- 206
			) -- 206
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
						function() -- 213
							local splitterOrigin = ImGui.GetCursorScreenPos() -- 214
							drawVerticalSplitter( -- 215
								"RightSplitter", -- 215
								mainHeight, -- 215
								function(deltaX) return resizeSidePanels(deltaX, "right") end -- 215
							) -- 215
							ImGui.SameLine(0, 0) -- 216
							ImGui.BeginChild( -- 217
								"RightDockContent", -- 217
								Vec2( -- 217
									math.max(1, state.rightWidth - splitterWidth), -- 217
									mainHeight -- 217
								), -- 217
								{}, -- 217
								verticalScrollFlags, -- 217
								function() return drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor) end -- 217
							) -- 217
						end -- 213
					) -- 213
				end -- 212
			) -- 212
			ImGui.PushStyleColor( -- 220
				"ChildBg", -- 220
				panelBg, -- 220
				function() -- 220
					ImGui.BeginChild( -- 221
						"BottomConsoleDock", -- 221
						Vec2(0, bottomHeight), -- 221
						{}, -- 221
						noScrollFlags, -- 221
						function() return drawConsolePanel(state) end -- 221
					) -- 221
				end -- 220
			) -- 220
		end -- 143
	) -- 143
	drawGamePreviewWindow(state) -- 224
end -- 132
function ____exports.drawRuntimeError(message) -- 227
	local size = App.visualSize -- 228
	ImGui.SetNextWindowPos( -- 229
		Vec2(10, 10), -- 229
		"Always" -- 229
	) -- 229
	ImGui.SetNextWindowSize( -- 230
		Vec2( -- 230
			math.max(320, size.width - 20), -- 230
			math.max(220, size.height - 20) -- 230
		), -- 230
		"Always" -- 230
	) -- 230
	ImGui.Begin( -- 231
		"Dora Visual Editor Error", -- 231
		mainWindowFlags, -- 231
		function() -- 231
			ImGui.TextColored(warnColor, zh and "Dora Visual Editor 运行时错误" or "Dora Visual Editor Runtime Error") -- 232
			ImGui.Separator() -- 233
			ImGui.TextWrapped(message or "unknown error") -- 234
		end -- 231
	) -- 231
end -- 227
return ____exports -- 227