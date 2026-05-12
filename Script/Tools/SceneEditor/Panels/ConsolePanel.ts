import * as ImGui from 'ImGui';
import { EditorState } from 'Script/Tools/SceneEditor/EditorTypes';
import { okColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { zh } from 'Script/Tools/SceneEditor/Model';

export function drawConsolePanel(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '控制台' : 'Console');
	ImGui.SameLine();
	ImGui.TextColored(okColor, state.status);
	ImGui.Separator();
	for (const line of state.console) ImGui.TextDisabled(line);
}
