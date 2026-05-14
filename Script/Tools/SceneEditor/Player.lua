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
local playTarget = nil -- 16
local playTargetWidth = 0 -- 17
local playTargetHeight = 0 -- 18
local function makeGameBackground(width, height) -- 20
	local hw = width / 2 -- 21
	local hh = height / 2 -- 22
	local bg = DrawNode() -- 23
	bg:drawPolygon( -- 24
		{ -- 24
			Vec2(-hw, -hh), -- 25
			Vec2(hw, -hh), -- 26
			Vec2(hw, hh), -- 27
			Vec2(-hw, hh) -- 28
		}, -- 28
		viewportBgColor, -- 29
		1.4, -- 29
		okColor -- 29
	) -- 29
	return bg -- 30
end -- 20
local function makeFallbackRect(width, height, color) -- 33
	local hw = width / 2 -- 34
	local hh = height / 2 -- 35
	local rect = DrawNode() -- 36
	rect:drawSegment( -- 37
		Vec2(-hw, -hh), -- 37
		Vec2(hw, -hh), -- 37
		1, -- 37
		color -- 37
	) -- 37
	rect:drawSegment( -- 38
		Vec2(hw, -hh), -- 38
		Vec2(hw, hh), -- 38
		1, -- 38
		color -- 38
	) -- 38
	rect:drawSegment( -- 39
		Vec2(hw, hh), -- 39
		Vec2(-hw, hh), -- 39
		1, -- 39
		color -- 39
	) -- 39
	rect:drawSegment( -- 40
		Vec2(-hw, hh), -- 40
		Vec2(-hw, -hh), -- 40
		1, -- 40
		color -- 40
	) -- 40
	return rect -- 41
end -- 33
local function createPlayVisual(item) -- 44
	if item.kind == "Sprite" then -- 44
		if item.texture ~= "" then -- 44
			local sprite = Sprite(item.texture) -- 47
			if sprite ~= nil then -- 47
				return sprite -- 48
			end -- 48
		end -- 48
		return makeFallbackRect( -- 50
			128, -- 50
			96, -- 50
			Color(2859640520) -- 50
		) -- 50
	end -- 50
	if item.kind == "Label" then -- 50
		local label = Label("sarasa-mono-sc-regular", 32) -- 53
		if label ~= nil then -- 53
			label.text = item.text or "Label" -- 55
			return label -- 56
		end -- 56
		return makeFallbackRect( -- 58
			180, -- 58
			56, -- 58
			Color(2866196799) -- 58
		) -- 58
	end -- 58
	return Node() -- 60
end -- 44
local function applyTransform(target, item) -- 63
	target.x = item.x -- 64
	target.y = item.y -- 65
	target.scaleX = item.scaleX -- 66
	target.scaleY = item.scaleY -- 67
	target.angle = item.rotation -- 68
	target.visible = item.visible -- 69
	target.tag = item.name -- 70
end -- 63
local function firstCameraId(state) -- 73
	for ____, id in ipairs(state.order) do -- 74
		local item = state.nodes[id] -- 75
		if item ~= nil and item.kind == "Camera" and item.visible then -- 75
			return id -- 76
		end -- 76
	end -- 76
	return nil -- 78
end -- 73
local function sceneWorldPosition(state, id) -- 81
	local x = 0 -- 82
	local y = 0 -- 83
	local cursor = state.nodes[id] -- 84
	while cursor ~= nil do -- 84
		x = x + cursor.x -- 86
		y = y + cursor.y -- 87
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 88
	end -- 88
	return {x, y} -- 90
end -- 81
local function loadScriptText(scriptPath) -- 93
	if scriptPath == "" then -- 93
		return "" -- 94
	end -- 94
	local projectPath = workspacePath(scriptPath) -- 95
	if Content:exist(projectPath) then -- 95
		return Content:load(projectPath) or "" -- 96
	end -- 96
	if Content:exist(scriptPath) then -- 96
		return Content:load(scriptPath) or "" -- 97
	end -- 97
	return "" -- 98
end -- 93
local function runNodeScript(state, item, runtimeNode) -- 101
	local scriptText = loadScriptText(item.script) -- 102
	if scriptText == "" then -- 102
		return -- 103
	end -- 103
	local chunk, loadError = load(scriptText, item.script) -- 104
	if chunk == nil then -- 104
		pushConsole( -- 106
			state, -- 106
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 106
		) -- 106
		return -- 107
	end -- 107
	local ok, result = pcall(chunk) -- 109
	if not ok then -- 109
		pushConsole( -- 111
			state, -- 111
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 111
		) -- 111
		return -- 112
	end -- 112
	if type(result) == "function" then -- 112
		local behavior = result -- 115
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 116
		if not behaviorOk then -- 116
			pushConsole( -- 117
				state, -- 117
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 117
			) -- 117
		end -- 117
	end -- 117
