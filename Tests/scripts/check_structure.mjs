import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';

const repo = process.cwd();
const read = (file) => fs.readFileSync(path.join(repo, file), 'utf8');

function fail(message) {
  console.error(`[structure] ${message}`);
  process.exitCode = 1;
}

function assertSourceGuard(file, pattern, label) {
  const source = read(file);
  if (!pattern.test(source)) fail(`${file} is missing ${label}`);
}

assertSourceGuard('Script/Tools/SceneEditor/SceneGraph.ts', /export function nodePath[\s\S]*visited[\s\S]*cursor\.parentId === cursor\.id/, 'nodePath cycle guard');
assertSourceGuard('Script/Tools/SceneEditor/Model.ts', /export function addNode[\s\S]*isRootNodeKind\(kind\)[\s\S]*resolvedParentId = ''/, 'root parent normalization');
assertSourceGuard('Script/Tools/SceneEditor/SceneGraph.ts', /export function worldPositionOf[\s\S]*visited[\s\S]*cursor\.parentId === cursor\.id/, 'world-position cycle guard');
assertSourceGuard('Script/Tools/SceneEditor/Panels.ts', /parentId: node\.id === 'root' \? undefined : node\.parentId/, 'root save parent cleanup');
assertSourceGuard('Script/Tools/SceneEditor/SceneGraph.ts', /export function canReparentSceneNode[\s\S]*canNodeHaveChildren[\s\S]*isAncestorOf/, 'safe reparent validation');
assertSourceGuard('Script/Tools/SceneEditor/Panels/SceneTreePanel.ts', /buildSceneTreeRows[\s\S]*toggleTreeNodeExpanded/, 'tree row view model rendering');
assertSourceGuard('Script/Tools/SceneEditor/Panels/AddNodePopup.ts', /nodeCategoryDefinitions[\s\S]*nodeKindDefinitions/, 'catalog-driven add-node popup');
assertSourceGuard('Script/Tools/SceneEditor/NodeFactory.ts', /indexedSpawnPosition[\s\S]*export function createSceneNodeData[\s\S]*defaultNodeText/, 'central node factory defaults');
assertSourceGuard('Script/Tools/SceneEditor/SceneNodeRenderer.ts', /export function createSceneNodeVisual[\s\S]*createBaseVisual[\s\S]*addEditorSelectionOverlay/, 'central node renderer');
assertSourceGuard('Script/Tools/SceneEditor/NodeCatalog.ts', /canBindTexture[\s\S]*canBindScript[\s\S]*viewportPickLayer/, 'node capability catalog');

function loadFixture(name) {
  const file = path.join(repo, 'Tests', 'fixtures', name);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function validateScene(scene, { allowRootSelfParent = false } = {}) {
  assert.ok(Array.isArray(scene.nodes), 'scene.nodes must be an array');
  const ids = new Set();
  const nodes = new Map();
  for (const node of scene.nodes) {
    assert.equal(typeof node.id, 'string', 'node.id must be string');
    assert.ok(!ids.has(node.id), `duplicate node id: ${node.id}`);
    ids.add(node.id);
    nodes.set(node.id, node);
  }
  assert.ok(nodes.has('root'), 'scene must contain root');
  const root = nodes.get('root');
  assert.equal(root.kind, 'Root', 'root.kind must be Root');
  if (!allowRootSelfParent) {
    assert.notEqual(root.parentId, 'root', 'root must not point to itself');
  }
  for (const node of scene.nodes) {
    if (node.id === 'root') continue;
    assert.equal(typeof node.parentId, 'string', `${node.id} must have parentId`);
    assert.ok(nodes.has(node.parentId), `${node.id} parent ${node.parentId} is missing`);
  }
  for (const node of scene.nodes) {
    const seen = new Set();
    let cursor = node;
    while (cursor && cursor.parentId) {
      if (seen.has(cursor.id)) throw new Error(`parent cycle detected at ${cursor.id}`);
      seen.add(cursor.id);
      if (cursor.parentId === cursor.id) throw new Error(`parent cycle detected at ${cursor.id}`);
      cursor = nodes.get(cursor.parentId);
    }
  }
}

for (const name of ['basic.scene.json', 'nested-parent.scene.json']) {
  validateScene(loadFixture(name));
}

let detectedBadRoot = false;
try {
  validateScene(loadFixture('bad-root-cycle.scene.json'));
} catch (error) {
  detectedBadRoot = /root must not point to itself/.test(String(error.message));
}
if (!detectedBadRoot) fail('bad-root-cycle fixture did not trigger root self-parent detection');

let detectedNestedCycle = false;
try {
  validateScene(loadFixture('bad-nested-cycle.scene.json'));
} catch (error) {
  detectedNestedCycle = /parent cycle detected/.test(String(error.message));
}
if (!detectedNestedCycle) fail('bad-nested-cycle fixture did not trigger parent cycle detection');

if (process.exitCode) process.exit(process.exitCode);
console.log('[structure] ok');
