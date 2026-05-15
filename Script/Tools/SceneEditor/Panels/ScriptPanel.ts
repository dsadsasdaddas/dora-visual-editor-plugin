import { App, Content, Path, Vec2, emit, json, sleep, thread } from 'Dora';
import * as ImGui from 'ImGui';
import { StyleColor } from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { inputTextFlags, noScrollFlags, scriptPanelBg, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { importFileDialog, isFolderAsset, isScriptAsset, pushConsole, workspacePath, workspaceRoot, zh } from 'Script/Tools/SceneEditor/Model';

declare function pcall(fn: () => void): LuaMultiReturn<[boolean, unknown]>;
type EntryConfig = {
	editingInfo?: string;
};

type EntryApi = {
	getConfig: (this: void) => EntryConfig | undefined;
};

declare function require(path: 'Script.Dev.Entry'): EntryApi;
declare function require(path: string): unknown;

type AttachScriptToNode = (state: EditorState, node: SceneNodeData, scriptPath: string, message?: string) => void;

function scriptTemplate(node?: SceneNodeData) {
	const name = node !== undefined ? node.name : 'Script';
	return '-- ' + name + ' behavior\n'
		+ 'return function(node, scene, nodes)\n'
		+ '\tif node == nil then\n'
		+ '\t\tprint("[SceneScript] ' + name + ': node is nil; run the scene/game preview instead of this behavior script directly.")\n'
		+ '\t\treturn\n'
		+ '\tend\n'
		+ '\t-- write behavior here\n'
		+ 'end\n';
}

function gameMainTemplate() {
	return '-- Game main script\n'
		+ '-- This file runs after the scene nodes are created.\n'
		+ '-- Use A/D or Left/Right to move the first Sprite node.\n'
		+ 'local _ENV = Dora\n\n'
		+ 'return {\n'
		+ '\tstart = function(scene, nodes, world)\n'
		+ '\t\tlocal player = nil\n'
		+ '\t\tfor _, node in pairs(nodes) do\n'
		+ '\t\t\tlocal tag = tostring(node.tag or "")\n'
		+ '\t\t\tif node ~= scene and player == nil and string.find(tag, "Camera") == nil then\n'
		+ '\t\t\t\tplayer = node\n'
		+ '\t\t\tend\n'
		+ '\t\tend\n'
		+ '\t\tif player == nil then\n'
		+ '\t\t\tprint("[GameMain] no playable node found")\n'
		+ '\t\t\treturn\n'
		+ '\t\tend\n'
		+ '\t\tscene:schedule(function(deltaTime)\n'
		+ '\t\t\tlocal speed = 220\n'
		+ '\t\t\tif Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") then\n'
		+ '\t\t\t\tplayer.x = player.x - speed * deltaTime\n'
		+ '\t\t\tend\n'
		+ '\t\t\tif Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") then\n'
		+ '\t\t\t\tplayer.x = player.x + speed * deltaTime\n'
		+ '\t\t\tend\n'
		+ '\t\t\treturn false\n'
		+ '\t\tend)\n'
		+ '\tend\n'
		+ '}\n';
}

function loadScriptIntoEditor(
	state: EditorState,
	node: SceneNodeData | undefined,
	scriptPath: string,
	attachScriptToNode: AttachScriptToNode
) {
	if (node !== undefined) {
		attachScriptToNode(state, node, scriptPath);
	} else {
		state.activeScriptNodeId = undefined;
	}
	state.scriptPathBuffer.text = scriptPath;
	const scriptFile = workspacePath(scriptPath);
	if (Content.exist(scriptFile)) {
		state.scriptContentBuffer.text = Content.load(scriptFile) || '';
	} else if (Content.exist(scriptPath)) {
		state.scriptContentBuffer.text = Content.load(scriptPath) || '';
	} else {
		state.scriptContentBuffer.text = scriptTemplate(node);
	}
	state.mode = 'Script';
}

function loadGameMainIntoEditor(state: EditorState) {
	state.activeScriptNodeId = '__game_main__';
	const scriptPath = state.gameScript !== '' ? state.gameScript : 'Script/Main.lua';
	state.gameScript = scriptPath;
	state.gameScriptBuffer.text = scriptPath;
	state.scriptPathBuffer.text = scriptPath;
	const scriptFile = workspacePath(scriptPath);
	if (Content.exist(scriptFile)) {
		state.scriptContentBuffer.text = Content.load(scriptFile) || '';
	} else if (Content.exist(scriptPath)) {
		state.scriptContentBuffer.text = Content.load(scriptPath) || '';
	} else {
		state.scriptContentBuffer.text = gameMainTemplate();
	}
	state.mode = 'Script';
}

export function openScriptForNode(state: EditorState, node: SceneNodeData, attachScriptToNode: AttachScriptToNode) {
	const path = node.script !== '' ? node.script : 'Script/' + node.name + '.lua';
	loadScriptIntoEditor(state, node, path, attachScriptToNode);
}

function saveScriptFile(state: EditorState, node: SceneNodeData | undefined, attachScriptToNode: AttachScriptToNode) {
	const path = state.scriptPathBuffer.text !== '' ? state.scriptPathBuffer.text : 'Script/NewScript.lua';
	state.scriptPathBuffer.text = path;
	const scriptFile = workspacePath(path);
	Content.mkdir(Path.getPath(scriptFile));
	let statusAlreadyLogged = false;
	if (Content.save(scriptFile, state.scriptContentBuffer.text)) {
		if (node !== undefined) {
			attachScriptToNode(state, node, path, (zh ? '脚本已保存并挂载：' : 'Script saved and attached: ') + path);
			statusAlreadyLogged = true;
		} else {
			state.status = (zh ? '脚本已保存：' : 'Script saved: ') + path;
		}
		if (state.selectedAsset !== path) state.selectedAsset = path;
		let exists = false;
		for (const asset of state.assets) if (asset === path) exists = true;
		if (!exists) state.assets.push(path);
	} else {
		state.status = zh ? '脚本保存失败' : 'Failed to save script';
	}
	if (!statusAlreadyLogged) pushConsole(state, state.status);
}

function useCurrentScriptAsGameMain(state: EditorState) {
	const path = state.scriptPathBuffer.text !== '' ? state.scriptPathBuffer.text : 'Script/Main.lua';
	state.gameScript = path;
	state.gameScriptBuffer.text = path;
	state.status = (zh ? '已设置游戏主脚本：' : 'Game main script set: ') + path;
	pushConsole(state, state.status);
}

function currentScriptPath(state: EditorState, node?: SceneNodeData) {
	if (state.scriptPathBuffer.text !== '') return state.scriptPathBuffer.text;
	if (node !== undefined && node.script !== '') return node.script;
	if (node !== undefined) return 'Script/' + node.name + '.lua';
	return 'Script/NewScript.lua';
}

function sendWebIDEMessage(payload: object) {
	const [text] = json.encode(payload);
	if (text !== undefined) emit('AppWS', 'Send', text);
}

function openScriptInWebIDE(state: EditorState, node: SceneNodeData | undefined, attachScriptToNode: AttachScriptToNode) {
	const scriptPath = currentScriptPath(state, node);
	state.scriptPathBuffer.text = scriptPath;
	if (state.scriptContentBuffer.text === '') {
		state.scriptContentBuffer.text = scriptTemplate(node);
	}
	saveScriptFile(state, node, attachScriptToNode);
	const title = Path.getFilename(scriptPath) || scriptPath;
	const root = workspaceRoot();
	const rootTitle = Path.getFilename(root) || 'Workspace';
	const fullScriptPath = workspacePath(scriptPath);
	const openWorkspaceMessage = {
		name: 'OpenFile',
		file: root,
		title: rootTitle,
		folder: true,
		workspaceView: 'agent',
	};
	const updateScriptMessage = {
		name: 'UpdateFile',
		file: fullScriptPath,
		exists: true,
		content: state.scriptContentBuffer.text,
	};
	const openScriptMessage = {
		name: 'OpenFile',
		file: fullScriptPath,
		title,
		folder: false,
		position: { lineNumber: 1, column: 1 },
	};
	const sendOpenMessages = function(this: void) {
		sendWebIDEMessage(openWorkspaceMessage);
		sendWebIDEMessage(updateScriptMessage);
		sendWebIDEMessage(openScriptMessage);
	};
	const editingInfo = {
		index: 1,
		files: [
			{
				key: root,
				title: rootTitle,
				folder: true,
				workspaceView: 'agent',
			},
			{
				key: fullScriptPath,
				title,
				folder: false,
				position: { lineNumber: 1, column: 1 },
			},
		],
	};
	const [editingText] = json.encode(editingInfo);
	if (editingText !== undefined) {
		Content.mkdir(workspacePath('.dora'));
		Content.save(workspacePath(Path('.dora', 'open-script.editing.json')), editingText);
		pcall(() => {
			const Entry = require('Script.Dev.Entry');
			const config = Entry.getConfig();
			if (config !== undefined) config.editingInfo = editingText;
		});
	}
	App.openURL('http://127.0.0.1:8866/');
	sendOpenMessages();
	thread(function(this: void) {
		for (let i = 0; i < 4; i++) {
			sleep(0.5);
			sendOpenMessages();
		}
	});
	state.status = (zh ? '已打开 Web IDE：' : 'Opened Web IDE: ') + scriptPath;
	pushConsole(state, state.status);
}

function drawScriptAssetList(state: EditorState, node: SceneNodeData | undefined, attachScriptToNode: AttachScriptToNode) {
	ImGui.TextColored(themeColor, zh ? '脚本资源' : 'Script Assets');
	for (const asset of state.assets) {
		if (isScriptAsset(asset) && !isFolderAsset(asset)) {
			if (ImGui.Selectable('◇  ' + asset, state.selectedAsset === asset)) {
				state.selectedAsset = asset;
				loadScriptIntoEditor(state, node, asset, attachScriptToNode);
			}
		}
	}
}

export function drawScriptPanel(state: EditorState, attachScriptToNode: AttachScriptToNode) {
	const activeId = state.activeScriptNodeId || state.selectedId;
	const node = state.nodes[activeId];
	ImGui.TextColored(themeColor, zh ? '脚本编辑器' : 'Script Editor');
	ImGui.SameLine();
	ImGui.TextDisabled(node !== undefined ? node.name : (zh ? '独立文件模式' : 'File mode'));
	ImGui.Separator();
	ImGui.BeginChild('ScriptSidebar', Vec2(220, 0), [], noScrollFlags, () => {
		ImGui.TextColored(themeColor, zh ? '游戏入口' : 'Game Entry');
		ImGui.TextDisabled(state.gameScript !== '' ? state.gameScript : 'Script/Main.lua');
		if (ImGui.Button(zh ? '打开主脚本' : 'Open Main')) loadGameMainIntoEditor(state);
		if (ImGui.Button(zh ? '当前脚本设为主入口' : 'Use Current As Main')) useCurrentScriptAsGameMain(state);
		ImGui.Separator();
		drawScriptAssetList(state, node, attachScriptToNode);
		ImGui.Separator();
		if (ImGui.Button(zh ? '新建脚本' : 'New Script')) {
			const scriptName = node !== undefined ? node.name : 'NewScript';
			const path = 'Script/' + scriptName + '.lua';
			state.scriptPathBuffer.text = path;
			state.scriptContentBuffer.text = scriptTemplate(node);
			if (node !== undefined) {
				attachScriptToNode(state, node, path, (zh ? '已新建脚本并挂载：' : 'New script attached and saved: ') + path);
			}
		}
		if (ImGui.Button(zh ? '导入脚本文件' : 'Import Script')) importFileDialog(state);
		if (node !== undefined && ImGui.Button(zh ? '绑定选中资源' : 'Attach Selected')) {
			if (state.selectedAsset !== '' && isScriptAsset(state.selectedAsset)) {
				loadScriptIntoEditor(state, node, state.selectedAsset, attachScriptToNode);
			}
		}
		if (ImGui.Button(zh ? '重新加载' : 'Reload')) {
			loadScriptIntoEditor(state, node, state.scriptPathBuffer.text, attachScriptToNode);
		}
	});
	ImGui.SameLine();
	ImGui.PushStyleColor(StyleColor.ChildBg, scriptPanelBg, () => {
		ImGui.BeginChild('ScriptEditorPane', Vec2(0, 0), [], noScrollFlags, () => {
			ImGui.TextDisabled(zh ? '脚本路径' : 'Script Path');
			ImGui.InputText('##ScriptPath', state.scriptPathBuffer, inputTextFlags);
			ImGui.SameLine();
			if (ImGui.Button(zh ? '保存' : 'Save')) saveScriptFile(state, node, attachScriptToNode);
			ImGui.SameLine();
			if (ImGui.Button(zh ? '设为主入口' : 'Set Main')) useCurrentScriptAsGameMain(state);
			ImGui.SameLine();
			if (ImGui.Button(zh ? 'Web IDE 打开' : 'Open in Web IDE')) openScriptInWebIDE(state, node, attachScriptToNode);
			if (node !== undefined) {
				ImGui.SameLine();
				if (ImGui.Button(zh ? '绑定到节点' : 'Attach Node')) {
					attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh ? '脚本已挂载并保存到节点：' : 'Script attached and saved to node: ') + node.name);
				}
			}
			ImGui.Separator();
			ImGui.InputTextMultiline('##ScriptEditor', state.scriptContentBuffer, Vec2(0, -4), []);
		});
	});
}
