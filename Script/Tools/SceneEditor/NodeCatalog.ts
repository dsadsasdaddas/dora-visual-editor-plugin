import { SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';

export type NodeCategoryId = 'structure' | 'renderable' | 'view';

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

export function categoryLabel(category: NodeCategoryDefinition, zh: boolean) {
	return zh ? category.labelZh : category.labelEn;
}

export function defaultNodeName(kind: SceneNodeKind, index: number) {
	if (kind === 'Root') return 'MainScene';
	if (kind === 'Camera') return 'Camera' + (tostring(index) || '');
	return kind + (tostring(index) || '');
}
