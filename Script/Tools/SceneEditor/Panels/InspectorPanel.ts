import { App } from 'Dora';
import * as ImGui from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { inputTextFlags, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { addAssetPath, iconFor, isTextureAsset, zh } from 'Script/Tools/SceneEditor/Model';

type BindTextureToSprite = (state: EditorState, node: SceneNodeData, texture: string) => void;
type OpenScriptForNode = (state: EditorState, node: SceneNodeData) => void;

function markSceneChanged(state: EditorState) {
	state.previewDirty = true;
	state.playDirty = true;
}

export function drawInspectorPanel(
	state: EditorState,
	bindTextureToSprite: BindTextureToSprite,
	openScriptForNode: OpenScriptForNode
) {
	ImGui.TextColored(themeColor, zh ? '属性检查器' : 'Inspector');
	ImGui.Separator();
	const node = state.nodes[state.selectedId];
	if (node === undefined) {
		ImGui.TextDisabled(zh ? '没有选中节点' : 'No node selected');
		return;
	}
	ImGui.Text(iconFor(node.kind) + '  ' + node.kind);
	if (state.isPlaying) {
		ImGui.TextDisabled(zh ? '运行中属性锁定；点 Stop 后再编辑节点。' : 'Properties are locked in Play Mode. Stop to edit nodes.');
		ImGui.Separator();
		ImGui.TextDisabled('Name: ' + node.name);
		ImGui.TextDisabled('Position: ' + tostring(node.x) + ', ' + tostring(node.y));
		ImGui.TextDisabled('Scale: ' + tostring(node.scaleX) + ', ' + tostring(node.scaleY));
		ImGui.TextDisabled('Rotation: ' + tostring(node.rotation));
		ImGui.TextDisabled('Script: ' + node.script);
		if (node.kind === 'Sprite') ImGui.TextDisabled('Texture: ' + node.texture);
		if (node.kind === 'Label') ImGui.TextDisabled('Text: ' + node.text);
		return;
	}
	if (ImGui.InputText('Name', node.nameBuffer, inputTextFlags)) { node.name = node.nameBuffer.text; markSceneChanged(state); }
	let [changed, x, y] = ImGui.DragFloat2('Position', node.x, node.y, 1, -10000, 10000, '%.1f');
	if (changed) { node.x = x; node.y = y; markSceneChanged(state); }
	[changed, x, y] = ImGui.DragFloat2('Scale', node.scaleX, node.scaleY, 0.01, -100, 100, '%.2f');
	if (changed) { node.scaleX = x; node.scaleY = y; markSceneChanged(state); }
	const [angleChanged, angle] = ImGui.DragFloat('Rotation', node.rotation, 1, -360, 360, '%.1f');
	if (angleChanged) { node.rotation = angle; markSceneChanged(state); }
	const [visibleChanged, visible] = ImGui.Checkbox('Visible', node.visible);
	if (visibleChanged) { node.visible = visible; markSceneChanged(state); }
	ImGui.Separator();
	if (ImGui.InputText('Script', node.scriptBuffer, inputTextFlags)) { node.script = node.scriptBuffer.text; markSceneChanged(state); }
	if (ImGui.Button(zh ? '打开脚本' : 'Open Script')) openScriptForNode(state, node);
	if (node.kind === 'Sprite') {
		ImGui.Separator();
		if (ImGui.InputText('Texture', node.textureBuffer, inputTextFlags)) {
			node.texture = node.textureBuffer.text;
			markSceneChanged(state);
		}
		if (ImGui.Button(zh ? '导入并绑定贴图' : 'Import Texture')) {
			App.openFileDialog(false, function(this: void, path: string) {
				const asset = addAssetPath(state, path);
				if (asset !== undefined && isTextureAsset(asset)) bindTextureToSprite(state, node, asset);
			});
		}
		ImGui.SameLine();
		if (ImGui.Button(zh ? '绑定选中贴图' : 'Use Selected')) {
			if (state.selectedAsset !== '' && isTextureAsset(state.selectedAsset)) bindTextureToSprite(state, node, state.selectedAsset);
		}
	} else if (node.kind === 'Label') {
		ImGui.Separator();
		if (ImGui.InputText('Text', node.textBuffer, inputTextFlags)) { node.text = node.textBuffer.text; markSceneChanged(state); }
	} else if (node.kind === 'Camera') {
		ImGui.Separator();
		ImGui.TextDisabled(zh ? 'Camera 显示真实取景框。' : 'Camera shows a real frame in viewport.');
	}
}
