-- [ts]: SceneTreePanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local iconFor = ____Model.iconFor -- 4
local zh = ____Model.zh -- 4
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 5
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 5
local function drawNodeRow(state, id, depth) -- 7
	local node = state.nodes[id] -- 8
	if node == nil then -- 8
		return -- 9
	end -- 9
	local indent = string.rep("  ", depth) -- 10
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 11
	if ImGui.Selectable(label, state.selectedId == id) then -- 11
		state.selectedId = id -- 13
		state.previewDirty = true -- 14
	end -- 14
	for ____, childId in ipairs(node.children) do -- 16
		drawNodeRow(state, childId, depth + 1) -- 17
	end -- 17
end -- 7
function ____exports.drawSceneTreePanel(state) -- 21
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 22
	ImGui.SameLine() -- 23
	if state.isPlaying then -- 23
		ImGui.BeginDisabled(function() return ImGui.SmallButton("＋##scene_add") end) -- 25
	elseif ImGui.SmallButton("＋##scene_add") then -- 25
		ImGui.OpenPopup("AddNodePopup") -- 27
	end -- 27
	drawAddNodePopup(state) -- 29
	ImGui.Separator() -- 30
	drawNodeRow(state, "root", 0) -- 31
	ImGui.Separator() -- 32
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 33
end -- 21
return ____exports -- 21