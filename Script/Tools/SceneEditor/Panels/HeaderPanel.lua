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
		ImGui.TextDisabled(zh and "Game Preview 窗口正在运行" or "Game Preview is running") -- 14
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
		saveScene(state) -- 26
		startPlay(state) -- 27
	end -- 27
	ImGui.SameLine() -- 29
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 29
		saveScene(state) -- 30
	end -- 30
	ImGui.SameLine() -- 31
	ImGui.TextDisabled(zh and "游戏窗口" or "Game") -- 32
	ImGui.SameLine() -- 33
	ImGui.PushItemWidth( -- 34
		150, -- 34
		function() -- 34
			local sizeChanged, width, height = ImGui.DragInt2( -- 35
				"##game_resolution", -- 35
				state.gameWidth, -- 35
				state.gameHeight, -- 35
				1, -- 35
				160, -- 35
				8192, -- 35
				"%d" -- 35
			) -- 35
			if sizeChanged then -- 35
				state.gameWidth = math.max( -- 37
					160, -- 37
					math.min(8192, width) -- 37
				) -- 37
				state.gameHeight = math.max( -- 38
					120, -- 38
					math.min(8192, height) -- 38
				) -- 38
				state.previewDirty = true -- 39
				state.playDirty = true -- 40
			end -- 40
		end -- 34
	) -- 34
	ImGui.SameLine() -- 43
	if ImGui.Button("16:9") then -- 43
		state.gameWidth = 960 -- 45
		state.gameHeight = 540 -- 46
		state.previewDirty = true -- 47
		state.playDirty = true -- 48
	end -- 48
	ImGui.SameLine() -- 50
	if ImGui.Button("HD") then -- 50
		state.gameWidth = 1280 -- 52
		state.gameHeight = 720 -- 53
		state.previewDirty = true -- 54
		state.playDirty = true -- 55
	end -- 55
	ImGui.SameLine() -- 57
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 57
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 59
		pushConsole(state, state.status) -- 60
	end -- 60
	ImGui.SameLine() -- 62
	ImGui.TextDisabled("|") -- 63
	ImGui.SameLine() -- 64
	if state.isPlaying then -- 64
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 66
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 66
		ImGui.OpenPopup("AddNodePopup") -- 68
	end -- 68
	drawAddNodePopup(state) -- 70
	ImGui.SameLine() -- 71
	if state.isPlaying then -- 71
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 73
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 73
		deleteNode(state, state.selectedId) -- 75
	end -- 75
	ImGui.Separator() -- 77
end -- 8
return ____exports -- 8