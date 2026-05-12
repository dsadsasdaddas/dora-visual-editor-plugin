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
				if node.kind == "Camera" then -- 53
					local width = math.max(160, state.gameWidth) -- 56
					local height = math.max(120, state.gameHeight) -- 57
					if math.abs(sceneX - node.x) <= width / 2 and math.abs(sceneY - node.y) <= height / 2 then -- 57
						return id -- 58
					end -- 58
				elseif isScenePointInsideNode(node, sceneX, sceneY) then -- 58
					return id -- 59
				end -- 59
			end -- 59
			i = i - 1 -- 51
		end -- 51
	end -- 51
	return nil -- 62
end -- 49
local function handleViewportMouse(state, hovered) -- 65
	if state.isPlaying then -- 65
		state.draggingNodeId = nil -- 67
		state.draggingViewport = false -- 68
		return -- 69
	end -- 69
	if not hovered then -- 69
		return -- 71
	end -- 71
	local spacePressed = Keyboard:isKeyPressed("Space") -- 72
	local wheel = Mouse.wheel -- 73
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 74
	if wheelDelta ~= 0 then -- 74
		local mouse = ImGui.GetMousePos() -- 76
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 77
	end -- 77
	if ImGui.IsMouseClicked(2) then -- 77
		state.draggingNodeId = nil -- 80
		state.draggingViewport = true -- 81
		ImGui.ResetMouseDragDelta(2) -- 82
	end -- 82
	if ImGui.IsMouseClicked(0) then -- 82
		if spacePressed then -- 82
			state.draggingNodeId = nil -- 86
			state.draggingViewport = true -- 87
		else -- 87
			local mouse = ImGui.GetMousePos() -- 89
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 90
			if picked ~= nil then -- 90
				state.selectedId = picked -- 92
				state.previewDirty = true -- 93
				state.draggingNodeId = picked -- 94
				state.draggingViewport = false -- 95
			else -- 95
				state.draggingNodeId = nil -- 97
				state.draggingViewport = true -- 98
			end -- 98
		end -- 98
		ImGui.ResetMouseDragDelta(0) -- 101
	end -- 101
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 101
		state.draggingNodeId = nil -- 104
		state.draggingViewport = false -- 105
	end -- 105
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 105
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 108
		local delta = ImGui.GetMouseDragDelta(panButton) -- 109
		if delta.x ~= 0 or delta.y ~= 0 then -- 109
			if state.draggingNodeId ~= nil and panButton == 0 then -- 109
				local node = state.nodes[state.draggingNodeId] -- 112
				if node ~= nil then -- 112
					local scale = viewportScale(state) -- 114
					node.x = node.x + delta.x / scale -- 115
					node.y = node.y - delta.y / scale -- 116
					if state.snapEnabled then -- 116
						local step = 16 -- 118
						node.x = math.floor(node.x / step + 0.5) * step -- 119
						node.y = math.floor(node.y / step + 0.5) * step -- 120
					end -- 120
					state.previewDirty = true -- 122
					state.playDirty = true -- 123
				end -- 123
			elseif state.draggingViewport then -- 123
				state.viewportPanX = state.viewportPanX + delta.x -- 126
				state.viewportPanY = state.viewportPanY - delta.y -- 127
			end -- 127
			ImGui.ResetMouseDragDelta(panButton) -- 129
		end -- 129
	end -- 129
end -- 65
local function drawViewportToolButton(state, tool, label) -- 134
	if state.isPlaying then -- 134
		ImGui.BeginDisabled(function() return ImGui.Button(label) end) -- 136
		return -- 137
	end -- 137
	local active = state.viewportTool == tool -- 139
	if active then -- 139
		ImGui.PushStyleColor( -- 141
			"Button", -- 141
			Color(4281349698), -- 141
			function() -- 141
				ImGui.PushStyleColor( -- 142
					"Text", -- 142
					themeColor, -- 142
					function() -- 142
						if ImGui.Button(label) then -- 142
							state.viewportTool = tool -- 143
						end -- 143
					end -- 142
				) -- 142
			end -- 141
		) -- 141
	elseif ImGui.Button(label) then -- 141
		state.viewportTool = tool -- 147
	end -- 147
