-- [ts]: ConsolePanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local okColor = ____Theme.okColor -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local zh = ____Model.zh -- 4
function ____exports.drawConsolePanel(state) -- 6
	ImGui.TextColored(themeColor, zh and "控制台" or "Console") -- 7
	ImGui.SameLine() -- 8
	ImGui.TextColored(okColor, state.status) -- 9
	ImGui.Separator() -- 10
	for ____, line in ipairs(state.console) do -- 11
		ImGui.TextDisabled(line) -- 11
	end -- 11
end -- 6
return ____exports -- 6