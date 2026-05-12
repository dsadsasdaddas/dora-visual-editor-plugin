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
	if state.isPlaying then -- 27
		ImGui.TextDisabled(zh and "运行中属性锁定；点 Stop 后再编辑节点。" or "Properties are locked in Play Mode. Stop to edit nodes.") -- 29
		ImGui.Separator() -- 30
		ImGui.TextDisabled("Name: " .. node.name) -- 31
		ImGui.TextDisabled((("Position: " .. tostring(node.x)) .. ", ") .. tostring(node.y)) -- 32
		ImGui.TextDisabled((("Scale: " .. tostring(node.scaleX)) .. ", ") .. tostring(node.scaleY)) -- 33
		ImGui.TextDisabled("Rotation: " .. tostring(node.rotation)) -- 34
		ImGui.TextDisabled("Script: " .. node.script) -- 35
		if node.kind == "Sprite" then -- 35
			ImGui.TextDisabled("Texture: " .. node.texture) -- 36
		end -- 36
		if node.kind == "Label" then -- 36
			ImGui.TextDisabled("Text: " .. node.text) -- 37
		end -- 37
		return -- 38
	end -- 38
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 38
		node.name = node.nameBuffer.text -- 40
		markSceneChanged(state) -- 40
	end -- 40
	local changed, x, y = ImGui.DragFloat2( -- 41
		"Position", -- 41
		node.x, -- 41
		node.y, -- 41
		1, -- 41
		-10000, -- 41
		10000, -- 41
		"%.1f" -- 41
	) -- 41
	if changed then -- 41
		node.x = x -- 42
		node.y = y -- 42
		markSceneChanged(state) -- 42
	end -- 42
	changed, x, y = ImGui.DragFloat2( -- 43
		"Scale", -- 43
		node.scaleX, -- 43
		node.scaleY, -- 43
		0.01, -- 43
		-100, -- 43
		100, -- 43
		"%.2f" -- 43
	) -- 43
	if changed then -- 43
		node.scaleX = x -- 44
		node.scaleY = y -- 44
		markSceneChanged(state) -- 44
	end -- 44
	local angleChanged, angle = ImGui.DragFloat( -- 45
		"Rotation", -- 45
		node.rotation, -- 45
		1, -- 45
		-360, -- 45
		360, -- 45
		"%.1f" -- 45
	) -- 45
	if angleChanged then -- 45
		node.rotation = angle -- 46
		markSceneChanged(state) -- 46
	end -- 46
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 47
	if visibleChanged then -- 47
		node.visible = visible -- 48
		markSceneChanged(state) -- 48
	end -- 48
	ImGui.Separator() -- 49
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 49
		node.script = node.scriptBuffer.text -- 50
		markSceneChanged(state) -- 50
	end -- 50
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 50
		openScriptForNode(state, node) -- 51
	end -- 51
	if node.kind == "Sprite" then -- 51
		ImGui.Separator() -- 53
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 53
			node.texture = node.textureBuffer.text -- 55
			markSceneChanged(state) -- 56
		end -- 56
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 56
			App:openFileDialog( -- 59
				false, -- 59
				function(path) -- 59
					local asset = addAssetPath(state, path) -- 60
					if asset ~= nil and isTextureAsset(asset) then -- 60
						bindTextureToSprite(state, node, asset) -- 61
					end -- 61
				end -- 59
			) -- 59
		end -- 59
		ImGui.SameLine() -- 64
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 64
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 64
				bindTextureToSprite(state, node, state.selectedAsset) -- 66
			end -- 66
		end -- 66
	elseif node.kind == "Label" then -- 66
		ImGui.Separator() -- 69
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 69
			node.text = node.textBuffer.text -- 70
			markSceneChanged(state) -- 70
		end -- 70
	elseif node.kind == "Camera" then -- 70
		ImGui.Separator() -- 72
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 73
	end -- 73
end -- 15
return ____exports -- 15