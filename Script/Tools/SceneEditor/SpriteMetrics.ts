import { Texture2D } from 'Dora';
import { SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';

const textureSizeCache: Record<string, [number, number]> = {};

function safeScale(value: number) {
	const scale = math.abs(value);
	return scale > 0.001 ? scale : 1;
}

export function getTextureSize(texture: string): [number, number] | undefined {
	if (texture === '') return undefined;
	const cached = textureSizeCache[texture];
	if (cached !== undefined) return cached;
	const image = Texture2D(texture);
	if (image === undefined) return undefined;
	const size: [number, number] = [math.max(1, image.width), math.max(1, image.height)];
	textureSizeCache[texture] = size;
	return size;
}

export function getNodeVisualSize(item: SceneNodeData, gameWidth?: number, gameHeight?: number): [number, number] {
	if (item.kind === 'Camera') return [math.max(160, gameWidth || 960), math.max(120, gameHeight || 540)];
	if (item.kind === 'Sprite') {
		const size = getTextureSize(item.texture);
		if (size !== undefined) return size;
		return [128, 96];
	}
	if (item.kind === 'Label') return [180, 56];
	return [72, 72];
}

export function isScenePointInsideNode(item: SceneNodeData, sceneX: number, sceneY: number, gameWidth?: number, gameHeight?: number) {
	const [width, height] = getNodeVisualSize(item, gameWidth, gameHeight);
	const dx = sceneX - item.x;
	const dy = sceneY - item.y;
	const radians = -item.rotation * math.pi / 180;
	const cos = math.cos(radians);
	const sin = math.sin(radians);
	const localX = (dx * cos - dy * sin) / safeScale(item.scaleX);
	const localY = (dx * sin + dy * cos) / safeScale(item.scaleY);
	return math.abs(localX) <= width / 2 && math.abs(localY) <= height / 2;
}
