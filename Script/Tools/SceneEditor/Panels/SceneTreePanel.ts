import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { helperColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { nodePath, reparentNode, zh } from 'Script/Tools/SceneEditor/Model';
import { buildSceneTreeRows, canReparentSceneNode, toggleTreeNodeExpanded } from 'Script/Tools/SceneEditor/SceneGraph';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

function childCountSuffix(count: number) {
	if (count <= 0) return '';
	return '  (' + (tostring(count) || '0') + ')';
}

function foldGlyph(hasChildren: boolean, expanded: boolean) {
	if (!hasChildren) return '  ';
	return expanded ? '▼ ' : '▶ ';
}

function drawTreeRow(state: EditorState, id: string, label: string, canAcceptDrop: boolean) {
	if (ImGui.Selectable(label, state.selectedId === id)) {
		state.selectedId = id;
		state.previewDirty = true;
	}
	if (!state.isPlaying) {
		if (id !== 'root' && ImGui.IsItemActive() && ImGui.IsMouseDragging(0)) {
			state.treeDraggingNodeId = id;
		}
		const draggingId = state.treeDraggingNodeId;
		if (draggingId !== undefined && canAcceptDrop && ImGui.IsItemHovered()) {
			state.treeDropTargetId = id;
			const target = state.nodes[id];
			ImGui.BeginTooltip(() => ImGui.Text((zh ? '松开移动到：' : 'Release to move under: ') + (target !== undefined ? target.name : id)));
		}
	}
}

export function drawSceneTreePanel(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '场景层级' : 'Scene Hierarchy');
	ImGui.SameLine();
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => ImGui.SmallButton('＋##scene_add'));
	} else if (ImGui.SmallButton('＋##scene_add')) {
		ImGui.OpenPopup('AddNodePopup');
	}
	drawAddNodePopup(state);
	ImGui.Separator();
	const selected = state.nodes[state.selectedId];
	if (selected !== undefined) {
		ImGui.TextColored(helperColor, zh ? '当前父子路径' : 'Current path');
		ImGui.TextDisabled(nodePath(state, selected.id));
		ImGui.Separator();
	}

	state.treeDropTargetId = undefined;
	const rows = buildSceneTreeRows(state, zh);
	for (const row of rows) {
		const draggingId = state.treeDraggingNodeId;
		const canAcceptDrop = draggingId !== undefined && canReparentSceneNode(state, draggingId, row.id);
		const isDropTarget = state.treeDropTargetId === row.id && draggingId !== undefined;
		const dropMarker = isDropTarget ? '→ ' : '  ';
		const label = dropMarker
			+ row.connectorPrefix
			+ row.connector
			+ foldGlyph(row.hasChildren, row.expanded)
			+ row.icon
			+ '  '
			+ row.name
			+ '  · '
			+ row.kindLabel
			+ childCountSuffix(row.childCount)
			+ '##tree_'
			+ row.id;
		drawTreeRow(state, row.id, label, canAcceptDrop);
		if (row.hasChildren && ImGui.IsItemHovered() && ImGui.IsMouseDoubleClicked(0)) {
			toggleTreeNodeExpanded(state, row.id);
		}
	}

	if (state.treeDraggingNodeId !== undefined && ImGui.IsMouseReleased(0)) {
		const dragId = state.treeDraggingNodeId;
		const dropId = state.treeDropTargetId;
		if (dropId !== undefined) {
			reparentNode(state, dragId, dropId);
		}
		state.treeDraggingNodeId = undefined;
		state.treeDropTargetId = undefined;
	}
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '拖动节点到可作为父级的节点上；双击父节点可折叠。' : 'Drag onto a valid parent; double-click parent rows to fold.');
}
