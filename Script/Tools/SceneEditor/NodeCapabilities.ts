import { SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';
import { getNodeKindDefinition } from 'Script/Tools/SceneEditor/NodeCatalog';

export type ViewportPickLayer = 'object' | 'camera' | 'none';

interface NodeCapabilityDefinition {
	canDelete?: boolean;
	canHaveChildren?: boolean;
	canBindTexture?: boolean;
	canBindScript?: boolean;
	canEditText?: boolean;
	canFollowTarget?: boolean;
	canBeFollowTarget?: boolean;
	selectableInViewport?: boolean;
	viewportPickLayer?: ViewportPickLayer;
	usesTextureSize?: boolean;
	usesGameFrameSize?: boolean;
	spawnAtOrigin?: boolean;
	defaultText?: string;
	defaultWidth?: number;
	defaultHeight?: number;
}

function nodeCapability(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind) as unknown as NodeCapabilityDefinition;
}

export function isRootNodeKind(kind: SceneNodeKind) {
	return kind === 'Root';
}

export function canDeleteNodeKind(kind: SceneNodeKind) {
	return nodeCapability(kind).canDelete === true;
}

export function canNodeKindHaveChildren(kind: SceneNodeKind) {
	return nodeCapability(kind).canHaveChildren === true;
}

export function canNodeKindBindTexture(kind: SceneNodeKind) {
	return nodeCapability(kind).canBindTexture === true;
}

export function canNodeKindBindScript(kind: SceneNodeKind) {
	return nodeCapability(kind).canBindScript === true;
}

export function canNodeKindEditText(kind: SceneNodeKind) {
	return nodeCapability(kind).canEditText === true;
}

export function canNodeKindFollowTarget(kind: SceneNodeKind) {
	return nodeCapability(kind).canFollowTarget === true;
}

export function canNodeKindBeFollowTarget(kind: SceneNodeKind) {
	return nodeCapability(kind).canBeFollowTarget === true;
}

export function canSelectNodeKindInViewport(kind: SceneNodeKind) {
	return nodeCapability(kind).selectableInViewport === true;
}

export function nodeKindViewportPickLayer(kind: SceneNodeKind) {
	return nodeCapability(kind).viewportPickLayer || 'none';
}

export function nodeKindUsesTextureSize(kind: SceneNodeKind) {
	return nodeCapability(kind).usesTextureSize === true;
}

export function nodeKindUsesGameFrameSize(kind: SceneNodeKind) {
	return nodeCapability(kind).usesGameFrameSize === true;
}

export function defaultNodeText(kind: SceneNodeKind) {
	return nodeCapability(kind).defaultText || '';
}

export function defaultNodeVisualSize(kind: SceneNodeKind): [number, number] {
	const capability = nodeCapability(kind);
	return [capability.defaultWidth || 72, capability.defaultHeight || 72];
}

export function shouldSpawnNodeAtOrigin(kind: SceneNodeKind) {
	return nodeCapability(kind).spawnAtOrigin === true;
}
