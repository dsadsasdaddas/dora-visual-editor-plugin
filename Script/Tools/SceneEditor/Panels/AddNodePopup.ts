import * as ImGui from 'ImGui';
import { EditorState, SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';
import { helperColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { addChildNode, nodePath, resolveAddParentId, zh } from 'Script/Tools/SceneEditor/Model';
import { categoryLabel, canCreateNodeKind, nodeCategoryDefinitions, nodeKindDefinitions } from 'Script/Tools/SceneEditor/NodeCatalog';

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
		for (const category of nodeCategoryDefinitions) {
			drawSection(categoryLabel(category, zh));
			for (const definition of nodeKindDefinitions) {
				if (definition.category === category.id && canCreateNodeKind(definition.kind)) {
					drawNodeOption(
						state,
						definition.kind,
						definition.icon,
						zh ? definition.labelZh : definition.labelEn,
						zh ? definition.descriptionZh : definition.descriptionEn
					);
				}
			}
		}
	});
}
