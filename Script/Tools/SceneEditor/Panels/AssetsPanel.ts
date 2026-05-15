import { Vec2 } from 'Dora';
import * as ImGui from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { themeColor } from 'Script/Tools/SceneEditor/Theme';
import { importFileDialog, importFolderDialog, isFolderAsset, isScriptAsset, isTextureAsset, lowerExt, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { canNodeKindBindScript, canNodeKindBindTexture } from 'Script/Tools/SceneEditor/NodeCapabilities';

declare function pcall(fn: () => void): LuaMultiReturn<[boolean, unknown]>;

type BindTextureToSprite = (state: EditorState, node: SceneNodeData, texture: string) => void;
type CreateSpriteFromTexture = (state: EditorState, texture: string) => void;
type AttachScriptToNode = (state: EditorState, node: SceneNodeData, scriptPath: string, message?: string) => void;

function assetIcon(asset: string) {
	if (isFolderAsset(asset)) return '📁';
	if (isTextureAsset(asset)) return '🖼';
	if (isScriptAsset(asset)) return '◇';
	const ext = lowerExt(asset);
	if (ext === 'wav' || ext === 'mp3' || ext === 'ogg' || ext === 'flac') return '♪';
	if (ext === 'ttf' || ext === 'otf' || ext === 'fnt') return 'F';
	if (ext === 'json' || ext === 'xml' || ext === 'yaml' || ext === 'yml') return '{}';
	if (ext === 'atlas' || ext === 'model' || ext === 'skel' || ext === 'anim') return '◆';
	return '·';
}

function startsWith(text: string, prefix: string) {
	return string.sub(text, 1, string.len(prefix)) === prefix;
}

function drawAssetRow(
	state: EditorState,
	asset: string,
	bindTextureToSprite: BindTextureToSprite,
	attachScriptToNode: AttachScriptToNode
) {
	if (isFolderAsset(asset)) {
		ImGui.TreeNode(assetIcon(asset) + '  ' + asset, () => {
			for (const child of state.assets) {
				if (child !== asset && !isFolderAsset(child) && startsWith(child, asset)) {
					drawAssetRow(state, child, bindTextureToSprite, attachScriptToNode);
				}
			}
		});
		return;
	}
	if (ImGui.Selectable(assetIcon(asset) + '  ' + asset, state.selectedAsset === asset)) {
		state.selectedAsset = asset;
		if (state.isPlaying) {
			state.status = zh ? '运行中资源只允许选择，不会改场景。点 Stop 后再绑定。' : 'Play Mode: asset selection is read-only. Stop to bind assets.';
			pushConsole(state, state.status);
			return;
		}
		const node = state.nodes[state.selectedId];
		if (node !== undefined && canNodeKindBindTexture(node.kind) && isTextureAsset(asset)) {
			bindTextureToSprite(state, node, asset);
			return;
		} else if (node !== undefined && canNodeKindBindScript(node.kind) && isScriptAsset(asset)) {
			attachScriptToNode(state, node, asset, (zh ? '已绑定脚本并保存：' : 'Script assigned and saved: ') + asset);
			return;
		} else {
			state.status = zh ? '已选择资源；选中支持的节点可绑定图片或脚本' : 'Asset selected; select a compatible node to bind images or scripts';
		}
		pushConsole(state, state.status);
	}
}

export function drawAssetsPanel(
	state: EditorState,
	bindTextureToSprite: BindTextureToSprite,
	createSpriteFromTexture: CreateSpriteFromTexture,
	attachScriptToNode: AttachScriptToNode
) {
	ImGui.TextColored(themeColor, zh ? '资源' : 'Assets');
	ImGui.SameLine();
	if (ImGui.SmallButton(zh ? '＋ 文件' : '＋ File')) importFileDialog(state);
	ImGui.SameLine();
	if (ImGui.SmallButton(zh ? '＋ 文件夹' : '＋ Folder')) importFolderDialog(state);
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。' : 'Supports images, scripts, json, audio, fonts, models; folders import recursively.');
	ImGui.Separator();
	if (state.assets.length === 0) {
		ImGui.TextDisabled(zh ? '点击 + File 或 + Folder 导入资源。' : 'Click + File or + Folder to import assets.');
		return;
	}
	for (const asset of state.assets) {
		if (isFolderAsset(asset)) {
			drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode);
		}
	}
	for (const asset of state.assets) {
		let insideFolder = false;
		for (const folder of state.assets) {
			if (isFolderAsset(folder) && startsWith(asset, folder)) insideFolder = true;
		}
		if (!insideFolder && !isFolderAsset(asset)) drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode);
	}
	if (state.selectedAsset !== '' && isTextureAsset(state.selectedAsset)) {
		ImGui.Separator();
		ImGui.TextColored(themeColor, zh ? '贴图预览' : 'Texture Preview');
		const [ok] = pcall(() => ImGui.Image(state.selectedAsset, Vec2(160, 120)));
		if (!ok) ImGui.TextDisabled(zh ? '无法预览该贴图；但仍可尝试绑定到 Sprite。' : 'Unable to preview; still can bind to Sprite.');
		const selectedNode = state.nodes[state.selectedId];
		if (state.isPlaying) {
			ImGui.BeginDisabled(() => {
				ImGui.Button(zh ? '绑定到当前节点' : 'Bind To Node');
				ImGui.SameLine();
				ImGui.Button(zh ? '用此贴图创建 Sprite' : 'Create Sprite');
			});
		} else {
			if (selectedNode !== undefined && canNodeKindBindTexture(selectedNode.kind)) {
				if (ImGui.Button(zh ? '绑定到当前节点' : 'Bind To Node')) bindTextureToSprite(state, selectedNode, state.selectedAsset);
				ImGui.SameLine();
			}
			if (ImGui.Button(zh ? '用此贴图创建 Sprite' : 'Create Sprite')) createSpriteFromTexture(state, state.selectedAsset);
		}
	}
}
