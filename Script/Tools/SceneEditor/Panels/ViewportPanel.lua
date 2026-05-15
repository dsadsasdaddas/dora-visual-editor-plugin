-- [ts]: ViewportPanel.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Mouse = ____Dora.Mouse -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local okColor = ____Theme.okColor -- 5
local themeColor = ____Theme.themeColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____SpriteMetrics = require("Script.Tools.SceneEditor.SpriteMetrics") -- 8
local isScenePointInsideNode = ____SpriteMetrics.isScenePointInsideNode -- 8
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 9
local canSelectNodeKindInViewport = ____NodeCapabilities.canSelectNodeKindInViewport -- 9
local nodeKindViewportPickLayer = ____NodeCapabilities.nodeKindViewportPickLayer -- 9
local function viewportScale(state) -- 11
	return math.max(0.25, state.zoom / 100) -- 12
end -- 11
local function clampZoom(value) -- 15
	return math.max( -- 16
		25, -- 16
		math.min(400, value) -- 16
	) -- 16
end -- 15
local function zoomViewportAt(state, delta, screenX, screenY) -- 19
	if delta == 0 then -- 19
		return -- 20
	end -- 20
	local before = state.zoom -- 21
	local beforeScale = viewportScale(state) -- 22
	local p = state.preview -- 23
	local centerX = p.x + p.width / 2 -- 24
	local centerY = p.y + p.height / 2 -- 25
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 26
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 27
	state.zoom = clampZoom(state.zoom + delta) -- 28
	if state.zoom ~= before then -- 28
		local afterScale = viewportScale(state) -- 30
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 31
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 32
		state.previewDirty = true -- 33
	end -- 33
end -- 19
local function zoomViewportFromCenter(state, delta) -- 37
	local p = state.preview -- 38
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 39
end -- 37
local function screenToScene(state, screenX, screenY) -- 42
	local p = state.preview -- 43
	local scale = viewportScale(state) -- 44
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 45
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 46
	return {localX / scale, localY / scale} -- 47
end -- 42
local function pickNodeAt(state, screenX, screenY) -- 50
	local sceneX, sceneY = table.unpack( -- 51
		screenToScene(state, screenX, screenY), -- 51
		1, -- 51
		2 -- 51
	) -- 51
	do -- 51
		local i = #state.order -- 52
		while i >= 1 do -- 52
			local id = state.order[i] -- 53
			local node = state.nodes[id] -- 54
			if node ~= nil and node.visible and canSelectNodeKindInViewport(node.kind) and nodeKindViewportPickLayer(node.kind) == "object" then -- 54
				if isScenePointInsideNode( -- 54
					node, -- 56
					sceneX, -- 56
					sceneY, -- 56
					state.gameWidth, -- 56
					state.gameHeight -- 56
				) then -- 56
					return id -- 56
				end -- 56
			end -- 56
			i = i - 1 -- 52
		end -- 52
	end -- 52
	do -- 52
		local i = #state.order -- 59
		while i >= 1 do -- 59
			local id = state.order[i] -- 60
			local node = state.nodes[id] -- 61
			if node ~= nil and node.visible and canSelectNodeKindInViewport(node.kind) and nodeKindViewportPickLayer(node.kind) == "camera" then -- 61
				if isScenePointInsideNode( -- 61
					node, -- 63
					sceneX, -- 63
					sceneY, -- 63
					state.gameWidth, -- 63
					state.gameHeight -- 63
				) then -- 63
					return id -- 63
				end -- 63
			end -- 63
			i = i - 1 -- 59
		end -- 59
	end -- 59
	return nil -- 66
