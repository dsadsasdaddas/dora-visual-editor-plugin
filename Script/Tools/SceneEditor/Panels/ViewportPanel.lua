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
local function viewportScale(state) -- 10
	return math.max(0.25, state.zoom / 100) -- 11
end -- 10
local function clampZoom(value) -- 14
	return math.max( -- 15
		25, -- 15
		math.min(400, value) -- 15
	) -- 15
end -- 14
local function zoomViewportAt(state, delta, screenX, screenY) -- 18
	if delta == 0 then -- 18
		return -- 19
	end -- 19
	local before = state.zoom -- 20
	local beforeScale = viewportScale(state) -- 21
	local p = state.preview -- 22
	local centerX = p.x + p.width / 2 -- 23
	local centerY = p.y + p.height / 2 -- 24
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 25
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 26
	state.zoom = clampZoom(state.zoom + delta) -- 27
	if state.zoom ~= before then -- 27
		local afterScale = viewportScale(state) -- 29
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 30
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 31
		state.previewDirty = true -- 32
	end -- 32
end -- 18
local function zoomViewportFromCenter(state, delta) -- 36
	local p = state.preview -- 37
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 38
end -- 36
local function screenToScene(state, screenX, screenY) -- 41
	local p = state.preview -- 42
	local scale = viewportScale(state) -- 43
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 44
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 45
	return {localX / scale, localY / scale} -- 46
end -- 41
local function pickNodeAt(state, screenX, screenY) -- 49
	local sceneX, sceneY = table.unpack( -- 50
		screenToScene(state, screenX, screenY), -- 50
		1, -- 50
		2 -- 50
	) -- 50
	do -- 50
		local i = #state.order -- 51
		while i >= 1 do -- 51
			local id = state.order[i] -- 52
			local node = state.nodes[id] -- 53
			if node ~= nil and id ~= "root" and node.visible then -- 53
				if isScenePointInsideNode(node, sceneX, sceneY) then -- 53
					return id -- 55
				end -- 55
			end -- 55
			i = i - 1 -- 51
		end -- 51
	end -- 51
	return nil -- 58
end -- 49
local function handleViewportMouse(state, hovered) -- 61
	if state.isPlaying then -- 61
		state.draggingNodeId = nil -- 63
		state.draggingViewport = false -- 64
		return -- 65
	end -- 65
	if not hovered then -- 65
		return -- 67
	end -- 67
	local spacePressed = Keyboard:isKeyPressed("Space") -- 68
	local wheel = Mouse.wheel -- 69
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 70
	if wheelDelta ~= 0 then -- 70
		local mouse = ImGui.GetMousePos() -- 72
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 73
	end -- 73
	if ImGui.IsMouseClicked(2) then -- 73
		state.draggingNodeId = nil -- 76
		state.draggingViewport = true -- 77
		ImGui.ResetMouseDragDelta(2) -- 78
	end -- 78
	if ImGui.IsMouseClicked(0) then -- 78
		if spacePressed then -- 78
			state.draggingNodeId = nil -- 82
			state.draggingViewport = true -- 83
		else -- 83
			local mouse = ImGui.GetMousePos() -- 85
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 86
			if picked ~= nil then -- 86
				state.selectedId = picked -- 88
				state.previewDirty = true -- 89
				state.draggingNodeId = picked -- 90
				state.draggingViewport = false -- 91
			else -- 91
				state.draggingNodeId = nil -- 93
				state.draggingViewport = true -- 94
			end -- 94
		end -- 94
		ImGui.ResetMouseDragDelta(0) -- 97
	end -- 97
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 97
		state.draggingNodeId = nil -- 100
		state.draggingViewport = false -- 101
	end -- 101
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 101
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 104
		local delta = ImGui.GetMouseDragDelta(panButton) -- 105
		if delta.x ~= 0 or delta.y ~= 0 then -- 105
			if state.draggingNodeId ~= nil and panButton == 0 then -- 105
				local node = state.nodes[state.draggingNodeId] -- 108
				if node ~= nil then -- 108
					local scale = viewportScale(state) -- 110
					node.x = node.x + delta.x / scale -- 111
					node.y = node.y - delta.y / scale -- 112
					if state.snapEnabled then -- 112
						local step = 16 -- 114
						node.x = math.floor(node.x / step + 0.5) * step -- 115
						node.y = math.floor(node.y / step + 0.5) * step -- 116
					end -- 116
					state.previewDirty = true -- 118
					state.playDirty = true -- 119
				end -- 119
			elseif state.draggingViewport then -- 119
				state.viewportPanX = state.viewportPanX + delta.x -- 122
				state.viewportPanY = state.viewportPanY - delta.y -- 123
			end -- 123
			ImGui.ResetMouseDragDelta(panButton) -- 125
		end -- 125
	end -- 125
