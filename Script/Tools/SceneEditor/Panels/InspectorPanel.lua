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
function ____exports.drawInspectorPanel(state, bindTextureToSprite, openScriptForNode) -- 10
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 15
	ImGui.Separator() -- 16
	local node = state.nodes[state.selectedId] -- 17
	if node == nil then -- 17
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 19
		return -- 20
	end -- 20
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 22
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 22
		node.name = node.nameBuffer.text -- 23
	end -- 23
	local changed, x, y = ImGui.DragFloat2( -- 24
		"Position", -- 24
		node.x, -- 24
		node.y, -- 24
		1, -- 24
		-10000, -- 24
		10000, -- 24
		"%.1f" -- 24
	) -- 24
	if changed then -- 24
		node.x = x -- 25
		node.y = y -- 25
	end -- 25
	changed, x, y = ImGui.DragFloat2( -- 26
		"Scale", -- 26
		node.scaleX, -- 26
		node.scaleY, -- 26
		0.01, -- 26
		-100, -- 26
		100, -- 26
		"%.2f" -- 26
	) -- 26
	if changed then -- 26
		node.scaleX = x -- 27
		node.scaleY = y -- 27
	end -- 27
	local angleChanged, angle = ImGui.DragFloat( -- 28
		"Rotation", -- 28
		node.rotation, -- 28
		1, -- 28
		-360, -- 28
		360, -- 28
		"%.1f" -- 28
	) -- 28
	if angleChanged then -- 28
		node.rotation = angle -- 29
	end -- 29
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 30
	if visibleChanged then -- 30
		node.visible = visible -- 31
	end -- 31
	ImGui.Separator() -- 32
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 32
		node.script = node.scriptBuffer.text -- 33
	end -- 33
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 33
		openScriptForNode(state, node) -- 34
	end -- 34
	if node.kind == "Sprite" then -- 34
		ImGui.Separator() -- 36
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 36
			node.texture = node.textureBuffer.text -- 38
			state.previewDirty = true -- 39
		end -- 39
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 39
			App:openFileDialog( -- 42
				false, -- 42
				function(path) -- 42
					local asset = addAssetPath(state, path) -- 43
					if asset ~= nil and isTextureAsset(asset) then -- 43
						bindTextureToSprite(state, node, asset) -- 44
					end -- 44
				end -- 42
			) -- 42
		end -- 42
		ImGui.SameLine() -- 47
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 47
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 47
				bindTextureToSprite(state, node, state.selectedAsset) -- 49
			end -- 49
		end -- 49
	elseif node.kind == "Label" then -- 49
		ImGui.Separator() -- 52
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 52
			node.text = node.textBuffer.text -- 53
		end -- 53
	elseif node.kind == "Camera" then -- 53
		ImGui.Separator() -- 55
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 56
	end -- 56
end -- 10
return ____exports -- 10