end -- 50
local function handleViewportMouse(state, hovered) -- 69
	if state.isPlaying then -- 69
		state.draggingNodeId = nil -- 71
		state.draggingViewport = false -- 72
		return -- 73
	end -- 73
	if not hovered then -- 73
		return -- 75
	end -- 75
	local spacePressed = Keyboard:isKeyPressed("Space") -- 76
	local wheel = Mouse.wheel -- 77
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 78
	if wheelDelta ~= 0 then -- 78
		local mouse = ImGui.GetMousePos() -- 80
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 81
	end -- 81
	if ImGui.IsMouseClicked(2) then -- 81
		state.draggingNodeId = nil -- 84
		state.draggingViewport = true -- 85
		ImGui.ResetMouseDragDelta(2) -- 86
	end -- 86
	if ImGui.IsMouseClicked(0) then -- 86
		if spacePressed then -- 86
			state.draggingNodeId = nil -- 90
			state.draggingViewport = true -- 91
		else -- 91
			local mouse = ImGui.GetMousePos() -- 93
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 94
			if picked ~= nil then -- 94
				state.selectedId = picked -- 96
				state.previewDirty = true -- 97
				state.draggingNodeId = picked -- 98
				state.draggingViewport = false -- 99
			else -- 99
				state.draggingNodeId = nil -- 101
				state.draggingViewport = true -- 102
			end -- 102
		end -- 102
		ImGui.ResetMouseDragDelta(0) -- 105
	end -- 105
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 105
		state.draggingNodeId = nil -- 108
		state.draggingViewport = false -- 109
	end -- 109
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 109
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 112
		local delta = ImGui.GetMouseDragDelta(panButton) -- 113
		if delta.x ~= 0 or delta.y ~= 0 then -- 113
			if state.draggingNodeId ~= nil and panButton == 0 then -- 113
				local node = state.nodes[state.draggingNodeId] -- 116
				if node ~= nil then -- 116
					local scale = viewportScale(state) -- 118
					node.x = node.x + delta.x / scale -- 119
					node.y = node.y - delta.y / scale -- 120
					if state.snapEnabled then -- 120
						local step = 16 -- 122
						node.x = math.floor(node.x / step + 0.5) * step -- 123
						node.y = math.floor(node.y / step + 0.5) * step -- 124
					end -- 124
					state.previewDirty = true -- 126
					state.playDirty = true -- 127
				end -- 127
			elseif state.draggingViewport then -- 127
				state.viewportPanX = state.viewportPanX + delta.x -- 130
				state.viewportPanY = state.viewportPanY - delta.y -- 131
			end -- 131
			ImGui.ResetMouseDragDelta(panButton) -- 133
		end -- 133
	end -- 133
end -- 69
local function drawViewportToolButton(state, tool, label) -- 138
	if state.isPlaying then -- 138
		ImGui.BeginDisabled(function() return ImGui.Button(label) end) -- 140
		return -- 141
	end -- 141
	local active = state.viewportTool == tool -- 143
	if active then -- 143
		ImGui.PushStyleColor( -- 145
			"Button", -- 145
			Color(4281349698), -- 145
			function() -- 145
				ImGui.PushStyleColor( -- 146
					"Text", -- 146
					themeColor, -- 146
					function() -- 146
						if ImGui.Button(label) then -- 146
							state.viewportTool = tool -- 147
						end -- 147
					end -- 146
				) -- 146
			end -- 145
		) -- 145
	elseif ImGui.Button(label) then -- 145
		state.viewportTool = tool -- 151
	end -- 151
