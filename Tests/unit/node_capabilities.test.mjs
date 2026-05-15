import assert from 'node:assert/strict';
import { loadNodeKindDefinitions, nodeDefinitionsByKind } from './helpers/source_catalog.mjs';

const definitions = loadNodeKindDefinitions();
const byKind = nodeDefinitionsByKind();
const expectedKinds = ['Root', 'Node', 'Sprite', 'Label', 'Camera'];

assert.deepEqual([...byKind.keys()].sort(), expectedKinds.slice().sort(), 'node kind set must stay explicit');
assert.equal(definitions.length, expectedKinds.length, 'node kind definitions must not contain duplicates');

const root = byKind.get('Root');
assert.equal(root.canCreate, false, 'Root is created by the scene, not the Add popup');
assert.equal(root.canDelete, false, 'Root must not be deletable');
assert.equal(root.canHaveChildren, true, 'Root must be a valid parent');
assert.equal(root.canBindScript, false, 'Root should not own gameplay script attachments');
assert.equal(root.viewportPickLayer, 'none', 'Root is not picked in the viewport');

const sprite = byKind.get('Sprite');
assert.equal(sprite.canCreate, true);
assert.equal(sprite.canBindTexture, true, 'Sprite must accept textures');
assert.equal(sprite.canBindScript, true, 'Sprite can own behavior scripts');
assert.equal(sprite.canBeFollowTarget, true, 'Sprite can be followed by Camera');
assert.equal(sprite.usesTextureSize, true, 'Sprite visual size should come from texture when available');
assert.equal(sprite.defaultWidth, 128);
assert.equal(sprite.defaultHeight, 96);

const label = byKind.get('Label');
assert.equal(label.canEditText, true, 'Label exposes text editing');
assert.equal(label.defaultText, 'Label', 'Label has a useful default text');
assert.equal(label.canBindTexture, false, 'Label should not accept textures');

const camera = byKind.get('Camera');
assert.equal(camera.canHaveChildren, false, 'Camera is a view, not a transform parent');
assert.equal(camera.canFollowTarget, true, 'Camera supports follow target');
assert.equal(camera.canBeFollowTarget, false, 'Camera should not be followed as gameplay object');
assert.equal(camera.viewportPickLayer, 'camera', 'Camera is picked after objects');
assert.equal(camera.usesGameFrameSize, true, 'Camera visual size uses game frame');
assert.equal(camera.spawnAtOrigin, true, 'Camera starts centered on the scene');

for (const definition of definitions) {
  assert.equal(typeof definition.labelZh, 'string', `${definition.kind} needs zh label`);
  assert.equal(typeof definition.labelEn, 'string', `${definition.kind} needs en label`);
  assert.equal(typeof definition.descriptionZh, 'string', `${definition.kind} needs zh description`);
  assert.equal(typeof definition.descriptionEn, 'string', `${definition.kind} needs en description`);
  assert.ok(definition.defaultWidth > 0, `${definition.kind} defaultWidth must be positive`);
  assert.ok(definition.defaultHeight > 0, `${definition.kind} defaultHeight must be positive`);
}

console.log('[unit] node capabilities ok');
