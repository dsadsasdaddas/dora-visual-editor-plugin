import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';

export const repoRoot = path.resolve(new URL('../../..', import.meta.url).pathname);

export function readRepoFile(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), 'utf8');
}

function extractArrayLiteral(source, exportName) {
  const marker = `export const ${exportName}`;
  const markerIndex = source.indexOf(marker);
  if (markerIndex < 0) throw new Error(`Missing export ${exportName}`);
  const equalsIndex = source.indexOf('=', markerIndex);
  if (equalsIndex < 0) throw new Error(`Missing initializer for ${exportName}`);
  const start = source.indexOf('[', equalsIndex);
  if (start < 0) throw new Error(`Missing array literal for ${exportName}`);
  let depth = 0;
  for (let i = start; i < source.length; i++) {
    const char = source[i];
    if (char === '[') depth += 1;
    if (char === ']') {
      depth -= 1;
      if (depth === 0) return source.slice(start, i + 1);
    }
  }
  throw new Error(`Unclosed array literal for ${exportName}`);
}

function evaluateLiteral(literal, label) {
  return vm.runInNewContext(`(${literal})`, Object.freeze({}), {
    filename: `${label}.literal.js`,
    timeout: 1000,
  });
}

export function loadNodeKindDefinitions() {
  const source = readRepoFile('Script/Tools/SceneEditor/NodeCatalog.ts');
  const literal = extractArrayLiteral(source, 'nodeKindDefinitions');
  return evaluateLiteral(literal, 'nodeKindDefinitions');
}

export function nodeDefinitionsByKind() {
  const map = new Map();
  for (const definition of loadNodeKindDefinitions()) {
    if (map.has(definition.kind)) throw new Error(`Duplicate node kind ${definition.kind}`);
    map.set(definition.kind, definition);
  }
  return map;
}

export function loadFixture(name) {
  return JSON.parse(readRepoFile(path.join('Tests', 'fixtures', name)));
}
