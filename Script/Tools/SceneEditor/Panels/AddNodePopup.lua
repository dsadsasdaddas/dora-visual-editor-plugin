-- [ts]: AddNodePopup.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local addChildNode = ____Model.addChildNode -- 4
local zh = ____Model.zh -- 4
function ____exports.drawAddNodePopup(state) -- 6
	ImGui.BeginPopup( -- 7
		"AddNodePopup", -- 7
		function() -- 7
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 8
			ImGui.Separator() -- 9
			if ImGui.Selectable("○  Node", false) then -- 9
				addChildNode(state, "Node") -- 10
				ImGui.CloseCurrentPopup() -- 10
			end -- 10
			if ImGui.Selectable("▣  Sprite", false) then -- 10
				addChildNode(state, "Sprite") -- 11
				ImGui.CloseCurrentPopup() -- 11
			end -- 11
			if ImGui.Selectable("T  Label", false) then -- 11
				addChildNode(state, "Label") -- 12
				ImGui.CloseCurrentPopup() -- 12
			end -- 12
			if ImGui.Selectable("◉  Camera", false) then -- 12
				addChildNode(state, "Camera") -- 13
				ImGui.CloseCurrentPopup() -- 13
			end -- 13
		end -- 7
	) -- 7
end -- 6
return ____exports -- 6