import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/Types';
import { themeColor } from 'Script/Tools/SceneEditor/Theme';
import { deleteNode, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { startPlay, stopPlay } from 'Script/Tools/SceneEditor/Player';
import { drawAddNodePopup } from 'Script/Tools/SceneEditor/Panels/AddNodePopup';

export function drawHeaderPanel(state: EditorState, saveScene: (state: EditorState) => void) {
	ImGui.TextColored(themeColor, '✦ Dora Visual Editor');
	ImGui.SameLine();
	if (ImGui.Button(zh ? '场景' : 'Scene')) state.mode = '2D';
	ImGui.SameLine();
	if (ImGui.Button(zh ? '脚本' : 'Scripts')) state.mode = 'Script';
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? 'Dora 原生 2D 场景编辑器' : 'Dora Native 2D Scene Editor');
	ImGui.Separator();
	if (state.isPlaying) {
		if (ImGui.Button(zh ? '■ 停止' : '■ Stop')) stopPlay(state);
	} else if (ImGui.Button(zh ? '▶ 运行' : '▶ Run')) {
		startPlay(state);
	}
	ImGui.SameLine();
	if (ImGui.Button(zh ? '▣ 保存' : '▣ Save')) saveScene(state);
	ImGui.SameLine();
	if (ImGui.Button(zh ? '◇ 构建' : '◇ Build')) {
		state.status = zh ? 'Build 会在代码生成稳定后接入' : 'Build will be wired after codegen is stable';
		pushConsole(state, state.status);
	}
	ImGui.SameLine();
	ImGui.TextDisabled('|');
	ImGui.SameLine();
	if (ImGui.Button(zh ? '＋ 添加' : '＋ Add')) ImGui.OpenPopup('AddNodePopup');
	drawAddNodePopup(state);
	ImGui.SameLine();
	if (ImGui.Button(zh ? '删除' : 'Delete')) deleteNode(state, state.selectedId);
	ImGui.Separator();
}
