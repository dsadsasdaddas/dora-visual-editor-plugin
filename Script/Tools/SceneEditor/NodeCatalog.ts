import { SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';

export type NodeCategoryId = 'structure' | 'renderable' | 'view';
export type ViewportPickLayer = 'object' | 'camera' | 'none';

export interface NodeCategoryDefinition {
	id: NodeCategoryId;
	labelZh: string;
	labelEn: string;
}

export interface NodeKindDefinition {
	kind: SceneNodeKind;
	category: NodeCategoryId;
	icon: string;
	labelZh: string;
	labelEn: string;
	descriptionZh: string;
	descriptionEn: string;
	canCreate: boolean;
	canDelete: boolean;
	canHaveChildren: boolean;
	canBindTexture: boolean;
	canBindScript: boolean;
	canEditText: boolean;
	canFollowTarget: boolean;
	canBeFollowTarget: boolean;
	selectableInViewport: boolean;
	viewportPickLayer: ViewportPickLayer;
	usesTextureSize: boolean;
	usesGameFrameSize: boolean;
	spawnAtOrigin: boolean;
	defaultName: string;
	defaultNamePrefix: string;
	defaultText: string;
	defaultWidth: number;
	defaultHeight: number;
}

export const nodeCategoryDefinitions: NodeCategoryDefinition[] = [
	{ id: 'structure', labelZh: '结构节点', labelEn: 'Structure' },
	{ id: 'renderable', labelZh: '可见对象', labelEn: 'Renderable' },
	{ id: 'view', labelZh: '视图', labelEn: 'View' },
];

export const nodeKindDefinitions: NodeKindDefinition[] = [
	{
		kind: 'Root',
		category: 'structure',
		icon: '◎',
		labelZh: '根节点',
		labelEn: 'Root',
		descriptionZh: '场景根节点。一个场景只能有一个。',
		descriptionEn: 'Scene root. A scene has exactly one root.',
		canCreate: false,
		canDelete: false,
		canHaveChildren: true,
		canBindTexture: false,
		canBindScript: false,
		canEditText: false,
		canFollowTarget: false,
		canBeFollowTarget: false,
		selectableInViewport: false,
		viewportPickLayer: 'none',
		usesTextureSize: false,
		usesGameFrameSize: false,
		spawnAtOrigin: true,
		defaultName: 'MainScene',
		defaultNamePrefix: 'Root',
		defaultText: '',
		defaultWidth: 72,
		defaultHeight: 72,
	},
	{
		kind: 'Node',
		category: 'structure',
		icon: '○',
		labelZh: '空节点',
		labelEn: 'Node',
		descriptionZh: '用于分组、变换和挂载脚本。',
		descriptionEn: 'Group node for transforms and scripts.',
		canCreate: true,
		canDelete: true,
		canHaveChildren: true,
		canBindTexture: false,
		canBindScript: true,
		canEditText: false,
		canFollowTarget: false,
		canBeFollowTarget: true,
		selectableInViewport: true,
		viewportPickLayer: 'object',
		usesTextureSize: false,
		usesGameFrameSize: false,
		spawnAtOrigin: false,
		defaultName: '',
		defaultNamePrefix: 'Node',
		defaultText: '',
		defaultWidth: 72,
		defaultHeight: 72,
	},
	{
		kind: 'Sprite',
		category: 'renderable',
		icon: '▣',
		labelZh: '精灵',
		labelEn: 'Sprite',
		descriptionZh: '图片节点，可绑定 texture。',
		descriptionEn: 'Image node with an optional texture.',
		canCreate: true,
		canDelete: true,
		canHaveChildren: true,
		canBindTexture: true,
		canBindScript: true,
		canEditText: false,
		canFollowTarget: false,
		canBeFollowTarget: true,
		selectableInViewport: true,
		viewportPickLayer: 'object',
		usesTextureSize: true,
		usesGameFrameSize: false,
		spawnAtOrigin: false,
		defaultName: '',
		defaultNamePrefix: 'Sprite',
		defaultText: '',
		defaultWidth: 128,
		defaultHeight: 96,
	},
	{
		kind: 'Label',
		category: 'renderable',
		icon: 'T',
		labelZh: '文本',
		labelEn: 'Label',
		descriptionZh: '文字节点，用于显示文本。',
		descriptionEn: 'Text node for simple labels.',
		canCreate: true,
		canDelete: true,
		canHaveChildren: true,
		canBindTexture: false,
		canBindScript: true,
		canEditText: true,
		canFollowTarget: false,
		canBeFollowTarget: true,
		selectableInViewport: true,
		viewportPickLayer: 'object',
		usesTextureSize: false,
		usesGameFrameSize: false,
		spawnAtOrigin: false,
		defaultName: '',
		defaultNamePrefix: 'Label',
		defaultText: 'Label',
		defaultWidth: 180,
		defaultHeight: 56,
	},
	{
		kind: 'Camera',
		category: 'view',
		icon: '◉',
		labelZh: '相机',
		labelEn: 'Camera',
		descriptionZh: '定义运行时可见区域。',
		descriptionEn: 'Defines the runtime visible area.',
		canCreate: true,
		canDelete: true,
		canHaveChildren: false,
		canBindTexture: false,
		canBindScript: false,
		canEditText: false,
		canFollowTarget: true,
		canBeFollowTarget: false,
		selectableInViewport: true,
		viewportPickLayer: 'camera',
		usesTextureSize: false,
		usesGameFrameSize: true,
		spawnAtOrigin: true,
		defaultName: '',
		defaultNamePrefix: 'Camera',
		defaultText: '',
		defaultWidth: 960,
		defaultHeight: 540,
	},
];

export function normalizeNodeKind(value: unknown): SceneNodeKind {
	if (value === 'Root' || value === 'Node' || value === 'Sprite' || value === 'Label' || value === 'Camera') return value;
	return 'Node';
}

export function getNodeKindDefinition(kind: SceneNodeKind) {
	for (const definition of nodeKindDefinitions) {
		if (definition.kind === kind) return definition;
	}
	return nodeKindDefinitions[1];
}

export function isRootNodeKind(kind: SceneNodeKind) {
	return kind === 'Root';
}

export function nodeKindIcon(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).icon;
}

