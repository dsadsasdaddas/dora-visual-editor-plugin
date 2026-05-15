import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { canNodeKindHaveChildren, nodeKindIcon, nodeKindLabel } from 'Script/Tools/SceneEditor/NodeCatalog';

export interface SceneTreeRow {
	id: string;
	depth: number;
	connectorPrefix: string;
	connector: string;
	hasChildren: boolean;
	expanded: boolean;
	icon: string;
	name: string;
	kindLabel: string;
	childCount: number;
	canHaveChildren: boolean;
}

function ensureTreeExpanded(state: EditorState) {
	if (state.treeExpanded.root === undefined) state.treeExpanded.root = true;
}

function isValidNode(state: EditorState, id: string) {
	return id !== '' && state.nodes[id] !== undefined;
}

export function canNodeHaveChildren(node: SceneNodeData | undefined) {
	return node !== undefined && canNodeKindHaveChildren(node.kind);
}

export function isAncestorOf(state: EditorState, ancestorId: string, nodeId: string) {
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = state.nodes[nodeId];
	while (cursor !== undefined) {
		if (cursor.id === ancestorId) return true;
		if (visited[cursor.id]) return false;
		visited[cursor.id] = true;
		if (cursor.parentId === undefined || cursor.parentId === '' || cursor.parentId === cursor.id) return false;
		cursor = state.nodes[cursor.parentId];
	}
	return false;
}

export function rebuildSceneChildren(state: EditorState) {
	for (const id of state.order) {
		const node = state.nodes[id];
		if (node !== undefined) node.children = [];
	}
	for (const id of state.order) {
		if (id === 'root') continue;
		const node = state.nodes[id];
		if (node === undefined) continue;
		let parentId = node.parentId || 'root';
		if (!isValidNode(state, parentId) || !canNodeHaveChildren(state.nodes[parentId]) || isAncestorOf(state, id, parentId)) {
			parentId = 'root';
		}
		node.parentId = parentId;
		const parent = state.nodes[parentId];
		if (parent !== undefined) parent.children.push(id);
	}
}

export function normalizeSceneGraph(state: EditorState) {
	ensureTreeExpanded(state);
	const root = state.nodes.root;
	if (root !== undefined) {
		root.kind = 'Root';
		root.parentId = '';
	}
	rebuildSceneChildren(state);
	if (!isValidNode(state, state.selectedId)) state.selectedId = state.nodes.root !== undefined ? 'root' : (state.order[0] || 'root');
	for (const id of state.order) {
		const node = state.nodes[id];
		if (node !== undefined && state.treeExpanded[id] === undefined) state.treeExpanded[id] = true;
	}
}

export function worldPositionOf(state: EditorState, id: string): [number, number] {
	let x = 0;
	let y = 0;
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = state.nodes[id];
	while (cursor !== undefined) {
		if (visited[cursor.id]) break;
		visited[cursor.id] = true;
		x += cursor.x;
		y += cursor.y;
		if (cursor.parentId === undefined || cursor.parentId === '' || cursor.parentId === cursor.id) break;
		cursor = state.nodes[cursor.parentId];
	}
	return [x, y];
}

export function canReparentSceneNode(state: EditorState, id: string, newParentId: string) {
	if (id === 'root') return false;
	const node = state.nodes[id];
	const newParent = state.nodes[newParentId];
	if (node === undefined || newParent === undefined) return false;
	if (node.parentId === newParentId) return false;
	if (!canNodeHaveChildren(newParent)) return false;
	if (id === newParentId) return false;
	if (isAncestorOf(state, id, newParentId)) return false;
	return true;
}

export function reparentSceneNode(state: EditorState, id: string, newParentId: string) {
	if (!canReparentSceneNode(state, id, newParentId)) return false;
	const node = state.nodes[id];
	const newParent = state.nodes[newParentId];
	if (node === undefined || newParent === undefined) return false;
	const [worldX, worldY] = worldPositionOf(state, id);
	const [parentWorldX, parentWorldY] = worldPositionOf(state, newParentId);
	const oldParent = node.parentId !== undefined && node.parentId !== '' ? state.nodes[node.parentId] : undefined;
	if (oldParent !== undefined) {
		for (let i = oldParent.children.length; i >= 1; i--) {
			if (oldParent.children[i - 1] === id) table.remove(oldParent.children, i);
		}
	}
	node.parentId = newParentId;
	node.x = worldX - parentWorldX;
	node.y = worldY - parentWorldY;
	newParent.children.push(id);
	state.treeExpanded[newParentId] = true;
	return true;
}

export function resolveAddParentId(state: EditorState) {
	let parentId = state.selectedId || 'root';
	let parent = state.nodes[parentId];
	if (canNodeHaveChildren(parent)) return parentId;
	if (parent !== undefined && parent.parentId !== undefined && parent.parentId !== '') {
		parentId = parent.parentId;
		parent = state.nodes[parentId];
		if (canNodeHaveChildren(parent)) return parentId;
	}
	return 'root';
}

export function nodePath(state: EditorState, id: string) {
	const parts: string[] = [];
	const visited: Record<string, boolean> = {};
	let cursor: SceneNodeData | undefined = state.nodes[id];
	while (cursor !== undefined) {
		if (visited[cursor.id]) break;
		visited[cursor.id] = true;
		parts.push(cursor.name);
		if (cursor.parentId === undefined || cursor.parentId === '' || cursor.parentId === cursor.id) break;
		cursor = state.nodes[cursor.parentId];
	}
	let path = '';
	for (let i = parts.length; i >= 1; i--) {
		path += (path === '' ? '' : ' / ') + parts[i - 1];
	}
	return path === '' ? 'Root' : path;
}

export function isTreeNodeExpanded(state: EditorState, id: string) {
	ensureTreeExpanded(state);
	return state.treeExpanded[id] !== false;
}

export function toggleTreeNodeExpanded(state: EditorState, id: string) {
	state.treeExpanded[id] = !isTreeNodeExpanded(state, id);
}

function appendTreeRow(state: EditorState, rows: SceneTreeRow[], id: string, depth: number, prefix: string, isLast: boolean, zh: boolean, visited: Record<string, boolean>) {
	const node = state.nodes[id];
	if (node === undefined) return;
	if (visited[id]) return;
	visited[id] = true;
	const hasChildren = node.children.length > 0;
	const expanded = hasChildren && isTreeNodeExpanded(state, id);
	rows.push({
		id,
		depth,
		connectorPrefix: prefix,
		connector: id === 'root' ? '' : (isLast ? '└─ ' : '├─ '),
		hasChildren,
		expanded,
		icon: nodeKindIcon(node.kind),
		name: node.name,
		kindLabel: nodeKindLabel(node.kind, zh),
		childCount: node.children.length,
		canHaveChildren: canNodeHaveChildren(node),
	});
	if (!expanded) return;
	const childPrefix = id === 'root' ? '' : prefix + (isLast ? '   ' : '│  ');
	for (let i = 0; i < node.children.length; i++) {
		appendTreeRow(state, rows, node.children[i], depth + 1, childPrefix, i === node.children.length - 1, zh, visited);
	}
}

export function buildSceneTreeRows(state: EditorState, zh: boolean) {
	const rows: SceneTreeRow[] = [];
	normalizeSceneGraph(state);
	appendTreeRow(state, rows, 'root', 0, '', true, zh, {});
	return rows;
}
