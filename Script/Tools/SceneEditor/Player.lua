-- [ts]: Player.ts
local ____exports = {} -- 1
local gameWidthOf, gameHeightOf -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local RenderTarget = ____Dora.RenderTarget -- 1
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
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 8
local canNodeKindFollowTarget = ____NodeCapabilities.canNodeKindFollowTarget -- 8
local ____SceneNodeRenderer = require("Script.Tools.SceneEditor.SceneNodeRenderer") -- 9
local applySceneNodeTransform = ____SceneNodeRenderer.applySceneNodeTransform -- 9
local createSceneNodeVisual = ____SceneNodeRenderer.createSceneNodeVisual -- 9
local updateSceneNodeDynamicVisual = ____SceneNodeRenderer.updateSceneNodeDynamicVisual -- 9
function gameWidthOf(state) -- 174
	return math.max( -- 175
		160, -- 175
		math.floor(state.gameWidth) -- 175
	) -- 175
end -- 175
function gameHeightOf(state) -- 178
	return math.max( -- 179
		120, -- 179
		math.floor(state.gameHeight) -- 179
	) -- 179
end -- 179
local playTarget = nil -- 19
local playTargetWidth = 0 -- 20
local playTargetHeight = 0 -- 21
local function makeGameBackground(width, height) -- 23
	local hw = width / 2 -- 24
	local hh = height / 2 -- 25
	local bg = DrawNode() -- 26
	bg:drawPolygon( -- 27
		{ -- 27
			Vec2(-hw, -hh), -- 28
			Vec2(hw, -hh), -- 29
			Vec2(hw, hh), -- 30
			Vec2(-hw, hh) -- 31
		}, -- 31
		viewportBgColor, -- 32
		1.4, -- 32
		okColor -- 32
	) -- 32
	return bg -- 33
end -- 23
local function createPlayVisual(state, item) -- 36
	return createSceneNodeVisual( -- 37
		item, -- 37
		{ -- 37
			mode = "play", -- 38
			selected = false, -- 39
			gameWidth = gameWidthOf(state), -- 40
			gameHeight = gameHeightOf(state), -- 41
			labels = state.playRuntimeLabels -- 42
		} -- 42
	) -- 42
end -- 36
local function firstCameraId(state) -- 46
	for ____, id in ipairs(state.order) do -- 47
		local item = state.nodes[id] -- 48
		if item ~= nil and canNodeKindFollowTarget(item.kind) and item.visible then -- 48
			return id -- 49
		end -- 49
	end -- 49
	return nil -- 51
end -- 46
local function loadScriptText(scriptPath) -- 54
	if scriptPath == "" then -- 54
		return "" -- 55
	end -- 55
	local projectPath = workspacePath(scriptPath) -- 56
	if Content:exist(projectPath) then -- 56
		return Content:load(projectPath) or "" -- 57
	end -- 57
	if Content:exist(scriptPath) then -- 57
		return Content:load(scriptPath) or "" -- 58
	end -- 58
	return "" -- 59
end -- 54
local function runNodeScript(state, item, runtimeNode) -- 62
	local scriptText = loadScriptText(item.script) -- 63
	if scriptText == "" then -- 63
		return -- 64
	end -- 64
	local chunk, loadError = load(scriptText, item.script) -- 65
	if chunk == nil then -- 65
		pushConsole( -- 67
			state, -- 67
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 67
		) -- 67
		return -- 68
	end -- 68
	local ok, result = pcall(chunk) -- 70
	if not ok then -- 70
		pushConsole( -- 72
			state, -- 72
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 72
		) -- 72
		return -- 73
	end -- 73
	if type(result) == "function" then -- 73
		local behavior = result -- 76
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 77
		if not behaviorOk then -- 77
			pushConsole( -- 78
				state, -- 78
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 78
			) -- 78
		end -- 78
	end -- 78
