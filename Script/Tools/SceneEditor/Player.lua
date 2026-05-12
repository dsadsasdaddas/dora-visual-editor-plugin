-- [ts]: Player.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local okColor = ____Theme.okColor -- 5
local panelBg = ____Theme.panelBg -- 5
local viewportBgColor = ____Theme.viewportBgColor -- 5
local viewportFrameColor = ____Theme.viewportFrameColor -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local function playStateOf(state) -- 18
	return state -- 19
end -- 18
local function ensurePlayWindowState(state) -- 22
	local playState = playStateOf(state) -- 23
	if playState.playWindow == nil then -- 23
		playState.playWindow = {x = 0, y = 0, width = 960, height = 620} -- 25
	end -- 25
	return playState.playWindow -- 27
end -- 22
local function worldPointFromScreen(screenX, screenY) -- 30
	local size = App.visualSize -- 31
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 32
end -- 30
local function makeClipStencil(width, height) -- 35
	local hw = width / 2 -- 36
	local hh = height / 2 -- 37
	local stencil = DrawNode() -- 38
	stencil:drawPolygon( -- 39
		{ -- 39
			Vec2(-hw, -hh), -- 40
			Vec2(hw, -hh), -- 41
			Vec2(hw, hh), -- 42
			Vec2(-hw, hh) -- 43
		}, -- 43
		Color(4294967295), -- 44
		0, -- 44
		Color() -- 44
	) -- 44
	return stencil -- 45
end -- 35
local function makeGameBackground(width, height) -- 48
	local hw = width / 2 -- 49
	local hh = height / 2 -- 50
	local bg = DrawNode() -- 51
	bg:drawPolygon( -- 52
		{ -- 52
			Vec2(-hw, -hh), -- 53
			Vec2(hw, -hh), -- 54
			Vec2(hw, hh), -- 55
			Vec2(-hw, hh) -- 56
		}, -- 56
		viewportBgColor, -- 57
		1, -- 57
		viewportFrameColor -- 57
	) -- 57
	return bg -- 58
end -- 48
local function makeWindowBackground(width, height) -- 61
	local hw = width / 2 -- 62
	local hh = height / 2 -- 63
	local bg = DrawNode() -- 64
	bg:drawPolygon( -- 65
		{ -- 65
			Vec2(-hw, -hh), -- 66
			Vec2(hw, -hh), -- 67
			Vec2(hw, hh), -- 68
			Vec2(-hw, hh) -- 69
		}, -- 69
		panelBg, -- 70
		1, -- 70
		viewportFrameColor -- 70
	) -- 70
	return bg -- 71
end -- 61
local function makeFallbackRect(width, height, color) -- 74
	local hw = width / 2 -- 75
	local hh = height / 2 -- 76
	local rect = DrawNode() -- 77
	rect:drawSegment( -- 78
		Vec2(-hw, -hh), -- 78
		Vec2(hw, -hh), -- 78
		1, -- 78
		color -- 78
	) -- 78
	rect:drawSegment( -- 79
		Vec2(hw, -hh), -- 79
		Vec2(hw, hh), -- 79
		1, -- 79
		color -- 79
	) -- 79
	rect:drawSegment( -- 80
		Vec2(hw, hh), -- 80
		Vec2(-hw, hh), -- 80
		1, -- 80
		color -- 80
	) -- 80
	rect:drawSegment( -- 81
		Vec2(-hw, hh), -- 81
		Vec2(-hw, -hh), -- 81
		1, -- 81
		color -- 81
	) -- 81
	return rect -- 82
end -- 74
local function createPlayVisual(item) -- 85
	if item.kind == "Sprite" then -- 85
		if item.texture ~= "" then -- 85
			local sprite = Sprite(item.texture) -- 88
			if sprite ~= nil then -- 88
				return sprite -- 89
			end -- 89
		end -- 89
		return makeFallbackRect( -- 91
			128, -- 91
			96, -- 91
			Color(2859640520) -- 91
		) -- 91
	end -- 91
	if item.kind == "Label" then -- 91
		local label = Label("sarasa-mono-sc-regular", 32) -- 94
		if label ~= nil then -- 94
			label.text = item.text or "Label" -- 96
			return label -- 97
		end -- 97
		return makeFallbackRect( -- 99
			180, -- 99
			56, -- 99
			Color(2866196799) -- 99
		) -- 99
	end -- 99
	return Node() -- 101
end -- 85
local function applyTransform(target, item) -- 104
	target.x = item.x -- 105
	target.y = item.y -- 106
	target.scaleX = item.scaleX -- 107
	target.scaleY = item.scaleY -- 108
	target.angle = item.rotation -- 109
	target.visible = item.visible -- 110
	target.tag = item.name -- 111
