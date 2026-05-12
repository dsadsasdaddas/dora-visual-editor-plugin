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
	local editorState = state -- 9
	if editorState.gameWidth == nil then -- 9
		editorState.gameWidth = 960 -- 10
	end -- 10
	if editorState.gameHeight == nil then -- 10
		editorState.gameHeight = 540 -- 11
	end -- 11
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 12
	if state.isPlaying then -- 12
		ImGui.SameLine() -- 14
		ImGui.TextColored(okColor, zh and "● 运行模式" or "● PLAY MODE") -- 15
		ImGui.SameLine() -- 16
		ImGui.TextDisabled(zh and "点 Stop 返回编辑" or "Stop to edit") -- 17
	end -- 17
	ImGui.SameLine() -- 19
	if ImGui.Button(zh and "场景" or "Scene") then -- 19
		state.mode = "2D" -- 20
	end -- 20
	ImGui.SameLine() -- 21
	if ImGui.Button(zh and "脚本" or "Scripts") then -- 21
		state.mode = "Script" -- 22
	end -- 22
	ImGui.SameLine() -- 23
	ImGui.TextDisabled(zh and "Dora 原生 2D 场景编辑器" or "Dora Native 2D Scene Editor") -- 24
	ImGui.Separator() -- 25
	if state.isPlaying then -- 25
		if ImGui.Button(zh and "■ 停止" or "■ Stop") then -- 25
			stopPlay(state) -- 27
		end -- 27
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then -- 27
		startPlay(state) -- 29
	end -- 29
	ImGui.SameLine() -- 31
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 31
		saveScene(state) -- 32
	end -- 32
	ImGui.SameLine() -- 33
	ImGui.TextDisabled(zh and "游戏窗口" or "Game") -- 34
	ImGui.SameLine() -- 35
	ImGui.PushItemWidth( -- 36
		150, -- 36
		function() -- 36
			if state.isPlaying then -- 36
				ImGui.BeginDisabled(function() return ImGui.DragInt2( -- 38
					"##game_resolution", -- 38
					editorState.gameWidth, -- 38
					editorState.gameHeight, -- 38
					1, -- 38
					160, -- 38
					8192, -- 38
					"%d" -- 38
				) end) -- 38
			else -- 38
				local sizeChanged, width, height = ImGui.DragInt2( -- 40
					"##game_resolution", -- 40
					editorState.gameWidth, -- 40
					editorState.gameHeight, -- 40
					1, -- 40
					160, -- 40
					8192, -- 40
					"%d" -- 40
				) -- 40
				if sizeChanged then -- 40
					editorState.gameWidth = math.max( -- 42
						160, -- 42
						math.min(8192, width) -- 42
					) -- 42
					editorState.gameHeight = math.max( -- 43
						120, -- 43
						math.min(8192, height) -- 43
					) -- 43
					state.previewDirty = true -- 44
					state.playDirty = true -- 45
				end -- 45
			end -- 45
		end -- 36
	) -- 36
	ImGui.SameLine() -- 49
	if state.isPlaying then -- 49
		ImGui.BeginDisabled(function() return ImGui.Button("16:9") end) -- 51
	elseif ImGui.Button("16:9") then -- 51
		editorState.gameWidth = 960 -- 53
		editorState.gameHeight = 540 -- 54
		state.previewDirty = true -- 55
		state.playDirty = true -- 56
	end -- 56
	ImGui.SameLine() -- 58
	if state.isPlaying then -- 58
		ImGui.BeginDisabled(function() return ImGui.Button("HD") end) -- 60
	elseif ImGui.Button("HD") then -- 60
		editorState.gameWidth = 1280 -- 62
		editorState.gameHeight = 720 -- 63
		state.previewDirty = true -- 64
		state.playDirty = true -- 65
	end -- 65
	ImGui.SameLine() -- 67
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 67
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 69
		pushConsole(state, state.status) -- 70
	end -- 70
	ImGui.SameLine() -- 72
	ImGui.TextDisabled("|") -- 73
	ImGui.SameLine() -- 74
	if state.isPlaying then -- 74
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 76
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 76
		ImGui.OpenPopup("AddNodePopup") -- 78
	end -- 78
	drawAddNodePopup(state) -- 80
	ImGui.SameLine() -- 81
	if state.isPlaying then -- 81
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 83
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 83
		deleteNode(state, state.selectedId) -- 85
	end -- 85
	ImGui.Separator() -- 87
end -- 8
return ____exports -- 8