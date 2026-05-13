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
			if node ~= nil and id ~= "root" and node.visible and node.kind ~= "Camera" then -- 53
				if isScenePointInsideNode(node, sceneX, sceneY) then -- 53
					return id -- 55
				end -- 55
			end -- 55
			i = i - 1 -- 51
		end -- 51
	end -- 51
	do -- 51
		local i = #state.order -- 58
		while i >= 1 do -- 58
			local id = state.order[i] -- 59
			local node = state.nodes[id] -- 60
			if node ~= nil and id ~= "root" and node.visible and node.kind == "Camera" then -- 60
				local width = math.max(160, state.gameWidth) -- 62
				local height = math.max(120, state.gameHeight) -- 63
				if math.abs(sceneX - node.x) <= width / 2 and math.abs(sceneY - node.y) <= height / 2 then -- 63
					return id -- 64
				end -- 64
			end -- 64
			i = i - 1 -- 58
		end -- 58
	end -- 58
	return nil -- 67
end -- 49
local function handleViewportMouse(state, hovered) -- 70
	if state.isPlaying then -- 70
		state.draggingNodeId = nil -- 72
		state.draggingViewport = false -- 73
		return -- 74
	end -- 74
	if not hovered then -- 74
		return -- 76
	end -- 76
	local spacePressed = Keyboard:isKeyPressed("Space") -- 77
	local wheel = Mouse.wheel -- 78
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 79
	if wheelDelta ~= 0 then -- 79
		local mouse = ImGui.GetMousePos() -- 81
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 82
	end -- 82
	if ImGui.IsMouseClicked(2) then -- 82
		state.draggingNodeId = nil -- 85
		state.draggingViewport = true -- 86
		ImGui.ResetMouseDragDelta(2) -- 87
	end -- 87
	if ImGui.IsMouseClicked(0) then -- 87
		if spacePressed then -- 87
			state.draggingNodeId = nil -- 91
			state.draggingViewport = true -- 92
		else -- 92
			local mouse = ImGui.GetMousePos() -- 94
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 95
			if picked ~= nil then -- 95
				state.selectedId = picked -- 97
				state.previewDirty = true -- 98
				state.draggingNodeId = picked -- 99
				state.draggingViewport = false -- 100
			else -- 100
				state.draggingNodeId = nil -- 102
				state.draggingViewport = true -- 103
			end -- 103
		end -- 103
		ImGui.ResetMouseDragDelta(0) -- 106
	end -- 106
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 106
		state.draggingNodeId = nil -- 109
		state.draggingViewport = false -- 110
	end -- 110
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 110
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 113
		local delta = ImGui.GetMouseDragDelta(panButton) -- 114
		if delta.x ~= 0 or delta.y ~= 0 then -- 114
			if state.draggingNodeId ~= nil and panButton == 0 then -- 114
				local node = state.nodes[state.draggingNodeId] -- 117
				if node ~= nil then -- 117
					local scale = viewportScale(state) -- 119
					node.x = node.x + delta.x / scale -- 120
					node.y = node.y - delta.y / scale -- 121
					if state.snapEnabled then -- 121
						local step = 16 -- 123
						node.x = math.floor(node.x / step + 0.5) * step -- 124
						node.y = math.floor(node.y / step + 0.5) * step -- 125
					end -- 125
					state.previewDirty = true -- 127
					state.playDirty = true -- 128
				end -- 128
			elseif state.draggingViewport then -- 128
				state.viewportPanX = state.viewportPanX + delta.x -- 131
				state.viewportPanY = state.viewportPanY - delta.y -- 132
			end -- 132
			ImGui.ResetMouseDragDelta(panButton) -- 134
		end -- 134
	end -- 134
end -- 70
local function drawViewportToolButton(state, tool, label) -- 139
	if state.isPlaying then -- 139
		ImGui.BeginDisabled(function() return ImGui.Button(label) end) -- 141
		return -- 142
	end -- 142
	local active = state.viewportTool == tool -- 144
	if active then -- 144
		ImGui.PushStyleColor( -- 146
			"Button", -- 146
			Color(4281349698), -- 146
			function() -- 146
				ImGui.PushStyleColor( -- 147
					"Text", -- 147
					themeColor, -- 147
					function() -- 147
						if ImGui.Button(label) then -- 147
							state.viewportTool = tool -- 148
						end -- 148
					end -- 147
				) -- 147
			end -- 146
		) -- 146
	elseif ImGui.Button(label) then -- 146
		state.viewportTool = tool -- 152
	end -- 152
