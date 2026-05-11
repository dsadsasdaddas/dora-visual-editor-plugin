import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/Types';
import { themeColor } from 'Script/Tools/SceneEditor/Theme';
import { iconFor, zh } from 'Script/Tools/SceneEditor/Model';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

function drawNodeRow(state: EditorState, id: string, depth: number) {
	const node = state.nodes[id];
	if (node === undefined) return;
	const indent = string.rep('  ', depth);
	const label = indent + iconFor(node.kind) + '  ' + node.name + '##tree_' + id;
	if (ImGui.Selectable(label, state.selectedId === id)) {
		state.selectedId = id;
		state.previewDirty = true;
	}
	for (const childId of node.children) {
		drawNodeRow(state, childId, depth + 1);
	}
}

export function drawSceneTreePanel(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '场景层级' : 'Scene Hierarchy');
	ImGui.SameLine();
	if (ImGui.SmallButton('＋##scene_add')) ImGui.OpenPopup('AddNodePopup');
	drawAddNodePopup(state);
	ImGui.Separator();
	drawNodeRow(state, 'root', 0);
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '＋ 添加到当前选中节点下' : '+ adds under selected node');
}
