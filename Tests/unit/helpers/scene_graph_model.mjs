import assert from 'node:assert/strict';
import { nodeDefinitionsByKind } from './source_catalog.mjs';

const definitions = nodeDefinitionsByKind();

export function normalizeKind(kind) {
  return definitions.has(kind) ? kind : 'Node';
}

export function canHaveChildren(kind) {
  return definitions.get(normalizeKind(kind)).canHaveChildren === true;
}

export function buildState(scene) {
  const nodes = {};
  const order = [];
  for (const raw of scene.nodes) {
    const kind = normalizeKind(raw.kind);
    const id = typeof raw.id === 'string' ? raw.id : kind.toLowerCase();
    nodes[id] = {
      ...raw,
      id,
      kind,
      parentId: raw.parentId,
      children: [],
      x: Number(raw.x ?? 0),
      y: Number(raw.y ?? 0),
      scaleX: Number(raw.scaleX ?? 1),
      scaleY: Number(raw.scaleY ?? 1),
      rotation: Number(raw.rotation ?? 0),
      visible: typeof raw.visible === 'boolean' ? raw.visible : true,
      texture: typeof raw.texture === 'string' ? raw.texture : '',
      text: typeof raw.text === 'string' ? raw.text : definitions.get(kind).defaultText || '',
      script: typeof raw.script === 'string' ? raw.script : '',
      followTargetId: typeof raw.followTargetId === 'string' ? raw.followTargetId : '',
      followOffsetX: Number(raw.followOffsetX ?? 0),
      followOffsetY: Number(raw.followOffsetY ?? 0),
    };
    order.push(id);
  }
  if (nodes.root === undefined) {
    nodes.root = { id: 'root', kind: 'Root', name: 'MainScene', parentId: '', children: [], x: 0, y: 0 };
    order.unshift('root');
  }
  return { nodes, order };
}

export function isAncestorOf(state, ancestorId, nodeId) {
  const visited = new Set();
  let cursor = state.nodes[nodeId];
  while (cursor !== undefined) {
    if (cursor.id === ancestorId) return true;
    if (visited.has(cursor.id)) return false;
    visited.add(cursor.id);
    if (cursor.parentId === undefined || cursor.parentId === '' || cursor.parentId === cursor.id) return false;
    cursor = state.nodes[cursor.parentId];
  }
  return false;
}

export function rebuildChildren(state) {
  for (const id of state.order) {
    if (state.nodes[id] !== undefined) state.nodes[id].children = [];
  }
  if (state.nodes.root !== undefined) {
    state.nodes.root.kind = 'Root';
    state.nodes.root.parentId = '';
  }
  for (const id of state.order) {
    if (id === 'root') continue;
    const node = state.nodes[id];
    if (node === undefined) continue;
    let parentId = node.parentId || 'root';
    if (state.nodes[parentId] === undefined || !canHaveChildren(state.nodes[parentId].kind) || isAncestorOf(state, id, parentId)) {
      parentId = 'root';
    }
    node.parentId = parentId;
    state.nodes[parentId].children.push(id);
  }
  return state;
}

export function worldPositionOf(state, id) {
  let x = 0;
  let y = 0;
  const visited = new Set();
  let cursor = state.nodes[id];
  while (cursor !== undefined) {
    if (visited.has(cursor.id)) break;
    visited.add(cursor.id);
    x += Number(cursor.x || 0);
    y += Number(cursor.y || 0);
    if (cursor.parentId === undefined || cursor.parentId === '' || cursor.parentId === cursor.id) break;
    cursor = state.nodes[cursor.parentId];
  }
  return [x, y];
}

export function canReparent(state, id, newParentId) {
  if (id === 'root') return false;
  const node = state.nodes[id];
  const parent = state.nodes[newParentId];
  if (node === undefined || parent === undefined) return false;
  if (node.parentId === newParentId) return false;
  if (!canHaveChildren(parent.kind)) return false;
  if (id === newParentId) return false;
  if (isAncestorOf(state, id, newParentId)) return false;
  return true;
}

export function reparent(state, id, newParentId) {
  if (!canReparent(state, id, newParentId)) return false;
  const node = state.nodes[id];
  const oldParent = state.nodes[node.parentId];
  const [worldX, worldY] = worldPositionOf(state, id);
  const [parentWorldX, parentWorldY] = worldPositionOf(state, newParentId);
  if (oldParent !== undefined) oldParent.children = oldParent.children.filter((childId) => childId !== id);
  node.parentId = newParentId;
  node.x = worldX - parentWorldX;
  node.y = worldY - parentWorldY;
  state.nodes[newParentId].children.push(id);
  return true;
}

export function serializeScene(state) {
  return state.order.map((id) => {
    const node = state.nodes[id];
    assert.notEqual(node, undefined, `missing node ${id}`);
    return {
      id: node.id,
      kind: node.kind,
      parentId: node.id === 'root' ? undefined : node.parentId,
    };
  });
}
