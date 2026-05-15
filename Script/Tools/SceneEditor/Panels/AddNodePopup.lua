-- [ts]: AddNodePopup.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local helperColor = ____Theme.helperColor -- 3
local themeColor = ____Theme.themeColor -- 3
local ____Model = require("Script.Tools.SceneEditor.Model") -- 4
local addChildNode = ____Model.addChildNode -- 4
local nodePath = ____Model.nodePath -- 4
local resolveAddParentId = ____Model.resolveAddParentId -- 4
local zh = ____Model.zh -- 4
local function drawNodeOption(state, kind, icon, title, description) -- 6
	if ImGui.Selectable((((icon .. "  ") .. title) .. "##add_") .. kind, false) then -- 6
		addChildNode(state, kind) -- 8
		ImGui.CloseCurrentPopup() -- 9
	end -- 9
	ImGui.TextDisabled("   " .. description) -- 11
end -- 6
local function drawSection(title) -- 14
	ImGui.Spacing() -- 15
	ImGui.TextColored(helperColor, title) -- 16
end -- 14
function ____exports.drawAddNodePopup(state) -- 19
	ImGui.BeginPopup( -- 20
		"AddNodePopup", -- 20
		function() -- 20
			local parentId = resolveAddParentId(state) -- 21
			local selected = state.nodes[state.selectedId] -- 22
			local parent = state.nodes[parentId] -- 23
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 24
			ImGui.TextDisabled(zh and "新节点会挂到下面这个父节点：" or "New node will be created under:") -- 25
			ImGui.Text(parent ~= nil and nodePath(state, parent.id) or "Root") -- 26
			if selected ~= nil and selected.kind == "Camera" then -- 26
				ImGui.TextDisabled(zh and "提示：Camera 不作为父节点，已自动使用它的父节点。" or "Tip: Camera is not used as a parent; its parent is used instead.") -- 28
			end -- 28
			ImGui.Separator() -- 30
			drawSection(zh and "结构节点" or "Structure") -- 31
			drawNodeOption( -- 32
				state, -- 32
				"Node", -- 32
				"○", -- 32
				"Node", -- 32
				zh and "空节点。用来做父级、分组、挂脚本。" or "Empty parent/group node for transforms and scripts." -- 32
			) -- 32
			drawSection(zh and "可见对象" or "Renderable") -- 33
			drawNodeOption( -- 34
				state, -- 34
				"Sprite", -- 34
				"▣", -- 34
				"Sprite", -- 34
				zh and "图片节点。可绑定 texture。" or "Image node with an optional texture." -- 34
			) -- 34
			drawNodeOption( -- 35
				state, -- 35
				"Label", -- 35
				"T", -- 35
				"Label", -- 35
				zh and "文字节点。显示一段文本。" or "Text node for simple labels." -- 35
			) -- 35
			drawSection(zh and "视图" or "View") -- 36
			drawNodeOption( -- 37
				state, -- 37
				"Camera", -- 37
				"◉", -- 37
				"Camera", -- 37
				zh and "相机节点。定义运行时可见区域。" or "Camera node for the runtime view." -- 37
			) -- 37
		end -- 20
	) -- 20
end -- 19
return ____exports -- 19