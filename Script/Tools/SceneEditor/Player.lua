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
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local okColor = ____Theme.okColor -- 3
local viewportBgColor = ____Theme.viewportBgColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local pushConsole = ____Model.pushConsole -- 4
local zh = ____Model.zh -- 4
local function worldPointFromScreen(screenX, screenY) -- 11
	local size = App.visualSize -- 12
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 13
end -- 11
local function makeClipStencil(width, height) -- 16
	local hw = width / 2 -- 17
	local hh = height / 2 -- 18
	local stencil = DrawNode() -- 19
	stencil:drawPolygon( -- 20
		{ -- 20
			Vec2(-hw, -hh), -- 21
			Vec2(hw, -hh), -- 22
			Vec2(hw, hh), -- 23
			Vec2(-hw, hh) -- 24
		}, -- 24
		Color(4294967295), -- 25
		0, -- 25
		Color() -- 25
	) -- 25
	return stencil -- 26
end -- 16
local function makeGameBackground(width, height) -- 29
	local hw = width / 2 -- 30
	local hh = height / 2 -- 31
	local bg = DrawNode() -- 32
	bg:drawPolygon( -- 33
		{ -- 33
			Vec2(-hw, -hh), -- 34
			Vec2(hw, -hh), -- 35
			Vec2(hw, hh), -- 36
			Vec2(-hw, hh) -- 37
		}, -- 37
		viewportBgColor, -- 38
		1.4, -- 38
		okColor -- 38
	) -- 38
	return bg -- 39
end -- 29
local function makeFallbackRect(width, height, color) -- 42
	local hw = width / 2 -- 43
	local hh = height / 2 -- 44
	local rect = DrawNode() -- 45
	rect:drawSegment( -- 46
		Vec2(-hw, -hh), -- 46
		Vec2(hw, -hh), -- 46
		1, -- 46
		color -- 46
	) -- 46
	rect:drawSegment( -- 47
		Vec2(hw, -hh), -- 47
		Vec2(hw, hh), -- 47
		1, -- 47
		color -- 47
	) -- 47
	rect:drawSegment( -- 48
		Vec2(hw, hh), -- 48
		Vec2(-hw, hh), -- 48
		1, -- 48
		color -- 48
	) -- 48
	rect:drawSegment( -- 49
		Vec2(-hw, hh), -- 49
		Vec2(-hw, -hh), -- 49
		1, -- 49
		color -- 49
	) -- 49
	return rect -- 50
end -- 42
local function createPlayVisual(item) -- 53
	if item.kind == "Sprite" then -- 53
		if item.texture ~= "" then -- 53
			local sprite = Sprite(item.texture) -- 56
			if sprite ~= nil then -- 56
				return sprite -- 57
			end -- 57
		end -- 57
		return makeFallbackRect( -- 59
			128, -- 59
			96, -- 59
			Color(2859640520) -- 59
		) -- 59
	end -- 59
	if item.kind == "Label" then -- 59
		local label = Label("sarasa-mono-sc-regular", 32) -- 62
		if label ~= nil then -- 62
			label.text = item.text or "Label" -- 64
			return label -- 65
		end -- 65
		return makeFallbackRect( -- 67
			180, -- 67
			56, -- 67
			Color(2866196799) -- 67
		) -- 67
	end -- 67
	return Node() -- 69
end -- 53
local function applyTransform(target, item) -- 72
	target.x = item.x -- 73
	target.y = item.y -- 74
	target.scaleX = item.scaleX -- 75
	target.scaleY = item.scaleY -- 76
	target.angle = item.rotation -- 77
	target.visible = item.visible -- 78
	target.tag = item.name -- 79
end -- 72
local function firstCamera(state) -- 82
	for ____, id in ipairs(state.order) do -- 83
		local item = state.nodes[id] -- 84
		if item ~= nil and item.kind == "Camera" and item.visible then -- 84
			return item -- 85
		end -- 85
	end -- 85
	return nil -- 87
end -- 82
local function loadNodeScript(item) -- 90
	if item.script == "" then -- 90
		return "" -- 91
	end -- 91
	local writablePath = Path(Content.writablePath, item.script) -- 92
	if Content:exist(writablePath) then -- 92
		return Content:load(writablePath) or "" -- 93
	end -- 93
	if Content:exist(item.script) then -- 93
		return Content:load(item.script) or "" -- 94
	end -- 94
	return "" -- 95
end -- 90
local function runNodeScript(state, item, runtimeNode) -- 98
	local scriptText = loadNodeScript(item) -- 99
	if scriptText == "" then -- 99
		return -- 100
	end -- 100
	local chunk, loadError = load(scriptText, item.script) -- 101
	if chunk == nil then -- 101
		pushConsole( -- 103
			state, -- 103
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 103
		) -- 103
		return -- 104
	end -- 104
	local ok, result = pcall(chunk) -- 106
	if not ok then -- 106
		pushConsole( -- 108
			state, -- 108
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 108
		) -- 108
		return -- 109
	end -- 109
	if type(result) == "function" then -- 109
		local behavior = result -- 112
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 113
		if not behaviorOk then -- 113
			pushConsole( -- 114
				state, -- 114
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 114
			) -- 114
		end -- 114
	end -- 114
end -- 98
local function clearPlayRuntime(state) -- 118
	if state.playRoot ~= nil then -- 118
		state.playRoot:removeFromParent(true) -- 120
		state.playRoot = nil -- 121
	end -- 121
	state.playWorld = nil -- 123
	state.playContent = nil -- 124
	state.playRuntimeNodes = {} -- 125
	state.playRuntimeLabels = {} -- 126
	state.isPlaying = false -- 127
	state.playDirty = true -- 128
