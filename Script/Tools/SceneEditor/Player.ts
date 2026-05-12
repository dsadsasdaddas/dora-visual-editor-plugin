import { App, ClipNode, Color, Content, Director, DrawNode, Label, Node, Path, Sprite, Vec2 } from 'Dora';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/Types';
import { okColor, viewportBgColor } from 'Script/Tools/SceneEditor/Theme';
import { pushConsole, zh } from 'Script/Tools/SceneEditor/Model';

declare function load(code: string, chunkname?: string): LuaMultiReturn<[(() => unknown) | undefined, string | undefined]>;
declare function pcall(fn: () => unknown): LuaMultiReturn<[boolean, unknown]>;
declare function type(value: unknown): string;


function worldPointFromScreen(screenX: number, screenY: number): [number, number] {
	const size = App.visualSize;
	return [screenX - size.width / 2, size.height / 2 - screenY];
}

function makeClipStencil(width: number, height: number) {
	const hw = width / 2;
	const hh = height / 2;
	const stencil = DrawNode();
	stencil.drawPolygon([
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	], Color(0xffffffff), 0, Color());
	return stencil;
}

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

function firstCamera(state: EditorState) {
	for (const id of state.order) {
		const item = state.nodes[id];
		if (item !== undefined && item.kind === 'Camera' && item.visible) return item;
	}
	return undefined;
}

function loadNodeScript(item: SceneNodeData) {
	if (item.script === '') return '';
	const writablePath = Path(Content.writablePath, item.script);
	if (Content.exist(writablePath)) return Content.load(writablePath) || '';
	if (Content.exist(item.script)) return Content.load(item.script) || '';
	return '';
}

function runNodeScript(state: EditorState, item: SceneNodeData, runtimeNode: Node.Type) {
	const scriptText = loadNodeScript(item);
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
	state.isPlaying = true;
	state.gameWindowOpen = true;
	state.playDirty = true;
	state.status = zh ? '游戏预览运行中' : 'Game preview running';
	pushConsole(state, state.status);
}

function rebuildPlayRuntime(state: EditorState) {
	if (state.playRoot === undefined) {
		state.playRoot = Node();
		state.playRoot.tag = '__DoraImGuiGamePreview__';
		Director.entry.addChild(state.playRoot);
	}
	state.playRoot.removeAllChildren(true);
	state.playRuntimeNodes = {};
	state.playRuntimeLabels = {};

	const renderScale = App.devicePixelRatio || 1;
	const width = math.max(160, state.playViewport.width * renderScale);
	const height = math.max(120, state.playViewport.height * renderScale);
	const clip = ClipNode(makeClipStencil(width, height));
	clip.alphaThreshold = 0.01;
	state.playRoot.addChild(clip);
	clip.addChild(makeGameBackground(width, height));

	const world = Node();
	state.playWorld = world;
	clip.addChild(world);
	const content = Node();
	state.playContent = content;
	world.addChild(content);
	state.playRuntimeNodes.root = content;

	const camera = firstCamera(state);
	if (camera !== undefined) {
		world.x = -camera.x;
		world.y = -camera.y;
		world.angle = -camera.rotation;
	}

	for (const id of state.order) {
		const item = state.nodes[id];
		if (item !== undefined && id !== 'root' && item.kind !== 'Camera') {
			const runtime = createPlayVisual(item);
			applyTransform(runtime, item);
			state.playRuntimeNodes[id] = runtime;
			if (item.kind === 'Label') state.playRuntimeLabels[id] = runtime;
			const parent = state.playRuntimeNodes[item.parentId || 'root'] || content;
			parent.addChild(runtime);
		}
	}
	for (const id of state.order) {
		const item = state.nodes[id];
		const runtime = state.playRuntimeNodes[id];
		if (item !== undefined && runtime !== undefined) {
			runNodeScript(state, item, runtime);
		}
	}
	state.playDirty = false;
}

function updatePlayRuntime(state: EditorState) {
	if (!state.isPlaying) return;
	if (state.playDirty || state.playRoot === undefined) rebuildPlayRuntime(state);
	const p = state.playViewport;
	const [cx, cy] = worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2);
	if (state.playRoot !== undefined) {
		state.playRoot.x = cx;
		state.playRoot.y = cy;
	}
}


export function drawGamePreviewWindow(state: EditorState) {
	if (!state.isPlaying) return;
	const p = state.preview;
	if (math.abs(state.playViewport.x - p.x) > 1 || math.abs(state.playViewport.y - p.y) > 1
		|| math.abs(state.playViewport.width - p.width) > 1 || math.abs(state.playViewport.height - p.height) > 1) {
		state.playViewport.x = p.x;
		state.playViewport.y = p.y;
		state.playViewport.width = p.width;
		state.playViewport.height = p.height;
		state.playDirty = true;
	}
	updatePlayRuntime(state);
}
