import { Color, Keyboard, KeyName, Mouse, Vec2 } from 'Dora';
import * as ImGui from 'ImGui';
import { StyleColor } from 'ImGui';
import { EditorState, ViewportTool } from 'Script/Tools/SceneEditor/EditorTypes';
import { okColor, themeColor } from 'Script/Tools/SceneEditor/Theme';
import { zh } from 'Script/Tools/SceneEditor/Model';
import { updatePreviewRuntime } from 'Script/Tools/SceneEditor/Runtime';
import { isScenePointInsideNode } from 'Script/Tools/SceneEditor/SpriteMetrics';

function viewportScale(state: EditorState) {
	return math.max(0.25, state.zoom / 100);
}

function clampZoom(value: number) {
	return math.max(25, math.min(400, value));
}

function zoomViewportAt(state: EditorState, delta: number, screenX: number, screenY: number) {
	if (delta === 0) return;
	const before = state.zoom;
	const beforeScale = viewportScale(state);
	const p = state.preview;
	const centerX = p.x + p.width / 2;
	const centerY = p.y + p.height / 2;
	const sceneX = (screenX - centerX - state.viewportPanX) / beforeScale;
	const sceneY = (centerY - screenY - state.viewportPanY) / beforeScale;
	state.zoom = clampZoom(state.zoom + delta);
	if (state.zoom !== before) {
		const afterScale = viewportScale(state);
		state.viewportPanX = screenX - centerX - sceneX * afterScale;
		state.viewportPanY = centerY - screenY - sceneY * afterScale;
		state.previewDirty = true;
	}
}

function zoomViewportFromCenter(state: EditorState, delta: number) {
	const p = state.preview;
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2);
}

function screenToScene(state: EditorState, screenX: number, screenY: number): [number, number] {
	const p = state.preview;
	const scale = viewportScale(state);
	const localX = screenX - (p.x + p.width / 2) - state.viewportPanX;
	const localY = (p.y + p.height / 2) - screenY - state.viewportPanY;
	return [localX / scale, localY / scale];
}

function pickNodeAt(state: EditorState, screenX: number, screenY: number) {
	const [sceneX, sceneY] = screenToScene(state, screenX, screenY);
	for (let i = state.order.length; i >= 1; i--) {
		const id = state.order[i - 1];
		const node = state.nodes[id];
		if (node !== undefined && id !== 'root' && node.visible) {
			if (node.kind === 'Camera') {
				const width = math.max(160, state.gameWidth);
				const height = math.max(120, state.gameHeight);
				if (math.abs(sceneX - node.x) <= width / 2 && math.abs(sceneY - node.y) <= height / 2) return id;
			} else if (isScenePointInsideNode(node, sceneX, sceneY)) return id;
		}
	}
	return undefined;
}

function handleViewportMouse(state: EditorState, hovered: boolean) {
	if (state.isPlaying) {
		state.draggingNodeId = undefined;
		state.draggingViewport = false;
		return;
	}
	if (!hovered) return;
	const spacePressed = Keyboard.isKeyPressed(KeyName.Space);
	const wheel = Mouse.wheel;
	const wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) ? wheel.y : wheel.x;
	if (wheelDelta !== 0) {
		const mouse = ImGui.GetMousePos();
		zoomViewportAt(state, wheelDelta > 0 ? 6 : -6, mouse.x, mouse.y);
	}
	if (ImGui.IsMouseClicked(2)) {
		state.draggingNodeId = undefined;
		state.draggingViewport = true;
		ImGui.ResetMouseDragDelta(2);
	}
	if (ImGui.IsMouseClicked(0)) {
		if (spacePressed) {
			state.draggingNodeId = undefined;
			state.draggingViewport = true;
		} else {
			const mouse = ImGui.GetMousePos();
			const picked = pickNodeAt(state, mouse.x, mouse.y);
			if (picked !== undefined) {
				state.selectedId = picked;
				state.previewDirty = true;
				state.draggingNodeId = picked;
				state.draggingViewport = false;
			} else {
				state.draggingNodeId = undefined;
				state.draggingViewport = true;
			}
		}
		ImGui.ResetMouseDragDelta(0);
	}
	if (ImGui.IsMouseReleased(0) || ImGui.IsMouseReleased(2)) {
		state.draggingNodeId = undefined;
		state.draggingViewport = false;
	}
	if (ImGui.IsMouseDragging(0) || ImGui.IsMouseDragging(2)) {
		const panButton = ImGui.IsMouseDragging(2) ? 2 : 0;
		const delta = ImGui.GetMouseDragDelta(panButton);
		if (delta.x !== 0 || delta.y !== 0) {
			if (state.draggingNodeId !== undefined && panButton === 0) {
				const node = state.nodes[state.draggingNodeId];
				if (node !== undefined) {
					const scale = viewportScale(state);
					node.x += delta.x / scale;
					node.y -= delta.y / scale;
					if (state.snapEnabled) {
						const step = 16;
						node.x = math.floor(node.x / step + 0.5) * step;
						node.y = math.floor(node.y / step + 0.5) * step;
					}
					state.previewDirty = true;
					state.playDirty = true;
				}
			} else if (state.draggingViewport) {
				state.viewportPanX += delta.x;
				state.viewportPanY -= delta.y;
			}
			ImGui.ResetMouseDragDelta(panButton);
		}
	}
}

