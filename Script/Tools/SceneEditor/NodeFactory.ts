import { Buffer } from 'Dora';
import { SceneNodeData, SceneNodeKind } from 'Script/Tools/SceneEditor/EditorTypes';
import { defaultNodeName } from 'Script/Tools/SceneEditor/NodeCatalog';
import { defaultNodeText, shouldSpawnNodeAtOrigin } from 'Script/Tools/SceneEditor/NodeCapabilities';

export interface SceneNodeDataInput {
	id: string;
	kind: SceneNodeKind;
	name?: string;
	parentId?: string;
	index?: number;
	x?: number;
	y?: number;
	scaleX?: number;
	scaleY?: number;
	rotation?: number;
	visible?: boolean;
	texture?: string;
	text?: string;
	script?: string;
	followTargetId?: string;
	followOffsetX?: number;
	followOffsetY?: number;
}

function nodeBuffer(text: string, size: number) {
	const buffer = Buffer(size);
	buffer.text = text;
	return buffer;
}

function indexedSpawnPosition(kind: SceneNodeKind, index: number): [number, number] {
	if (shouldSpawnNodeAtOrigin(kind)) return [0, 0];
	return [((index % 5) - 2) * 70, (math.floor(index / 5) % 4) * 55];
}

export function createSceneNodeData(input: SceneNodeDataInput): SceneNodeData {
	const index = input.index !== undefined ? input.index : 0;
	const [defaultX, defaultY] = indexedSpawnPosition(input.kind, index);
	const text = input.text !== undefined ? input.text : defaultNodeText(input.kind);
	const name = input.name !== undefined ? input.name : defaultNodeName(input.kind, index);
	const texture = input.texture !== undefined ? input.texture : '';
	const script = input.script !== undefined ? input.script : '';
	const followTargetId = input.followTargetId !== undefined ? input.followTargetId : '';
	return {
		id: input.id,
		kind: input.kind,
		name,
		parentId: input.parentId,
		children: [],
		x: input.x !== undefined ? input.x : defaultX,
		y: input.y !== undefined ? input.y : defaultY,
		scaleX: input.scaleX !== undefined ? input.scaleX : 1,
		scaleY: input.scaleY !== undefined ? input.scaleY : 1,
		rotation: input.rotation !== undefined ? input.rotation : 0,
		visible: input.visible !== undefined ? input.visible : true,
		texture,
		text,
		script,
		followTargetId,
		followOffsetX: input.followOffsetX !== undefined ? input.followOffsetX : 0,
		followOffsetY: input.followOffsetY !== undefined ? input.followOffsetY : 0,
		nameBuffer: nodeBuffer(name, 128),
		textureBuffer: nodeBuffer(texture, 256),
		textBuffer: nodeBuffer(text, 256),
		scriptBuffer: nodeBuffer(script, 256),
		followTargetBuffer: nodeBuffer(followTargetId, 128),
	};
}

export function refreshSceneNodeBuffers(node: SceneNodeData) {
	node.nameBuffer.text = node.name;
	node.textureBuffer.text = node.texture;
	node.textBuffer.text = node.text;
	node.scriptBuffer.text = node.script;
	node.followTargetBuffer.text = node.followTargetId;
}