end -- 101
local function defaultGameMainLua() -- 121
	return ((((((((((((((((("-- Game main script\n" .. "-- Auto-created by Dora Visual Editor.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then player = node end\n") .. "\t\tend\n") .. "\t\tif player == nil then return end\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then player.x = player.x - speed * deltaTime end\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then player.x = player.x + speed * deltaTime end\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 121
local function ensureGameMainScript(state) -- 143
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 144
	state.gameScript = scriptPath -- 145
	state.gameScriptBuffer.text = scriptPath -- 146
	local file = workspacePath(scriptPath) -- 147
	if not Content:exist(file) then -- 147
		Content:mkdir(Path:getPath(file)) -- 149
		Content:save( -- 150
			file, -- 150
			defaultGameMainLua() -- 150
		) -- 150
	end -- 150
end -- 143
local function runGameMain(state) -- 154
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 155
	local scriptText = loadScriptText(scriptPath) -- 156
	if scriptText == "" then -- 156
		return -- 157
	end -- 157
	local chunk, loadError = load(scriptText, scriptPath) -- 158
	if chunk == nil then -- 158
		pushConsole( -- 160
			state, -- 160
			(((zh and "主脚本加载失败：" or "Main script load failed: ") .. scriptPath) .. " ") .. tostring(loadError or "") -- 160
		) -- 160
		return -- 161
	end -- 161
	local ok, result = pcall(chunk) -- 163
	if not ok then -- 163
		pushConsole( -- 165
			state, -- 165
			(((zh and "主脚本执行失败：" or "Main script failed: ") .. scriptPath) .. " ") .. tostring(result) -- 165
		) -- 165
		return -- 166
	end -- 166
	local start = nil -- 168
	if type(result) == "function" then -- 168
		start = result -- 170
	elseif type(result) == "table" then -- 170
		local module = result -- 172
		if module.start ~= nil then -- 172
			start = module.start -- 173
		end -- 173
	end -- 173
	local scene = state.playContent -- 175
	local world = state.playWorld -- 176
	if start ~= nil and scene ~= nil and world ~= nil then -- 176
		local entry = start -- 178
		local startOk, startError = pcall(function() return entry(scene, state.playRuntimeNodes, world) end) -- 179
		if not startOk then -- 179
			pushConsole( -- 180
				state, -- 180
				(zh and "主脚本启动失败：" or "Main script start failed: ") .. tostring(startError) -- 180
			) -- 180
		end -- 180
	end -- 180
end -- 154
local function clearPlayRuntime(state) -- 184
	if state.playRoot ~= nil then -- 184
		state.playRoot:removeFromParent(true) -- 186
		state.playRoot = nil -- 187
	end -- 187
	state.playWorld = nil -- 189
	state.playContent = nil -- 190
	state.playRuntimeNodes = {} -- 191
	state.playRuntimeLabels = {} -- 192
	state.isPlaying = false -- 193
	state.playDirty = true -- 194
end -- 184
function ____exports.stopPlay(state) -- 197
	clearPlayRuntime(state) -- 198
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 199
	pushConsole(state, state.status) -- 200
end -- 197
function ____exports.startPlay(state) -- 203
	clearPlayRuntime(state) -- 204
	ensureGameMainScript(state) -- 205
	state.isPlaying = true -- 206
	state.gameWindowOpen = true -- 207
	state.playDirty = true -- 208
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 209
	pushConsole(state, state.status) -- 210
end -- 203
local function gameWidthOf(state) -- 213
	return math.max( -- 214
		160, -- 214
		math.floor(state.gameWidth) -- 214
	) -- 214
end -- 213
local function gameHeightOf(state) -- 217
	return math.max( -- 218
		120, -- 218
		math.floor(state.gameHeight) -- 218
	) -- 218
end -- 217
local function rebuildPlayRuntime(state) -- 221
	local width = gameWidthOf(state) -- 222
	local height = gameHeightOf(state) -- 223
	state.playRoot = Node() -- 224
	state.playRoot.tag = "__DoraImGuiGamePreview__" -- 225
	state.playRoot.visible = false -- 226
	state.playRuntimeNodes = {} -- 227
	state.playRuntimeLabels = {} -- 228
	Director.entry:addChild(state.playRoot) -- 229
	local background = makeGameBackground(width, height) -- 231
	background.x = width / 2 -- 232
	background.y = height / 2 -- 233
	state.playRoot:addChild(background) -- 234
	local world = Node() -- 235
	state.playWorld = world -- 236
	world.x = width / 2 -- 237
	world.y = height / 2 -- 238
	state.playRoot:addChild(world) -- 239
	local content = Node() -- 240
	state.playContent = content -- 241
	world:addChild(content) -- 242
	state.playRuntimeNodes.root = content -- 243
	for ____, id in ipairs(state.order) do -- 245
		local item = state.nodes[id] -- 246
		if item ~= nil and id ~= "root" then -- 246
			local runtime = createPlayVisual(item) -- 248
			applyTransform(runtime, item) -- 249
			state.playRuntimeNodes[id] = runtime -- 250
			if item.kind == "Label" then -- 250
				state.playRuntimeLabels[id] = runtime -- 251
			end -- 251
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 252
			parent:addChild(runtime) -- 253
		end -- 253
	end -- 253
	local cameraId = firstCameraId(state) -- 257
	local cameraData = cameraId ~= nil and state.nodes[cameraId] or nil -- 258
	local cameraNode = cameraId ~= nil and state.playRuntimeNodes[cameraId] or nil -- 259
	local function updateCamera() -- 260
		if cameraNode ~= nil and cameraData ~= nil then -- 260
			if cameraData.followTargetId ~= "" then -- 260
				local targetNode = state.playRuntimeNodes[cameraData.followTargetId] -- 263
				if targetNode ~= nil then -- 263
					local targetX, targetY = table.unpack( -- 265
						sceneWorldPosition(state, cameraData.followTargetId), -- 265
						1, -- 265
						2 -- 265
					) -- 265
					cameraNode.x = targetX + cameraData.followOffsetX -- 266
					cameraNode.y = targetY + cameraData.followOffsetY -- 267
				end -- 267
			end -- 267
			world.x = width / 2 -- 270
			world.y = height / 2 -- 271
			world.angle = -cameraNode.angle -- 272
			world.scaleX = cameraNode.scaleX ~= 0 and 1 / cameraNode.scaleX or 1 -- 273
			world.scaleY = cameraNode.scaleY ~= 0 and 1 / cameraNode.scaleY or 1 -- 274
			content.x = -cameraNode.x -- 275
			content.y = -cameraNode.y -- 276
		else -- 276
			world.x = width / 2 -- 278
			world.y = height / 2 -- 279
			world.angle = 0 -- 280
			world.scaleX = 1 -- 281
			world.scaleY = 1 -- 282
			content.x = 0 -- 283
			content.y = 0 -- 284
		end -- 284
	end -- 260
	updateCamera() -- 287
	world:schedule(function() -- 288
		updateCamera() -- 289
		return false -- 290
	end) -- 288
	for ____, id in ipairs(state.order) do -- 293
		local item = state.nodes[id] -- 294
		local runtime = state.playRuntimeNodes[id] -- 295
		if item ~= nil and runtime ~= nil then -- 295
			runNodeScript(state, item, runtime) -- 296
		end -- 296
	end -- 296
	runGameMain(state) -- 298
	state.playDirty = false -- 299
end -- 221
local function ensurePlayTarget(state) -- 302
	local width = gameWidthOf(state) -- 303
	local height = gameHeightOf(state) -- 304
	if playTarget == nil or playTargetWidth ~= width or playTargetHeight ~= height then -- 304
		playTarget = RenderTarget(width, height) -- 306
		playTargetWidth = width -- 307
		playTargetHeight = height -- 308
	end -- 308
	return playTarget -- 310
end -- 302
local function renderPlayTarget(state) -- 313
	if not state.isPlaying then -- 313
		return -- 314
	end -- 314
	if state.playDirty or state.playRoot == nil then -- 314
		rebuildPlayRuntime(state) -- 315
	end -- 315
	local target = ensurePlayTarget(state) -- 316
	if state.playRoot ~= nil then -- 316
		state.playRoot.visible = true -- 318
		target:renderWithClear( -- 319
			state.playRoot, -- 319
			Color(4279572511) -- 319
		) -- 319
		state.playRoot.visible = false -- 320
	end -- 320
end -- 313
function ____exports.drawGamePreviewWindow(state) -- 324
	if not state.isPlaying then -- 324
		return -- 325
	end -- 325
	renderPlayTarget(state) -- 326
	if playTarget == nil then -- 326
		return -- 327
	end -- 327
	local target = playTarget -- 328
	ImGui.SetNextWindowSize( -- 329
		Vec2(720, 480), -- 329
		"FirstUseEver" -- 329
	) -- 329
	ImGui.Begin( -- 330
		zh and "游戏预览" or "Game Preview", -- 330
		function() -- 330
			local avail = ImGui.GetContentRegionAvail() -- 331
			local width = gameWidthOf(state) -- 332
			local height = gameHeightOf(state) -- 333
			local scale = math.max( -- 334
				0.1, -- 334
				math.min(avail.x / width, avail.y / height) -- 334
			) -- 334
			local displayWidth = width * scale -- 335
			local displayHeight = height * scale -- 336
			ImGui.TextDisabled((((zh and "运行尺寸：" or "Game Size: ") .. tostring(width)) .. " x ") .. tostring(height)) -- 337
			ImGui.ImageTexture( -- 338
				target.texture, -- 338
				Vec2(displayWidth, displayHeight) -- 338
			) -- 338
		end -- 330
	) -- 330
end -- 324
return ____exports -- 324