end -- 134
function ____exports.drawViewportPanel(state) -- 151
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 152
	ImGui.SameLine() -- 153
	drawViewportToolButton(state, "Select", "Select") -- 154
	ImGui.SameLine() -- 155
	drawViewportToolButton(state, "Move", "Move") -- 156
	ImGui.SameLine() -- 157
	drawViewportToolButton(state, "Rotate", "Rotate") -- 158
	ImGui.SameLine() -- 159
	drawViewportToolButton(state, "Scale", "Scale") -- 160
	ImGui.SameLine() -- 161
	ImGui.TextDisabled("|") -- 162
	ImGui.SameLine() -- 163
	local snapChanged = false -- 164
	local snap = state.snapEnabled -- 165
	if state.isPlaying then -- 165
		ImGui.BeginDisabled(function() -- 167
			local changed, value = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 168
			snapChanged = changed -- 169
			snap = value -- 170
		end) -- 167
	else -- 167
		snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 173
	end -- 173
	if not state.isPlaying and snapChanged then -- 173
		state.snapEnabled = snap -- 175
	end -- 175
	ImGui.SameLine() -- 176
	local gridChanged = false -- 177
	local grid = state.showGrid -- 178
	if state.isPlaying then -- 178
		ImGui.BeginDisabled(function() -- 180
			local changed, value = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 181
			gridChanged = changed -- 182
			grid = value -- 183
		end) -- 180
	else -- 180
		gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 186
	end -- 186
	if not state.isPlaying and gridChanged then -- 186
		state.showGrid = grid -- 188
		state.previewDirty = true -- 188
	end -- 188
	ImGui.SameLine() -- 189
	if state.isPlaying then -- 189
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "居中" or "Center") end) -- 191
	elseif ImGui.Button(zh and "居中" or "Center") then -- 191
		state.viewportPanX = 0 -- 193
		state.viewportPanY = 0 -- 194
		state.zoom = 100 -- 195
		state.previewDirty = true -- 196
	end -- 196
	ImGui.SameLine() -- 198
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 199
	ImGui.Separator() -- 200
	local cursor = ImGui.GetCursorScreenPos() -- 201
	local avail = ImGui.GetContentRegionAvail() -- 202
	local viewportWidth = math.max(360, avail.x - 8) -- 203
	local viewportHeight = math.max(300, avail.y - 38) -- 204
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 204
		state.previewDirty = true -- 206
	end -- 206
	state.preview.x = cursor.x -- 208
	state.preview.y = cursor.y -- 209
	state.preview.width = viewportWidth -- 210
	state.preview.height = viewportHeight -- 211
	updatePreviewRuntime(state) -- 212
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 213
	local hovered = ImGui.IsItemHovered() -- 214
	handleViewportMouse(state, hovered) -- 215
	if state.isPlaying then -- 215
		ImGui.SetCursorScreenPos(Vec2(cursor.x + 12, cursor.y + 10)) -- 217
		ImGui.TextColored(okColor, zh and "▶ 运行模式" or "▶ PLAY MODE") -- 218
		ImGui.SameLine() -- 219
		ImGui.TextDisabled(zh and "Stop 后才能编辑场景" or "Stop to edit the scene") -- 220
	end -- 220
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 222
	if state.isPlaying then -- 222
		ImGui.BeginDisabled(function() -- 224
			ImGui.SmallButton("-##viewport_zoom_out") -- 225
			ImGui.SameLine() -- 226
			ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") -- 227
			ImGui.SameLine() -- 228
			ImGui.SmallButton("+##viewport_zoom_in") -- 229
		end) -- 224
	else -- 224
		if ImGui.SmallButton("-##viewport_zoom_out") then -- 224
			zoomViewportFromCenter(state, -10) -- 232
		end -- 232
		ImGui.SameLine() -- 233
		ImGui.PushStyleColor( -- 234
			"Text", -- 234
			themeColor, -- 234
			function() -- 234
				if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 234
					state.zoom = 100 -- 236
					state.viewportPanX = 0 -- 237
					state.viewportPanY = 0 -- 238
					state.previewDirty = true -- 239
				end -- 239
			end -- 234
		) -- 234
		ImGui.SameLine() -- 242
		if ImGui.SmallButton("+##viewport_zoom_in") then -- 242
			zoomViewportFromCenter(state, 10) -- 243
		end -- 243
	end -- 243
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 245
	ImGui.Separator() -- 246
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 247
	ImGui.SameLine() -- 248
	if state.isPlaying then -- 248
		ImGui.TextDisabled(zh and "运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。" or "Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.") -- 250
	else -- 250
		ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 252
	end -- 252
end -- 151
return ____exports -- 151