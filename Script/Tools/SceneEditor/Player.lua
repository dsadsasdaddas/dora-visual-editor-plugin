-- [ts]: Player.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local RenderTarget = ____Dora.RenderTarget -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local okColor = ____Theme.okColor -- 5
local viewportBgColor = ____Theme.viewportBgColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local pushConsole = ____Model.pushConsole -- 6
local workspacePath = ____Model.workspacePath -- 6
local zh = ____Model.zh -- 6
local ____SceneGraph = require("Script.Tools.SceneEditor.SceneGraph") -- 7
local worldPositionOf = ____SceneGraph.worldPositionOf -- 7
local playTarget = nil -- 17
local playTargetWidth = 0 -- 18
local playTargetHeight = 0 -- 19
local function makeGameBackground(width, height) -- 21
	local hw = width / 2 -- 22
	local hh = height / 2 -- 23
	local bg = DrawNode() -- 24
	bg:drawPolygon( -- 25
		{ -- 25
			Vec2(-hw, -hh), -- 26
			Vec2(hw, -hh), -- 27
			Vec2(hw, hh), -- 28
			Vec2(-hw, hh) -- 29
		}, -- 29
		viewportBgColor, -- 30
		1.4, -- 30
		okColor -- 30
	) -- 30
	return bg -- 31
end -- 21
local function makeFallbackRect(width, height, color) -- 34
	local hw = width / 2 -- 35
	local hh = height / 2 -- 36
	local rect = DrawNode() -- 37
	rect:drawSegment( -- 38
		Vec2(-hw, -hh), -- 38
		Vec2(hw, -hh), -- 38
		1, -- 38
		color -- 38
	) -- 38
	rect:drawSegment( -- 39
		Vec2(hw, -hh), -- 39
		Vec2(hw, hh), -- 39
		1, -- 39
		color -- 39
	) -- 39
	rect:drawSegment( -- 40
		Vec2(hw, hh), -- 40
		Vec2(-hw, hh), -- 40
		1, -- 40
		color -- 40
	) -- 40
	rect:drawSegment( -- 41
		Vec2(-hw, hh), -- 41
		Vec2(-hw, -hh), -- 41
		1, -- 41
		color -- 41
	) -- 41
	return rect -- 42
end -- 34
local function createPlayVisual(item) -- 45
	if item.kind == "Sprite" then -- 45
		if item.texture ~= "" then -- 45
			local sprite = Sprite(item.texture) -- 48
			if sprite ~= nil then -- 48
				return sprite -- 49
			end -- 49
		end -- 49
		return makeFallbackRect( -- 51
			128, -- 51
			96, -- 51
			Color(2859640520) -- 51
		) -- 51
	end -- 51
	if item.kind == "Label" then -- 51
		local label = Label("sarasa-mono-sc-regular", 32) -- 54
		if label ~= nil then -- 54
			label.text = item.text or "Label" -- 56
			return label -- 57
		end -- 57
		return makeFallbackRect( -- 59
			180, -- 59
			56, -- 59
			Color(2866196799) -- 59
		) -- 59
	end -- 59
	return Node() -- 61
end -- 45
local function applyTransform(target, item) -- 64
	target.x = item.x -- 65
	target.y = item.y -- 66
	target.scaleX = item.scaleX -- 67
	target.scaleY = item.scaleY -- 68
	target.angle = item.rotation -- 69
	target.visible = item.visible -- 70
	target.tag = item.name -- 71
end -- 64
local function firstCameraId(state) -- 74
	for ____, id in ipairs(state.order) do -- 75
		local item = state.nodes[id] -- 76
		if item ~= nil and item.kind == "Camera" and item.visible then -- 76
			return id -- 77
		end -- 77
	end -- 77
	return nil -- 79
end -- 74
local function loadScriptText(scriptPath) -- 82
	if scriptPath == "" then -- 82
		return "" -- 83
	end -- 83
	local projectPath = workspacePath(scriptPath) -- 84
	if Content:exist(projectPath) then -- 84
		return Content:load(projectPath) or "" -- 85
	end -- 85
	if Content:exist(scriptPath) then -- 85
		return Content:load(scriptPath) or "" -- 86
	end -- 86
	return "" -- 87
end -- 82
local function runNodeScript(state, item, runtimeNode) -- 90
	local scriptText = loadScriptText(item.script) -- 91
	if scriptText == "" then -- 91
		return -- 92
	end -- 92
	local chunk, loadError = load(scriptText, item.script) -- 93
	if chunk == nil then -- 93
		pushConsole( -- 95
			state, -- 95
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 95
		) -- 95
		return -- 96
	end -- 96
	local ok, result = pcall(chunk) -- 98
	if not ok then -- 98
		pushConsole( -- 100
			state, -- 100
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 100
		) -- 100
		return -- 101
	end -- 101
	if type(result) == "function" then -- 101
		local behavior = result -- 104
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 105
		if not behaviorOk then -- 105
			pushConsole( -- 106
				state, -- 106
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 106
			) -- 106
		end -- 106
	end -- 106
