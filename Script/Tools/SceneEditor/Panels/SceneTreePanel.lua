-- [ts]: SceneTreePanel.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local helperColor = ____Theme.helperColor -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local iconFor = ____Model.iconFor -- 4
local nodePath = ____Model.nodePath -- 4
local reparentNode = ____Model.reparentNode -- 4
local zh = ____Model.zh -- 4
local ____AddNodePopup = require("Script.Tools.SceneEditor.Panels.AddNodePopup") -- 5
local drawAddNodePopup = ____AddNodePopup.drawAddNodePopup -- 5
local function kindLabel(kind) -- 7
	if kind == "Root" then -- 7
		return zh and "根" or "Root" -- 8
	end -- 8
	if kind == "Node" then -- 8
		return zh and "分组" or "Node" -- 9
	end -- 9
	if kind == "Sprite" then -- 9
		return zh and "精灵" or "Sprite" -- 10
	end -- 10
	if kind == "Label" then -- 10
		return zh and "文本" or "Label" -- 11
	end -- 11
	if kind == "Camera" then -- 11
		return zh and "相机" or "Camera" -- 12
	end -- 12
	return kind -- 13
end -- 7
local function childCountSuffix(count) -- 16
	if count <= 0 then -- 16
		return "" -- 17
	end -- 17
	return ("  (" .. tostring(count)) .. ")" -- 18
end -- 16
local function drawNodeRow(state, id, prefix, isLast) -- 21
	local node = state.nodes[id] -- 22
	if node == nil then -- 22
		return -- 23
	end -- 23
	local isDropTarget = state.treeDropTargetId == id and state.treeDraggingNodeId ~= nil -- 24
	local connector = id == "root" and "" or (isLast and "└─ " or "├─ ") -- 25
	local dropMarker = isDropTarget and "→ " or "  " -- 26
	local label = (((((((((dropMarker .. prefix) .. connector) .. iconFor(node.kind)) .. "  ") .. node.name) .. "  · ") .. kindLabel(node.kind)) .. childCountSuffix(#node.children)) .. "##tree_") .. id -- 27
	if ImGui.Selectable(label, state.selectedId == id) then -- 27
		state.selectedId = id -- 29
		state.previewDirty = true -- 30
	end -- 30
	if not state.isPlaying then -- 30
		if id ~= "root" and ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 30
			state.treeDraggingNodeId = id -- 34
		end -- 34
		local draggingId = state.treeDraggingNodeId -- 36
		if draggingId ~= nil and draggingId ~= id and ImGui.IsItemHovered() then -- 36
			state.treeDropTargetId = id -- 38
			local targetName = node.name -- 39
			ImGui.BeginTooltip(function() return ImGui.Text((zh and "松开移动到：" or "Release to move under: ") .. targetName) end) -- 40
		end -- 40
	end -- 40
	local childPrefix = id == "root" and "" or prefix .. (isLast and "   " or "│  ") -- 43
	do -- 43
		local i = 0 -- 44
		while i < #node.children do -- 44
			local childId = node.children[i + 1] -- 45
			drawNodeRow(state, childId, childPrefix, i == #node.children - 1) -- 46
			i = i + 1 -- 44
		end -- 44
	end -- 44
end -- 21
function ____exports.drawSceneTreePanel(state) -- 50
	ImGui.TextColored(themeColor, zh and "场景层级" or "Scene Hierarchy") -- 51
	ImGui.SameLine() -- 52
	if state.isPlaying then -- 52
		ImGui.BeginDisabled(function() return ImGui.SmallButton("＋##scene_add") end) -- 54
	elseif ImGui.SmallButton("＋##scene_add") then -- 54
		ImGui.OpenPopup("AddNodePopup") -- 56
	end -- 56
	drawAddNodePopup(state) -- 58
	ImGui.Separator() -- 59
	local selected = state.nodes[state.selectedId] -- 60
	if selected ~= nil then -- 60
		ImGui.TextColored(helperColor, zh and "当前父子路径" or "Current path") -- 62
		ImGui.TextDisabled(nodePath(state, selected.id)) -- 63
		ImGui.Separator() -- 64
	end -- 64
	state.treeDropTargetId = nil -- 66
	drawNodeRow(state, "root", "", true) -- 67
	if state.treeDraggingNodeId ~= nil and ImGui.IsMouseReleased(0) then -- 67
		local dragId = state.treeDraggingNodeId -- 69
		local dropId = state.treeDropTargetId -- 70
		if dropId ~= nil then -- 70
			reparentNode(state, dragId, dropId) -- 72
		end -- 72
		state.treeDraggingNodeId = nil -- 74
		state.treeDropTargetId = nil -- 75
	end -- 75
	ImGui.Separator() -- 77
	ImGui.TextDisabled(zh and "拖动节点到另一个节点上可调整父子关系" or "Drag a node onto another node to reparent it") -- 78
end -- 50
return ____exports -- 50