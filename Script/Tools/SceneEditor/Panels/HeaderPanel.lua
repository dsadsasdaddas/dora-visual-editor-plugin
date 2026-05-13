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
local ____ExternalPreview = require("Script.Tools.SceneEditor.ExternalPreview") -- 5
local launchExternalPreview = ____ExternalPreview.launchExternalPreview -- 5
local stopExternalPreview = ____ExternalPreview.stopExternalPreview -- 5
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 6
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 6
function ____exports.drawHeaderPanel(state, saveScene) -- 8
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 9
	if state.externalPreviewRunning then -- 9
		ImGui.SameLine() -- 11
		ImGui.TextColored(okColor, zh and "● 外部预览" or "● EXTERNAL PREVIEW") -- 12
		ImGui.SameLine() -- 13
		ImGui.TextDisabled(zh and "编辑器仍可继续编辑" or "Editor remains editable") -- 14
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
	if state.externalPreviewRunning then -- 22
		if ImGui.Button(zh and "■ 停止标记" or "■ Stop Mark") then -- 22
			stopExternalPreview(state) -- 24
		end -- 24
		ImGui.SameLine() -- 25
		if ImGui.Button(zh and "↻ 重新运行" or "↻ Relaunch") then -- 25
			saveScene(state) -- 27
			launchExternalPreview(state) -- 28
		end -- 28
	elseif ImGui.Button(zh and "▶ 运行" or "▶ Run") then -- 28
		saveScene(state) -- 31
		launchExternalPreview(state) -- 32
	end -- 32
	ImGui.SameLine() -- 34
	if ImGui.Button(zh and "▣ 保存" or "▣ Save") then -- 34
		saveScene(state) -- 35
	end -- 35
	ImGui.SameLine() -- 36
	ImGui.TextDisabled(zh and "游戏窗口" or "Game") -- 37
	ImGui.SameLine() -- 38
	ImGui.PushItemWidth( -- 39
		150, -- 39
		function() -- 39
			local sizeChanged, width, height = ImGui.DragInt2( -- 40
				"##game_resolution", -- 40
				state.gameWidth, -- 40
				state.gameHeight, -- 40
				1, -- 40
				160, -- 40
				8192, -- 40
				"%d" -- 40
			) -- 40
			if sizeChanged then -- 40
				state.gameWidth = math.max( -- 42
					160, -- 42
					math.min(8192, width) -- 42
				) -- 42
				state.gameHeight = math.max( -- 43
					120, -- 43
					math.min(8192, height) -- 43
				) -- 43
				state.previewDirty = true -- 44
				state.playDirty = true -- 45
			end -- 45
		end -- 39
	) -- 39
	ImGui.SameLine() -- 48
	if ImGui.Button("16:9") then -- 48
		state.gameWidth = 960 -- 50
		state.gameHeight = 540 -- 51
		state.previewDirty = true -- 52
		state.playDirty = true -- 53
	end -- 53
	ImGui.SameLine() -- 55
	if ImGui.Button("HD") then -- 55
		state.gameWidth = 1280 -- 57
		state.gameHeight = 720 -- 58
		state.previewDirty = true -- 59
		state.playDirty = true -- 60
	end -- 60
	ImGui.SameLine() -- 62
	if ImGui.Button(zh and "◇ 构建" or "◇ Build") then -- 62
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 64
		pushConsole(state, state.status) -- 65
	end -- 65
	ImGui.SameLine() -- 67
	ImGui.TextDisabled("|") -- 68
	ImGui.SameLine() -- 69
	if state.isPlaying then -- 69
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "＋ 添加" or "＋ Add") end) -- 71
	elseif ImGui.Button(zh and "＋ 添加" or "＋ Add") then -- 71
		ImGui.OpenPopup("AddNodePopup") -- 73
	end -- 73
	drawAddNodePopup(state) -- 75
	ImGui.SameLine() -- 76
	if state.isPlaying then -- 76
		ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除" or "Delete") end) -- 78
	elseif ImGui.Button(zh and "删除" or "Delete") then -- 78
		deleteNode(state, state.selectedId) -- 80
	end -- 80
	ImGui.Separator() -- 82
end -- 8
return ____exports -- 8