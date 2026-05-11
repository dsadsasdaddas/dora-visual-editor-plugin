import { App, Color, Content, Keyboard, KeyName, Mouse, Path, Vec2, emit, json, sleep, thread } from 'Dora';
import * as ImGui from 'ImGui';
import { SetCond, StyleColor } from 'ImGui';
import { EditorState, SceneNodeData, ViewportTool } from 'Script/Tools/SceneEditor/Types';
import { inputTextFlags, mainWindowFlags, noScrollFlags, okColor, panelBg, scriptPanelBg, themeColor, transparent, warnColor } from 'Script/Tools/SceneEditor/Theme';
import { addAssetPath, addChildNode, deleteNode, iconFor, importFileDialog, importFolderDialog, isFolderAsset, isScriptAsset, isTextureAsset, lowerExt, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { updatePreviewRuntime } from 'Script/Tools/SceneEditor/Runtime';
import { drawGamePreviewWindow, startPlay, stopPlay } from 'Script/Tools/SceneEditor/Player';

declare function pcall(fn: () => void): LuaMultiReturn<[boolean, unknown]>;
declare function require(path: string): any;

const SceneModel = require('Script.Tools.SceneEditor.Model');
function workspacePath(path: string) { return SceneModel.workspacePath(path) as string; }
function workspaceRoot() { return SceneModel.workspaceRoot() as string; }

function sceneSaveFile() {
	return workspacePath(Path('.dora', 'imgui-editor.scene.json'));
}

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

function drawAddNodePopup(state: EditorState) {
	ImGui.BeginPopup('AddNodePopup', () => {
		ImGui.TextColored(themeColor, zh ? '添加节点' : 'Add Node');
		ImGui.Separator();
		if (ImGui.Selectable('○  Node', false)) { addChildNode(state, 'Node'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('▣  Sprite', false)) { addChildNode(state, 'Sprite'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('T  Label', false)) { addChildNode(state, 'Label'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('◉  Camera', false)) { addChildNode(state, 'Camera'); ImGui.CloseCurrentPopup(); }
	});
}

function writeSceneFile(state: EditorState) {
	Content.mkdir(workspacePath('.dora'));
	const data = { version: 1, nodes: [] as object[] };
	for (const id of state.order) {
		const node = state.nodes[id];
		if (node !== undefined) {
			data.nodes.push({
				id: node.id,
				kind: node.kind,
				name: node.name,
				parentId: node.parentId,
				x: node.x,
				y: node.y,
				scaleX: node.scaleX,
				scaleY: node.scaleY,
				rotation: node.rotation,
				visible: node.visible,
				texture: node.texture,
				text: node.text,
				script: node.script,
			});
		}
	}
	const [text] = json.encode(data);
	const file = sceneSaveFile();
	if (text !== undefined && Content.save(file, text)) return file;
	return undefined;
}

function saveScene(state: EditorState) {
	const file = writeSceneFile(state);
	if (file !== undefined) {
		state.status = (zh ? '已保存：' : 'Saved: ') + file;
	} else {
		state.status = zh ? '保存失败' : 'Save failed';
	}
	pushConsole(state, state.status);
}

function attachScriptToNode(state: EditorState, node: SceneNodeData, scriptPath: string, message?: string) {
	node.script = scriptPath;
	node.scriptBuffer.text = scriptPath;
	state.activeScriptNodeId = node.id;
	const sceneFile = writeSceneFile(state);
	if (sceneFile === undefined) {
		state.status = zh ? '脚本已挂载，但场景保存失败' : 'Script attached, but scene save failed';
	} else {
		state.status = message || ((zh ? '脚本已挂载并保存：' : 'Script attached and saved: ') + scriptPath);
	}
	pushConsole(state, state.status);
}

function drawHeader(state: EditorState) {
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

function drawScenePanel(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '场景层级' : 'Scene Hierarchy');
	ImGui.SameLine();
	if (ImGui.SmallButton('＋##scene_add')) ImGui.OpenPopup('AddNodePopup');
	drawAddNodePopup(state);
	ImGui.Separator();
	drawNodeRow(state, 'root', 0);
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '＋ 添加到当前选中节点下' : '+ adds under selected node');
}

function bindTextureToSprite(state: EditorState, node: SceneNodeData, texture: string) {
	node.texture = texture;
	node.textureBuffer.text = texture;
	state.selectedAsset = texture;
	state.previewDirty = true;
	state.status = (zh ? '已绑定贴图：' : 'Texture assigned: ') + texture;
	pushConsole(state, state.status);
}

function createSpriteFromTexture(state: EditorState, texture: string) {
	addChildNode(state, 'Sprite');
	const node = state.nodes[state.selectedId];
	if (node !== undefined && node.kind === 'Sprite') {
		bindTextureToSprite(state, node, texture);
	}
}

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

function drawAssetRow(state: EditorState, asset: string) {
	if (isFolderAsset(asset)) {
		ImGui.TreeNode(assetIcon(asset) + '  ' + asset, () => {
			for (const child of state.assets) {
				if (child !== asset && !isFolderAsset(child) && startsWith(child, asset)) {
					drawAssetRow(state, child);
				}
			}
		});
		return;
	}
	if (ImGui.Selectable(assetIcon(asset) + '  ' + asset, state.selectedAsset === asset)) {
		state.selectedAsset = asset;
		const node = state.nodes[state.selectedId];
		if (node !== undefined && node.kind === 'Sprite' && isTextureAsset(asset)) {
			bindTextureToSprite(state, node, asset);
			return;
		} else if (node !== undefined && isScriptAsset(asset)) {
			attachScriptToNode(state, node, asset, (zh ? '已绑定脚本并保存：' : 'Script assigned and saved: ') + asset);
			return;
		} else {
			state.status = zh ? '已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本' : 'Asset selected; select a Sprite for images, or a node for scripts';
		}
		pushConsole(state, state.status);
	}
}

function drawAssetsPanel(state: EditorState) {
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
			drawAssetRow(state, asset);
		}
	}
	for (const asset of state.assets) {
		let insideFolder = false;
		for (const folder of state.assets) {
			if (isFolderAsset(folder) && startsWith(asset, folder)) insideFolder = true;
		}
		if (!insideFolder && !isFolderAsset(asset)) drawAssetRow(state, asset);
	}
	if (state.selectedAsset !== '' && isTextureAsset(state.selectedAsset)) {
		ImGui.Separator();
		ImGui.TextColored(themeColor, zh ? '贴图预览' : 'Texture Preview');
		const [ok] = pcall(() => ImGui.Image(state.selectedAsset, Vec2(160, 120)));
		if (!ok) ImGui.TextDisabled(zh ? '无法预览该贴图；但仍可尝试绑定到 Sprite。' : 'Unable to preview; still can bind to Sprite.');
		const selectedNode = state.nodes[state.selectedId];
		if (selectedNode !== undefined && selectedNode.kind === 'Sprite') {
			if (ImGui.Button(zh ? '绑定到当前 Sprite' : 'Bind To Sprite')) bindTextureToSprite(state, selectedNode, state.selectedAsset);
			ImGui.SameLine();
		}
		if (ImGui.Button(zh ? '用此贴图创建 Sprite' : 'Create Sprite')) createSpriteFromTexture(state, state.selectedAsset);
	}
}

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

function loadScriptIntoEditor(state: EditorState, node: SceneNodeData | undefined, scriptPath: string) {
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

function openScriptForNode(state: EditorState, node: SceneNodeData) {
	const path = node.script !== '' ? node.script : 'Script/' + node.name + '.lua';
	loadScriptIntoEditor(state, node, path);
}

function saveScriptFile(state: EditorState, node?: SceneNodeData) {
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

function openScriptInWebIDE(state: EditorState, node?: SceneNodeData) {
	const scriptPath = currentScriptPath(state, node);
	state.scriptPathBuffer.text = scriptPath;
	if (state.scriptContentBuffer.text === '') {
		state.scriptContentBuffer.text = scriptTemplate(node);
	}
	saveScriptFile(state, node);
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

function drawScriptAssetList(state: EditorState, node?: SceneNodeData) {
	ImGui.TextColored(themeColor, zh ? '脚本资源' : 'Script Assets');
	for (const asset of state.assets) {
		if (isScriptAsset(asset) && !isFolderAsset(asset)) {
			if (ImGui.Selectable('◇  ' + asset, state.selectedAsset === asset)) {
				state.selectedAsset = asset;
				loadScriptIntoEditor(state, node, asset);
			}
		}
	}
}

function drawScriptPanel(state: EditorState) {
	const activeId = state.activeScriptNodeId || state.selectedId;
	const node = state.nodes[activeId];
	ImGui.TextColored(themeColor, zh ? '脚本编辑器' : 'Script Editor');
	ImGui.SameLine();
	ImGui.TextDisabled(node !== undefined ? node.name : (zh ? '独立文件模式' : 'File mode'));
	ImGui.Separator();
	ImGui.BeginChild('ScriptSidebar', Vec2(220, 0), [], noScrollFlags, () => {
		drawScriptAssetList(state, node);
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
				loadScriptIntoEditor(state, node, state.selectedAsset);
			}
		}
		if (ImGui.Button(zh ? '重新加载' : 'Reload')) {
			loadScriptIntoEditor(state, node, state.scriptPathBuffer.text);
		}
	});
	ImGui.SameLine();
	ImGui.PushStyleColor(StyleColor.ChildBg, scriptPanelBg, () => {
		ImGui.BeginChild('ScriptEditorPane', Vec2(0, 0), [], noScrollFlags, () => {
			ImGui.TextDisabled(zh ? '脚本路径' : 'Script Path');
			ImGui.InputText('##ScriptPath', state.scriptPathBuffer, inputTextFlags);
			ImGui.SameLine();
			if (ImGui.Button(zh ? '保存' : 'Save')) saveScriptFile(state, node);
			ImGui.SameLine();
			if (ImGui.Button(zh ? 'Web IDE 打开' : 'Open in Web IDE')) openScriptInWebIDE(state, node);
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

function viewportScale(state: EditorState) {
	return math.max(0.25, state.zoom / 100);
}

function clampZoom(value: number) {
	return math.max(25, math.min(400, value));
}

function zoomViewportAt(state: EditorState, delta: number, screenX: number, screenY: number) {
	if (delta === 0) return;
	const before = state.zoom;
	const beforeScale = viewportScale(state);
	const p = state.preview;
	const centerX = p.x + p.width / 2;
	const centerY = p.y + p.height / 2;
	const sceneX = (screenX - centerX - state.viewportPanX) / beforeScale;
	const sceneY = (centerY - screenY - state.viewportPanY) / beforeScale;
	state.zoom = clampZoom(state.zoom + delta);
	if (state.zoom !== before) {
		const afterScale = viewportScale(state);
		state.viewportPanX = screenX - centerX - sceneX * afterScale;
		state.viewportPanY = centerY - screenY - sceneY * afterScale;
		state.previewDirty = true;
	}
}

function zoomViewportFromCenter(state: EditorState, delta: number) {
	const p = state.preview;
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2);
}

function screenToScene(state: EditorState, screenX: number, screenY: number): [number, number] {
	const p = state.preview;
	const scale = viewportScale(state);
	const localX = screenX - (p.x + p.width / 2) - state.viewportPanX;
	const localY = (p.y + p.height / 2) - screenY - state.viewportPanY;
	return [localX / scale, localY / scale];
}

function pickNodeAt(state: EditorState, screenX: number, screenY: number) {
	const [sceneX, sceneY] = screenToScene(state, screenX, screenY);
	for (let i = state.order.length; i >= 1; i--) {
		const id = state.order[i - 1];
		const node = state.nodes[id];
		if (node !== undefined && id !== 'root' && node.visible) {
			const dx = sceneX - node.x;
			const dy = sceneY - node.y;
			const radius = node.kind === 'Camera' ? 185 : (node.kind === 'Sprite' ? 82 : 54);
			if ((dx * dx + dy * dy) <= radius * radius) return id;
		}
	}
	return undefined;
}

function handleViewportMouse(state: EditorState, hovered: boolean) {
	if (!hovered) return;
	const spacePressed = Keyboard.isKeyPressed(KeyName.Space);
	const wheel = Mouse.wheel;
	const wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) ? wheel.y : wheel.x;
	if (wheelDelta !== 0) {
		const mouse = ImGui.GetMousePos();
		zoomViewportAt(state, wheelDelta > 0 ? 6 : -6, mouse.x, mouse.y);
	}
	if (ImGui.IsMouseClicked(2)) {
		state.draggingNodeId = undefined;
		state.draggingViewport = true;
		ImGui.ResetMouseDragDelta(2);
	}
	if (ImGui.IsMouseClicked(0)) {
		if (spacePressed) {
			state.draggingNodeId = undefined;
			state.draggingViewport = true;
		} else {
			const mouse = ImGui.GetMousePos();
			const picked = pickNodeAt(state, mouse.x, mouse.y);
			if (picked !== undefined) {
				state.selectedId = picked;
				state.previewDirty = true;
				state.draggingNodeId = picked;
				state.draggingViewport = false;
			} else {
				state.draggingNodeId = undefined;
				state.draggingViewport = true;
			}
		}
		ImGui.ResetMouseDragDelta(0);
	}
	if (ImGui.IsMouseReleased(0) || ImGui.IsMouseReleased(2)) {
		state.draggingNodeId = undefined;
		state.draggingViewport = false;
	}
	if (ImGui.IsMouseDragging(0) || ImGui.IsMouseDragging(2)) {
		const panButton = ImGui.IsMouseDragging(2) ? 2 : 0;
		const delta = ImGui.GetMouseDragDelta(panButton);
		if (delta.x !== 0 || delta.y !== 0) {
			if (state.draggingNodeId !== undefined && panButton === 0) {
				const node = state.nodes[state.draggingNodeId];
				if (node !== undefined) {
					const scale = viewportScale(state);
					node.x += delta.x / scale;
					node.y -= delta.y / scale;
					if (state.snapEnabled) {
						const step = 16;
						node.x = math.floor(node.x / step + 0.5) * step;
						node.y = math.floor(node.y / step + 0.5) * step;
					}
				}
			} else if (state.draggingViewport) {
				state.viewportPanX += delta.x;
				state.viewportPanY -= delta.y;
			}
			ImGui.ResetMouseDragDelta(panButton);
		}
	}
}

function drawViewportToolButton(state: EditorState, tool: ViewportTool, label: string) {
	const active = state.viewportTool === tool;
	if (active) {
		ImGui.PushStyleColor(StyleColor.Button, Color(0xff303642), () => {
			ImGui.PushStyleColor(StyleColor.Text, themeColor, () => {
				if (ImGui.Button(label)) state.viewportTool = tool;
			});
		});
	} else if (ImGui.Button(label)) {
		state.viewportTool = tool;
	}
}

function drawViewport(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '场景' : 'Scene');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Select', 'Select');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Move', 'Move');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Rotate', 'Rotate');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Scale', 'Scale');
	ImGui.SameLine();
	ImGui.TextDisabled('|');
	ImGui.SameLine();
	const [snapChanged, snap] = ImGui.Checkbox(zh ? '吸附' : 'Snap', state.snapEnabled);
	if (snapChanged) state.snapEnabled = snap;
	ImGui.SameLine();
	const [gridChanged, grid] = ImGui.Checkbox(zh ? '网格' : 'Grid', state.showGrid);
	if (gridChanged) { state.showGrid = grid; state.previewDirty = true; }
	ImGui.SameLine();
	if (ImGui.Button(zh ? '居中' : 'Center')) {
		state.viewportPanX = 0;
		state.viewportPanY = 0;
		state.zoom = 100;
		state.previewDirty = true;
	}
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? '当前场景：Main' : 'Scene: Main');
	ImGui.Separator();
	const cursor = ImGui.GetCursorScreenPos();
	const avail = ImGui.GetContentRegionAvail();
	const viewportWidth = math.max(360, avail.x - 8);
	const viewportHeight = math.max(300, avail.y - 38);
	if (math.abs(state.preview.width - viewportWidth) > 1 || math.abs(state.preview.height - viewportHeight) > 1) {
		state.previewDirty = true;
	}
	state.preview.x = cursor.x;
	state.preview.y = cursor.y;
	state.preview.width = viewportWidth;
	state.preview.height = viewportHeight;
	updatePreviewRuntime(state);
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight));
	const hovered = ImGui.IsItemHovered();
	handleViewportMouse(state, hovered);
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8));
	if (ImGui.SmallButton('-##viewport_zoom_out')) zoomViewportFromCenter(state, -10);
	ImGui.SameLine();
	ImGui.PushStyleColor(StyleColor.Text, themeColor, () => {
		if (ImGui.SmallButton(tostring(math.floor(state.zoom)) + '%')) {
			state.zoom = 100;
			state.viewportPanX = 0;
			state.viewportPanY = 0;
			state.previewDirty = true;
		}
	});
	ImGui.SameLine();
	if (ImGui.SmallButton('+##viewport_zoom_in')) zoomViewportFromCenter(state, 10);
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4));
	ImGui.Separator();
	ImGui.TextColored(okColor, zh ? '场景视口' : 'Scene Viewport');
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? '滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。' : 'Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.');
}

