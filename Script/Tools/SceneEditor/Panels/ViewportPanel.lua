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
	if not hovered then -- 63
		return -- 64
	end -- 64
	local spacePressed = Keyboard:isKeyPressed("Space") -- 65
	local wheel = Mouse.wheel -- 66
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 67
	if wheelDelta ~= 0 then -- 67
		local mouse = ImGui.GetMousePos() -- 69
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 70
	end -- 70
	if ImGui.IsMouseClicked(2) then -- 70
		state.draggingNodeId = nil -- 73
		state.draggingViewport = true -- 74
		ImGui.ResetMouseDragDelta(2) -- 75
	end -- 75
	if ImGui.IsMouseClicked(0) then -- 75
		if spacePressed then -- 75
			state.draggingNodeId = nil -- 79
			state.draggingViewport = true -- 80
		else -- 80
			local mouse = ImGui.GetMousePos() -- 82
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 83
			if picked ~= nil then -- 83
				state.selectedId = picked -- 85
				state.previewDirty = true -- 86
				state.draggingNodeId = picked -- 87
				state.draggingViewport = false -- 88
			else -- 88
				state.draggingNodeId = nil -- 90
				state.draggingViewport = true -- 91
			end -- 91
		end -- 91
		ImGui.ResetMouseDragDelta(0) -- 94
	end -- 94
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 94
		state.draggingNodeId = nil -- 97
		state.draggingViewport = false -- 98
	end -- 98
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 98
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 101
		local delta = ImGui.GetMouseDragDelta(panButton) -- 102
		if delta.x ~= 0 or delta.y ~= 0 then -- 102
			if state.draggingNodeId ~= nil and panButton == 0 then -- 102
				local node = state.nodes[state.draggingNodeId] -- 105
				if node ~= nil then -- 105
					local scale = viewportScale(state) -- 107
					node.x = node.x + delta.x / scale -- 108
					node.y = node.y - delta.y / scale -- 109
					if state.snapEnabled then -- 109
						local step = 16 -- 111
						node.x = math.floor(node.x / step + 0.5) * step -- 112
						node.y = math.floor(node.y / step + 0.5) * step -- 113
					end -- 113
				end -- 113
			elseif state.draggingViewport then -- 113
				state.viewportPanX = state.viewportPanX + delta.x -- 117
				state.viewportPanY = state.viewportPanY - delta.y -- 118
			end -- 118
			ImGui.ResetMouseDragDelta(panButton) -- 120
		end -- 120
	end -- 120
end -- 63
local function drawViewportToolButton(state, tool, label) -- 125
	local active = state.viewportTool == tool -- 126
	if active then -- 126
		ImGui.PushStyleColor( -- 128
			"Button", -- 128
			Color(4281349698), -- 128
			function() -- 128
				ImGui.PushStyleColor( -- 129
					"Text", -- 129
					themeColor, -- 129
					function() -- 129
						if ImGui.Button(label) then -- 129
							state.viewportTool = tool -- 130
						end -- 130
					end -- 129
				) -- 129
			end -- 128
		) -- 128
	elseif ImGui.Button(label) then -- 128
		state.viewportTool = tool -- 134
	end -- 134
end -- 125
function ____exports.drawViewportPanel(state) -- 138
	ImGui.TextColored(themeColor, zh and "场景" or "Scene") -- 139
	ImGui.SameLine() -- 140
	drawViewportToolButton(state, "Select", "Select") -- 141
	ImGui.SameLine() -- 142
	drawViewportToolButton(state, "Move", "Move") -- 143
	ImGui.SameLine() -- 144
	drawViewportToolButton(state, "Rotate", "Rotate") -- 145
	ImGui.SameLine() -- 146
	drawViewportToolButton(state, "Scale", "Scale") -- 147
	ImGui.SameLine() -- 148
	ImGui.TextDisabled("|") -- 149
	ImGui.SameLine() -- 150
	local snapChanged, snap = ImGui.Checkbox(zh and "吸附" or "Snap", state.snapEnabled) -- 151
	if snapChanged then -- 151
		state.snapEnabled = snap -- 152
	end -- 152
	ImGui.SameLine() -- 153
	local gridChanged, grid = ImGui.Checkbox(zh and "网格" or "Grid", state.showGrid) -- 154
	if gridChanged then -- 154
		state.showGrid = grid -- 155
		state.previewDirty = true -- 155
	end -- 155
	ImGui.SameLine() -- 156
	if ImGui.Button(zh and "居中" or "Center") then -- 156
		state.viewportPanX = 0 -- 158
		state.viewportPanY = 0 -- 159
		state.zoom = 100 -- 160
		state.previewDirty = true -- 161
	end -- 161
	ImGui.SameLine() -- 163
	ImGui.TextDisabled(zh and "当前场景：Main" or "Scene: Main") -- 164
	ImGui.Separator() -- 165
	local cursor = ImGui.GetCursorScreenPos() -- 166
	local avail = ImGui.GetContentRegionAvail() -- 167
	local viewportWidth = math.max(360, avail.x - 8) -- 168
	local viewportHeight = math.max(300, avail.y - 38) -- 169
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 169
		state.previewDirty = true -- 171
	end -- 171
	state.preview.x = cursor.x -- 173
	state.preview.y = cursor.y -- 174
	state.preview.width = viewportWidth -- 175
	state.preview.height = viewportHeight -- 176
	updatePreviewRuntime(state) -- 177
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 178
	local hovered = ImGui.IsItemHovered() -- 179
	handleViewportMouse(state, hovered) -- 180
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 181
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 181
		zoomViewportFromCenter(state, -10) -- 182
	end -- 182
	ImGui.SameLine() -- 183
	ImGui.PushStyleColor( -- 184
		"Text", -- 184
		themeColor, -- 184
		function() -- 184
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 184
				state.zoom = 100 -- 186
				state.viewportPanX = 0 -- 187
				state.viewportPanY = 0 -- 188
				state.previewDirty = true -- 189
			end -- 189
		end -- 184
	) -- 184
	ImGui.SameLine() -- 192
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 192
		zoomViewportFromCenter(state, 10) -- 193
	end -- 193
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 194
	ImGui.Separator() -- 195
	ImGui.TextColored(okColor, zh and "场景视口" or "Scene Viewport") -- 196
	ImGui.SameLine() -- 197
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 198
end -- 138
return ____exports -- 138