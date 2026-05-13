-- [ts]: SceneTreePanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local iconFor = ____Model.iconFor -- 4
local reparentNode = ____Model.reparentNode -- 4
local zh = ____Model.zh -- 4
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 5
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 5
local function drawNodeRow(state, id, depth) -- 7
	local node = state.nodes[id] -- 8
	if node == nil then -- 8
		return -- 9
	end -- 9
	local indent = string.rep("  ", depth) -- 10
	local isDropTarget = state.treeDropTargetId == id and state.treeDraggingNodeId ~= nil -- 11
	local label = ((((((isDropTarget and "→ " or "") .. indent) .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 12
	if ImGui.Selectable(label, state.selectedId == id) then -- 12
		state.selectedId = id -- 14
		state.previewDirty = true -- 15
	end -- 15
	if not state.isPlaying then -- 15
		if id ~= "root" and ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 15
			state.treeDraggingNodeId = id -- 19
		end -- 19
		local draggingId = state.treeDraggingNodeId -- 21
		if draggingId ~= nil and draggingId ~= id and ImGui.IsItemHovered() then -- 21
			state.treeDropTargetId = id -- 23
			local targetName = node.name -- 24
			ImGui.BeginTooltip(function() return ImGui.Text((zh and "松开移动到：" or "Release to move under: ") .. targetName) end) -- 25
		end -- 25
	end -- 25
	for ____, childId in ipairs(node.children) do -- 28
		drawNodeRow(state, childId, depth + 1) -- 29
	end -- 29
end -- 7
function ____exports.drawSceneTreePanel(state) -- 33
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 34
	ImGui.SameLine() -- 35
	if state.isPlaying then -- 35
		ImGui.BeginDisabled(function() return ImGui.SmallButton("＋##scene_add") end) -- 37
	elseif ImGui.SmallButton("＋##scene_add") then -- 37
		ImGui.OpenPopup("AddNodePopup") -- 39
	end -- 39
	drawAddNodePopup(state) -- 41
	ImGui.Separator() -- 42
	state.treeDropTargetId = nil -- 43
	drawNodeRow(state, "root", 0) -- 44
	if state.treeDraggingNodeId ~= nil and ImGui.IsMouseReleased(0) then -- 44
		local dragId = state.treeDraggingNodeId -- 46
		local dropId = state.treeDropTargetId -- 47
		if dropId ~= nil then -- 47
			reparentNode(state, dragId, dropId) -- 49
		end -- 49
		state.treeDraggingNodeId = nil -- 51
		state.treeDropTargetId = nil -- 52
	end -- 52
	ImGui.Separator() -- 54
	ImGui.TextDisabled(zh and "拖动节点到另一个节点上可调整父子关系" or "Drag a node onto another node to reparent it") -- 55
end -- 33
return ____exports -- 33