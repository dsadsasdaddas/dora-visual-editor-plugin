import { Color, Content, Director, DrawNode, Label, Node, Path, RenderTarget, Sprite, Vec2 } from 'Dora';
import * as ImGui from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { okColor, viewportBgColor } from 'Script/Tools/SceneEditor/Theme';
import { pushConsole, workspacePath, zh } from 'Script/Tools/SceneEditor/Model';

declare function load(code: string, chunkname?: string): LuaMultiReturn<[(() => unknown) | undefined, string | undefined]>;
declare function pcall(fn: () => unknown): LuaMultiReturn<[boolean, unknown]>;
declare function type(value: unknown): string;

type GameMainModule = {
	start?: (scene: Node.Type, nodes: Record<string, Node.Type>, world: Node.Type) => unknown;
};

let playTarget: any = undefined;
let playTargetWidth = 0;
let playTargetHeight = 0;

function makeGameBackground(width: number, height: number) {
	const hw = width / 2;
	const hh = height / 2;
	const bg = DrawNode();
	bg.drawPolygon([
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	], viewportBgColor, 1.4, okColor);
	return bg;
}

function makeFallbackRect(width: number, height: number, color: Color.Type) {
	const hw = width / 2;
	const hh = height / 2;
	const rect = DrawNode();
	rect.drawSegment(Vec2(-hw, -hh), Vec2(hw, -hh), 1, color);
	rect.drawSegment(Vec2(hw, -hh), Vec2(hw, hh), 1, color);
	rect.drawSegment(Vec2(hw, hh), Vec2(-hw, hh), 1, color);
	rect.drawSegment(Vec2(-hw, hh), Vec2(-hw, -hh), 1, color);
	return rect;
}

function createPlayVisual(item: SceneNodeData) {
	if (item.kind === 'Sprite') {
		if (item.texture !== '') {
			const sprite = Sprite(item.texture);
			if (sprite !== undefined) return sprite;
		}
		return makeFallbackRect(128, 96, Color(0xaa72a6c8));
	}
	if (item.kind === 'Label') {
		const label = Label('sarasa-mono-sc-regular', 32);
		if (label !== undefined) {
			label.text = item.text || 'Label';
			return label;
		}
		return makeFallbackRect(180, 56, Color(0xaad6b13f));
	}
	return Node();
}

function applyTransform(target: Node.Type, item: SceneNodeData) {
	target.x = item.x;
	target.y = item.y;
	target.scaleX = item.scaleX;
	target.scaleY = item.scaleY;
	target.angle = item.rotation;
	target.visible = item.visible;
	target.tag = item.name;
}

function firstCameraId(state: EditorState) {
	for (const id of state.order) {
		const item = state.nodes[id];
		if (item !== undefined && item.kind === 'Camera' && item.visible) return id;
	}
	return undefined;
}

function loadScriptText(scriptPath: string) {
	if (scriptPath === '') return '';
	const projectPath = workspacePath(scriptPath);
	if (Content.exist(projectPath)) return Content.load(projectPath) || '';
	if (Content.exist(scriptPath)) return Content.load(scriptPath) || '';
	return '';
}

function runNodeScript(state: EditorState, item: SceneNodeData, runtimeNode: Node.Type) {
	const scriptText = loadScriptText(item.script);
	if (scriptText === '') return;
	const [chunk, loadError] = load(scriptText, item.script);
	if (chunk === undefined) {
		pushConsole(state, (zh ? '脚本加载失败：' : 'Script load failed: ') + item.script + ' ' + tostring(loadError || ''));
		return;
	}
	const [ok, result] = pcall(chunk);
	if (!ok) {
		pushConsole(state, (zh ? '脚本执行失败：' : 'Script failed: ') + item.script + ' ' + tostring(result));
		return;
	}
	if (type(result) === 'function') {
		const behavior = result as (node: Node.Type, scene: Node.Type, nodes: Record<string, Node.Type>) => unknown;
		const [behaviorOk, behaviorError] = pcall(() => behavior(runtimeNode, state.playContent || runtimeNode, state.playRuntimeNodes));
		if (!behaviorOk) pushConsole(state, (zh ? '脚本绑定失败：' : 'Script attach failed: ') + item.script + ' ' + tostring(behaviorError));
	}
}

