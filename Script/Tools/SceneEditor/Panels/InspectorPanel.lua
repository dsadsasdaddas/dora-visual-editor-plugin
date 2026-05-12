-- [ts]: InspectorPanel.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 4
local inputTextFlags = ____Theme.inputTextFlags -- 4
local themeColor = ____Theme.themeColor -- 4
local ____Model = require("Script.Tools.SceneEditor.Model") -- 5
local addAssetPath = ____Model.addAssetPath -- 5
local iconFor = ____Model.iconFor -- 5
local isTextureAsset = ____Model.isTextureAsset -- 5
local zh = ____Model.zh -- 5
local function markSceneChanged(state) -- 10
	state.previewDirty = true -- 11
	state.playDirty = true -- 12
end -- 10
function ____exports.drawInspectorPanel(state, bindTextureToSprite, openScriptForNode) -- 15
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 20
	ImGui.Separator() -- 21
	local node = state.nodes[state.selectedId] -- 22
	if node == nil then -- 22
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 24
		return -- 25
	end -- 25
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 27
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 27
		node.name = node.nameBuffer.text -- 28
		markSceneChanged(state) -- 28
	end -- 28
	local changed, x, y = ImGui.DragFloat2( -- 29
		"Position", -- 29
		node.x, -- 29
		node.y, -- 29
		1, -- 29
		-10000, -- 29
		10000, -- 29
		"%.1f" -- 29
	) -- 29
	if changed then -- 29
		node.x = x -- 30
		node.y = y -- 30
		markSceneChanged(state) -- 30
	end -- 30
	changed, x, y = ImGui.DragFloat2( -- 31
		"Scale", -- 31
		node.scaleX, -- 31
		node.scaleY, -- 31
		0.01, -- 31
		-100, -- 31
		100, -- 31
		"%.2f" -- 31
	) -- 31
	if changed then -- 31
		node.scaleX = x -- 32
		node.scaleY = y -- 32
		markSceneChanged(state) -- 32
	end -- 32
	local angleChanged, angle = ImGui.DragFloat( -- 33
		"Rotation", -- 33
		node.rotation, -- 33
		1, -- 33
		-360, -- 33
		360, -- 33
		"%.1f" -- 33
	) -- 33
	if angleChanged then -- 33
		node.rotation = angle -- 34
		markSceneChanged(state) -- 34
	end -- 34
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 35
	if visibleChanged then -- 35
		node.visible = visible -- 36
		markSceneChanged(state) -- 36
	end -- 36
	ImGui.Separator() -- 37
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 37
		node.script = node.scriptBuffer.text -- 38
		markSceneChanged(state) -- 38
	end -- 38
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 38
		openScriptForNode(state, node) -- 39
	end -- 39
	if node.kind == "Sprite" then -- 39
		ImGui.Separator() -- 41
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 41
			node.texture = node.textureBuffer.text -- 43
			markSceneChanged(state) -- 44
		end -- 44
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 44
			App:openFileDialog( -- 47
				false, -- 47
				function(path) -- 47
					local asset = addAssetPath(state, path) -- 48
					if asset ~= nil and isTextureAsset(asset) then -- 48
						bindTextureToSprite(state, node, asset) -- 49
					end -- 49
				end -- 47
			) -- 47
		end -- 47
		ImGui.SameLine() -- 52
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 52
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 52
				bindTextureToSprite(state, node, state.selectedAsset) -- 54
			end -- 54
		end -- 54
	elseif node.kind == "Label" then -- 54
		ImGui.Separator() -- 57
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 57
			node.text = node.textBuffer.text -- 58
			markSceneChanged(state) -- 58
		end -- 58
	elseif node.kind == "Camera" then -- 58
		ImGui.Separator() -- 60
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 61
	end -- 61
end -- 15
return ____exports -- 15