-- [ts]: SceneTreePanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local helperColor = ____Theme.helperColor -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local nodePath = ____Model.nodePath -- 4
local reparentNode = ____Model.reparentNode -- 4
local zh = ____Model.zh -- 4
local ____SceneGraph = require("Script.Tools.SceneEditor.SceneGraph") -- 5
local buildSceneTreeRows = ____SceneGraph.buildSceneTreeRows -- 5
local canReparentSceneNode = ____SceneGraph.canReparentSceneNode -- 5
local toggleTreeNodeExpanded = ____SceneGraph.toggleTreeNodeExpanded -- 5
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 6
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 6
local function childCountSuffix(count) -- 8
	if count <= 0 then -- 8
		return "" -- 9
	end -- 9
	return ("  (" .. (tostring(count) or "0")) .. ")" -- 10
end -- 8
local function foldGlyph(hasChildren, expanded) -- 13
	if not hasChildren then -- 13
		return "  " -- 14
	end -- 14
	return expanded and "▼ " or "▶ " -- 15
end -- 13
local function drawTreeRow(state, id, label, canAcceptDrop) -- 18
	if ImGui.Selectable(label, state.selectedId == id) then -- 18
		state.selectedId = id -- 20
		state.previewDirty = true -- 21
	end -- 21
	if not state.isPlaying then -- 21
		if id ~= "root" and ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 21
			state.treeDraggingNodeId = id -- 25
		end -- 25
		local draggingId = state.treeDraggingNodeId -- 27
		if draggingId ~= nil and canAcceptDrop and ImGui.IsItemHovered() then -- 27
			state.treeDropTargetId = id -- 29
			local target = state.nodes[id] -- 30
			ImGui.BeginTooltip(function() return ImGui.Text((zh and "松开移动到：" or "Release to move under: ") .. (target ~= nil and target.name or id)) end) -- 31
		end -- 31
	end -- 31
end -- 18
function ____exports.drawSceneTreePanel(state) -- 36
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 37
	ImGui.SameLine() -- 38
	if state.isPlaying then -- 38
		ImGui.BeginDisabled(function() return ImGui.SmallButton("＋##scene_add") end) -- 40
	elseif ImGui.SmallButton("＋##scene_add") then -- 40
		ImGui.OpenPopup("AddNodePopup") -- 42
	end -- 42
	drawAddNodePopup(state) -- 44
	ImGui.Separator() -- 45
	local selected = state.nodes[state.selectedId] -- 46
	if selected ~= nil then -- 46
		ImGui.TextColored(helperColor, zh and "当前父子路径" or "Current path") -- 48
		ImGui.TextDisabled(nodePath(state, selected.id)) -- 49
		ImGui.Separator() -- 50
	end -- 50
	state.treeDropTargetId = nil -- 53
	local rows = buildSceneTreeRows(state, zh) -- 54
	for ____, row in ipairs(rows) do -- 55
		local draggingId = state.treeDraggingNodeId -- 56
		local canAcceptDrop = draggingId ~= nil and canReparentSceneNode(state, draggingId, row.id) -- 57
		local isDropTarget = state.treeDropTargetId == row.id and draggingId ~= nil -- 58
		local dropMarker = isDropTarget and "→ " or "  " -- 59
		local label = ((((((((((dropMarker .. row.connectorPrefix) .. row.connector) .. foldGlyph(row.hasChildren, row.expanded)) .. row.icon) .. "  ") .. row.name) .. "  · ") .. row.kindLabel) .. childCountSuffix(row.childCount)) .. "##tree_") .. row.id -- 60
		drawTreeRow(state, row.id, label, canAcceptDrop) -- 72
		if row.hasChildren and ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(0) then -- 72
			toggleTreeNodeExpanded(state, row.id) -- 74
		end -- 74
	end -- 74
	if state.treeDraggingNodeId ~= nil and ImGui.IsMouseReleased(0) then -- 74
		local dragId = state.treeDraggingNodeId -- 79
		local dropId = state.treeDropTargetId -- 80
		if dropId ~= nil then -- 80
			reparentNode(state, dragId, dropId) -- 82
		end -- 82
		state.treeDraggingNodeId = nil -- 84
		state.treeDropTargetId = nil -- 85
	end -- 85
	ImGui.Separator() -- 87
	ImGui.TextDisabled(zh and "拖动节点到可作为父级的节点上；双击父节点可折叠。" or "Drag onto a valid parent; double-click parent rows to fold.") -- 88
end -- 36
return ____exports -- 36