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
	local visited = {} -- 84
	local cursor = state.nodes[id] -- 85
	while cursor ~= nil do -- 85
		if visited[cursor.id] then -- 85
			break -- 87
		end -- 87
		visited[cursor.id] = true -- 88
		x = x + cursor.x -- 89
		y = y + cursor.y -- 90
		if cursor.parentId == nil or cursor.parentId == cursor.id then -- 90
			break -- 91
		end -- 91
		cursor = cursor.parentId ~= nil and state.nodes[cursor.parentId] or nil -- 92
	end -- 92
	return {x, y} -- 94
end -- 81
local function loadScriptText(scriptPath) -- 97
	if scriptPath == "" then -- 97
		return "" -- 98
	end -- 98
	local projectPath = workspacePath(scriptPath) -- 99
	if Content:exist(projectPath) then -- 99
		return Content:load(projectPath) or "" -- 100
	end -- 100
	if Content:exist(scriptPath) then -- 100
		return Content:load(scriptPath) or "" -- 101
	end -- 101
	return "" -- 102
end -- 97
local function runNodeScript(state, item, runtimeNode) -- 105
	local scriptText = loadScriptText(item.script) -- 106
	if scriptText == "" then -- 106
		return -- 107
	end -- 107
	local chunk, loadError = load(scriptText, item.script) -- 108
	if chunk == nil then -- 108
		pushConsole( -- 110
			state, -- 110
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 110
		) -- 110
		return -- 111
	end -- 111
	local ok, result = pcall(chunk) -- 113
	if not ok then -- 113
		pushConsole( -- 115
			state, -- 115
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 115
		) -- 115
		return -- 116
	end -- 116
	if type(result) == "function" then -- 116
		local behavior = result -- 119
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 120
		if not behaviorOk then -- 120
			pushConsole( -- 121
				state, -- 121
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 121
			) -- 121
		end -- 121
	end -- 121
