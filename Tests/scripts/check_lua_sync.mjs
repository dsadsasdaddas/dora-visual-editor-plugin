import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const scriptRoot = path.join(repo, 'Script');
const ignoredDirs = new Set(['node_modules', 'dist', 'Imported']);
let failed = false;

function fail(message) {
  console.error(`[lua-sync] ${message}`);
  failed = true;
}

function walk(dir, files = []) {
  if (!fs.existsSync(dir)) return files;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ignoredDirs.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(full, files);
    } else if (entry.isFile()) {
      files.push(full);
    }
  }
  return files;
}

function relative(file) {
  return path.relative(repo, file).split(path.sep).join('/');
}

function matchingLuaPath(tsPath) {
  return tsPath.replace(/\.tsx?$/, '.lua');
}

function matchingTsPaths(luaPath) {
  return [luaPath.replace(/\.lua$/, '.ts'), luaPath.replace(/\.lua$/, '.tsx')];
}

function git(args) {
  try {
    return execFileSync('git', args, { cwd: repo, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return '';
  }
}

function comparisonBase() {
  const githubBase = process.env.GITHUB_BASE_REF;
  if (githubBase !== undefined && githubBase !== '') {
    git(['fetch', '--no-tags', 'origin', githubBase]);
    const base = git(['merge-base', 'HEAD', `origin/${githubBase}`]);
    if (base !== '') return base;
  }
  const upstream = git(['rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}']);
  if (upstream !== '') {
    const base = git(['merge-base', 'HEAD', upstream]);
    if (base !== '') return base;
  }
  return '';
}

function changedFilesSinceBase() {
  const base = comparisonBase();
  if (base === '') return new Set();
  const output = git(['diff', '--name-status', `${base}...HEAD`, '--', 'Script']);
  const changed = new Set();
  if (output === '') return changed;
  for (const line of output.split(/\r?\n/)) {
    const parts = line.split('\t');
    if (parts.length < 2) continue;
    const status = parts[0];
    if (status.startsWith('R') || status.startsWith('C')) {
      if (parts[2] !== undefined) changed.add(parts[2]);
    } else {
      changed.add(parts[1]);
    }
  }
  return changed;
}

for (const tsFile of walk(scriptRoot).filter((file) => file.endsWith('.ts') || file.endsWith('.tsx'))) {
  const luaFile = matchingLuaPath(tsFile);
  const tsRel = relative(tsFile);
  const luaRel = relative(luaFile);
  if (!fs.existsSync(luaFile)) {
    fail(`${tsRel} is missing generated ${luaRel}`);
    continue;
  }
  const lua = fs.readFileSync(luaFile, 'utf8');
  const expectedHeader = `-- [ts]: ${path.basename(tsFile)}`;
  const firstLine = lua.split(/\r?\n/, 1)[0] || '';
  if (firstLine.trim() !== expectedHeader) {
    fail(`${luaRel} header is ${JSON.stringify(firstLine)}; expected ${JSON.stringify(expectedHeader)}`);
  }
  const luaStat = fs.statSync(luaFile);
  if (luaStat.size === 0) {
    fail(`${luaRel} is empty`);
  }
}

for (const luaFile of walk(scriptRoot).filter((file) => file.endsWith('.lua'))) {
  const tsMatches = matchingTsPaths(luaFile);
  const luaRel = relative(luaFile);
  if (!tsMatches.some((file) => fs.existsSync(file))) {
    const lua = fs.readFileSync(luaFile, 'utf8');
    if (lua.startsWith('-- [ts]:')) {
      fail(`${luaRel} looks generated but no matching .ts/.tsx source exists`);
    }
  }
}

const changed = changedFilesSinceBase();
for (const file of changed) {
  if (!file.endsWith('.ts') && !file.endsWith('.tsx')) continue;
  const luaFile = matchingLuaPath(file);
  if (!changed.has(luaFile)) {
    fail(`${file} changed but generated ${luaFile} was not changed in this branch`);
  }
}

if (failed) process.exit(1);
console.log('[lua-sync] ok');
