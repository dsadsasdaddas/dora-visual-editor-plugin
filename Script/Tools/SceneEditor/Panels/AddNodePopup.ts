import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { themeColor } from 'Script/Tools/SceneEditor/Theme';
import { addChildNode, zh } from 'Script/Tools/SceneEditor/Model';

export function drawAddNodePopup(state: EditorState) {
	ImGui.BeginPopup('AddNodePopup', () => {
		ImGui.TextColored(themeColor, zh ? '添加节点' : 'Add Node');
		ImGui.Separator();
		if (ImGui.Selectable('○  Node', false)) { addChildNode(state, 'Node'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('▣  Sprite', false)) { addChildNode(state, 'Sprite'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('T  Label', false)) { addChildNode(state, 'Label'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('◉  Camera', false)) { addChildNode(state, 'Camera'); ImGui.CloseCurrentPopup(); }
	});
}