function drawInspector(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '属性检查器' : 'Inspector');
	ImGui.Separator();
	const node = state.nodes[state.selectedId];
	if (node === undefined) {
		ImGui.TextDisabled(zh ? '没有选中节点' : 'No node selected');
		return;
	}
	ImGui.Text(iconFor(node.kind) + '  ' + node.kind);
	if (ImGui.InputText('Name', node.nameBuffer, inputTextFlags)) node.name = node.nameBuffer.text;
	let [changed, x, y] = ImGui.DragFloat2('Position', node.x, node.y, 1, -10000, 10000, '%.1f');
	if (changed) { node.x = x; node.y = y; }
	[changed, x, y] = ImGui.DragFloat2('Scale', node.scaleX, node.scaleY, 0.01, -100, 100, '%.2f');
	if (changed) { node.scaleX = x; node.scaleY = y; }
	const [angleChanged, angle] = ImGui.DragFloat('Rotation', node.rotation, 1, -360, 360, '%.1f');
	if (angleChanged) node.rotation = angle;
	const [visibleChanged, visible] = ImGui.Checkbox('Visible', node.visible);
	if (visibleChanged) node.visible = visible;
	ImGui.Separator();
	if (ImGui.InputText('Script', node.scriptBuffer, inputTextFlags)) node.script = node.scriptBuffer.text;
	if (ImGui.Button(zh ? '打开脚本' : 'Open Script')) openScriptForNode(state, node);
	if (node.kind === 'Sprite') {
		ImGui.Separator();
		if (ImGui.InputText('Texture', node.textureBuffer, inputTextFlags)) {
			node.texture = node.textureBuffer.text;
			state.previewDirty = true;
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
		if (ImGui.InputText('Text', node.textBuffer, inputTextFlags)) node.text = node.textBuffer.text;
	} else if (node.kind === 'Camera') {
		ImGui.Separator();
		ImGui.TextDisabled(zh ? 'Camera 显示真实取景框。' : 'Camera shows a real frame in viewport.');
	}
}