function drawViewportToolButton(state: EditorState, tool: ViewportTool, label: string) {
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => ImGui.Button(label));
		return;
	}
	const active = state.viewportTool === tool;
	if (active) {
		ImGui.PushStyleColor(StyleColor.Button, Color(0xff303642), () => {
			ImGui.PushStyleColor(StyleColor.Text, themeColor, () => {
				if (ImGui.Button(label)) state.viewportTool = tool;
			});
		});
	} else if (ImGui.Button(label)) {
		state.viewportTool = tool;
	}
}

export function drawViewportPanel(state: EditorState) {
	ImGui.TextColored(themeColor, zh ? '场景' : 'Scene');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Select', 'Select');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Move', 'Move');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Rotate', 'Rotate');
	ImGui.SameLine();
	drawViewportToolButton(state, 'Scale', 'Scale');
	ImGui.SameLine();
	ImGui.TextDisabled('|');
	ImGui.SameLine();
	let snapChanged = false;
	let snap = state.snapEnabled;
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => {
			const [changed, value] = ImGui.Checkbox(zh ? '吸附' : 'Snap', state.snapEnabled);
			snapChanged = changed;
			snap = value;
		});
	} else {
		[snapChanged, snap] = ImGui.Checkbox(zh ? '吸附' : 'Snap', state.snapEnabled);
	}
	if (!state.isPlaying && snapChanged) state.snapEnabled = snap;
	ImGui.SameLine();
	let gridChanged = false;
	let grid = state.showGrid;
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => {
			const [changed, value] = ImGui.Checkbox(zh ? '网格' : 'Grid', state.showGrid);
			gridChanged = changed;
			grid = value;
		});
	} else {
		[gridChanged, grid] = ImGui.Checkbox(zh ? '网格' : 'Grid', state.showGrid);
	}
	if (!state.isPlaying && gridChanged) { state.showGrid = grid; state.previewDirty = true; }
	ImGui.SameLine();
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => ImGui.Button(zh ? '居中' : 'Center'));
	} else if (ImGui.Button(zh ? '居中' : 'Center')) {
		state.viewportPanX = 0;
		state.viewportPanY = 0;
		state.zoom = 100;
		state.previewDirty = true;
	}
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? '当前场景：Main' : 'Scene: Main');
	ImGui.Separator();
	const cursor = ImGui.GetCursorScreenPos();
	const avail = ImGui.GetContentRegionAvail();
	const viewportWidth = math.max(360, avail.x - 8);
	const viewportHeight = math.max(300, avail.y - 38);
	if (math.abs(state.preview.width - viewportWidth) > 1 || math.abs(state.preview.height - viewportHeight) > 1) {
		state.previewDirty = true;
	}
	state.preview.x = cursor.x;
	state.preview.y = cursor.y;
	state.preview.width = viewportWidth;
	state.preview.height = viewportHeight;
	updatePreviewRuntime(state);
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight));
	const hovered = ImGui.IsItemHovered();
	handleViewportMouse(state, hovered);
	if (state.isPlaying) {
		ImGui.SetCursorScreenPos(Vec2(cursor.x + 12, cursor.y + 10));
		ImGui.TextColored(okColor, zh ? '▶ 运行模式' : '▶ PLAY MODE');
		ImGui.SameLine();
		ImGui.TextDisabled(zh ? 'Stop 后才能编辑场景' : 'Stop to edit the scene');
	}
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8));
	if (state.isPlaying) {
		ImGui.BeginDisabled(() => {
			ImGui.SmallButton('-##viewport_zoom_out');
			ImGui.SameLine();
			ImGui.SmallButton(tostring(math.floor(state.zoom)) + '%');
			ImGui.SameLine();
			ImGui.SmallButton('+##viewport_zoom_in');
		});
	} else {
		if (ImGui.SmallButton('-##viewport_zoom_out')) zoomViewportFromCenter(state, -10);
		ImGui.SameLine();
		ImGui.PushStyleColor(StyleColor.Text, themeColor, () => {
			if (ImGui.SmallButton(tostring(math.floor(state.zoom)) + '%')) {
				state.zoom = 100;
				state.viewportPanX = 0;
				state.viewportPanY = 0;
				state.previewDirty = true;
			}
		});
		ImGui.SameLine();
		if (ImGui.SmallButton('+##viewport_zoom_in')) zoomViewportFromCenter(state, 10);
	}
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4));
	ImGui.Separator();
	ImGui.TextColored(okColor, zh ? '场景视口' : 'Scene Viewport');
	ImGui.SameLine();
	if (state.isPlaying) {
		ImGui.TextDisabled(zh ? '运行中：编辑器已锁定；只能由游戏脚本/输入改变运行画面。点 Stop 返回编辑。' : 'Play Mode: editor is locked; only game scripts/input can change the runtime view. Stop to edit.');
	} else {
		ImGui.TextDisabled(zh ? '滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。' : 'Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.');
	}
}