end -- 90
local function defaultGameMainLua() -- 110
	return ((((((((((((((((("-- Game main script\n" .. "-- Auto-created by Dora Visual Editor.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then player = node end\n") .. "\t\tend\n") .. "\t\tif player == nil then return end\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then player.x = player.x - speed * deltaTime end\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then player.x = player.x + speed * deltaTime end\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 110
local function ensureGameMainScript(state) -- 132
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 133
	state.gameScript = scriptPath -- 134
	state.gameScriptBuffer.text = scriptPath -- 135
	local file = workspacePath(scriptPath) -- 136
	if not Content:exist(file) then -- 136
		Content:mkdir(Path:getPath(file)) -- 138
		Content:save( -- 139
			file, -- 139
			defaultGameMainLua() -- 139
		) -- 139
	end -- 139
end -- 132
local function runGameMain(state) -- 143
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 144
	local scriptText = loadScriptText(scriptPath) -- 145
	if scriptText == "" then -- 145
		return -- 146
	end -- 146
	local chunk, loadError = load(scriptText, scriptPath) -- 147
	if chunk == nil then -- 147
		pushConsole( -- 149
			state, -- 149
			(((zh and "主脚本加载失败：" or "Main script load failed: ") .. scriptPath) .. " ") .. tostring(loadError or "") -- 149
		) -- 149
		return -- 150
	end -- 150
	local ok, result = pcall(chunk) -- 152
	if not ok then -- 152
		pushConsole( -- 154
			state, -- 154
			(((zh and "主脚本执行失败：" or "Main script failed: ") .. scriptPath) .. " ") .. tostring(result) -- 154
		) -- 154
		return -- 155
	end -- 155
	local start = nil -- 157
	if type(result) == "function" then -- 157
		start = result -- 159
	elseif type(result) == "table" then -- 159
		local module = result -- 161
		if module.start ~= nil then -- 161
			start = module.start -- 162
		end -- 162
	end -- 162
	local scene = state.playContent -- 164
	local world = state.playWorld -- 165
	if start ~= nil and scene ~= nil and world ~= nil then -- 165
		local entry = start -- 167
		local startOk, startError = pcall(function() return entry(scene, state.playRuntimeNodes, world) end) -- 168
		if not startOk then -- 168
			pushConsole( -- 169
				state, -- 169
				(zh and "主脚本启动失败：" or "Main script start failed: ") .. tostring(startError) -- 169
			) -- 169
		end -- 169
	end -- 169
end -- 143
local function clearPlayRuntime(state) -- 173
	if state.playRoot ~= nil then -- 173
		state.playRoot:removeFromParent(true) -- 175
		state.playRoot = nil -- 176
	end -- 176
	state.playWorld = nil -- 178
	state.playContent = nil -- 179
	state.playRuntimeNodes = {} -- 180
	state.playRuntimeLabels = {} -- 181
	state.isPlaying = false -- 182
	state.playDirty = true -- 183
end -- 173
function ____exports.stopPlay(state) -- 186
	clearPlayRuntime(state) -- 187
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 188
	pushConsole(state, state.status) -- 189
end -- 186
function ____exports.startPlay(state) -- 192
	clearPlayRuntime(state) -- 193
	ensureGameMainScript(state) -- 194
	state.isPlaying = true -- 195
	state.gameWindowOpen = true -- 196
	state.playDirty = true -- 197
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 198
	pushConsole(state, state.status) -- 199
end -- 192
local function gameWidthOf(state) -- 202
	return math.max( -- 203
		160, -- 203
		math.floor(state.gameWidth) -- 203
	) -- 203
end -- 202
local function gameHeightOf(state) -- 206
	return math.max( -- 207
		120, -- 207
		math.floor(state.gameHeight) -- 207
	) -- 207
end -- 206
local function rebuildPlayRuntime(state) -- 210
	local width = gameWidthOf(state) -- 211
	local height = gameHeightOf(state) -- 212
	state.playRoot = Node() -- 213
	state.playRoot.tag = "__DoraImGuiGamePreview__" -- 214
	state.playRoot.visible = false -- 215
	state.playRuntimeNodes = {} -- 216
	state.playRuntimeLabels = {} -- 217
	Director.entry:addChild(state.playRoot) -- 218
	local background = makeGameBackground(width, height) -- 220
	background.x = width / 2 -- 221
	background.y = height / 2 -- 222
	state.playRoot:addChild(background) -- 223
	local world = Node() -- 224
	state.playWorld = world -- 225
	world.x = width / 2 -- 226
	world.y = height / 2 -- 227
	state.playRoot:addChild(world) -- 228
	local content = Node() -- 229
	state.playContent = content -- 230
	world:addChild(content) -- 231
	state.playRuntimeNodes.root = content -- 232
	for ____, id in ipairs(state.order) do -- 234
		local item = state.nodes[id] -- 235
		if item ~= nil and id ~= "root" then -- 235
			local runtime = createPlayVisual(item) -- 237
			applyTransform(runtime, item) -- 238
			state.playRuntimeNodes[id] = runtime -- 239
			if item.kind == "Label" then -- 239
				state.playRuntimeLabels[id] = runtime -- 240
			end -- 240
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 241
			parent:addChild(runtime) -- 242
		end -- 242
	end -- 242
	local cameraId = firstCameraId(state) -- 246
	local cameraData = cameraId ~= nil and state.nodes[cameraId] or nil -- 247
	local cameraNode = cameraId ~= nil and state.playRuntimeNodes[cameraId] or nil -- 248
	local function updateCamera() -- 249
		if cameraNode ~= nil and cameraData ~= nil then -- 249
			if cameraData.followTargetId ~= "" then -- 249
				local targetNode = state.playRuntimeNodes[cameraData.followTargetId] -- 252
				if targetNode ~= nil then -- 252
					local targetX, targetY = table.unpack( -- 254
						worldPositionOf(state, cameraData.followTargetId), -- 254
						1, -- 254
						2 -- 254
					) -- 254
					cameraNode.x = targetX + cameraData.followOffsetX -- 255
					cameraNode.y = targetY + cameraData.followOffsetY -- 256
				end -- 256
			end -- 256
			world.x = width / 2 -- 259
			world.y = height / 2 -- 260
			world.angle = -cameraNode.angle -- 261
			world.scaleX = cameraNode.scaleX ~= 0 and 1 / cameraNode.scaleX or 1 -- 262
			world.scaleY = cameraNode.scaleY ~= 0 and 1 / cameraNode.scaleY or 1 -- 263
			content.x = -cameraNode.x -- 264
			content.y = -cameraNode.y -- 265
		else -- 265
			world.x = width / 2 -- 267
			world.y = height / 2 -- 268
			world.angle = 0 -- 269
			world.scaleX = 1 -- 270
			world.scaleY = 1 -- 271
			content.x = 0 -- 272
			content.y = 0 -- 273
		end -- 273
	end -- 249
	updateCamera() -- 276
	world:schedule(function() -- 277
		updateCamera() -- 278
		return false -- 279
	end) -- 277
	for ____, id in ipairs(state.order) do -- 282
		local item = state.nodes[id] -- 283
		local runtime = state.playRuntimeNodes[id] -- 284
		if item ~= nil and runtime ~= nil then -- 284
			runNodeScript(state, item, runtime) -- 285
		end -- 285
	end -- 285
	runGameMain(state) -- 287
	state.playDirty = false -- 288
end -- 210
local function ensurePlayTarget(state) -- 291
	local width = gameWidthOf(state) -- 292
	local height = gameHeightOf(state) -- 293
	if playTarget == nil or playTargetWidth ~= width or playTargetHeight ~= height then -- 293
		playTarget = RenderTarget(width, height) -- 295
		playTargetWidth = width -- 296
		playTargetHeight = height -- 297
	end -- 297
	return playTarget -- 299
end -- 291
local function renderPlayTarget(state) -- 302
	if not state.isPlaying then -- 302
		return -- 303
	end -- 303
	if state.playDirty or state.playRoot == nil then -- 303
		rebuildPlayRuntime(state) -- 304
	end -- 304
	local target = ensurePlayTarget(state) -- 305
	if state.playRoot ~= nil then -- 305
		state.playRoot.visible = true -- 307
		target:renderWithClear( -- 308
			state.playRoot, -- 308
			Color(4279572511) -- 308
		) -- 308
		state.playRoot.visible = false -- 309
	end -- 309
end -- 302
function ____exports.drawGamePreviewWindow(state) -- 313
	if not state.isPlaying then -- 313
		return -- 314
	end -- 314
	renderPlayTarget(state) -- 315
	if playTarget == nil then -- 315
		return -- 316
	end -- 316
	ImGui.SetNextWindowSize( -- 317
		Vec2(720, 480), -- 317
		"FirstUseEver" -- 317
	) -- 317
	ImGui.Begin( -- 318
		zh and "游戏预览" or "Game Preview", -- 318
		function() -- 318
			local avail = ImGui.GetContentRegionAvail() -- 319
			local width = gameWidthOf(state) -- 320
			local height = gameHeightOf(state) -- 321
			local scale = math.max( -- 322
				0.1, -- 322
				math.min(avail.x / width, avail.y / height) -- 322
			) -- 322
			local displayWidth = width * scale -- 323
			local displayHeight = height * scale -- 324
			ImGui.TextDisabled((((zh and "运行尺寸：" or "Game Size: ") .. tostring(width)) .. " x ") .. tostring(height)) -- 325
			ImGui.TextColored(okColor, zh and "游戏正在运行。当前 Dora App 缺少稳定的 ImGui 纹理显示接口，独立预览窗口暂不显示画面。" or "Game is running. The current Dora App lacks a stable ImGui texture display API, so this detached preview window does not show the frame yet.") -- 326
			ImGui.TextDisabled((((zh and "目标显示尺寸：" or "Target display size: ") .. tostring(math.floor(displayWidth))) .. " x ") .. tostring(math.floor(displayHeight))) -- 327
		end -- 318
	) -- 318
end -- 313
return ____exports -- 313