end -- 62
local function defaultGameMainLua() -- 82
	return ((((((((((((((((("-- Game main script\n" .. "-- Auto-created by Dora Visual Editor.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then player = node end\n") .. "\t\tend\n") .. "\t\tif player == nil then return end\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then player.x = player.x - speed * deltaTime end\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then player.x = player.x + speed * deltaTime end\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 82
local function ensureGameMainScript(state) -- 104
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 105
	state.gameScript = scriptPath -- 106
	state.gameScriptBuffer.text = scriptPath -- 107
	local file = workspacePath(scriptPath) -- 108
	if not Content:exist(file) then -- 108
		Content:mkdir(Path:getPath(file)) -- 110
		Content:save( -- 111
			file, -- 111
			defaultGameMainLua() -- 111
		) -- 111
	end -- 111
end -- 104
local function runGameMain(state) -- 115
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 116
	local scriptText = loadScriptText(scriptPath) -- 117
	if scriptText == "" then -- 117
		return -- 118
	end -- 118
	local chunk, loadError = load(scriptText, scriptPath) -- 119
	if chunk == nil then -- 119
		pushConsole( -- 121
			state, -- 121
			(((zh and "主脚本加载失败：" or "Main script load failed: ") .. scriptPath) .. " ") .. tostring(loadError or "") -- 121
		) -- 121
		return -- 122
	end -- 122
	local ok, result = pcall(chunk) -- 124
	if not ok then -- 124
		pushConsole( -- 126
			state, -- 126
			(((zh and "主脚本执行失败：" or "Main script failed: ") .. scriptPath) .. " ") .. tostring(result) -- 126
		) -- 126
		return -- 127
	end -- 127
	local start = nil -- 129
	if type(result) == "function" then -- 129
		start = result -- 131
	elseif type(result) == "table" then -- 131
		local module = result -- 133
		if module.start ~= nil then -- 133
			start = module.start -- 134
		end -- 134
	end -- 134
	local scene = state.playContent -- 136
	local world = state.playWorld -- 137
	if start ~= nil and scene ~= nil and world ~= nil then -- 137
		local entry = start -- 139
		local startOk, startError = pcall(function() return entry(scene, state.playRuntimeNodes, world) end) -- 140
		if not startOk then -- 140
			pushConsole( -- 141
				state, -- 141
				(zh and "主脚本启动失败：" or "Main script start failed: ") .. tostring(startError) -- 141
			) -- 141
		end -- 141
	end -- 141
end -- 115
local function clearPlayRuntime(state) -- 145
	if state.playRoot ~= nil then -- 145
		state.playRoot:removeFromParent(true) -- 147
		state.playRoot = nil -- 148
	end -- 148
	state.playWorld = nil -- 150
	state.playContent = nil -- 151
	state.playRuntimeNodes = {} -- 152
	state.playRuntimeLabels = {} -- 153
	state.isPlaying = false -- 154
	state.playDirty = true -- 155
end -- 145
function ____exports.stopPlay(state) -- 158
	clearPlayRuntime(state) -- 159
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 160
	pushConsole(state, state.status) -- 161
end -- 158
function ____exports.startPlay(state) -- 164
	clearPlayRuntime(state) -- 165
	ensureGameMainScript(state) -- 166
	state.isPlaying = true -- 167
	state.gameWindowOpen = true -- 168
	state.playDirty = true -- 169
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 170
	pushConsole(state, state.status) -- 171
end -- 164
local function rebuildPlayRuntime(state) -- 182
	local width = gameWidthOf(state) -- 183
	local height = gameHeightOf(state) -- 184
	state.playRoot = Node() -- 185
	state.playRoot.tag = "__DoraImGuiGamePreview__" -- 186
	state.playRoot.visible = false -- 187
	state.playRuntimeNodes = {} -- 188
	state.playRuntimeLabels = {} -- 189
	Director.entry:addChild(state.playRoot) -- 190
	local background = makeGameBackground(width, height) -- 192
	background.x = width / 2 -- 193
	background.y = height / 2 -- 194
	state.playRoot:addChild(background) -- 195
	local world = Node() -- 196
	state.playWorld = world -- 197
	world.x = width / 2 -- 198
	world.y = height / 2 -- 199
	state.playRoot:addChild(world) -- 200
	local content = Node() -- 201
	state.playContent = content -- 202
	world:addChild(content) -- 203
	state.playRuntimeNodes.root = content -- 204
	for ____, id in ipairs(state.order) do -- 206
		local item = state.nodes[id] -- 207
		if item ~= nil and id ~= "root" then -- 207
			local runtime = createPlayVisual(state, item) -- 209
			applySceneNodeTransform(runtime, item) -- 210
			updateSceneNodeDynamicVisual(item, state.playRuntimeLabels) -- 211
			state.playRuntimeNodes[id] = runtime -- 212
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 213
			parent:addChild(runtime) -- 214
		end -- 214
	end -- 214
	local cameraId = firstCameraId(state) -- 218
	local cameraData = cameraId ~= nil and state.nodes[cameraId] or nil -- 219
	local cameraNode = cameraId ~= nil and state.playRuntimeNodes[cameraId] or nil -- 220
	local function updateCamera() -- 221
		if cameraNode ~= nil and cameraData ~= nil then -- 221
			if cameraData.followTargetId ~= "" then -- 221
				local targetNode = state.playRuntimeNodes[cameraData.followTargetId] -- 224
				if targetNode ~= nil then -- 224
					local targetX, targetY = table.unpack( -- 226
						worldPositionOf(state, cameraData.followTargetId), -- 226
						1, -- 226
						2 -- 226
					) -- 226
					cameraNode.x = targetX + cameraData.followOffsetX -- 227
					cameraNode.y = targetY + cameraData.followOffsetY -- 228
				end -- 228
			end -- 228
			world.x = width / 2 -- 231
			world.y = height / 2 -- 232
			world.angle = -cameraNode.angle -- 233
			world.scaleX = cameraNode.scaleX ~= 0 and 1 / cameraNode.scaleX or 1 -- 234
			world.scaleY = cameraNode.scaleY ~= 0 and 1 / cameraNode.scaleY or 1 -- 235
			content.x = -cameraNode.x -- 236
			content.y = -cameraNode.y -- 237
		else -- 237
			world.x = width / 2 -- 239
			world.y = height / 2 -- 240
			world.angle = 0 -- 241
			world.scaleX = 1 -- 242
			world.scaleY = 1 -- 243
			content.x = 0 -- 244
			content.y = 0 -- 245
		end -- 245
	end -- 221
	updateCamera() -- 248
	world:schedule(function() -- 249
		updateCamera() -- 250
		return false -- 251
	end) -- 249
	for ____, id in ipairs(state.order) do -- 254
		local item = state.nodes[id] -- 255
		local runtime = state.playRuntimeNodes[id] -- 256
		if item ~= nil and runtime ~= nil then -- 256
			runNodeScript(state, item, runtime) -- 257
		end -- 257
	end -- 257
	runGameMain(state) -- 259
	state.playDirty = false -- 260
end -- 182
local function ensurePlayTarget(state) -- 263
	local width = gameWidthOf(state) -- 264
	local height = gameHeightOf(state) -- 265
	if playTarget == nil or playTargetWidth ~= width or playTargetHeight ~= height then -- 265
		playTarget = RenderTarget(width, height) -- 267
		playTargetWidth = width -- 268
		playTargetHeight = height -- 269
	end -- 269
	return playTarget -- 271
end -- 263
local function renderPlayTarget(state) -- 274
	if not state.isPlaying then -- 274
		return -- 275
	end -- 275
	if state.playDirty or state.playRoot == nil then -- 275
		rebuildPlayRuntime(state) -- 276
	end -- 276
	local target = ensurePlayTarget(state) -- 277
	if state.playRoot ~= nil then -- 277
		state.playRoot.visible = true -- 279
		target:renderWithClear( -- 280
			state.playRoot, -- 280
			Color(4279572511) -- 280
		) -- 280
		state.playRoot.visible = false -- 281
	end -- 281
end -- 274
function ____exports.drawGamePreviewWindow(state) -- 285
	if not state.isPlaying then -- 285
		return -- 286
	end -- 286
	renderPlayTarget(state) -- 287
	if playTarget == nil then -- 287
		return -- 288
	end -- 288
	ImGui.SetNextWindowSize( -- 289
		Vec2(720, 480), -- 289
		"FirstUseEver" -- 289
	) -- 289
	ImGui.Begin( -- 290
		zh and "游戏预览" or "Game Preview", -- 290
		function() -- 290
			local avail = ImGui.GetContentRegionAvail() -- 291
			local width = gameWidthOf(state) -- 292
			local height = gameHeightOf(state) -- 293
			local scale = math.max( -- 294
				0.1, -- 294
				math.min(avail.x / width, avail.y / height) -- 294
			) -- 294
			local displayWidth = width * scale -- 295
			local displayHeight = height * scale -- 296
			ImGui.TextDisabled((((zh and "运行尺寸：" or "Game Size: ") .. tostring(width)) .. " x ") .. tostring(height)) -- 297
			ImGui.TextColored(okColor, zh and "游戏正在运行。当前 Dora App 缺少稳定的 ImGui 纹理显示接口，独立预览窗口暂不显示画面。" or "Game is running. The current Dora App lacks a stable ImGui texture display API, so this detached preview window does not show the frame yet.") -- 298
			ImGui.TextDisabled((((zh and "目标显示尺寸：" or "Target display size: ") .. tostring(math.floor(displayWidth))) .. " x ") .. tostring(math.floor(displayHeight))) -- 299
		end -- 290
	) -- 290
end -- 285
return ____exports -- 285