end -- 139
function ____exports.drawViewportPanel(state) -- 156
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 157
	ImGui.SameLine() -- 158
	drawViewportToolButton(state, "Select", "Select") -- 159
	ImGui.SameLine() -- 160
	drawViewportToolButton(state, "Move", "Move") -- 161
	ImGui.SameLine() -- 162
	drawViewportToolButton(state, "Rotate", "Rotate") -- 163
	ImGui.SameLine() -- 164
	drawViewportToolButton(state, "Scale", "Scale") -- 165
	ImGui.SameLine() -- 166
	ImGui.TextDisabled("|") -- 167
	ImGui.SameLine() -- 168
	local snapChanged = false -- 169
	local snap = state.snapEnabled -- 170
	if state.isPlaying then -- 170
		ImGui.BeginDisabled(function() -- 172
			local changed, value = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 173
			snapChanged = changed -- 174
			snap = value -- 175
		end) -- 172
	else -- 172
		snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 178
	end -- 178
	if not state.isPlaying and snapChanged then -- 178
		state.snapEnabled = snap -- 180
	end -- 180
	ImGui.SameLine() -- 181
	local gridChanged = false -- 182
	local grid = state.showGrid -- 183
	if state.isPlaying then -- 183
		ImGui.BeginDisabled(function() -- 185
			local changed, value = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 186
			gridChanged = changed -- 187
			grid = value -- 188
		end) -- 185
	else -- 185
		gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 191
	end -- 191
	if not state.isPlaying and gridChanged then -- 191
		state.showGrid = grid -- 193
		state.previewDirty = true -- 193
	end -- 193
	ImGui.SameLine() -- 194
	if state.isPlaying then -- 194
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "居中" or "Center") end) -- 196
	elseif ImGui.Button(zh and "居中" or "Center") then -- 196
		state.viewportPanX = 0 -- 198
		state.viewportPanY = 0 -- 199
		state.zoom = 100 -- 200
		state.previewDirty = true -- 201
	end -- 201
	ImGui.SameLine() -- 203
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 204
	ImGui.Separator() -- 205
	local cursor = ImGui.GetCursorScreenPos() -- 206
	local avail = ImGui.GetContentRegionAvail() -- 207
	local viewportWidth = math.max(360, avail.x - 8) -- 208
	local viewportHeight = math.max(300, avail.y - 38) -- 209
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 209
		state.previewDirty = true -- 211
	end -- 211
	state.preview.x = cursor.x -- 213
	state.preview.y = cursor.y -- 214
	state.preview.width = viewportWidth -- 215
	state.preview.height = viewportHeight -- 216
	updatePreviewRuntime(state) -- 217
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 218
	local hovered = ImGui.IsItemHovered() -- 219
	handleViewportMouse(state, hovered) -- 220
	if state.isPlaying then -- 220
		ImGui.SetCursorScreenPos(Vec2(cursor.x + 12, cursor.y + 10)) -- 222
		ImGui.TextColored(okColor, zh and "▶ 运行模式" or "▶ PLAY MODE") -- 223
		ImGui.SameLine() -- 224
		ImGui.TextDisabled(zh and "Stop 后才能编辑场景" or "Stop to edit the scene") -- 225
	end -- 225
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 227
	if state.isPlaying then -- 227
		ImGui.BeginDisabled(function() -- 229
			ImGui.SmallButton("-##viewport_zoom_out") -- 230
			ImGui.SameLine() -- 231
			ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") -- 232
			ImGui.SameLine() -- 233
			ImGui.SmallButton("+##viewport_zoom_in") -- 234
		end) -- 229
	else -- 229
		if ImGui.SmallButton("-##viewport_zoom_out") then -- 229
			zoomViewportFromCenter(state, -10) -- 237
		end -- 237
		ImGui.SameLine() -- 238
		ImGui.PushStyleColor( -- 239
			"Text", -- 239
			themeColor, -- 239
			function() -- 239
				if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 239
					state.zoom = 100 -- 241
					state.viewportPanX = 0 -- 242
					state.viewportPanY = 0 -- 243
					state.previewDirty = true -- 244
				end -- 244
			end -- 239
		) -- 239
		ImGui.SameLine() -- 247
		if ImGui.SmallButton("+##viewport_zoom_in") then -- 247
			zoomViewportFromCenter(state, 10) -- 248
		end -- 248
	end -- 248
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 250
	ImGui.Separator() -- 251
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 252
	ImGui.SameLine() -- 253
	if state.isPlaying then -- 253
		ImGui.TextDisabled(zh and "运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。" or "Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.") -- 255
	else -- 255
		ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 257
	end -- 257
end -- 156
return ____exports -- 156