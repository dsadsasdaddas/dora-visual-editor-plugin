import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { themeColor } from 'Script/Tools/SceneEditor/Theme';
import { iconFor, reparentNode, zh } from 'Script/Tools/SceneEditor/Model';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

function drawNodeRow(state: EditorState, id: string, depth: number) {
	const node = state.nodes[id];
	if (node === undefined) return;
	const indent = string.rep('  ', depth);
	const isDropTarget = state.treeDropTargetId === id && state.treeDraggingNodeId !== undefined;
	const label = (isDropTarget ? '→ ' : '') + indent + iconFor(node.kind) + '  ' + node.name + '##tree_' + id;
	if (ImGui.Selectable(label, state.selectedId === id)) {
		state.selectedId = id;
		state.previewDirty = true;
	}
	if (!state.isPlaying) {
		if (id !== 'root' && ImGui.IsItemActive() && ImGui.IsMouseDragging(0)) {
			state.treeDraggingNodeId = id;
		}
		const draggingId = state.treeDraggingNodeId;
		if (draggingId !== undefined && draggingId !== id && ImGui.IsItemHovered()) {
			state.treeDropTargetId = id;
			const targetName = node.name;
			ImGui.BeginTooltip(() => ImGui.Text((zh ? '松开移动到：' : 'Release to move under: ') + targetName));
		}
	}
	for (const childId of node.children) {
		drawNodeRow(state, childId, depth + 1);
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
	state.treeDropTargetId = undefined;
	drawNodeRow(state, 'root', 0);
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
	ImGui.TextDisabled(zh ? '拖动节点到另一个节点上可调整父子关系' : 'Drag a node onto another node to reparent it');
}