end -- 104
local function firstCamera(state) -- 114
	for ____, id in ipairs(state.order) do -- 115
		local item = state.nodes[id] -- 116
		if item ~= nil and item.kind == "Camera" and item.visible then -- 116
			return item -- 117
		end -- 117
	end -- 117
	return nil -- 119
end -- 114
local function loadNodeScript(item) -- 122
	if item.script == "" then -- 122
		return "" -- 123
	end -- 123
	local writablePath = Path(Content.writablePath, item.script) -- 124
	if Content:exist(writablePath) then -- 124
		return Content:load(writablePath) or "" -- 125
	end -- 125
	if Content:exist(item.script) then -- 125
		return Content:load(item.script) or "" -- 126
	end -- 126
	return "" -- 127
end -- 122
local function runNodeScript(state, item, runtimeNode) -- 130
	local scriptText = loadNodeScript(item) -- 131
	if scriptText == "" then -- 131
		return -- 132
	end -- 132
	local chunk, loadError = load(scriptText, item.script) -- 133
	if chunk == nil then -- 133
		pushConsole( -- 135
			state, -- 135
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 135
		) -- 135
		return -- 136
	end -- 136
	local ok, result = pcall(chunk) -- 138
	if not ok then -- 138
		pushConsole( -- 140
			state, -- 140
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 140
		) -- 140
		return -- 141
	end -- 141
	if type(result) == "function" then -- 141
		local behavior = result -- 144
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 145
		if not behaviorOk then -- 145
			pushConsole( -- 146
				state, -- 146
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 146
			) -- 146
		end -- 146
	end -- 146
end -- 130
local function clearPlayRuntime(state) -- 150
	if state.playRoot ~= nil then -- 150
		state.playRoot:removeFromParent(true) -- 152
		state.playRoot = nil -- 153
	end -- 153
	playStateOf(state).playWindowBackground = nil -- 155
	state.playWorld = nil -- 156
	state.playContent = nil -- 157
	state.playRuntimeNodes = {} -- 158
	state.playRuntimeLabels = {} -- 159
	state.isPlaying = false -- 160
	state.playDirty = true -- 161
end -- 150
function ____exports.stopPlay(state) -- 164
	clearPlayRuntime(state) -- 165
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 166
	pushConsole(state, state.status) -- 167
end -- 164
function ____exports.startPlay(state) -- 170
	clearPlayRuntime(state) -- 171
	state.isPlaying = true -- 172
	state.gameWindowOpen = true -- 173
	state.playDirty = true -- 174
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 175
	pushConsole(state, state.status) -- 176
end -- 170
local function rebuildPlayRuntime(state) -- 179
	if state.playRoot == nil then -- 179
		state.playRoot = Node() -- 181
		state.playRoot.tag = "__DoraImGuiGamePreview__" -- 182
		Director.entry:addChild(state.playRoot) -- 183
	end -- 183
	state.playRoot:removeAllChildren(true) -- 185
	state.playRuntimeNodes = {} -- 186
	state.playRuntimeLabels = {} -- 187
	local playWindow = ensurePlayWindowState(state) -- 189
	local windowWidth = math.max(320, playWindow.width) -- 190
	local windowHeight = math.max(260, playWindow.height) -- 191
	local playState = playStateOf(state) -- 192
	playState.playWindowBackground = makeWindowBackground(windowWidth, windowHeight) -- 193
	state.playRoot:addChild(playState.playWindowBackground) -- 194
	local width = math.max(160, state.playViewport.width) -- 196
	local height = math.max(120, state.playViewport.height) -- 197
	local clip = ClipNode(makeClipStencil(width, height)) -- 198
	clip.alphaThreshold = 0.01 -- 199
	state.playRoot:addChild(clip) -- 200
	clip:addChild(makeGameBackground(width, height)) -- 201
	local world = Node() -- 203
	state.playWorld = world -- 204
	clip:addChild(world) -- 205
	local content = Node() -- 206
	state.playContent = content -- 207
	world:addChild(content) -- 208
	state.playRuntimeNodes.root = content -- 209
	local camera = firstCamera(state) -- 211
	if camera ~= nil then -- 211
		world.x = -camera.x -- 213
		world.y = -camera.y -- 214
		world.angle = -camera.rotation -- 215
	end -- 215
	for ____, id in ipairs(state.order) do -- 218
		local item = state.nodes[id] -- 219
		if item ~= nil and id ~= "root" and item.kind ~= "Camera" then -- 219
			local runtime = createPlayVisual(item) -- 221
			applyTransform(runtime, item) -- 222
			state.playRuntimeNodes[id] = runtime -- 223
			if item.kind == "Label" then -- 223
				state.playRuntimeLabels[id] = runtime -- 224
			end -- 224
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 225
			parent:addChild(runtime) -- 226
		end -- 226
	end -- 226
	for ____, id in ipairs(state.order) do -- 229
		local item = state.nodes[id] -- 230
		local runtime = state.playRuntimeNodes[id] -- 231
		if item ~= nil and runtime ~= nil then -- 231
			runNodeScript(state, item, runtime) -- 233
		end -- 233
	end -- 233
	state.playDirty = false -- 236
