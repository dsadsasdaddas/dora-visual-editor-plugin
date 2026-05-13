local ____exports = {}
local ImGui = require("ImGui")
local ____Theme = require("Script.Tools.SceneEditor.Theme")
local okColor = ____Theme.okColor
local themeColor = ____Theme.themeColor
local ____Model = require("Script.Tools.SceneEditor.Model")
local deleteNode = ____Model.deleteNode
local pushConsole = ____Model.pushConsole
local zh = ____Model.zh
local ____Player = require("Script.Tools.SceneEditor.Player")
local startPlay = ____Player.startPlay
local stopPlay = ____Player.stopPlay
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup")
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup

function ____exports.drawHeaderPanel(state, saveScene)
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor")
	if state.isPlaying then
		ImGui.SameLine()
		ImGui.TextColored(okColor, zh and "● 运行模式" or "● PLAY MODE")
		ImGui.SameLine()
		ImGui.TextDisabled(zh and "Game Preview 窗口正在运行" or "Game Preview is running")
	end
	ImGui.SameLine()
	if ImGui.Button(zh and "场景" or "Scene") then state.mode = "2D" end
	ImGui.SameLine()
	if ImGui.Button(zh and "脚本" or "Scripts") then state.mode = "Script" end
	ImGui.SameLine()
	ImGui.TextDisabled(zh and "Dora 原生 2D 场景编辑器" or "Dora Native 2D Scene Editor")
	ImGui.Separator()
	if state.isPlaying then
		if ImGui.Button(zh and "■ 停止" or "■ Stop") then stopPlay(state) end
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then
		saveScene(state)
		startPlay(state)
	end
	ImGui.SameLine()
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then saveScene(state) end
	ImGui.SameLine()
	ImGui.TextDisabled(zh and "游戏窗口" or "Game")
	ImGui.SameLine()
	ImGui.PushItemWidth(150, function()
		local sizeChanged, width, height = ImGui.DragInt2("##game_resolution", state.gameWidth, state.gameHeight, 1, 160, 8192, "%d")
		if sizeChanged then
			state.gameWidth = math.max(160, math.min(8192, width))
			state.gameHeight = math.max(120, math.min(8192, height))
			state.previewDirty = true
			state.playDirty = true
		end
	end)
	ImGui.SameLine()
	if ImGui.Button("16:9") then
		state.gameWidth = 960
		state.gameHeight = 540
		state.previewDirty = true
		state.playDirty = true
	end
	ImGui.SameLine()
	if ImGui.Button("HD") then
		state.gameWidth = 1280
		state.gameHeight = 720
		state.previewDirty = true
		state.playDirty = true
	end
	ImGui.SameLine()
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable"
		pushConsole(state, state.status)
	end
	ImGui.SameLine()
	ImGui.TextDisabled("|")
	ImGui.SameLine()
	if state.isPlaying then
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end)
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then
		ImGui.OpenPopup("AddNodePopup")
	end
	drawAddNodePopup(state)
	ImGui.SameLine()
	if state.isPlaying then
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end)
	elseif ImGui.Button(zh and "删除" or "Delete") then
		deleteNode(state, state.selectedId)
	end
	ImGui.Separator()
end

return ____exports
