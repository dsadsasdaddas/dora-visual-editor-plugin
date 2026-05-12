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
local function viewportScale(state) -- 9
	return math.max(0.25, state.zoom / 100) -- 10
end -- 9
local function clampZoom(value) -- 13
	return math.max( -- 14
		25, -- 14
		math.min(400, value) -- 14
	) -- 14
end -- 13
local function zoomViewportAt(state, delta, screenX, screenY) -- 17
	if delta == 0 then -- 17
		return -- 18
	end -- 18
	local before = state.zoom -- 19
	local beforeScale = viewportScale(state) -- 20
	local p = state.preview -- 21
	local centerX = p.x + p.width / 2 -- 22
	local centerY = p.y + p.height / 2 -- 23
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 24
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 25
	state.zoom = clampZoom(state.zoom + delta) -- 26
	if state.zoom ~= before then -- 26
		local afterScale = viewportScale(state) -- 28
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 29
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 30
		state.previewDirty = true -- 31
	end -- 31
end -- 17
local function zoomViewportFromCenter(state, delta) -- 35
	local p = state.preview -- 36
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 37
end -- 35
local function screenToScene(state, screenX, screenY) -- 40
	local p = state.preview -- 41
	local scale = viewportScale(state) -- 42
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 43
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 44
	return {localX / scale, localY / scale} -- 45
end -- 40
local function pickNodeAt(state, screenX, screenY) -- 48
	local sceneX, sceneY = table.unpack( -- 49
		screenToScene(state, screenX, screenY), -- 49
		1, -- 49
		2 -- 49
	) -- 49
	do -- 49
		local i = #state.order -- 50
		while i >= 1 do -- 50
			local id = state.order[i] -- 51
			local node = state.nodes[id] -- 52
			if node ~= nil and id ~= "root" and node.visible then -- 52
				local dx = sceneX - node.x -- 54
				local dy = sceneY - node.y -- 55
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 56
				if dx * dx + dy * dy <= radius * radius then -- 56
					return id -- 57
				end -- 57
			end -- 57
			i = i - 1 -- 50
		end -- 50
	end -- 50
	return nil -- 60
end -- 48
local function handleViewportMouse(state, hovered) -- 63
	if state.isPlaying then -- 63
		state.draggingNodeId = nil -- 65
		state.draggingViewport = false -- 66
		return -- 67
	end -- 67
	if not hovered then -- 67
		return -- 69
	end -- 69
	local spacePressed = Keyboard:isKeyPressed("Space") -- 70
	local wheel = Mouse.wheel -- 71
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 72
	if wheelDelta ~= 0 then -- 72
		local mouse = ImGui.GetMousePos() -- 74
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 75
	end -- 75
	if ImGui.IsMouseClicked(2) then -- 75
		state.draggingNodeId = nil -- 78
		state.draggingViewport = true -- 79
		ImGui.ResetMouseDragDelta(2) -- 80
	end -- 80
	if ImGui.IsMouseClicked(0) then -- 80
		if spacePressed then -- 80
			state.draggingNodeId = nil -- 84
			state.draggingViewport = true -- 85
		else -- 85
			local mouse = ImGui.GetMousePos() -- 87
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 88
			if picked ~= nil then -- 88
				state.selectedId = picked -- 90
				state.previewDirty = true -- 91
				state.draggingNodeId = picked -- 92
				state.draggingViewport = false -- 93
			else -- 93
				state.draggingNodeId = nil -- 95
				state.draggingViewport = true -- 96
			end -- 96
		end -- 96
		ImGui.ResetMouseDragDelta(0) -- 99
	end -- 99
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 99
		state.draggingNodeId = nil -- 102
		state.draggingViewport = false -- 103
	end -- 103
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 103
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 106
		local delta = ImGui.GetMouseDragDelta(panButton) -- 107
		if delta.x ~= 0 or delta.y ~= 0 then -- 107
			if state.draggingNodeId ~= nil and panButton == 0 then -- 107
				local node = state.nodes[state.draggingNodeId] -- 110
				if node ~= nil then -- 110
					local scale = viewportScale(state) -- 112
					node.x = node.x + delta.x / scale -- 113
					node.y = node.y - delta.y / scale -- 114
					if state.snapEnabled then -- 114
						local step = 16 -- 116
						node.x = math.floor(node.x / step + 0.5) * step -- 117
						node.y = math.floor(node.y / step + 0.5) * step -- 118
					end -- 118
					state.previewDirty = true -- 120
					state.playDirty = true -- 121
				end -- 121
			elseif state.draggingViewport then -- 121
				state.viewportPanX = state.viewportPanX + delta.x -- 124
				state.viewportPanY = state.viewportPanY - delta.y -- 125
			end -- 125
			ImGui.ResetMouseDragDelta(panButton) -- 127
		end -- 127
	end -- 127
