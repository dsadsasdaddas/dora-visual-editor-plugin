import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { okColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { deleteNode, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { launchExternalPreview, stopExternalPreview } from 'Script/Tools/SceneEditor/ExternalPreview';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

export function drawHeaderPanel(state: EditorState, saveScene: (state: EditorState) => void) {
	ImGui.TextColored(themeColor, '✦ Dora Visual Editor');
	if (state.externalPreviewRunning) {
		ImGui.SameLine();
		ImGui.TextColored(okColor, zh ? '● 外部预览' : '● EXTERNAL PREVIEW');
		ImGui.SameLine();
		ImGui.TextDisabled(zh ? '编辑器仍可继续编辑' : 'Editor remains editable');
	}
	ImGui.SameLine();
	if (ImGui.Button(zh ? '场景' : 'Scene')) state.mode = '2D';
	ImGui.SameLine();
	if (ImGui.Button(zh ? '脚本' : 'Scripts')) state.mode = 'Script';
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? 'Dora 原生 2D 场景编辑器' : 'Dora Native 2D Scene Editor');
	ImGui.Separator();
	if (state.externalPreviewRunning) {
		if (ImGui.Button(zh ? '■ 停止标记' : '■ Stop Mark')) stopExternalPreview(state);
		ImGui.SameLine();
		if (ImGui.Button(zh ? '↻ 重新运行' : '↻ Relaunch')) {
			saveScene(state);
			launchExternalPreview(state);
		}
	} else if (ImGui.Button(zh ? '▶ 运行' : '▶ Run')) {
		saveScene(state);
		launchExternalPreview(state);
	}
	ImGui.SameLine();
	if (ImGui.Button(zh ? '▣ 保存' : '▣ Save')) saveScene(state);
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? '游戏窗口' : 'Game');
	ImGui.SameLine();
	ImGui.PushItemWidth(150, () => {
		const [sizeChanged, width, height] = ImGui.DragInt2('##game_resolution', state.gameWidth, state.gameHeight, 1, 160, 8192, '%d');
		if (sizeChanged) {
			state.gameWidth = math.max(160, math.min(8192, width));
			state.gameHeight = math.max(120, math.min(8192, height));
			state.previewDirty = true;
			state.playDirty = true;
		}
	});
	ImGui.SameLine();
	if (ImGui.Button('16:9')) {
		state.gameWidth = 960;
		state.gameHeight = 540;
		state.previewDirty = true;
		state.playDirty = true;
	}
	ImGui.SameLine();
	if (ImGui.Button('HD')) {
		state.gameWidth = 1280;
		state.gameHeight = 720;
		state.previewDirty = true;
		state.playDirty = true;
	}
	ImGui.SameLine();
	if (ImGui.Button(zh ? '◇ 构建' : '◇ Build')) {
		state.status = zh ? 'Build 会在代码生成稳定后接入' : 'Build will be wired after codegen is stable';
		pushConsole(state, state.status);
	}
	ImGui.SameLine();
	ImGui.TextDisabled('|');
	ImGui.SameLine();
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => ImGui.Button(zh ? '＋ 添加' : '＋ Add'));
	} else if (ImGui.Button(zh ? '＋ 添加' : '＋ Add')) {
		ImGui.OpenPopup('AddNodePopup');
	}
	drawAddNodePopup(state);
	ImGui.SameLine();
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => ImGui.Button(zh ? '删除' : 'Delete'));
	} else if (ImGui.Button(zh ? '删除' : 'Delete')) {
		deleteNode(state, state.selectedId);
	}
	ImGui.Separator();
}
