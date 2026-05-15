import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { helperColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { iconFor, nodePath, reparentNode, zh } from 'Script/Tools/SceneEditor/Model';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

function kindLabel(kind: string) {
	if (kind === 'Root') return zh ? '根' : 'Root';
	if (kind === 'Node') return zh ? '分组' : 'Node';
	if (kind === 'Sprite') return zh ? '精灵' : 'Sprite';
	if (kind === 'Label') return zh ? '文本' : 'Label';
	if (kind === 'Camera') return zh ? '相机' : 'Camera';
	return kind;
}

function childCountSuffix(count: number) {
	if (count <= 0) return '';
	return '  (' + tostring(count) + ')';
}

function drawNodeRow(state: EditorState, id: string, prefix: string, isLast: boolean) {
	const node = state.nodes[id];
	if (node === undefined) return;
	const isDropTarget = state.treeDropTargetId === id && state.treeDraggingNodeId !== undefined;
	const connector = id === 'root' ? '' : (isLast ? '└─ ' : '├─ ');
	const dropMarker = isDropTarget ? '→ ' : '  ';
	const label = dropMarker + prefix + connector + iconFor(node.kind) + '  ' + node.name + '  · ' + kindLabel(node.kind) + childCountSuffix(node.children.length) + '##tree_' + id;
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
	const childPrefix = id === 'root' ? '' : prefix + (isLast ? '   ' : '│  ');
	for (let i = 0; i < node.children.length; i++) {
		const childId = node.children[i];
		drawNodeRow(state, childId, childPrefix, i === node.children.length - 1);
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
	drawNodeRow(state, 'root', '', true);
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