end -- 138
function ____exports.drawViewportPanel(state) -- 155
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 156
	ImGui.SameLine() -- 157
	drawViewportToolButton(state, "Select", "Select") -- 158
	ImGui.SameLine() -- 159
	drawViewportToolButton(state, "Move", "Move") -- 160
	ImGui.SameLine() -- 161
	drawViewportToolButton(state, "Rotate", "Rotate") -- 162
	ImGui.SameLine() -- 163
	drawViewportToolButton(state, "Scale", "Scale") -- 164
	ImGui.SameLine() -- 165
	ImGui.TextDisabled("|") -- 166
	ImGui.SameLine() -- 167
	local snapChanged = false -- 168
	local snap = state.snapEnabled -- 169
	if state.isPlaying then -- 169
		ImGui.BeginDisabled(function() -- 171
			local changed, value = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 172
			snapChanged = changed -- 173
			snap = value -- 174
		end) -- 171
	else -- 171
		snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 177
	end -- 177
	if not state.isPlaying and snapChanged then -- 177
		state.snapEnabled = snap -- 179
	end -- 179
	ImGui.SameLine() -- 180
	local gridChanged = false -- 181
	local grid = state.showGrid -- 182
	if state.isPlaying then -- 182
		ImGui.BeginDisabled(function() -- 184
			local changed, value = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 185
			gridChanged = changed -- 186
			grid = value -- 187
		end) -- 184
	else -- 184
		gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 190
	end -- 190
	if not state.isPlaying and gridChanged then -- 190
		state.showGrid = grid -- 192
		state.previewDirty = true -- 192
	end -- 192
	ImGui.SameLine() -- 193
	if state.isPlaying then -- 193
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "居中" or "Center") end) -- 195
	elseif ImGui.Button(zh and "居中" or "Center") then -- 195
		state.viewportPanX = 0 -- 197
		state.viewportPanY = 0 -- 198
		state.zoom = 100 -- 199
		state.previewDirty = true -- 200
	end -- 200
	ImGui.SameLine() -- 202
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 203
	ImGui.Separator() -- 204
	local cursor = ImGui.GetCursorScreenPos() -- 205
	local avail = ImGui.GetContentRegionAvail() -- 206
	local viewportWidth = math.max(360, avail.x - 8) -- 207
	local viewportHeight = math.max(300, avail.y - 38) -- 208
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 208
		state.previewDirty = true -- 210
	end -- 210
	state.preview.x = cursor.x -- 212
	state.preview.y = cursor.y -- 213
	state.preview.width = viewportWidth -- 214
	state.preview.height = viewportHeight -- 215
	updatePreviewRuntime(state) -- 216
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 217
	local hovered = ImGui.IsItemHovered() -- 218
	handleViewportMouse(state, hovered) -- 219
	if state.isPlaying then -- 219
		ImGui.SetCursorScreenPos(Vec2(cursor.x + 12, cursor.y + 10)) -- 221
		ImGui.TextColored(okColor, zh and "▶ 运行模式" or "▶ PLAY MODE") -- 222
		ImGui.SameLine() -- 223
		ImGui.TextDisabled(zh and "Stop 后才能编辑场景" or "Stop to edit the scene") -- 224
	end -- 224
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 226
	if state.isPlaying then -- 226
		ImGui.BeginDisabled(function() -- 228
			ImGui.SmallButton("-##viewport_zoom_out") -- 229
			ImGui.SameLine() -- 230
			ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") -- 231
			ImGui.SameLine() -- 232
			ImGui.SmallButton("+##viewport_zoom_in") -- 233
		end) -- 228
	else -- 228
		if ImGui.SmallButton("-##viewport_zoom_out") then -- 228
			zoomViewportFromCenter(state, -10) -- 236
		end -- 236
		ImGui.SameLine() -- 237
		ImGui.PushStyleColor( -- 238
			"Text", -- 238
			themeColor, -- 238
			function() -- 238
				if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 238
					state.zoom = 100 -- 240
					state.viewportPanX = 0 -- 241
					state.viewportPanY = 0 -- 242
					state.previewDirty = true -- 243
				end -- 243
			end -- 238
		) -- 238
		ImGui.SameLine() -- 246
		if ImGui.SmallButton("+##viewport_zoom_in") then -- 246
			zoomViewportFromCenter(state, 10) -- 247
		end -- 247
	end -- 247
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 249
	ImGui.Separator() -- 250
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 251
	ImGui.SameLine() -- 252
	if state.isPlaying then -- 252
		ImGui.TextDisabled(zh and "运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。" or "Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.") -- 254
	else -- 254
		ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 256
	end -- 256
end -- 155
return ____exports -- 155