end -- 63
local function drawViewportToolButton(state, tool, label) -- 132
	if state.isPlaying then -- 132
		ImGui.BeginDisabled(function() return ImGui.Button(label) end) -- 134
		return -- 135
	end -- 135
	local active = state.viewportTool == tool -- 137
	if active then -- 137
		ImGui.PushStyleColor( -- 139
			"Button", -- 139
			Color(4281349698), -- 139
			function() -- 139
				ImGui.PushStyleColor( -- 140
					"Text", -- 140
					themeColor, -- 140
					function() -- 140
						if ImGui.Button(label) then -- 140
							state.viewportTool = tool -- 141
						end -- 141
					end -- 140
				) -- 140
			end -- 139
		) -- 139
	elseif ImGui.Button(label) then -- 139
		state.viewportTool = tool -- 145
	end -- 145
end -- 132
function ____exports.drawViewportPanel(state) -- 149
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 150
	ImGui.SameLine() -- 151
	drawViewportToolButton(state, "Select", "Select") -- 152
	ImGui.SameLine() -- 153
	drawViewportToolButton(state, "Move", "Move") -- 154
	ImGui.SameLine() -- 155
	drawViewportToolButton(state, "Rotate", "Rotate") -- 156
	ImGui.SameLine() -- 157
	drawViewportToolButton(state, "Scale", "Scale") -- 158
	ImGui.SameLine() -- 159
	ImGui.TextDisabled("|") -- 160
	ImGui.SameLine() -- 161
	local snapChanged = false -- 162
	local snap = state.snapEnabled -- 163
	if state.isPlaying then -- 163
		ImGui.BeginDisabled(function() -- 165
			local changed, value = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 166
			snapChanged = changed -- 167
			snap = value -- 168
		end) -- 165
	else -- 165
		snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 171
	end -- 171
	if not state.isPlaying and snapChanged then -- 171
		state.snapEnabled = snap -- 173
	end -- 173
	ImGui.SameLine() -- 174
	local gridChanged = false -- 175
	local grid = state.showGrid -- 176
	if state.isPlaying then -- 176
		ImGui.BeginDisabled(function() -- 178
			local changed, value = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 179
			gridChanged = changed -- 180
			grid = value -- 181
		end) -- 178
	else -- 178
		gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 184
	end -- 184
	if not state.isPlaying and gridChanged then -- 184
		state.showGrid = grid -- 186
		state.previewDirty = true -- 186
	end -- 186
	ImGui.SameLine() -- 187
	if state.isPlaying then -- 187
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "居中" or "Center") end) -- 189
	elseif ImGui.Button(zh and "居中" or "Center") then -- 189
		state.viewportPanX = 0 -- 191
		state.viewportPanY = 0 -- 192
		state.zoom = 100 -- 193
		state.previewDirty = true -- 194
	end -- 194
	ImGui.SameLine() -- 196
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 197
	ImGui.Separator() -- 198
	local cursor = ImGui.GetCursorScreenPos() -- 199
	local avail = ImGui.GetContentRegionAvail() -- 200
	local viewportWidth = math.max(360, avail.x - 8) -- 201
	local viewportHeight = math.max(300, avail.y - 38) -- 202
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 202
		state.previewDirty = true -- 204
	end -- 204
	state.preview.x = cursor.x -- 206
	state.preview.y = cursor.y -- 207
	state.preview.width = viewportWidth -- 208
	state.preview.height = viewportHeight -- 209
	updatePreviewRuntime(state) -- 210
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 211
	local hovered = ImGui.IsItemHovered() -- 212
	handleViewportMouse(state, hovered) -- 213
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 214
	if state.isPlaying then -- 214
		ImGui.BeginDisabled(function() -- 216
			ImGui.SmallButton("-##viewport_zoom_out") -- 217
			ImGui.SameLine() -- 218
			ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") -- 219
			ImGui.SameLine() -- 220
			ImGui.SmallButton("+##viewport_zoom_in") -- 221
		end) -- 216
	else -- 216
		if ImGui.SmallButton("-##viewport_zoom_out") then -- 216
			zoomViewportFromCenter(state, -10) -- 224
		end -- 224
		ImGui.SameLine() -- 225
		ImGui.PushStyleColor( -- 226
			"Text", -- 226
			themeColor, -- 226
			function() -- 226
				if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 226
					state.zoom = 100 -- 228
					state.viewportPanX = 0 -- 229
					state.viewportPanY = 0 -- 230
					state.previewDirty = true -- 231
				end -- 231
			end -- 226
		) -- 226
		ImGui.SameLine() -- 234
		if ImGui.SmallButton("+##viewport_zoom_in") then -- 234
			zoomViewportFromCenter(state, 10) -- 235
		end -- 235
	end -- 235
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 237
	ImGui.Separator() -- 238
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 239
	ImGui.SameLine() -- 240
	if state.isPlaying then -- 240
		ImGui.TextDisabled(zh and "运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。" or "Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.") -- 242
	else -- 242
		ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 244
	end -- 244
end -- 149
return ____exports -- 149