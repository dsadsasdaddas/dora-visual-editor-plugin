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
	ImGui.TextDisabled(zh and "游戏窗口" or "Game") -- 31
	ImGui.SameLine() -- 32
	ImGui.PushItemWidth( -- 33
		150, -- 33
		function() -- 33
			if state.isPlaying then -- 33
				ImGui.BeginDisabled(function() return ImGui.DragInt2( -- 35
					"##game_resolution", -- 35
					state.gameWidth, -- 35
					state.gameHeight, -- 35
					1, -- 35
					160, -- 35
					8192, -- 35
					"%d" -- 35
				) end) -- 35
			else -- 35
				local sizeChanged, width, height = ImGui.DragInt2( -- 37
					"##game_resolution", -- 37
					state.gameWidth, -- 37
					state.gameHeight, -- 37
					1, -- 37
					160, -- 37
					8192, -- 37
					"%d" -- 37
				) -- 37
				if sizeChanged then -- 37
					state.gameWidth = math.max( -- 39
						160, -- 39
						math.min(8192, width) -- 39
					) -- 39
					state.gameHeight = math.max( -- 40
						120, -- 40
						math.min(8192, height) -- 40
					) -- 40
					state.previewDirty = true -- 41
					state.playDirty = true -- 42
				end -- 42
			end -- 42
		end -- 33
	) -- 33
	ImGui.SameLine() -- 46
	if state.isPlaying then -- 46
		ImGui.BeginDisabled(function() return ImGui.Button("16:9") end) -- 48
	elseif ImGui.Button("16:9") then -- 48
		state.gameWidth = 960 -- 50
		state.gameHeight = 540 -- 51
		state.previewDirty = true -- 52
		state.playDirty = true -- 53
	end -- 53
	ImGui.SameLine() -- 55
	if state.isPlaying then -- 55
		ImGui.BeginDisabled(function() return ImGui.Button("HD") end) -- 57
	elseif ImGui.Button("HD") then -- 57
		state.gameWidth = 1280 -- 59
		state.gameHeight = 720 -- 60
		state.previewDirty = true -- 61
		state.playDirty = true -- 62
	end -- 62
	ImGui.SameLine() -- 64
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 64
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 66
		pushConsole(state, state.status) -- 67
	end -- 67
	ImGui.SameLine() -- 69
	ImGui.TextDisabled("|") -- 70
	ImGui.SameLine() -- 71
	if state.isPlaying then -- 71
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 73
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 73
		ImGui.OpenPopup("AddNodePopup") -- 75
	end -- 75
	drawAddNodePopup(state) -- 77
	ImGui.SameLine() -- 78
	if state.isPlaying then -- 78
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 80
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 80
		deleteNode(state, state.selectedId) -- 82
	end -- 82
	ImGui.Separator() -- 84
end -- 8
return ____exports -- 8