end -- 61
local function drawViewportToolButton(state, tool, label) -- 130
	if state.isPlaying then -- 130
		ImGui.BeginDisabled(function() return ImGui.Button(label) end) -- 132
		return -- 133
	end -- 133
	local active = state.viewportTool == tool -- 135
	if active then -- 135
		ImGui.PushStyleColor( -- 137
			"Button", -- 137
			Color(4281349698), -- 137
			function() -- 137
				ImGui.PushStyleColor( -- 138
					"Text", -- 138
					themeColor, -- 138
					function() -- 138
						if ImGui.Button(label) then -- 138
							state.viewportTool = tool -- 139
						end -- 139
					end -- 138
				) -- 138
			end -- 137
		) -- 137
	elseif ImGui.Button(label) then -- 137
		state.viewportTool = tool -- 143
	end -- 143
end -- 130
function ____exports.drawViewportPanel(state) -- 147
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 148
	ImGui.SameLine() -- 149
	drawViewportToolButton(state, "Select", "Select") -- 150
	ImGui.SameLine() -- 151
	drawViewportToolButton(state, "Move", "Move") -- 152
	ImGui.SameLine() -- 153
	drawViewportToolButton(state, "Rotate", "Rotate") -- 154
	ImGui.SameLine() -- 155
	drawViewportToolButton(state, "Scale", "Scale") -- 156
	ImGui.SameLine() -- 157
	ImGui.TextDisabled("|") -- 158
	ImGui.SameLine() -- 159
	local snapChanged = false -- 160
	local snap = state.snapEnabled -- 161
	if state.isPlaying then -- 161
		ImGui.BeginDisabled(function() -- 163
			local changed, value = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 164
			snapChanged = changed -- 165
			snap = value -- 166
		end) -- 163
	else -- 163
		snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 169
	end -- 169
	if not state.isPlaying and snapChanged then -- 169
		state.snapEnabled = snap -- 171
	end -- 171
	ImGui.SameLine() -- 172
	local gridChanged = false -- 173
	local grid = state.showGrid -- 174
	if state.isPlaying then -- 174
		ImGui.BeginDisabled(function() -- 176
			local changed, value = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 177
			gridChanged = changed -- 178
			grid = value -- 179
		end) -- 176
	else -- 176
		gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 182
	end -- 182
	if not state.isPlaying and gridChanged then -- 182
		state.showGrid = grid -- 184
		state.previewDirty = true -- 184
	end -- 184
	ImGui.SameLine() -- 185
	if state.isPlaying then -- 185
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "居中" or "Center") end) -- 187
	elseif ImGui.Button(zh and "居中" or "Center") then -- 187
		state.viewportPanX = 0 -- 189
		state.viewportPanY = 0 -- 190
		state.zoom = 100 -- 191
		state.previewDirty = true -- 192
	end -- 192
	ImGui.SameLine() -- 194
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 195
	ImGui.Separator() -- 196
	local cursor = ImGui.GetCursorScreenPos() -- 197
	local avail = ImGui.GetContentRegionAvail() -- 198
	local viewportWidth = math.max(360, avail.x - 8) -- 199
	local viewportHeight = math.max(300, avail.y - 38) -- 200
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 200
		state.previewDirty = true -- 202
	end -- 202
	state.preview.x = cursor.x -- 204
	state.preview.y = cursor.y -- 205
	state.preview.width = viewportWidth -- 206
	state.preview.height = viewportHeight -- 207
	updatePreviewRuntime(state) -- 208
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 209
	local hovered = ImGui.IsItemHovered() -- 210
	handleViewportMouse(state, hovered) -- 211
	if state.isPlaying then -- 211
		ImGui.SetCursorScreenPos(Vec2(cursor.x + 12, cursor.y + 10)) -- 213
		ImGui.TextColored(okColor, zh and "▶ 运行模式" or "▶ PLAY MODE") -- 214
		ImGui.SameLine() -- 215
		ImGui.TextDisabled(zh and "Stop 后才能编辑场景" or "Stop to edit the scene") -- 216
	end -- 216
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 218
	if state.isPlaying then -- 218
		ImGui.BeginDisabled(function() -- 220
			ImGui.SmallButton("-##viewport_zoom_out") -- 221
			ImGui.SameLine() -- 222
			ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") -- 223
			ImGui.SameLine() -- 224
			ImGui.SmallButton("+##viewport_zoom_in") -- 225
		end) -- 220
	else -- 220
		if ImGui.SmallButton("-##viewport_zoom_out") then -- 220
			zoomViewportFromCenter(state, -10) -- 228
		end -- 228
		ImGui.SameLine() -- 229
		ImGui.PushStyleColor( -- 230
			"Text", -- 230
			themeColor, -- 230
			function() -- 230
				if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 230
					state.zoom = 100 -- 232
					state.viewportPanX = 0 -- 233
					state.viewportPanY = 0 -- 234
					state.previewDirty = true -- 235
				end -- 235
			end -- 230
		) -- 230
		ImGui.SameLine() -- 238
		if ImGui.SmallButton("+##viewport_zoom_in") then -- 238
			zoomViewportFromCenter(state, 10) -- 239
		end -- 239
	end -- 239
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 241
	ImGui.Separator() -- 242
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 243
	ImGui.SameLine() -- 244
	if state.isPlaying then -- 244
		ImGui.TextDisabled(zh and "运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。" or "Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.") -- 246
	else -- 246
		ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 248
	end -- 248
end -- 147
return ____exports -- 147