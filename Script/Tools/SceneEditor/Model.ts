import { App, Buffer, Content, Path, emit, json } from 'Dora';
import { EditorState, SceneNodeData, SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';

type SceneNodeJson = {
	id?: unknown;
	kind?: unknown;
	name?: unknown;
	parentId?: unknown;
	x?: unknown;
	y?: unknown;
	scaleX?: unknown;
	scaleY?: unknown;
	rotation?: unknown;
	visible?: unknown;
	texture?: unknown;
	text?: unknown;
	script?: unknown;
	followTargetId?: unknown;
	followOffsetX?: unknown;
	followOffsetY?: unknown;
};

type SceneJson = {
	gameWidth?: unknown;
	gameHeight?: unknown;
	gameScript?: unknown;
	nodes?: SceneNodeJson[];
};

const [localeMatch] = string.match(App.locale, '^zh');
export const zh = localeMatch !== undefined;


const importedAssetRoot = 'Imported';
const importedAssetRootEntry = importedAssetRoot + '/';

function isPathInside(path: string, root: string) {
	const cleanPath = normalizeSlash(path);
	const cleanRoot = normalizeSlash(root);
	return cleanPath === cleanRoot || string.sub(cleanPath, 1, string.len(cleanRoot) + 1) === cleanRoot + '/';
}

function isProjectRootDir(dir: string) {
	if (dir === '' || !Content.exist(dir) || !Content.isdir(dir)) return false;
	for (const file of Content.getFiles(dir)) {
		if (string.lower(Path.getName(file)) === 'init') return true;
	}
	const agentDir = Path(dir, '.agent');
	return Content.exist(agentDir) && Content.isdir(agentDir);
}

function detectWorkspaceRoot() {
	for (const searchPath of Content.searchPaths) {
		let candidate = searchPath;
		if (Path.getFilename(candidate) === 'Script') candidate = Path.getPath(candidate);
		if (candidate !== Content.writablePath && isPathInside(candidate, Content.writablePath) && isProjectRootDir(candidate)) {
			return candidate;
		}
	}
	return Content.writablePath;
}

export function workspaceRoot() {
	return detectWorkspaceRoot();
}

export function workspacePath(path: string) {
	return Path(workspaceRoot(), path);
}

export function makeBuffer(text: string, size: number) {
	const buffer = Buffer(size);
	buffer.text = text;
	return buffer;
}

export function createEditorState(): EditorState {
	Content.addSearchPath(workspaceRoot());
	Content.mkdir(workspacePath(importedAssetRoot));
	const state: EditorState = {
		nextId: 0,
		selectedId: 'root',
		mode: '2D',
		zoom: 100,
		showGrid: true,
		snapEnabled: false,
		viewportTool: 'Select',
		leftWidth: 280,
		rightWidth: 340,
		bottomHeight: 132,
		gameWidth: 960,
		gameHeight: 540,
		gameScript: 'Script/Main.lua',
		gameScriptBuffer: makeBuffer('Script/Main.lua', 256),
		status: zh ? 'Dora Visual Editor 已加载' : 'Dora Visual Editor loaded',
		console: [zh ? '真实 Dora Viewport 已启用。' : 'Real Dora viewport enabled.'],
		nodes: {},
		order: [],
		preview: { x: 0, y: 0, width: 640, height: 360 },
		previewDirty: true,
		runtimeNodes: {},
		runtimeLabels: {},
		isPlaying: false,
		gameWindowOpen: false,
		playViewport: { x: 0, y: 0, width: 960, height: 540 },
		playDirty: true,
		playRuntimeNodes: {},
		playRuntimeLabels: {},
		assetImportBuffer: makeBuffer(importedAssetRoot + '/new.png', 256),
		scriptPathBuffer: makeBuffer('', 256),
		scriptContentBuffer: makeBuffer('', 8192),
		selectedAsset: '',
		assets: [],
		viewportPanX: 0,
		viewportPanY: 0,
		draggingViewport: false,
	};
	refreshImportedAssets(state);
	return state;
}

export function pushConsole(state: EditorState, message: string) {
	state.console.push(message);
	if (state.console.length > 7) {
		table.remove(state.console, 1);
	}
}

export function iconFor(kind: SceneNodeKind) {
	if (kind === 'Sprite') return '▣';
	if (kind === 'Label') return 'T';
	if (kind === 'Camera') return '◉';
	return '○';
}

export function lowerExt(path: string) {
	const ext = Path.getExt(path || '') || '';
	return string.lower(ext);
}

export function isTextureAsset(path: string) {
	const ext = lowerExt(path);
	return ext === 'png' || ext === 'jpg' || ext === 'jpeg' || ext === 'bmp' || ext === 'gif' || ext === 'webp' || ext === 'ktx' || ext === 'pvr' || ext === 'clip';
}

export function isScriptAsset(path: string) {
	const ext = lowerExt(path);
	return ext === 'lua' || ext === 'ts' || ext === 'tsx' || ext === 'yue' || ext === 'js' || ext === 'json';
}

export function isFolderAsset(path: string) {
	return path !== '' && string.sub(path, string.len(path), string.len(path)) === '/';
}

function hasAsset(state: EditorState, asset: string) {
	for (const item of state.assets) {
		if (item === asset) return true;
	}
	return false;
}

function rememberAsset(state: EditorState, asset: string) {
	if (asset === '') return;
	if (!hasAsset(state, asset)) state.assets.push(asset);
}

function sortAssets(state: EditorState) {
	table.sort(state.assets, (a, b) => {
		const aFolder = isFolderAsset(a);
		const bFolder = isFolderAsset(b);
		if (aFolder === bFolder) return a < b;
		return aFolder;
	});
}

function normalizeSlash(path: string) {
	let [result] = string.gsub(path, '\\', '/');
	let [found] = string.find(result, '//');
	while (found !== undefined) {
		[result] = string.gsub(result, '//', '/');
		[found] = string.find(result, '//');
	}
	return result;
}

function stripFolderPrefix(folder: string, path: string) {
	const cleanFolder = normalizeSlash(folder);
	const cleanPath = normalizeSlash(path);
	if (string.sub(cleanPath, 1, string.len(cleanFolder)) === cleanFolder) {
		let rest = string.sub(cleanPath, string.len(cleanFolder) + 1);
		if (string.sub(rest, 1, 1) === '/') rest = string.sub(rest, 2);
		return rest;
	}
	return Path.getFilename(path);
}

function refreshAssetSearchPath(importedPath?: string) {
	Content.addSearchPath(workspaceRoot());
	Content.addSearchPath(workspacePath(importedAssetRoot));
	if (importedPath !== undefined && importedPath !== '') {
		const importedFolder = Path.getPath(importedPath);
		if (importedFolder !== '') Content.addSearchPath(workspacePath(importedFolder));
	}
	Content.clearPathCache();
}

export function refreshImportedAssets(state: EditorState) {
	const importedAbsolutePath = workspacePath(importedAssetRoot);
	Content.mkdir(importedAbsolutePath);
	refreshAssetSearchPath(importedAssetRoot);
	rememberAsset(state, importedAssetRootEntry);
	for (const file of Content.getAllFiles(importedAbsolutePath)) {
		const asset = normalizeSlash(Path(importedAssetRoot, file));
		rememberAsset(state, asset);
	}
	sortAssets(state);
}

function notifyWebIDEFileAdded(workspaceRelativePath: string) {
	const fullPath = workspacePath(workspaceRelativePath);
	const [payload] = json.encode({
		name: 'UpdateFile',
		file: fullPath,
		exists: true,
		content: '',
	});
	if (payload !== undefined) {
		emit('AppWS', 'Send', payload);
	}
}

function copyFileToImported(srcPath: string, importedPath: string) {
	const target = workspacePath(importedPath);
	Content.mkdir(Path.getPath(target));
	if (srcPath === target || Content.copy(srcPath, target)) {
		refreshAssetSearchPath(importedPath);
		notifyWebIDEFileAdded(importedPath);
		return importedPath;
	}
	Content.clearPathCache();
	return undefined;
}

export function addAssetPath(state: EditorState, path?: string, importedPath?: string) {
	if (path === undefined || path === '') return undefined;
	if (Content.isdir(path)) {
		return addAssetFolder(state, path);
	}
	const asset = copyFileToImported(path, importedPath || Path(importedAssetRoot, Path.getFilename(path)));
	if (asset === undefined) {
		state.status = (zh ? '导入失败：' : 'Import failed: ') + path;
		pushConsole(state, state.status);
		return undefined;
	}
	rememberAsset(state, asset);
	rememberAsset(state, importedAssetRootEntry);
	refreshImportedAssets(state);
	state.selectedAsset = asset;
	state.status = (zh ? '已加入资源：' : 'Asset added: ') + asset;
	pushConsole(state, state.status);
	return asset;
}

export function addAssetFolder(state: EditorState, folderPath: string) {
	if (folderPath === '') return undefined;
	const folderName = Path.getName(folderPath) || 'Folder';
	const rootAsset = Path(importedAssetRoot, folderName) + '/';
	rememberAsset(state, importedAssetRootEntry);
	rememberAsset(state, rootAsset);
	let added = 0;
	for (const file of Content.getAllFiles(folderPath)) {
		const absoluteFile = Content.exist(file) ? file : Path(folderPath, file);
		const relativeFile = stripFolderPrefix(folderPath, absoluteFile);
		const importedFile = Path(importedAssetRoot, folderName, relativeFile);
		const asset = copyFileToImported(absoluteFile, importedFile);
		if (asset !== undefined) {
			rememberAsset(state, asset);
			added += 1;
		}
	}
	refreshImportedAssets(state);
	state.selectedAsset = rootAsset;
	state.status = (zh ? '已加入文件夹：' : 'Folder imported: ') + folderName + ' (' + tostring(added) + ')';
	pushConsole(state, state.status);
	return rootAsset;
}

export function importFileDialog(state: EditorState) {
	App.openFileDialog(false, function(this: void, path: string) {
		addAssetPath(state, path);
	});
}

export function importFolderDialog(state: EditorState) {
	App.openFileDialog(true, function(this: void, path: string) {
		addAssetFolder(state, path);
	});
}

function newNodeId(state: EditorState, kind: SceneNodeKind): string {
	state.nextId += 1;
	return string.lower(kind) + '-' + (tostring(state.nextId) || '0');
}

export function addNode(state: EditorState, kind: SceneNodeKind, name: string, parentId?: string) {
	let resolvedParentId = 'root';
	if (kind === 'Root') {
		resolvedParentId = '';
	} else if (parentId !== undefined && parentId !== '') {
		resolvedParentId = parentId;
	}
	const id = kind === 'Root' ? 'root' : newNodeId(state, kind);
	const index = state.nextId;
	const node: SceneNodeData = {
		id,
		kind,
		name,
		parentId: resolvedParentId,
		children: [],
		x: (kind === 'Root' || kind === 'Camera') ? 0 : ((index % 5) - 2) * 70,
		y: (kind === 'Root' || kind === 'Camera') ? 0 : (math.floor(index / 5) % 4) * 55,
		scaleX: 1,
		scaleY: 1,
		rotation: 0,
		visible: true,
		texture: '',
		text: kind === 'Label' ? 'Label' : '',
		script: '',
		followTargetId: '',
		followOffsetX: 0,
		followOffsetY: 0,
		nameBuffer: makeBuffer(name, 128),
		textureBuffer: makeBuffer('', 256),
		textBuffer: makeBuffer(kind === 'Label' ? 'Label' : '', 256),
		scriptBuffer: makeBuffer('', 256),
		followTargetBuffer: makeBuffer('', 128),
	};
	state.nodes[id] = node;
	state.order.push(id);
	const parent = resolvedParentId !== '' ? state.nodes[resolvedParentId] : undefined;
	if (id !== 'root' && parent !== undefined) {
		parent.children.push(id);
	}
	return node;
}

function sceneNodeKind(value: unknown): SceneNodeKind {
	if (value === 'Root' || value === 'Node' || value === 'Sprite' || value === 'Label' || value === 'Camera') {
		return value;
	}
	return 'Node';
}

function stringValue(value: unknown, fallback: string) {
	return type(value) === 'string' ? value as string : fallback;
}

function numberValue(value: unknown, fallback: number) {
	if (type(value) !== 'number' && type(value) !== 'string') return fallback;
	const parsed = tonumber(value);
	return parsed !== undefined ? parsed : fallback;
}

function booleanValue(value: unknown, fallback: boolean) {
	return type(value) === 'boolean' ? value as boolean : fallback;
}

function updateNextIdFromNodeId(state: EditorState, id: string) {
	const [digits] = string.match(id, '%-(%d+)$');
	if (digits !== undefined) {
		const value = tonumber(digits);
		if (value !== undefined && value > state.nextId) state.nextId = value;
	}
}

export function loadSceneFromFile(state: EditorState, file: string) {
	if (!Content.exist(file)) return false;
	const [decoded] = json.decode(Content.load(file));
	const data = decoded as unknown as SceneJson | undefined;
	if (data === undefined) return false;
	const rawNodes = data.nodes;
	if (rawNodes === undefined) return false;
	state.gameWidth = math.max(160, math.min(8192, numberValue(data.gameWidth, state.gameWidth || 960)));
	state.gameHeight = math.max(120, math.min(8192, numberValue(data.gameHeight, state.gameHeight || 540)));
	state.gameScript = stringValue(data.gameScript, state.gameScript || 'Script/Main.lua');
	state.gameScriptBuffer.text = state.gameScript;

	state.nodes = {};
	state.order = [];
	state.runtimeNodes = {};
	state.runtimeLabels = {};
	state.playRuntimeNodes = {};
	state.playRuntimeLabels = {};
	state.nextId = 0;

	for (const raw of rawNodes) {
		const kind = sceneNodeKind(raw.kind);
		const id = stringValue(raw.id, kind === 'Root' ? 'root' : string.lower(kind) + '-' + tostring(state.nextId + 1));
		const name = stringValue(raw.name, kind === 'Root' ? 'MainScene' : kind);
		const texture = stringValue(raw.texture, '');
		const text = stringValue(raw.text, kind === 'Label' ? 'Label' : '');
		const script = stringValue(raw.script, '');
		const followTargetId = stringValue(raw.followTargetId, '');
		const followOffsetX = numberValue(raw.followOffsetX, 0);
		const followOffsetY = numberValue(raw.followOffsetY, 0);
		const parentId = id === 'root' ? undefined : stringValue(raw.parentId, 'root');
		const node: SceneNodeData = {
			id,
			kind,
			name,
			parentId,
			children: [],
			x: numberValue(raw.x, 0),
			y: numberValue(raw.y, 0),
			scaleX: numberValue(raw.scaleX, 1),
			scaleY: numberValue(raw.scaleY, 1),
			rotation: numberValue(raw.rotation, 0),
			visible: booleanValue(raw.visible, true),
			texture,
			text,
			script,
			followTargetId,
			followOffsetX,
			followOffsetY,
			nameBuffer: makeBuffer(name, 128),
			textureBuffer: makeBuffer(texture, 256),
			textBuffer: makeBuffer(text, 256),
			scriptBuffer: makeBuffer(script, 256),
			followTargetBuffer: makeBuffer(followTargetId, 128),
		};
		state.nodes[id] = node;
		state.order.push(id);
		updateNextIdFromNodeId(state, id);
	}

	if (state.nodes.root === undefined) {
		addNode(state, 'Root', 'MainScene');
	}
	for (const id of state.order) {
		if (id === 'root') continue;
		const node = state.nodes[id];
		if (node === undefined) continue;
		if (node.parentId === undefined || state.nodes[node.parentId] === undefined) {
			node.parentId = 'root';
		}
		state.nodes[node.parentId].children.push(id);
	}
	state.selectedId = state.nodes.root !== undefined ? 'root' : (state.order[0] || 'root');
	state.previewDirty = true;
	state.playDirty = true;
	state.status = zh ? '已加载场景' : 'Scene loaded';
	pushConsole(state, state.status);
	return true;
}

function removeFromOrder(state: EditorState, id: string) {
	for (let i = state.order.length; i >= 1; i--) {
		if (state.order[i - 1] === id) {
			table.remove(state.order, i);
		}
	}
}

export function deleteNode(state: EditorState, id: string) {
	if (id === 'root') {
		state.status = zh ? '根节点不能删除' : 'Root cannot be deleted';
		return;
	}
	const node = state.nodes[id];
	if (node === undefined) return;
	for (let i = node.children.length; i >= 1; i--) {
		deleteNode(state, node.children[i - 1]);
	}
	const parent = node.parentId !== undefined ? state.nodes[node.parentId] : undefined;
	if (parent !== undefined) {
		for (let i = parent.children.length; i >= 1; i--) {
			if (parent.children[i - 1] === id) table.remove(parent.children, i);
		}
	}
	delete state.nodes[id];
	removeFromOrder(state, id);
	state.selectedId = 'root';
	state.draggingNodeId = undefined;
	state.previewDirty = true;
	state.playDirty = true;
	state.status = zh ? '已删除节点' : 'Node deleted';
	pushConsole(state, state.status);
}

function worldPositionOf(state: EditorState, id: string): [number, number] {
	let x = 0;
	let y = 0;
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = state.nodes[id];
	while (cursor !== undefined) {
		if (visited[cursor.id]) break;
		visited[cursor.id] = true;
		x += cursor.x;
		y += cursor.y;
		if (cursor.parentId === undefined || cursor.parentId === cursor.id) break;
		cursor = cursor.parentId !== undefined ? state.nodes[cursor.parentId] : undefined;
	}
	return [x, y];
}

export function reparentNode(state: EditorState, id: string, newParentId: string) {
	if (id === 'root') return false;
	const node = state.nodes[id];
	const newParent = state.nodes[newParentId];
	if (node === undefined || newParent === undefined || node.parentId === newParentId) return false;
	const [worldX, worldY] = worldPositionOf(state, id);
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = newParent;
	while (cursor !== undefined) {
		if (cursor.id === id) return false;
		if (visited[cursor.id]) return false;
		visited[cursor.id] = true;
		if (cursor.parentId === undefined || cursor.parentId === cursor.id) break;
		cursor = cursor.parentId !== undefined ? state.nodes[cursor.parentId] : undefined;
	}
	const oldParent = node.parentId !== undefined ? state.nodes[node.parentId] : undefined;
	if (oldParent !== undefined) {
		for (let i = oldParent.children.length; i >= 1; i--) {
			if (oldParent.children[i - 1] === id) table.remove(oldParent.children, i);
		}
	}
	node.parentId = newParentId;
	const [parentWorldX, parentWorldY] = worldPositionOf(state, newParentId);
	node.x = worldX - parentWorldX;
	node.y = worldY - parentWorldY;
	newParent.children.push(id);
	state.previewDirty = true;
	state.playDirty = true;
	state.status = (zh ? '已移动节点到：' : 'Moved node under: ') + newParent.name;
	pushConsole(state, state.status);
	return true;
}

export function resolveAddParentId(state: EditorState) {
	let parentId = state.selectedId || 'root';
	if (state.nodes[parentId] === undefined) parentId = 'root';
	const selected = state.nodes[parentId];
	if (selected !== undefined && selected.kind === 'Camera') {
		parentId = selected.parentId || 'root';
	}
	if (state.nodes[parentId] === undefined) return 'root';
	return parentId;
}

export function nodePath(state: EditorState, id: string) {
	const parts: string[] = [];
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = state.nodes[id];
	while (cursor !== undefined) {
		if (visited[cursor.id]) break;
		visited[cursor.id] = true;
		parts.push(cursor.name);
		if (cursor.parentId === undefined || cursor.parentId === cursor.id) break;
		cursor = cursor.parentId !== undefined ? state.nodes[cursor.parentId] : undefined;
	}
	let path = '';
	for (let i = parts.length; i >= 1; i--) {
		path += (path === '' ? '' : ' / ') + parts[i - 1];
	}
	return path === '' ? 'Root' : path;
}

export function addChildNode(state: EditorState, kind: SceneNodeKind) {
	const parentId = resolveAddParentId(state);
	const node = addNode(state, kind, kind + (tostring(state.nextId + 1) || ''), parentId);
	state.selectedId = node.id;
	state.previewDirty = true;
	state.playDirty = true;
	const parent = state.nodes[parentId];
	state.status = (zh ? '已添加 ' : 'Added ') + node.name + (parent !== undefined ? ((zh ? ' 到 ' : ' under ') + parent.name) : '');
	pushConsole(state, state.status);
}
