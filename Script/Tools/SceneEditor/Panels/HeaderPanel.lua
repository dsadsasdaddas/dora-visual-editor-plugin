-- [ts]: HeaderPanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local deleteNode = ____Model.deleteNode -- 4
local pushConsole = ____Model.pushConsole -- 4
local zh = ____Model.zh -- 4
local ____Player = require("Script.Tools.SceneEditor.Player") -- 5
local startPlay = ____Player.startPlay -- 5
local stopPlay = ____Player.stopPlay -- 5
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 6
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 6
function ____exports.drawHeaderPanel(state, saveScene) -- 8
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 9
	ImGui.SameLine() -- 10
	if ImGui.Button(zh and "场景" or "Scene") then -- 10
		state.mode = "2D" -- 11
	end -- 11
	ImGui.SameLine() -- 12
	if ImGui.Button(zh and "脚本" or "Scripts") then -- 12
		state.mode = "Script" -- 13
	end -- 13
	ImGui.SameLine() -- 14
	ImGui.TextDisabled(zh and "Dora 原生 2D 场景编辑器" or "Dora Native 2D Scene Editor") -- 15
	ImGui.Separator() -- 16
	if state.isPlaying then -- 16
		if ImGui.Button(zh and "■ 停止" or "■ Stop") then -- 16
			stopPlay(state) -- 18
		end -- 18
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then -- 18
		startPlay(state) -- 20
	end -- 20
	ImGui.SameLine() -- 22
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 22
		saveScene(state) -- 23
	end -- 23
	ImGui.SameLine() -- 24
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 24
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 26
		pushConsole(state, state.status) -- 27
	end -- 27
	ImGui.SameLine() -- 29
	ImGui.TextDisabled("|") -- 30
	ImGui.SameLine() -- 31
	if state.isPlaying then -- 31
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 33
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 33
		ImGui.OpenPopup("AddNodePopup") -- 35
	end -- 35
	drawAddNodePopup(state) -- 37
	ImGui.SameLine() -- 38
	if state.isPlaying then -- 38
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 40
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 40
		deleteNode(state, state.selectedId) -- 42
	end -- 42
	ImGui.Separator() -- 44
end -- 8
return ____exports -- 8