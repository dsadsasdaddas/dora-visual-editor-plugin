import * as ImGui from 'ImGui';
import { EditorState, SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';
import { helperColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { addChildNode, nodePath, resolveAddParentId, zh } from 'Script/Tools/SceneEditor/Model';

function drawNodeOption(state: EditorState, kind: SceneNodeKind, icon: string, title: string, description: string) {
	if (ImGui.Selectable(icon + '  ' + title + '##add_' + kind, false)) {
		addChildNode(state, kind);
		ImGui.CloseCurrentPopup();
	}
	ImGui.TextDisabled('   ' + description);
}

function drawSection(title: string) {
	ImGui.Spacing();
	ImGui.TextColored(helperColor, title);
}

export function drawAddNodePopup(state: EditorState) {
	ImGui.BeginPopup('AddNodePopup', () => {
		const parentId = resolveAddParentId(state);
		const selected = state.nodes[state.selectedId];
		const parent = state.nodes[parentId];
		ImGui.TextColored(themeColor, zh ? '添加节点' : 'Add Node');
		ImGui.TextDisabled(zh ? '新节点会挂到下面这个父节点：' : 'New node will be created under:');
		ImGui.Text(parent !== undefined ? nodePath(state, parent.id) : 'Root');
		if (selected !== undefined && selected.kind === 'Camera') {
			ImGui.TextDisabled(zh ? '提示：Camera 不作为父节点，已自动使用它的父节点。' : 'Tip: Camera is not used as a parent; its parent is used instead.');
		}
		ImGui.Separator();
		drawSection(zh ? '结构节点' : 'Structure');
		drawNodeOption(state, 'Node', '○', 'Node', zh ? '空节点。用来做父级、分组、挂脚本。' : 'Empty parent/group node for transforms and scripts.');
		drawSection(zh ? '可见对象' : 'Renderable');
		drawNodeOption(state, 'Sprite', '▣', 'Sprite', zh ? '图片节点。可绑定 texture。' : 'Image node with an optional texture.');
		drawNodeOption(state, 'Label', 'T', 'Label', zh ? '文字节点。显示一段文本。' : 'Text node for simple labels.');
		drawSection(zh ? '视图' : 'View');
		drawNodeOption(state, 'Camera', '◉', 'Camera', zh ? '相机节点。定义运行时可见区域。' : 'Camera node for the runtime view.');
	});
}
