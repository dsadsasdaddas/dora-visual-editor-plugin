import { App, Color, Content, Path, Vec2, json } from 'Dora';
import * as ImGui from 'ImGui';
import { SetCond, StyleColor } from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/EditorTypes';
import { mainWindowFlags, noScrollFlags, panelBg, transparent, warnColor } from 'Script/Tools/SceneEditor/Theme';
import { addChildNode, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { drawGamePreviewWindow } from 'Script/Tools/SceneEditor/Player';
import { drawHeaderPanel } from 'Script/Tools/SceneEditor/Panels/HeaderPanel';
import { drawConsolePanel } from 'Script/Tools/SceneEditor/Panels/ConsolePanel';
import { drawSceneTreePanel } from 'Script/Tools/SceneEditor/Panels/SceneTreePanel';
import { drawAssetsPanel } from 'Script/Tools/SceneEditor/Panels/AssetsPanel';
import { drawInspectorPanel } from 'Script/Tools/SceneEditor/Panels/InspectorPanel';
import { drawScriptPanel, openScriptForNode } from 'Script/Tools/SceneEditor/Panels/ScriptPanel';
import { drawViewportPanel } from 'Script/Tools/SceneEditor/Panels/ViewportPanel';

declare function require(path: string): any;

const SceneModel = require('Script.Tools.SceneEditor.Model');
function workspacePath(path: string) { return SceneModel.workspacePath(path) as string; }

function sceneSaveFile() {
	return workspacePath(Path('.dora', 'imgui-editor.scene.json'));
}

function writeSceneFile(state: EditorState) {
	Content.mkdir(workspacePath('.dora'));
	const data = {
		version: 1,
		gameWidth: math.floor(state.gameWidth),
		gameHeight: math.floor(state.gameHeight),
		nodes: [] as object[],
	};
	for (const id of state.order) {
		const node = state.nodes[id];
		if (node !== undefined) {
			data.nodes.push({
				id: node.id,
				kind: node.kind,
				name: node.name,
				parentId: node.parentId,
				x: node.x,
				y: node.y,
				scaleX: node.scaleX,
				scaleY: node.scaleY,
				rotation: node.rotation,
				visible: node.visible,
				texture: node.texture,
				text: node.text,
				script: node.script,
			});
		}
	}
	const [text] = json.encode(data);
	const file = sceneSaveFile();
	if (text !== undefined && Content.save(file, text)) return file;
	return undefined;
}

function saveScene(state: EditorState) {
	const file = writeSceneFile(state);
	if (file !== undefined) {
		state.status = (zh ? '已保存：' : 'Saved: ') + file;
	} else {
		state.status = zh ? '保存失败' : 'Save failed';
	}
	pushConsole(state, state.status);
}

function attachScriptToNode(state: EditorState, node: SceneNodeData, scriptPath: string, message?: string) {
	node.script = scriptPath;
	node.scriptBuffer.text = scriptPath;
	state.activeScriptNodeId = node.id;
	state.previewDirty = true;
	state.playDirty = true;
	const sceneFile = writeSceneFile(state);
	if (sceneFile === undefined) {
		state.status = zh ? '脚本已挂载，但场景保存失败' : 'Script attached, but scene save failed';
	} else {
		state.status = message || ((zh ? '脚本已挂载并保存：' : 'Script attached and saved: ') + scriptPath);
	}
	pushConsole(state, state.status);
}

function bindTextureToSprite(state: EditorState, node: SceneNodeData, texture: string) {
	node.texture = texture;
	node.textureBuffer.text = texture;
	state.selectedAsset = texture;
	state.previewDirty = true;
	state.playDirty = true;
	state.status = (zh ? '已绑定贴图：' : 'Texture assigned: ') + texture;
	pushConsole(state, state.status);
}

function createSpriteFromTexture(state: EditorState, texture: string) {
	addChildNode(state, 'Sprite');
	const node = state.nodes[state.selectedId];
	if (node !== undefined && node.kind === 'Sprite') {
		bindTextureToSprite(state, node, texture);
	}
}

function openNodeScriptInEditor(state: EditorState, node: SceneNodeData) {
	openScriptForNode(state, node, attachScriptToNode);
}

function drawVerticalSplitter(id: string, height: number, onDrag: (deltaX: number) => void) {
	ImGui.PushStyleColor(StyleColor.Button, Color(0xff343a44), () => {
		ImGui.PushStyleColor(StyleColor.ButtonHovered, Color(0xff4d5968), () => {
			ImGui.PushStyleColor(StyleColor.ButtonActive, Color(0xffffcc33), () => {
				ImGui.Button('##' + id, Vec2(8, height));
			});
		});
	});
	if (ImGui.IsItemHovered()) {
		ImGui.BeginTooltip(() => ImGui.Text(zh ? '拖动调整面板宽度' : 'Drag to resize panel'));
	}
	if (ImGui.IsItemActive() && ImGui.IsMouseDragging(0)) {
		const delta = ImGui.GetMouseDragDelta(0);
		if (delta.x !== 0) {
			onDrag(delta.x);
			ImGui.ResetMouseDragDelta(0);
		}
	}
}

export function drawEditor(state: EditorState) {
	const size = App.visualSize;
	const margin = 10;
	const nativeFooterSafeArea = 60;
	const windowWidth = math.max(360, size.width - margin * 2);
	const windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea);
	ImGui.SetNextWindowPos(Vec2(margin, margin), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(windowWidth, windowHeight), SetCond.Always);
	// Scene mode keeps the main ImGui window transparent so the real Dora viewport
	// underneath is not dimmed or color-shifted. Dock panels draw their own bg.
	ImGui.SetNextWindowBgAlpha(state.mode === 'Script' ? 0.96 : 0.0);
	ImGui.Begin('Dora Visual Editor', mainWindowFlags, () => {
		drawHeaderPanel(state, saveScene);
		const avail = ImGui.GetContentRegionAvail();
		const bottomHeight = math.max(72, math.min(state.bottomHeight, math.floor(avail.y * 0.28)));
		if (state.mode === 'Script') {
			const scriptHeight = math.max(180, avail.y - bottomHeight - 8);
			ImGui.PushStyleColor(StyleColor.ChildBg, panelBg, () => {
				ImGui.BeginChild('ScriptWorkspaceRoot', Vec2(0, scriptHeight), [], noScrollFlags, () => drawScriptPanel(state, attachScriptToNode));
			});
			ImGui.BeginChild('ScriptConsoleDock', Vec2(0, bottomHeight), [], noScrollFlags, () => drawConsolePanel(state));
			return;
		}
		const mainHeight = math.max(160, avail.y - bottomHeight - 10);
		const availableWidth = math.max(320, avail.x);
		const splitterWidth = 8;
		const compactLayout = availableWidth < 760;
		const minLeftWidth = compactLayout ? 110 : 170;
		const minRightWidth = compactLayout ? 130 : 220;
		const minCenterWidth = compactLayout ? 80 : 180;
		const sideBudget = math.max(0, availableWidth - splitterWidth * 2 - minCenterWidth);
		if (sideBudget <= minLeftWidth + minRightWidth) {
			state.leftWidth = math.max(1, math.floor(sideBudget * 0.45));
			state.rightWidth = math.max(1, sideBudget - state.leftWidth);
		} else {
			state.leftWidth = math.max(minLeftWidth, state.leftWidth);
			state.rightWidth = math.max(minRightWidth, state.rightWidth);
			if (state.leftWidth + state.rightWidth > sideBudget) {
				const ratio = state.leftWidth / math.max(1, state.leftWidth + state.rightWidth);
				state.leftWidth = math.max(minLeftWidth, math.floor(sideBudget * ratio));
				state.rightWidth = math.max(minRightWidth, sideBudget - state.leftWidth);
			}
			state.leftWidth = math.min(state.leftWidth, sideBudget - minRightWidth);
			state.rightWidth = math.min(state.rightWidth, sideBudget - state.leftWidth);
		}
		const centerWidth = math.max(1, availableWidth - state.leftWidth - state.rightWidth - splitterWidth * 2);
		const leftTopHeight = math.floor(mainHeight * 0.58);
		const leftBottomHeight = mainHeight - leftTopHeight - 8;
		const clampPanelWidth = function(this: void, value: number, minValue: number, maxValue: number) {
			const safeMax = math.max(1, maxValue);
			const safeMin = math.min(minValue, safeMax);
			return math.max(safeMin, math.min(value, safeMax));
		};
		const resizeSidePanels = function(this: void, deltaX: number, side: 'left' | 'right') {
			if (side === 'left') {
				state.leftWidth = clampPanelWidth(state.leftWidth + deltaX, minLeftWidth, availableWidth - state.rightWidth - splitterWidth * 2 - minCenterWidth);
			} else {
				state.rightWidth = clampPanelWidth(state.rightWidth - deltaX, minRightWidth, availableWidth - state.leftWidth - splitterWidth * 2 - minCenterWidth);
			}
		};

		ImGui.PushStyleColor(StyleColor.ChildBg, panelBg, () => {
			ImGui.BeginChild('LeftDock', Vec2(state.leftWidth, mainHeight), [], noScrollFlags, () => {
				ImGui.BeginChild('SceneDock', Vec2(0, leftTopHeight), [], noScrollFlags, () => drawSceneTreePanel(state));
				ImGui.BeginChild('AssetDock', Vec2(0, leftBottomHeight), [], noScrollFlags, () => drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode));
			});
		});
		ImGui.SameLine(0, 0);
		drawVerticalSplitter('LeftSplitter', mainHeight, (deltaX) => resizeSidePanels(deltaX, 'left'));
		ImGui.SameLine(0, 0);
		ImGui.PushStyleColor(StyleColor.ChildBg, transparent, () => {
			ImGui.BeginChild('CenterDock', Vec2(centerWidth, mainHeight), [], noScrollFlags, () => {
				if (state.mode === 'Script') drawScriptPanel(state, attachScriptToNode); else drawViewportPanel(state);
			});
		});
		ImGui.SameLine(0, 0);
		drawVerticalSplitter('RightSplitter', mainHeight, (deltaX) => resizeSidePanels(deltaX, 'right'));
		ImGui.SameLine(0, 0);
		ImGui.PushStyleColor(StyleColor.ChildBg, panelBg, () => {
			ImGui.BeginChild('RightDock', Vec2(state.rightWidth, mainHeight), [], noScrollFlags, () => drawInspectorPanel(state, bindTextureToSprite, openNodeScriptInEditor));
		});
		ImGui.PushStyleColor(StyleColor.ChildBg, panelBg, () => {
			ImGui.BeginChild('BottomConsoleDock', Vec2(0, bottomHeight), [], noScrollFlags, () => drawConsolePanel(state));
		});
	});
	drawGamePreviewWindow(state);
}

export function drawRuntimeError(message: string) {
	const size = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(10, 10), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(math.max(320, size.width - 20), math.max(220, size.height - 20)), SetCond.Always);
	ImGui.Begin('Dora Visual Editor Error', mainWindowFlags, () => {
		ImGui.TextColored(warnColor, zh ? 'Dora Visual Editor 运行时错误' : 'Dora Visual Editor Runtime Error');
		ImGui.Separator();
		ImGui.TextWrapped(message || 'unknown error');
	});
}