function defaultGameMainLua() {
	return '-- Game main script\n'
		+ '-- Auto-created by Dora Visual Editor.\n'
		+ 'local _ENV = Dora\n\n'
		+ 'return {\n'
		+ '\tstart = function(scene, nodes, world)\n'
		+ '\t\tlocal player = nil\n'
		+ '\t\tfor _, node in pairs(nodes) do\n'
		+ '\t\t\tlocal tag = tostring(node.tag or "")\n'
		+ '\t\t\tif node ~= scene and player == nil and string.find(tag, "Camera") == nil then player = node end\n'
		+ '\t\tend\n'
		+ '\t\tif player == nil then return end\n'
		+ '\t\tscene:schedule(function(deltaTime)\n'
		+ '\t\t\tlocal speed = 220\n'
		+ '\t\t\tif Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") then player.x = player.x - speed * deltaTime end\n'
		+ '\t\t\tif Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") then player.x = player.x + speed * deltaTime end\n'
		+ '\t\t\treturn false\n'
		+ '\t\tend)\n'
		+ '\tend\n'
		+ '}\n';
}

function ensureGameMainScript(state: EditorState) {
	const scriptPath = state.gameScript !== '' ? state.gameScript : 'Script/Main.lua';
	state.gameScript = scriptPath;
	state.gameScriptBuffer.text = scriptPath;
	const file = workspacePath(scriptPath);
	if (!Content.exist(file)) {
		Content.mkdir(Path.getPath(file));
		Content.save(file, defaultGameMainLua());
	}
}

function runGameMain(state: EditorState) {
	const scriptPath = state.gameScript !== '' ? state.gameScript : 'Script/Main.lua';
	const scriptText = loadScriptText(scriptPath);
	if (scriptText === '') return;
	const [chunk, loadError] = load(scriptText, scriptPath);
	if (chunk === undefined) {
		pushConsole(state, (zh ? '主脚本加载失败：' : 'Main script load failed: ') + scriptPath + ' ' + tostring(loadError || ''));
		return;
	}
	const [ok, result] = pcall(chunk);
	if (!ok) {
		pushConsole(state, (zh ? '主脚本执行失败：' : 'Main script failed: ') + scriptPath + ' ' + tostring(result));
		return;
	}
	let start: ((scene: Node.Type, nodes: Record<string, Node.Type>, world: Node.Type) => unknown) | undefined = undefined;
	if (type(result) === 'function') {
		start = result as (scene: Node.Type, nodes: Record<string, Node.Type>, world: Node.Type) => unknown;
	} else if (type(result) === 'table') {
		const module = result as GameMainModule;
		if (module.start !== undefined) start = module.start;
	}
	const scene = state.playContent;
	const world = state.playWorld;
	if (start !== undefined && scene !== undefined && world !== undefined) {
		const entry = start;
		const [startOk, startError] = pcall(() => entry(scene, state.playRuntimeNodes, world));
		if (!startOk) pushConsole(state, (zh ? '主脚本启动失败：' : 'Main script start failed: ') + tostring(startError));
	}
}

function clearPlayRuntime(state: EditorState) {
	if (state.playRoot !== undefined) {
		state.playRoot.removeFromParent(true);
		state.playRoot = undefined;
	}
	state.playWorld = undefined;
	state.playContent = undefined;
	state.playRuntimeNodes = {};
	state.playRuntimeLabels = {};
	state.isPlaying = false;
	state.playDirty = true;
}

export function stopPlay(state: EditorState) {
	clearPlayRuntime(state);
	state.status = zh ? '游戏预览已停止' : 'Game preview stopped';
	pushConsole(state, state.status);
}

export function startPlay(state: EditorState) {
	clearPlayRuntime(state);
	ensureGameMainScript(state);
	state.isPlaying = true;
	state.gameWindowOpen = true;
	state.playDirty = true;
	state.status = zh ? '游戏预览运行中' : 'Game preview running';
	pushConsole(state, state.status);
}

function gameWidthOf(state: EditorState) {
	return math.max(160, math.floor(state.gameWidth));
}

