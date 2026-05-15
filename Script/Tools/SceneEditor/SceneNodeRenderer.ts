import { Color, DrawNode, Label, Node, Sprite, Vec2 } from 'Dora';
import { SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { canNodeKindEditText, defaultNodeText, nodeKindUsesGameFrameSize, nodeKindUsesTextureSize } from 'Script/Tools/SceneEditor/NodeCapabilities';
import { getNodeVisualSize } from 'Script/Tools/SceneEditor/SpriteMetrics';
import { helperColor, selectionColor, viewportGameFrameColor } from 'Script/Tools/SceneEditor/Theme';

export type NodeRendererMode = 'editor' | 'play';

export interface NodeVisualContext {
	mode: NodeRendererMode;
	selected: boolean;
	gameWidth: number;
	gameHeight: number;
	labels: Record<string, unknown>;
}

function makeSegmentRect(width: number, height: number, color: Color.Type, thickness: number) {
	const hw = width / 2;
	const hh = height / 2;
	const rect = DrawNode();
	rect.drawSegment(Vec2(-hw, -hh), Vec2(hw, -hh), thickness, color);
	rect.drawSegment(Vec2(hw, -hh), Vec2(hw, hh), thickness, color);
	rect.drawSegment(Vec2(hw, hh), Vec2(-hw, hh), thickness, color);
	rect.drawSegment(Vec2(-hw, hh), Vec2(-hw, -hh), thickness, color);
	return rect;
}

function makeNodeCross(color: Color.Type) {
	const node = Node();
	const horizontal = DrawNode();
	horizontal.drawSegment(Vec2(-20, 0), Vec2(20, 0), 1.0, color);
	const vertical = DrawNode();
	vertical.drawSegment(Vec2(0, -20), Vec2(0, 20), 1.0, color);
	node.addChild(horizontal);
	node.addChild(vertical);
	return node;
}

function addCornerHandles(node: Node.Type, width: number, height: number, color: Color.Type) {
	const hw = width / 2;
	const hh = height / 2;
	const size = 8;
	const points = [
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	];
	for (const point of points) {
		const handle = DrawNode();
		handle.drawPolygon([
			Vec2(point.x - size / 2, point.y - size / 2),
			Vec2(point.x + size / 2, point.y - size / 2),
			Vec2(point.x + size / 2, point.y + size / 2),
			Vec2(point.x - size / 2, point.y + size / 2),
		], color, 0, Color());
		node.addChild(handle);
	}
}

function makeSpritePlaceholder(width: number, height: number) {
	const node = Node();
	node.addChild(makeSegmentRect(width, height, helperColor, 1.1));
	const cross = DrawNode();
	const hw = width / 2;
	const hh = height / 2;
	cross.drawSegment(Vec2(-hw, -hh), Vec2(hw, hh), 0.6, helperColor);
	cross.drawSegment(Vec2(-hw, hh), Vec2(hw, -hh), 0.6, helperColor);
	node.addChild(cross);
	return node;
}

function makeCameraShape(width: number, height: number) {
	const node = Node();
	node.addChild(makeSegmentRect(width, height, viewportGameFrameColor, 1.1));
	return node;
}

function makePlayFallback(width: number, height: number, color: Color.Type) {
	return makeSegmentRect(width, height, color, 1);
}

function addEditorSelectionOverlay(item: SceneNodeData, context: NodeVisualContext, node: Node.Type) {
	const [width, height] = getNodeVisualSize(item, context.gameWidth, context.gameHeight);
	const color = context.selected ? selectionColor : helperColor;
	node.addChild(makeSegmentRect(width, height, color, context.selected ? 1.6 : 0.8));
	if (context.selected) addCornerHandles(node, width, height, color);
}

function createTextureVisual(item: SceneNodeData, context: NodeVisualContext) {
	if (item.texture !== '') {
		const sprite = Sprite(item.texture);
		if (sprite !== undefined) return sprite;
	}
	const [width, height] = getNodeVisualSize(item, context.gameWidth, context.gameHeight);
	if (context.mode === 'play') return makePlayFallback(width, height, Color(0xaa72a6c8));
	return makeSpritePlaceholder(width, height);
}

function createLabelVisual(item: SceneNodeData, context: NodeVisualContext) {
	const label = Label('sarasa-mono-sc-regular', 32);
	if (label !== undefined) {
		label.text = item.text || defaultNodeText(item.kind);
		context.labels[item.id] = label;
		return label;
	}
	const [width, height] = getNodeVisualSize(item, context.gameWidth, context.gameHeight);
	return makePlayFallback(width, height, Color(0xaad6b13f));
}

function createBaseVisual(item: SceneNodeData, context: NodeVisualContext) {
	const [width, height] = getNodeVisualSize(item, context.gameWidth, context.gameHeight);
	if (nodeKindUsesTextureSize(item.kind)) return createTextureVisual(item, context);
	if (canNodeKindEditText(item.kind)) return createLabelVisual(item, context);
	if (nodeKindUsesGameFrameSize(item.kind)) return context.mode === 'editor' ? makeCameraShape(width, height) : Node();
	return context.mode === 'editor' ? makeNodeCross(helperColor) : Node();
}

export function createSceneNodeVisual(item: SceneNodeData, context: NodeVisualContext) {
	const visual = createBaseVisual(item, context);
	if (context.mode === 'play') return visual;
	const wrapper = Node();
	wrapper.addChild(visual);
	addEditorSelectionOverlay(item, context, wrapper);
	return wrapper;
}

export function sceneNodeVisualKey(item: SceneNodeData, context: NodeVisualContext) {
	return [
		context.mode,
		item.kind,
		item.texture || '',
		item.text || '',
		item.name || '',
		context.selected ? 'selected' : 'normal',
		tostring(context.gameWidth),
		tostring(context.gameHeight),
	].join('|');
}

export function applySceneNodeTransform(target: Node.Type, item: SceneNodeData) {
	target.x = item.x;
	target.y = item.y;
	target.scaleX = item.scaleX;
	target.scaleY = item.scaleY;
	target.angle = item.rotation;
	target.visible = item.visible;
	target.tag = item.name;
}

export function updateSceneNodeDynamicVisual(item: SceneNodeData, labels: Record<string, unknown>) {
	const label = labels[item.id] as Label.Type | undefined;
	if (label !== undefined) label.text = item.text || defaultNodeText(item.kind);
}