end -- 179
local function updatePlayWindowBackground(state) -- 239
	local playState = playStateOf(state) -- 240
	local bg = playState.playWindowBackground -- 241
	if bg == nil then -- 241
		return -- 242
	end -- 242
	local p = state.playViewport -- 243
	local w = ensurePlayWindowState(state) -- 244
	local contentCenterX = p.x + p.width / 2 -- 245
	local contentCenterY = p.y + p.height / 2 -- 246
	local windowCenterX = w.x + w.width / 2 -- 247
	local windowCenterY = w.y + w.height / 2 -- 248
	bg.x = windowCenterX - contentCenterX -- 249
	bg.y = contentCenterY - windowCenterY -- 250
end -- 239
local function updatePlayRuntime(state) -- 253
	if not state.isPlaying then -- 253
		return -- 254
	end -- 254
	if state.playDirty or state.playRoot == nil then -- 254
		rebuildPlayRuntime(state) -- 255
	end -- 255
	local p = state.playViewport -- 256
	local cx, cy = table.unpack( -- 257
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 257
		1, -- 257
		2 -- 257
	) -- 257
	if state.playRoot ~= nil then -- 257
		state.playRoot.x = cx -- 259
		state.playRoot.y = cy -- 260
	end -- 260
	updatePlayWindowBackground(state) -- 262
end -- 253
function ____exports.drawGamePreviewWindow(state) -- 265
	if not state.gameWindowOpen then -- 265
		return -- 266
	end -- 266
	local appSize = App.visualSize -- 267
	ImGui.SetNextWindowSize( -- 268
		Vec2( -- 268
			math.min(960, appSize.width - 80), -- 268
			math.min(620, appSize.height - 80) -- 268
		), -- 268
		"FirstUseEver" -- 268
	) -- 268
	ImGui.SetNextWindowBgAlpha(0.02) -- 269
	ImGui.Begin( -- 270
		"Game Preview", -- 270
		{"NoSavedSettings"}, -- 270
		function() -- 270
			if state.isPlaying then -- 270
				ImGui.TextColored(okColor, zh and "运行中" or "Running") -- 272
				ImGui.SameLine() -- 273
				if ImGui.Button("■ Stop") then -- 273
					____exports.stopPlay(state) -- 274
				end -- 274
				ImGui.SameLine() -- 275
				if ImGui.Button("↻ Restart") then -- 275
					____exports.startPlay(state) -- 276
				end -- 276
			else -- 276
				ImGui.TextColored(warnColor, zh and "已停止" or "Stopped") -- 278
				ImGui.SameLine() -- 279
				if ImGui.Button("▶ Run") then -- 279
					____exports.startPlay(state) -- 280
				end -- 280
			end -- 280
			ImGui.SameLine() -- 282
			ImGui.TextDisabled(zh and "这是独立 Game 预览，不是编辑视口。" or "Independent game preview, not the editor viewport.") -- 283
			ImGui.Separator() -- 284
			local windowPos = ImGui.GetWindowPos() -- 285
			local windowSize = ImGui.GetWindowSize() -- 286
			local playWindow = ensurePlayWindowState(state) -- 287
			if math.abs(playWindow.width - windowSize.x) > 1 or math.abs(playWindow.height - windowSize.y) > 1 then -- 287
				state.playDirty = true -- 289
			end -- 289
			playWindow.x = windowPos.x -- 291
			playWindow.y = windowPos.y -- 292
			playWindow.width = windowSize.x -- 293
			playWindow.height = windowSize.y -- 294
			local cursor = ImGui.GetCursorScreenPos() -- 296
			local avail = ImGui.GetContentRegionAvail() -- 297
			local width = math.max(320, avail.x) -- 298
			local height = math.max(240, avail.y) -- 299
			if math.abs(state.playViewport.width - width) > 1 or math.abs(state.playViewport.height - height) > 1 then -- 299
				state.playDirty = true -- 301
			end -- 301
			state.playViewport.x = cursor.x -- 303
			state.playViewport.y = cursor.y -- 304
			state.playViewport.width = width -- 305
			state.playViewport.height = height -- 306
			updatePlayRuntime(state) -- 307
			ImGui.Dummy(Vec2(width, height)) -- 308
		end -- 270
	) -- 270
end -- 265
return ____exports -- 265