end -- 118
function ____exports.stopPlay(state) -- 131
	clearPlayRuntime(state) -- 132
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 133
	pushConsole(state, state.status) -- 134
end -- 131
function ____exports.startPlay(state) -- 137
	clearPlayRuntime(state) -- 138
	state.isPlaying = true -- 139
	state.gameWindowOpen = true -- 140
	state.playDirty = true -- 141
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 142
	pushConsole(state, state.status) -- 143
end -- 137
local function gameWidthOf(state) -- 146
	return math.max(160, state.gameWidth) -- 147
end -- 146
local function gameHeightOf(state) -- 150
	return math.max(120, state.gameHeight) -- 151
end -- 150
local function playScaleForViewport(state) -- 154
	local renderScale = App.devicePixelRatio or 1 -- 155
	local designWidth = gameWidthOf(state) -- 156
	local designHeight = gameHeightOf(state) -- 157
	return math.min(state.playViewport.width * renderScale / designWidth, state.playViewport.height * renderScale / designHeight) -- 158
end -- 154
local function rebuildPlayRuntime(state) -- 161
	if state.playRoot == nil then -- 161
		state.playRoot = Node() -- 163
		state.playRoot.tag = "__DoraImGuiGamePreview__" -- 164
		Director.entry:addChild(state.playRoot) -- 165
	end -- 165
	state.playRoot:removeAllChildren(true) -- 167
	state.playRuntimeNodes = {} -- 168
	state.playRuntimeLabels = {} -- 169
	local width = gameWidthOf(state) -- 171
	local height = gameHeightOf(state) -- 172
	local clip = ClipNode(makeClipStencil(width, height)) -- 173
	clip.alphaThreshold = 0.01 -- 174
	state.playRoot:addChild(clip) -- 175
	clip:addChild(makeGameBackground(width, height)) -- 176
	local world = Node() -- 178
	state.playWorld = world -- 179
	clip:addChild(world) -- 180
	local content = Node() -- 181
	state.playContent = content -- 182
	world:addChild(content) -- 183
	state.playRuntimeNodes.root = content -- 184
	local camera = firstCamera(state) -- 186
	if camera ~= nil then -- 186
		world.x = -camera.x -- 188
		world.y = -camera.y -- 189
		world.angle = -camera.rotation -- 190
	end -- 190
	for ____, id in ipairs(state.order) do -- 193
		local item = state.nodes[id] -- 194
		if item ~= nil and id ~= "root" and item.kind ~= "Camera" then -- 194
			local runtime = createPlayVisual(item) -- 196
			applyTransform(runtime, item) -- 197
			state.playRuntimeNodes[id] = runtime -- 198
			if item.kind == "Label" then -- 198
				state.playRuntimeLabels[id] = runtime -- 199
			end -- 199
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 200
			parent:addChild(runtime) -- 201
		end -- 201
	end -- 201
	for ____, id in ipairs(state.order) do -- 204
		local item = state.nodes[id] -- 205
		local runtime = state.playRuntimeNodes[id] -- 206
		if item ~= nil and runtime ~= nil then -- 206
			runNodeScript(state, item, runtime) -- 208
		end -- 208
	end -- 208
	state.playDirty = false -- 211
end -- 161
local function updatePlayRuntime(state) -- 214
	if not state.isPlaying then -- 214
		return -- 215
	end -- 215
	if state.playDirty or state.playRoot == nil then -- 215
		rebuildPlayRuntime(state) -- 216
	end -- 216
	local p = state.playViewport -- 217
	local cx, cy = table.unpack( -- 218
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 218
		1, -- 218
		2 -- 218
	) -- 218
	if state.playRoot ~= nil then -- 218
		local scale = playScaleForViewport(state) -- 220
		state.playRoot.x = cx -- 221
		state.playRoot.y = cy -- 222
		state.playRoot.scaleX = scale -- 223
		state.playRoot.scaleY = scale -- 224
	end -- 224
end -- 214
function ____exports.drawGamePreviewWindow(state) -- 229
	if not state.isPlaying then -- 229
		return -- 230
	end -- 230
	local p = state.preview -- 231
	local renderScale = App.devicePixelRatio or 1 -- 232
	local designWidth = gameWidthOf(state) -- 233
	local designHeight = gameHeightOf(state) -- 234
	local fitScale = math.min(p.width * renderScale / designWidth, p.height * renderScale / designHeight) -- 235
	local displayWidth = designWidth * fitScale / renderScale -- 236
	local displayHeight = designHeight * fitScale / renderScale -- 237
	local nextX = p.x + (p.width - displayWidth) / 2 -- 238
	local nextY = p.y + (p.height - displayHeight) / 2 -- 239
	if math.abs(state.playViewport.x - nextX) > 1 or math.abs(state.playViewport.y - nextY) > 1 or math.abs(state.playViewport.width - displayWidth) > 1 or math.abs(state.playViewport.height - displayHeight) > 1 then -- 239
		state.playViewport.x = nextX -- 242
		state.playViewport.y = nextY -- 243
		state.playViewport.width = displayWidth -- 244
		state.playViewport.height = displayHeight -- 245
		state.playDirty = true -- 246
	end -- 246
	updatePlayRuntime(state) -- 248
end -- 229
return ____exports -- 229