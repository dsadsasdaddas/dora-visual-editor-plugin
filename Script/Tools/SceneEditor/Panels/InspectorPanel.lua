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
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 6
local nodeKindLabel = ____NodeCatalog.nodeKindLabel -- 6
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 7
local canNodeKindBeFollowTarget = ____NodeCapabilities.canNodeKindBeFollowTarget -- 7
local canNodeKindBindScript = ____NodeCapabilities.canNodeKindBindScript -- 7
local canNodeKindBindTexture = ____NodeCapabilities.canNodeKindBindTexture -- 7
local canNodeKindEditText = ____NodeCapabilities.canNodeKindEditText -- 7
local canNodeKindFollowTarget = ____NodeCapabilities.canNodeKindFollowTarget -- 7
local function markSceneChanged(state) -- 12
	state.previewDirty = true -- 13
	state.playDirty = true -- 14
end -- 12
local function nodeDisplayName(node) -- 17
	return ((node.name .. " (") .. node.id) .. ")" -- 18
end -- 17
local function selectNextFollowTarget(state, camera) -- 21
	local foundCurrent = camera.followTargetId == "" -- 22
	for ____, id in ipairs(state.order) do -- 23
		local candidate = state.nodes[id] -- 24
		if candidate ~= nil and candidate.id ~= camera.id and canNodeKindBeFollowTarget(candidate.kind) then -- 24
			if foundCurrent then -- 24
				camera.followTargetId = candidate.id -- 27
				camera.followTargetBuffer.text = candidate.id -- 28
				markSceneChanged(state) -- 29
				return -- 30
			end -- 30
			if candidate.id == camera.followTargetId then -- 30
				foundCurrent = true -- 32
			end -- 32
		end -- 32
	end -- 32
	camera.followTargetId = "" -- 35
	camera.followTargetBuffer.text = "" -- 36
	markSceneChanged(state) -- 37
