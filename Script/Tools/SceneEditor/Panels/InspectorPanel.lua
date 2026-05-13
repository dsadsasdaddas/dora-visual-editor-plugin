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
local function nodeDisplayName(node) -- 15
	return ((node.name .. " (") .. node.id) .. ")" -- 16
end -- 15
local function selectNextFollowTarget(state, camera) -- 19
	local foundCurrent = camera.followTargetId == "" -- 20
	for ____, id in ipairs(state.order) do -- 21
		local candidate = state.nodes[id] -- 22
		if candidate ~= nil and candidate.id ~= camera.id and candidate.kind ~= "Root" and candidate.kind ~= "Camera" then -- 22
			if foundCurrent then -- 22
				camera.followTargetId = candidate.id -- 25
				camera.followTargetBuffer.text = candidate.id -- 26
				markSceneChanged(state) -- 27
				return -- 28
			end -- 28
			if candidate.id == camera.followTargetId then -- 28
				foundCurrent = true -- 30
			end -- 30
		end -- 30
	end -- 30
	camera.followTargetId = "" -- 33
	camera.followTargetBuffer.text = "" -- 34
	markSceneChanged(state) -- 35
end -- 19
function ____exports.drawInspectorPanel(state, bindTextureToSprite, openScriptForNode) -- 38
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 43
	ImGui.Separator() -- 44
	local node = state.nodes[state.selectedId] -- 45
	if node == nil then -- 45
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 47
		return -- 48
	end -- 48
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 50
	if state.isPlaying then -- 50
		ImGui.TextDisabled(zh and "运行中属性锁定；点 Stop 后再编辑节点。" or "Properties are locked in Play Mode. Stop to edit nodes.") -- 52
		ImGui.Separator() -- 53
		ImGui.TextDisabled("Name: " .. node.name) -- 54
		ImGui.TextDisabled((("Position: " .. tostring(node.x)) .. ", ") .. tostring(node.y)) -- 55
		ImGui.TextDisabled((("Scale: " .. tostring(node.scaleX)) .. ", ") .. tostring(node.scaleY)) -- 56
		ImGui.TextDisabled("Rotation: " .. tostring(node.rotation)) -- 57
		ImGui.TextDisabled("Script: " .. node.script) -- 58
		if node.kind == "Sprite" then -- 58
			ImGui.TextDisabled("Texture: " .. node.texture) -- 59
		end -- 59
		if node.kind == "Label" then -- 59
			ImGui.TextDisabled("Text: " .. node.text) -- 60
		end -- 60
		return -- 61
	end -- 61
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 61
		node.name = node.nameBuffer.text -- 63
		markSceneChanged(state) -- 63
	end -- 63
	local changed, x, y = ImGui.DragFloat2( -- 64
		"Position", -- 64
		node.x, -- 64
		node.y, -- 64
		1, -- 64
		-10000, -- 64
		10000, -- 64
		"%.1f" -- 64
	) -- 64
	if changed then -- 64
		node.x = x -- 65
		node.y = y -- 65
		markSceneChanged(state) -- 65
	end -- 65
	changed, x, y = ImGui.DragFloat2( -- 66
		"Scale", -- 66
		node.scaleX, -- 66
		node.scaleY, -- 66
		0.01, -- 66
		-100, -- 66
		100, -- 66
		"%.2f" -- 66
	) -- 66
	if changed then -- 66
		node.scaleX = x -- 67
		node.scaleY = y -- 67
		markSceneChanged(state) -- 67
	end -- 67
	local angleChanged, angle = ImGui.DragFloat( -- 68
		"Rotation", -- 68
		node.rotation, -- 68
		1, -- 68
		-360, -- 68
		360, -- 68
		"%.1f" -- 68
	) -- 68
	if angleChanged then -- 68
		node.rotation = angle -- 69
		markSceneChanged(state) -- 69
	end -- 69
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 70
	if visibleChanged then -- 70
		node.visible = visible -- 71
		markSceneChanged(state) -- 71
	end -- 71
	ImGui.Separator() -- 72
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 72
		node.script = node.scriptBuffer.text -- 73
		markSceneChanged(state) -- 73
	end -- 73
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 73
		openScriptForNode(state, node) -- 74
	end -- 74
	if node.kind == "Sprite" then -- 74
		ImGui.Separator() -- 76
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 76
			node.texture = node.textureBuffer.text -- 78
			markSceneChanged(state) -- 79
		end -- 79
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 79
			App:openFileDialog( -- 82
				false, -- 82
				function(path) -- 82
					local asset = addAssetPath(state, path) -- 83
					if asset ~= nil and isTextureAsset(asset) then -- 83
						bindTextureToSprite(state, node, asset) -- 84
					end -- 84
				end -- 82
			) -- 82
		end -- 82
		ImGui.SameLine() -- 87
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 87
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 87
				bindTextureToSprite(state, node, state.selectedAsset) -- 89
			end -- 89
		end -- 89
	elseif node.kind == "Label" then -- 89
		ImGui.Separator() -- 92
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 92
			node.text = node.textBuffer.text -- 93
			markSceneChanged(state) -- 93
		end -- 93
	elseif node.kind == "Camera" then -- 93
		ImGui.Separator() -- 95
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 96
		ImGui.Separator() -- 97
		ImGui.TextColored(themeColor, zh and "跟随目标" or "Follow Target") -- 98
		if ImGui.InputText("Target Id", node.followTargetBuffer, inputTextFlags) then -- 98
			node.followTargetId = node.followTargetBuffer.text -- 100
			markSceneChanged(state) -- 101
		end -- 101
		ImGui.SameLine() -- 103
		if ImGui.Button(zh and "选择下一个" or "Next Target") then -- 103
			selectNextFollowTarget(state, node) -- 104
		end -- 104
		local target = node.followTargetId ~= "" and state.nodes[node.followTargetId] or nil -- 105
		ImGui.TextDisabled((zh and "当前：" or "Current: ") .. (target ~= nil and nodeDisplayName(target) or (zh and "无" or "None"))) -- 106
		local offsetChanged, offsetX, offsetY = ImGui.DragFloat2( -- 107
			"Follow Offset", -- 107
			node.followOffsetX, -- 107
			node.followOffsetY, -- 107
			1, -- 107
			-10000, -- 107
			10000, -- 107
			"%.1f" -- 107
		) -- 107
		if offsetChanged then -- 107
			node.followOffsetX = offsetX -- 109
			node.followOffsetY = offsetY -- 110
			markSceneChanged(state) -- 111
		end -- 111
		if ImGui.Button(zh and "清除跟随" or "Clear Follow") then -- 111
			node.followTargetId = "" -- 114
			node.followTargetBuffer.text = "" -- 115
			node.followOffsetX = 0 -- 116
			node.followOffsetY = 0 -- 117
			markSceneChanged(state) -- 118
		end -- 118
	end -- 118
end -- 38
return ____exports -- 38