export function nodeKindLabel(kind: SceneNodeKind, zh: boolean) {
	const definition = getNodeKindDefinition(kind);
	return zh ? definition.labelZh : definition.labelEn;
}

export function nodeKindDescription(kind: SceneNodeKind, zh: boolean) {
	const definition = getNodeKindDefinition(kind);
	return zh ? definition.descriptionZh : definition.descriptionEn;
}

export function canCreateNodeKind(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canCreate;
}

export function canDeleteNodeKind(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canDelete;
}

export function canNodeKindHaveChildren(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canHaveChildren;
}

export function canNodeKindBindTexture(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canBindTexture;
}

export function canNodeKindBindScript(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canBindScript;
}

export function canNodeKindEditText(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canEditText;
}

export function canNodeKindFollowTarget(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canFollowTarget;
}

export function canNodeKindBeFollowTarget(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).canBeFollowTarget;
}

export function canSelectNodeKindInViewport(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).selectableInViewport;
}

export function nodeKindViewportPickLayer(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).viewportPickLayer;
}

export function nodeKindUsesTextureSize(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).usesTextureSize;
}

export function nodeKindUsesGameFrameSize(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).usesGameFrameSize;
}

export function defaultNodeText(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).defaultText;
}

export function defaultNodeVisualSize(kind: SceneNodeKind): [number, number] {
	const definition = getNodeKindDefinition(kind);
	return [definition.defaultWidth, definition.defaultHeight];
}

export function shouldSpawnNodeAtOrigin(kind: SceneNodeKind) {
	return getNodeKindDefinition(kind).spawnAtOrigin;
}

export function categoryLabel(category: NodeCategoryDefinition, zh: boolean) {
	return zh ? category.labelZh : category.labelEn;
}

export function defaultNodeName(kind: SceneNodeKind, index: number) {
	const definition = getNodeKindDefinition(kind);
	if (definition.defaultName !== '') return definition.defaultName;
	return definition.defaultNamePrefix + (tostring(index) || '');
}