function drawConsole(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '控制台' : 'Console');
	ImGui.SameLine();
	ImGui.TextColored(okColor, state.status);
	ImGui.Separator();
	for (const line of state.console) ImGui.TextDisabled(line);
}

function drawVerticalSplitter(id: string, height: number, onDrag: (deltaX: number) => void) {
	ImGui.PushStyleColor(StyleColor.Button, Color(0xff343a44), () => {
		ImGui.PushStyleColor(StyleColor.ButtonHovered, Color(0xff4d5968), () => {
			ImGui.PushStyleColor(StyleColor.ButtonActive, Color(0xffffcc33), () => {
				ImGui.Button('##' + id, Vec2(8, height));
			});
		});
	});
	if (ImGui.IsItemHovered()) {
		ImGui.BeginTooltip(() => ImGui.Text(zh ? '拖动调整面板宽度' : 'Drag to resize panel'));
	}
	if (ImGui.IsItemActive() && ImGui.IsMouseDragging(0)) {
		const delta = ImGui.GetMouseDragDelta(0);
		if (delta.x !== 0) {
			onDrag(delta.x);
			ImGui.ResetMouseDragDelta(0);
		}
	}
}

export function drawEditor(state: EditorState) {
	const size = App.visualSize;
	const margin = 10;
	const nativeFooterSafeArea = 60;
	const windowWidth = math.max(360, size.width - margin * 2);
	const windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea);
	ImGui.SetNextWindowPos(Vec2(margin, margin), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(windowWidth, windowHeight), SetCond.Always);
	ImGui.SetNextWindowBgAlpha(state.mode === 'Script' ? 0.96 : 0.10);
	ImGui.Begin('Dora Visual Editor', mainWindowFlags, () => {
		drawHeader(state);
		const avail = ImGui.GetContentRegionAvail();
		const bottomHeight = math.max(72, math.min(state.bottomHeight, math.floor(avail.y * 0.28)));
		if (state.mode === 'Script') {
			const scriptHeight = math.max(180, avail.y - bottomHeight - 8);
			ImGui.PushStyleColor(StyleColor.ChildBg, panelBg, () => {
				ImGui.BeginChild('ScriptWorkspaceRoot', Vec2(0, scriptHeight), [], noScrollFlags, () => drawScriptPanel(state));
			});
			ImGui.BeginChild('ScriptConsoleDock', Vec2(0, bottomHeight), [], noScrollFlags, () => drawConsole(state));
			return;
		}
		const mainHeight = math.max(160, avail.y - bottomHeight - 10);
		const availableWidth = math.max(320, avail.x);
		const splitterWidth = 8;
		const compactLayout = availableWidth < 760;
		const minLeftWidth = compactLayout ? 110 : 170;
		const minRightWidth = compactLayout ? 130 : 220;
		const minCenterWidth = compactLayout ? 80 : 180;
		const sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth);
		if (sideBudget <= minLeftWidth + minRightWidth) {
			state.leftWidth = math.max(1, math.floor(sideBudget * 0.45));
			state.rightWidth = math.max(1, sideBudget - state.leftWidth);
		} else {
			state.leftWidth = math.max(minLeftWidth, state.leftWidth);
			state.rightWidth = math.max(minRightWidth, state.rightWidth);
			if (state.leftWidth + state.rightWidth > sideBudget) {
				const ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth);
				state.leftWidth = math.max(minLeftWidth, math.floor(sideBudget * ratio));
				state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth);
			}
			state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth);
			state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth);
		}
		const centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2);
		const leftTopHeight = math.floor(mainHeight * 0.58);
		const leftBottomHeight = mainHeight - leftTopHeight - 8;
		const clampPanelWidth = function(this: void, value: number, minValue: number, maxValue: number) {
			const safeMax = math.max(1, maxValue);
			const safeMin = math.min(minValue, safeMax);
			return math.max(safeMin, math.min(value, safeMax));
		};
		const resizeSidePanels = function(this: void, deltaX: number, side: 'left' | 'right') {
			if (side === 'left') {
				state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth);
			} else {
				state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth);
			}
		};

		ImGui.BeginChild('LeftDock', Vec2(state.leftWidth, mainHeight), [], noScrollFlags, () => {
			ImGui.BeginChild('SceneDock', Vec2(0, leftTopHeight), [], noScrollFlags, () => drawScenePanel(state));
			ImGui.BeginChild('AssetDock', Vec2(0, leftBottomHeight), [], noScrollFlags, () => drawAssetsPanel(state));
		});
		ImGui.SameLine(0, 0);
		drawVerticalSplitter('LeftSplitter', mainHeight, (deltaX) => resizeSidePanels(deltaX, 'left'));
		ImGui.SameLine(0, 0);
		ImGui.PushStyleColor(StyleColor.ChildBg, transparent, () => {
			ImGui.BeginChild('CenterDock', Vec2(centerWidth, mainHeight), [], noScrollFlags, () => {
				if (state.mode === 'Script') drawScriptPanel(state); else drawViewport(state);
			});
		});
		ImGui.SameLine(0, 0);
		drawVerticalSplitter('RightSplitter', mainHeight, (deltaX) => resizeSidePanels(deltaX, 'right'));
		ImGui.SameLine(0, 0);
		ImGui.BeginChild('RightDock', Vec2(state.rightWidth, mainHeight), [], noScrollFlags, () => drawInspector(state));
		ImGui.BeginChild('BottomConsoleDock', Vec2(0, bottomHeight), [], noScrollFlags, () => drawConsole(state));
	});
	drawGamePreviewWindow(state);
}

export function drawRuntimeError(message: string) {
	const size = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(10, 10), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(math.max(320, size.width - 20), math.max(220, size.height - 20)), SetCond.Always);
	ImGui.Begin('Dora Visual Editor Error', mainWindowFlags, () => {
		ImGui.TextColored(warnColor, zh ? 'Dora Visual Editor 运行时错误' : 'Dora Visual Editor Runtime Error');
		ImGui.Separator();
		ImGui.TextWrapped(message || 'unknown error');
	});
}
