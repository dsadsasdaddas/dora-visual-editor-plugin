import assert from 'node:assert/strict';
import { buildState, canReparent, isAncestorOf, rebuildChildren, reparent, worldPositionOf } from './helpers/scene_graph_model.mjs';
import { loadFixture as fixture } from './helpers/source_catalog.mjs';

const basic = rebuildChildren(buildState(fixture('basic.scene.json')));
assert.equal(isAncestorOf(basic, 'node-1', 'sprite-2'), true, 'parent must be ancestor of child');
assert.equal(isAncestorOf(basic, 'sprite-2', 'node-1'), false, 'child is not ancestor of parent');
assert.equal(canReparent(basic, 'root', 'node-1'), false, 'root cannot be reparented');
assert.equal(canReparent(basic, 'node-1', 'sprite-2'), false, 'node cannot be reparented below its own child');
assert.equal(canReparent(basic, 'sprite-2', 'root'), true, 'sprite can move to root');

const before = worldPositionOf(basic, 'sprite-2');
assert.deepEqual(before, [40, 60], 'fixture world position sanity check');
assert.equal(reparent(basic, 'sprite-2', 'root'), true, 'sprite reparent to root succeeds');
assert.deepEqual(worldPositionOf(basic, 'sprite-2'), before, 'reparent preserves world position');
assert.deepEqual(basic.nodes.root.children.sort(), ['node-1', 'sprite-2'].sort(), 'new parent receives child');
assert.deepEqual(basic.nodes['node-1'].children, [], 'old parent loses child');

const nested = rebuildChildren(buildState(fixture('nested-parent.scene.json')));
assert.equal(canReparent(nested, 'sprite-4', 'camera-3'), false, 'camera cannot accept children');
assert.equal(canReparent(nested, 'camera-3', 'node-2'), true, 'camera can be moved under a normal node');
assert.equal(reparent(nested, 'camera-3', 'node-2'), true, 'valid camera reparent succeeds');
assert.equal(nested.nodes['camera-3'].parentId, 'node-2');

console.log('[unit] scene graph ok');
