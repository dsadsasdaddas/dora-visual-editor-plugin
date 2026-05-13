local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local Color = ____Dora.Color
local Content = ____Dora.Content
local Director = ____Dora.Director
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Path = ____Dora.Path
local RenderTarget = ____Dora.RenderTarget
local Sprite = ____Dora.Sprite
local Vec2 = ____Dora.Vec2
local ImGui = require("ImGui")
local ____Theme = require("Script.Tools.SceneEditor.Theme")
local okColor = ____Theme.okColor
local viewportBgColor = ____Theme.viewportBgColor
local ____Model = require("Script.Tools.SceneEditor.Model")
local pushConsole = ____Model.pushConsole
local workspacePath = ____Model.workspacePath
local zh = ____Model.zh

local playTarget = nil
local playTargetWidth = 0
local playTargetHeight = 0

local function makeGameBackground(width, height)
	local hw = width / 2
	local hh = height / 2
	local bg = DrawNode()
	bg:drawPolygon({Vec2(-hw, -hh), Vec2(hw, -hh), Vec2(hw, hh), Vec2(-hw, hh)}, viewportBgColor, 1.4, okColor)
	return bg
end

local function makeFallbackRect(width, height, color)
	local hw = width / 2
	local hh = height / 2
	local rect = DrawNode()
	rect:drawSegment(Vec2(-hw, -hh), Vec2(hw, -hh), 1, color)
	rect:drawSegment(Vec2(hw, -hh), Vec2(hw, hh), 1, color)
	rect:drawSegment(Vec2(hw, hh), Vec2(-hw, hh), 1, color)
	rect:drawSegment(Vec2(-hw, hh), Vec2(-hw, -hh), 1, color)
	return rect
end

local function createPlayVisual(item)
	if item.kind == "Sprite" then
		if item.texture ~= "" then
			local sprite = Sprite(item.texture)
			if sprite ~= nil then return sprite end
		end
		return makeFallbackRect(128, 96, Color(0xaa72a6c8))
	end
	if item.kind == "Label" then
		local label = Label("sarasa-mono-sc-regular", 32)
		if label ~= nil then
			label.text = item.text or "Label"
			return label
		end
		return makeFallbackRect(180, 56, Color(0xaad6b13f))
	end
	return Node()
end

local function applyTransform(target, item)
	target.x = item.x
	target.y = item.y
	target.scaleX = item.scaleX
	target.scaleY = item.scaleY
	target.angle = item.rotation
	target.visible = item.visible
	target.tag = item.name
end

local function firstCameraId(state)
	for _, id in ipairs(state.order) do
		local item = state.nodes[id]
		if item ~= nil and item.kind == "Camera" and item.visible then return id end
	end
	return nil
end

local function loadScriptText(scriptPath)
	if scriptPath == "" then return "" end
	local projectPath = workspacePath(scriptPath)
	if Content:exist(projectPath) then return Content:load(projectPath) or "" end
	if Content:exist(scriptPath) then return Content:load(scriptPath) or "" end
	return ""
end