end -- 21
function ____exports.drawInspectorPanel(state, bindTextureToSprite, openScriptForNode) -- 40
	ImGui.TextColored(themeColor, zh and "属性检查器" or "Inspector") -- 45
	ImGui.Separator() -- 46
	local node = state.nodes[state.selectedId] -- 47
	if node == nil then -- 47
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 49
		return -- 50
	end -- 50
	ImGui.Text((iconFor(node.kind) .. "  ") .. nodeKindLabel(node.kind, zh)) -- 52
	if state.isPlaying then -- 52
		ImGui.TextDisabled(zh and "运行中属性锁定；点 Stop 后再编辑节点。" or "Properties are locked in Play Mode. Stop to edit nodes.") -- 54
		ImGui.Separator() -- 55
		ImGui.TextDisabled("Name: " .. node.name) -- 56
		ImGui.TextDisabled((("Position: " .. tostring(node.x)) .. ", ") .. tostring(node.y)) -- 57
		ImGui.TextDisabled((("Scale: " .. tostring(node.scaleX)) .. ", ") .. tostring(node.scaleY)) -- 58
		ImGui.TextDisabled("Rotation: " .. tostring(node.rotation)) -- 59
		ImGui.TextDisabled("Script: " .. node.script) -- 60
		if canNodeKindBindTexture(node.kind) then -- 60
			ImGui.TextDisabled("Texture: " .. node.texture) -- 61
		end -- 61
		if canNodeKindEditText(node.kind) then -- 61
			ImGui.TextDisabled("Text: " .. node.text) -- 62
		end -- 62
		return -- 63
	end -- 63
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 63
		node.name = node.nameBuffer.text -- 65
		markSceneChanged(state) -- 65
	end -- 65
	local changed, x, y = ImGui.DragFloat2( -- 66
		"Position", -- 66
		node.x, -- 66
		node.y, -- 66
		1, -- 66
		-10000, -- 66
		10000, -- 66
		"%.1f" -- 66
	) -- 66
	if changed then -- 66
		node.x = x -- 67
		node.y = y -- 67
		markSceneChanged(state) -- 67
	end -- 67
	changed, x, y = ImGui.DragFloat2( -- 68
		"Scale", -- 68
		node.scaleX, -- 68
		node.scaleY, -- 68
		0.01, -- 68
		-100, -- 68
		100, -- 68
		"%.2f" -- 68
	) -- 68
	if changed then -- 68
		node.scaleX = x -- 69
		node.scaleY = y -- 69
		markSceneChanged(state) -- 69
	end -- 69
	local angleChanged, angle = ImGui.DragFloat( -- 70
		"Rotation", -- 70
		node.rotation, -- 70
		1, -- 70
		-360, -- 70
		360, -- 70
		"%.1f" -- 70
	) -- 70
	if angleChanged then -- 70
		node.rotation = angle -- 71
		markSceneChanged(state) -- 71
	end -- 71
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 72
	if visibleChanged then -- 72
		node.visible = visible -- 73
		markSceneChanged(state) -- 73
	end -- 73
	ImGui.Separator() -- 74
	if canNodeKindBindScript(node.kind) then -- 74
		if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 74
			node.script = node.scriptBuffer.text -- 76
			markSceneChanged(state) -- 76
		end -- 76
		if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 76
			openScriptForNode(state, node) -- 77
		end -- 77
	else -- 77
		ImGui.TextDisabled(zh and "该节点不支持挂载脚本。" or "This node does not support scripts.") -- 79
	end -- 79
	if canNodeKindBindTexture(node.kind) then -- 79
		ImGui.Separator() -- 82
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 82
			node.texture = node.textureBuffer.text -- 84
			markSceneChanged(state) -- 85
		end -- 85
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 85
			App:openFileDialog( -- 88
				false, -- 88
				function(path) -- 88
					local asset = addAssetPath(state, path) -- 89
					if asset ~= nil and isTextureAsset(asset) then -- 89
						bindTextureToSprite(state, node, asset) -- 90
					end -- 90
				end -- 88
			) -- 88
		end -- 88
		ImGui.SameLine() -- 93
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 93
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 93
				bindTextureToSprite(state, node, state.selectedAsset) -- 95
			end -- 95
		end -- 95
	end -- 95
	if canNodeKindEditText(node.kind) then -- 95
		ImGui.Separator() -- 99
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 99
			node.text = node.textBuffer.text -- 100
			markSceneChanged(state) -- 100
		end -- 100
	end -- 100
	if canNodeKindFollowTarget(node.kind) then -- 100
		ImGui.Separator() -- 103
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 104
		ImGui.Separator() -- 105
		ImGui.TextColored(themeColor, zh and "跟随目标" or "Follow Target") -- 106
		if ImGui.InputText("Target Id", node.followTargetBuffer, inputTextFlags) then -- 106
			node.followTargetId = node.followTargetBuffer.text -- 108
			markSceneChanged(state) -- 109
		end -- 109
		ImGui.SameLine() -- 111
		if ImGui.Button(zh and "选择下一个" or "Next Target") then -- 111
			selectNextFollowTarget(state, node) -- 112
		end -- 112
		local target = node.followTargetId ~= "" and state.nodes[node.followTargetId] or nil -- 113
		ImGui.TextDisabled((zh and "当前：" or "Current: ") .. (target ~= nil and nodeDisplayName(target) or (zh and "无" or "None"))) -- 114
		local offsetChanged, offsetX, offsetY = ImGui.DragFloat2( -- 115
			"Follow Offset", -- 115
			node.followOffsetX, -- 115
			node.followOffsetY, -- 115
			1, -- 115
			-10000, -- 115
			10000, -- 115
			"%.1f" -- 115
		) -- 115
		if offsetChanged then -- 115
			node.followOffsetX = offsetX -- 117
			node.followOffsetY = offsetY -- 118
			markSceneChanged(state) -- 119
		end -- 119
		if ImGui.Button(zh and "清除跟随" or "Clear Follow") then -- 119
			node.followTargetId = "" -- 122
			node.followTargetBuffer.text = "" -- 123
			node.followOffsetX = 0 -- 124
			node.followOffsetY = 0 -- 125
			markSceneChanged(state) -- 126
		end -- 126
	end -- 126
end -- 40
return ____exports -- 40