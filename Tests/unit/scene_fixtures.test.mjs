import assert from 'node:assert/strict';
import { buildState, rebuildChildren, serializeScene } from './helpers/scene_graph_model.mjs';
import { loadFixture as fixture } from './helpers/source_catalog.mjs';

function normalized(name) {
  return rebuildChildren(buildState(fixture(name)));
}

for (const name of ['basic.scene.json', 'nested-parent.scene.json']) {
  const state = normalized(name);
  assert.ok(state.nodes.root, `${name} must have root`);
  assert.equal(state.nodes.root.kind, 'Root', `${name} root kind is normalized`);
  assert.equal(state.nodes.root.parentId, '', `${name} root parent is empty`);
  for (const id of state.order) {
    if (id === 'root') continue;
    assert.ok(state.nodes[state.nodes[id].parentId], `${name}:${id} parent exists`);
  }
}

const rootCycle = normalized('bad-root-cycle.scene.json');
assert.equal(rootCycle.nodes.root.parentId, '', 'root self-parent is removed during normalization');
assert.equal(serializeScene(rootCycle).find((node) => node.id === 'root').parentId, undefined, 'root parent is omitted during save serialization');

const nestedCycle = normalized('bad-nested-cycle.scene.json');
assert.equal(nestedCycle.nodes['node-1'].parentId, 'root', 'cycle entry is moved back to root');
assert.equal(nestedCycle.nodes['node-2'].parentId, 'node-1', 'remaining child keeps valid parent after cycle break');
assert.deepEqual(nestedCycle.nodes.root.children, ['node-1']);

const missingParentScene = {
  nodes: [
    { id: 'root', kind: 'Root', name: 'MainScene', parentId: 'root' },
    { id: 'orphan', kind: 'Sprite', name: 'Orphan', parentId: 'missing', x: 5, y: 6 },
  ],
};
const missingParent = rebuildChildren(buildState(missingParentScene));
assert.equal(missingParent.nodes.orphan.parentId, 'root', 'missing parent falls back to root');

const invalidKindScene = {
  nodes: [
    { id: 'root', kind: 'Root', name: 'MainScene' },
    { id: 'custom-1', kind: 'UnknownKind', name: 'Custom', parentId: 'root' },
  ],
};
const invalidKind = rebuildChildren(buildState(invalidKindScene));
assert.equal(invalidKind.nodes['custom-1'].kind, 'Node', 'unknown node kind normalizes to Node');
assert.equal(invalidKind.nodes['custom-1'].parentId, 'root');

console.log('[unit] scene fixtures ok');