end -- 105
local function defaultGameMainLua() -- 125
	return ((((((((((((((((("-- Game main script\n" .. "-- Auto-created by Dora Visual Editor.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then player = node end\n") .. "\t\tend\n") .. "\t\tif player == nil then return end\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then player.x = player.x - speed * deltaTime end\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then player.x = player.x + speed * deltaTime end\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 125
local function ensureGameMainScript(state) -- 147
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 148
	state.gameScript = scriptPath -- 149
	state.gameScriptBuffer.text = scriptPath -- 150
	local file = workspacePath(scriptPath) -- 151
	if not Content:exist(file) then -- 151
		Content:mkdir(Path:getPath(file)) -- 153
		Content:save( -- 154
			file, -- 154
			defaultGameMainLua() -- 154
		) -- 154
	end -- 154
end -- 147
local function runGameMain(state) -- 158
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 159
	local scriptText = loadScriptText(scriptPath) -- 160
	if scriptText == "" then -- 160
		return -- 161
	end -- 161
	local chunk, loadError = load(scriptText, scriptPath) -- 162
	if chunk == nil then -- 162
		pushConsole( -- 164
			state, -- 164
			(((zh and "主脚本加载失败：" or "Main script load failed: ") .. scriptPath) .. " ") .. tostring(loadError or "") -- 164
		) -- 164
		return -- 165
	end -- 165
	local ok, result = pcall(chunk) -- 167
	if not ok then -- 167
		pushConsole( -- 169
			state, -- 169
			(((zh and "主脚本执行失败：" or "Main script failed: ") .. scriptPath) .. " ") .. tostring(result) -- 169
		) -- 169
		return -- 170
	end -- 170
	local start = nil -- 172
	if type(result) == "function" then -- 172
		start = result -- 174
	elseif type(result) == "table" then -- 174
		local module = result -- 176
		if module.start ~= nil then -- 176
			start = module.start -- 177
		end -- 177
	end -- 177
	local scene = state.playContent -- 179
	local world = state.playWorld -- 180
	if start ~= nil and scene ~= nil and world ~= nil then -- 180
		local entry = start -- 182
		local startOk, startError = pcall(function() return entry(scene, state.playRuntimeNodes, world) end) -- 183
		if not startOk then -- 183
			pushConsole( -- 184
				state, -- 184
				(zh and "主脚本启动失败：" or "Main script start failed: ") .. tostring(startError) -- 184
			) -- 184
		end -- 184
	end -- 184
end -- 158
local function clearPlayRuntime(state) -- 188
	if state.playRoot ~= nil then -- 188
		state.playRoot:removeFromParent(true) -- 190
		state.playRoot = nil -- 191
	end -- 191
	state.playWorld = nil -- 193
	state.playContent = nil -- 194
	state.playRuntimeNodes = {} -- 195
	state.playRuntimeLabels = {} -- 196
	state.isPlaying = false -- 197
	state.playDirty = true -- 198
end -- 188
function ____exports.stopPlay(state) -- 201
	clearPlayRuntime(state) -- 202
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 203
	pushConsole(state, state.status) -- 204
end -- 201
function ____exports.startPlay(state) -- 207
	clearPlayRuntime(state) -- 208
	ensureGameMainScript(state) -- 209
	state.isPlaying = true -- 210
	state.gameWindowOpen = true -- 211
	state.playDirty = true -- 212
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 213
	pushConsole(state, state.status) -- 214
end -- 207
local function gameWidthOf(state) -- 217
	return math.max( -- 218
		160, -- 218
		math.floor(state.gameWidth) -- 218
	) -- 218
end -- 217
local function gameHeightOf(state) -- 221
	return math.max( -- 222
		120, -- 222
		math.floor(state.gameHeight) -- 222
	) -- 222
end -- 221
local function rebuildPlayRuntime(state) -- 225
	local width = gameWidthOf(state) -- 226
	local height = gameHeightOf(state) -- 227
	state.playRoot = Node() -- 228
	state.playRoot.tag = "__DoraImGuiGamePreview__" -- 229
	state.playRoot.visible = false -- 230
	state.playRuntimeNodes = {} -- 231
	state.playRuntimeLabels = {} -- 232
	Director.entry:addChild(state.playRoot) -- 233
	local background = makeGameBackground(width, height) -- 235
	background.x = width / 2 -- 236
	background.y = height / 2 -- 237
	state.playRoot:addChild(background) -- 238
	local world = Node() -- 239
	state.playWorld = world -- 240
	world.x = width / 2 -- 241
	world.y = height / 2 -- 242
	state.playRoot:addChild(world) -- 243
	local content = Node() -- 244
	state.playContent = content -- 245
	world:addChild(content) -- 246
	state.playRuntimeNodes.root = content -- 247
	for ____, id in ipairs(state.order) do -- 249
		local item = state.nodes[id] -- 250
		if item ~= nil and id ~= "root" then -- 250
			local runtime = createPlayVisual(item) -- 252
			applyTransform(runtime, item) -- 253
			state.playRuntimeNodes[id] = runtime -- 254
			if item.kind == "Label" then -- 254
				state.playRuntimeLabels[id] = runtime -- 255
			end -- 255
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 256
			parent:addChild(runtime) -- 257
		end -- 257
	end -- 257
	local cameraId = firstCameraId(state) -- 261
	local cameraData = cameraId ~= nil and state.nodes[cameraId] or nil -- 262
	local cameraNode = cameraId ~= nil and state.playRuntimeNodes[cameraId] or nil -- 263
	local function updateCamera() -- 264
		if cameraNode ~= nil and cameraData ~= nil then -- 264
			if cameraData.followTargetId ~= "" then -- 264
				local targetNode = state.playRuntimeNodes[cameraData.followTargetId] -- 267
				if targetNode ~= nil then -- 267
					local targetX, targetY = table.unpack( -- 269
						sceneWorldPosition(state, cameraData.followTargetId), -- 269
						1, -- 269
						2 -- 269
					) -- 269
					cameraNode.x = targetX + cameraData.followOffsetX -- 270
					cameraNode.y = targetY + cameraData.followOffsetY -- 271
				end -- 271
			end -- 271
			world.x = width / 2 -- 274
			world.y = height / 2 -- 275
			world.angle = -cameraNode.angle -- 276
			world.scaleX = cameraNode.scaleX ~= 0 and 1 / cameraNode.scaleX or 1 -- 277
			world.scaleY = cameraNode.scaleY ~= 0 and 1 / cameraNode.scaleY or 1 -- 278
			content.x = -cameraNode.x -- 279
			content.y = -cameraNode.y -- 280
		else -- 280
			world.x = width / 2 -- 282
			world.y = height / 2 -- 283
			world.angle = 0 -- 284
			world.scaleX = 1 -- 285
			world.scaleY = 1 -- 286
			content.x = 0 -- 287
			content.y = 0 -- 288
		end -- 288
	end -- 264
	updateCamera() -- 291
	world:schedule(function() -- 292
		updateCamera() -- 293
		return false -- 294
	end) -- 292
	for ____, id in ipairs(state.order) do -- 297
		local item = state.nodes[id] -- 298
		local runtime = state.playRuntimeNodes[id] -- 299
		if item ~= nil and runtime ~= nil then -- 299
			runNodeScript(state, item, runtime) -- 300
		end -- 300
	end -- 300
	runGameMain(state) -- 302
	state.playDirty = false -- 303
end -- 225
local function ensurePlayTarget(state) -- 306
	local width = gameWidthOf(state) -- 307
	local height = gameHeightOf(state) -- 308
	if playTarget == nil or playTargetWidth ~= width or playTargetHeight ~= height then -- 308
		playTarget = RenderTarget(width, height) -- 310
		playTargetWidth = width -- 311
		playTargetHeight = height -- 312
	end -- 312
	return playTarget -- 314
end -- 306
local function renderPlayTarget(state) -- 317
	if not state.isPlaying then -- 317
		return -- 318
	end -- 318
	if state.playDirty or state.playRoot == nil then -- 318
		rebuildPlayRuntime(state) -- 319
	end -- 319
	local target = ensurePlayTarget(state) -- 320
	if state.playRoot ~= nil then -- 320
		state.playRoot.visible = true -- 322
		target:renderWithClear( -- 323
			state.playRoot, -- 323
			Color(4279572511) -- 323
		) -- 323
		state.playRoot.visible = false -- 324
	end -- 324
end -- 317
function ____exports.drawGamePreviewWindow(state) -- 328
	if not state.isPlaying then -- 328
		return -- 329
	end -- 329
	renderPlayTarget(state) -- 330
	if playTarget == nil then -- 330
		return -- 331
	end -- 331
	local target = playTarget -- 332
	ImGui.SetNextWindowSize( -- 333
		Vec2(720, 480), -- 333
		"FirstUseEver" -- 333
	) -- 333
	ImGui.Begin( -- 334
		zh and "游戏预览" or "Game Preview", -- 334
		function() -- 334
			local avail = ImGui.GetContentRegionAvail() -- 335
			local width = gameWidthOf(state) -- 336
			local height = gameHeightOf(state) -- 337
			local scale = math.max( -- 338
				0.1, -- 338
				math.min(avail.x / width, avail.y / height) -- 338
			) -- 338
			local displayWidth = width * scale -- 339
			local displayHeight = height * scale -- 340
			ImGui.TextDisabled((((zh and "运行尺寸：" or "Game Size: ") .. tostring(width)) .. " x ") .. tostring(height)) -- 341
			if ImGui.ImageTexture ~= nil then -- 341
				ImGui.ImageTexture( -- 343
					target.texture, -- 343
					Vec2(displayWidth, displayHeight) -- 343
				) -- 343
			else -- 343
				ImGui.TextColored(okColor, zh and "游戏正在运行。当前 Dora App 缺少 ImGui.ImageTexture，无法显示独立预览窗口。" or "Game is running. Current Dora App lacks ImGui.ImageTexture, so the detached preview cannot be shown.") -- 345
			end -- 345
		end -- 334
	) -- 334
end -- 328
return ____exports -- 328