function gameHeightOf(state: EditorState) {
	return math.max(120, math.floor(state.gameHeight));
}

function rebuildPlayRuntime(state: EditorState) {
	const width = gameWidthOf(state);
	const height = gameHeightOf(state);
	state.playRoot = Node();
	state.playRoot.tag = '__DoraImGuiGamePreview__';
	state.playRoot.visible = false;
	state.playRuntimeNodes = {};
	state.playRuntimeLabels = {};
	Director.entry.addChild(state.playRoot);

	const background = makeGameBackground(width, height);
	background.x = width / 2;
	background.y = height / 2;
	state.playRoot.addChild(background);
	const world = Node();
	state.playWorld = world;
	world.x = width / 2;
	world.y = height / 2;
	state.playRoot.addChild(world);
	const content = Node();
	state.playContent = content;
	world.addChild(content);
	state.playRuntimeNodes.root = content;

	for (const id of state.order) {
		const item = state.nodes[id];
		if (item !== undefined && id !== 'root') {
			const runtime = createPlayVisual(item);
			applyTransform(runtime, item);
			state.playRuntimeNodes[id] = runtime;
			if (item.kind === 'Label') state.playRuntimeLabels[id] = runtime;
			const parent = state.playRuntimeNodes[item.parentId || 'root'] || content;
			parent.addChild(runtime);
		}
	}

	const cameraId = firstCameraId(state);
	const cameraNode = cameraId !== undefined ? state.playRuntimeNodes[cameraId] : undefined;
	const updateCamera = function(this: void) {
		if (cameraNode !== undefined) {
			world.x = width / 2;
			world.y = height / 2;
			world.angle = -cameraNode.angle;
			world.scaleX = cameraNode.scaleX !== 0 ? 1 / cameraNode.scaleX : 1;
			world.scaleY = cameraNode.scaleY !== 0 ? 1 / cameraNode.scaleY : 1;
			content.x = -cameraNode.x;
			content.y = -cameraNode.y;
		} else {
			world.x = width / 2;
			world.y = height / 2;
			world.angle = 0;
			world.scaleX = 1;
			world.scaleY = 1;
			content.x = 0;
			content.y = 0;
		}
	};
	updateCamera();
	world.schedule(() => {
		updateCamera();
		return false;
	});

	for (const id of state.order) {
		const item = state.nodes[id];
		const runtime = state.playRuntimeNodes[id];
		if (item !== undefined && runtime !== undefined) runNodeScript(state, item, runtime);
	}
	runGameMain(state);
	state.playDirty = false;
}

function ensurePlayTarget(state: EditorState) {
	const width = gameWidthOf(state);
	const height = gameHeightOf(state);
	if (playTarget === undefined || playTargetWidth !== width || playTargetHeight !== height) {
		playTarget = RenderTarget(width, height);
		playTargetWidth = width;
		playTargetHeight = height;
	}
	return playTarget;
}

function renderPlayTarget(state: EditorState) {
	if (!state.isPlaying) return;
	if (state.playDirty || state.playRoot === undefined) rebuildPlayRuntime(state);
	const target = ensurePlayTarget(state);
	if (state.playRoot !== undefined) {
		state.playRoot.visible = true;
		target.renderWithClear(state.playRoot, Color(0xff15181f));
		state.playRoot.visible = false;
	}
}

export function drawGamePreviewWindow(state: EditorState) {
	if (!state.isPlaying) return;
	renderPlayTarget(state);
	if (playTarget === undefined) return;
	ImGui.SetNextWindowSize(Vec2(720, 480), 'FirstUseEver');
	ImGui.Begin(zh ? '游戏预览' : 'Game Preview', () => {
		const avail = ImGui.GetContentRegionAvail();
		const width = gameWidthOf(state);
		const height = gameHeightOf(state);
		const scale = math.max(0.1, math.min(avail.x / width, avail.y / height));
		const displayWidth = width * scale;
		const displayHeight = height * scale;
		ImGui.TextDisabled((zh ? '运行尺寸：' : 'Game Size: ') + tostring(width) + ' x ' + tostring(height));
		ImGui.ImageTexture(playTarget.texture, Vec2(displayWidth, displayHeight));
	});
}