local function runNodeScript(state, item, runtimeNode)
	local scriptText = loadScriptText(item.script)
	if scriptText == "" then return end
	local chunk, loadError = load(scriptText, item.script)
	if chunk == nil then
		pushConsole(state, (zh and "脚本加载失败：" or "Script load failed: ") .. item.script .. " " .. tostring(loadError or ""))
		return
	end
	local ok, result = pcall(chunk)
	if not ok then
		pushConsole(state, (zh and "脚本执行失败：" or "Script failed: ") .. item.script .. " " .. tostring(result))
		return
	end
	if type(result) == "function" then
		local behaviorOk, behaviorError = pcall(function()
			result(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes)
		end)
		if not behaviorOk then pushConsole(state, (zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script .. " " .. tostring(behaviorError)) end
	end
end

local function defaultGameMainLua()
	return [=[-- Game main script
-- Auto-created by Dora Visual Editor.
local _ENV = Dora

return {
	start = function(scene, nodes, world)
		local player = nil
		for _, node in pairs(nodes) do
			local tag = tostring(node.tag or "")
			if node ~= scene and player == nil and string.find(tag, "Camera") == nil then player = node end
		end
		if player == nil then return end
		scene:schedule(function(deltaTime)
			local speed = 220
			if Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") then player.x = player.x - speed * deltaTime end
			if Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") then player.x = player.x + speed * deltaTime end
			return false
		end)
	end
}
]=]
end

local function ensureGameMainScript(state)
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua"
	state.gameScript = scriptPath
	state.gameScriptBuffer.text = scriptPath
	local file = workspacePath(scriptPath)
	if not Content:exist(file) then
		Content:mkdir(Path:getPath(file))
		Content:save(file, defaultGameMainLua())
	end
end

local function runGameMain(state)
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua"
	local scriptText = loadScriptText(scriptPath)
	if scriptText == "" then return end
	local chunk, loadError = load(scriptText, scriptPath)
	if chunk == nil then
		pushConsole(state, (zh and "主脚本加载失败：" or "Main script load failed: ") .. scriptPath .. " " .. tostring(loadError or ""))
		return
	end
	local ok, result = pcall(chunk)
	if not ok then
		pushConsole(state, (zh and "主脚本执行失败：" or "Main script failed: ") .. scriptPath .. " " .. tostring(result))
		return
	end
	local start = nil
	if type(result) == "function" then
		start = result
	elseif type(result) == "table" and type(result.start) == "function" then
		start = result.start
	end
	if start ~= nil and state.playContent ~= nil and state.playWorld ~= nil then
		local startOk, startError = pcall(function()
			start(state.playContent, state.playRuntimeNodes, state.playWorld)
		end)
		if not startOk then pushConsole(state, (zh and "主脚本启动失败：" or "Main script start failed: ") .. tostring(startError)) end
	end
end

local function clearPlayRuntime(state)
	if state.playRoot ~= nil then
		state.playRoot:removeFromParent(true)
		state.playRoot = nil
	end
	state.playWorld = nil
	state.playContent = nil
	state.playRuntimeNodes = {}
	state.playRuntimeLabels = {}
	state.isPlaying = false
	state.playDirty = true
end

function ____exports.stopPlay(state)
	clearPlayRuntime(state)
	state.status = zh and "游戏预览已停止" or "Game preview stopped"
	pushConsole(state, state.status)
end

function ____exports.startPlay(state)
	clearPlayRuntime(state)
	ensureGameMainScript(state)
	state.isPlaying = true
	state.gameWindowOpen = true
	state.playDirty = true
	state.status = zh and "游戏预览运行中" or "Game preview running"
	pushConsole(state, state.status)
end

local function gameWidthOf(state)
	return math.max(160, math.floor(state.gameWidth))
end

local function gameHeightOf(state)
	return math.max(120, math.floor(state.gameHeight))
end

local function rebuildPlayRuntime(state)
	local width = gameWidthOf(state)
	local height = gameHeightOf(state)
	state.playRoot = Node()
	state.playRoot.tag = "__DoraImGuiGamePreview__"
	state.playRoot.visible = false
	state.playRuntimeNodes = {}
	state.playRuntimeLabels = {}
	Director.entry:addChild(state.playRoot)
	local background = makeGameBackground(width, height)
	background.x = width / 2
	background.y = height / 2
	state.playRoot:addChild(background)
	local world = Node()
	state.playWorld = world
	world.x = width / 2
	world.y = height / 2
	state.playRoot:addChild(world)
	local content = Node()
	state.playContent = content
	world:addChild(content)
	state.playRuntimeNodes.root = content
	for _, id in ipairs(state.order) do
		local item = state.nodes[id]
		if item ~= nil and id ~= "root" then
			local runtime = createPlayVisual(item)
			applyTransform(runtime, item)
			state.playRuntimeNodes[id] = runtime
			if item.kind == "Label" then state.playRuntimeLabels[id] = runtime end
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content
			parent:addChild(runtime)
		end
	end
	local cameraId = firstCameraId(state)
	local cameraNode = cameraId ~= nil and state.playRuntimeNodes[cameraId] or nil
	local function updateCamera()
		if cameraNode ~= nil then
			world.x = width / 2
			world.y = height / 2
			world.angle = -cameraNode.angle
			world.scaleX = cameraNode.scaleX ~= 0 and 1 / cameraNode.scaleX or 1
			world.scaleY = cameraNode.scaleY ~= 0 and 1 / cameraNode.scaleY or 1
			content.x = -cameraNode.x
			content.y = -cameraNode.y
		else
			world.x = width / 2
			world.y = height / 2
			world.angle = 0
			world.scaleX = 1
			world.scaleY = 1
			content.x = 0
			content.y = 0
		end
	end
	updateCamera()
	world:schedule(function()
		updateCamera()
		return false
	end)
	for _, id in ipairs(state.order) do
		local item = state.nodes[id]
		local runtime = state.playRuntimeNodes[id]
		if item ~= nil and runtime ~= nil then runNodeScript(state, item, runtime) end
	end
	runGameMain(state)
	state.playDirty = false
end

local function ensurePlayTarget(state)
	local width = gameWidthOf(state)
	local height = gameHeightOf(state)
	if playTarget == nil or playTargetWidth ~= width or playTargetHeight ~= height then
		playTarget = RenderTarget(width, height)
		playTargetWidth = width
		playTargetHeight = height
	end
	return playTarget
end

local function renderPlayTarget(state)
	if not state.isPlaying then return end
	if state.playDirty or state.playRoot == nil then rebuildPlayRuntime(state) end
	local target = ensurePlayTarget(state)
	if state.playRoot ~= nil then
		state.playRoot.visible = true
		target:renderWithClear(state.playRoot, Color(0xff15181f))
		state.playRoot.visible = false
	end
end

function ____exports.drawGamePreviewWindow(state)
	if not state.isPlaying then return end
	renderPlayTarget(state)
	if playTarget == nil then return end
	ImGui.SetNextWindowSize(Vec2(720, 480), "FirstUseEver")
	ImGui.Begin(zh and "游戏预览" or "Game Preview", function()
		local avail = ImGui.GetContentRegionAvail()
		local width = gameWidthOf(state)
		local height = gameHeightOf(state)
		local scale = math.max(0.1, math.min(avail.x / width, avail.y / height))
		local displayWidth = width * scale
		local displayHeight = height * scale
		ImGui.TextDisabled((zh and "运行尺寸：" or "Game Size: ") .. tostring(width) .. " x " .. tostring(height))
		ImGui.ImageTexture(playTarget.texture, Vec2(displayWidth, displayHeight))
	end)
end

return ____exports
