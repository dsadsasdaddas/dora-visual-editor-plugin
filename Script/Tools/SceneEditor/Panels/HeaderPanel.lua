-- [ts]: HeaderPanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local okColor = ____Theme.okColor -- 3
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
	if state.isPlaying then -- 9
		ImGui.SameLine() -- 11
		ImGui.TextColored(okColor, zh and "● 运行模式" or "● PLAY MODE") -- 12
		ImGui.SameLine() -- 13
		ImGui.TextDisabled(zh and "点 Stop 返回编辑" or "Stop to edit") -- 14
	end -- 14
	ImGui.SameLine() -- 16
	if ImGui.Button(zh and "场景" or "Scene") then -- 16
		state.mode = "2D" -- 17
	end -- 17
	ImGui.SameLine() -- 18
	if ImGui.Button(zh and "脚本" or "Scripts") then -- 18
		state.mode = "Script" -- 19
	end -- 19
	ImGui.SameLine() -- 20
	ImGui.TextDisabled(zh and "Dora 原生 2D 场景编辑器" or "Dora Native 2D Scene Editor") -- 21
	ImGui.Separator() -- 22
	if state.isPlaying then -- 22
		if ImGui.Button(zh and "■ 停止" or "■ Stop") then -- 22
			stopPlay(state) -- 24
		end -- 24
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then -- 24
		startPlay(state) -- 26
	end -- 26
	ImGui.SameLine() -- 28
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 28
		saveScene(state) -- 29
	end -- 29
	ImGui.SameLine() -- 30
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 30
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 32
		pushConsole(state, state.status) -- 33
	end -- 33
	ImGui.SameLine() -- 35
	ImGui.TextDisabled("|") -- 36
	ImGui.SameLine() -- 37
	if state.isPlaying then -- 37
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 39
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 39
		ImGui.OpenPopup("AddNodePopup") -- 41
	end -- 41
	drawAddNodePopup(state) -- 43
	ImGui.SameLine() -- 44
	if state.isPlaying then -- 44
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 46
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 46
		deleteNode(state, state.selectedId) -- 48
	end -- 48
	ImGui.Separator() -- 50
end -- 8
return ____exports -- 8