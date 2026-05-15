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
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 5
local categoryLabel = ____NodeCatalog.categoryLabel -- 5
local canCreateNodeKind = ____NodeCatalog.canCreateNodeKind -- 5
local nodeCategoryDefinitions = ____NodeCatalog.nodeCategoryDefinitions -- 5
local nodeKindDefinitions = ____NodeCatalog.nodeKindDefinitions -- 5
local function drawNodeOption(state, kind, icon, title, description) -- 7
	if ImGui.Selectable((((icon .. "  ") .. title) .. "##add_") .. kind, false) then -- 7
		addChildNode(state, kind) -- 9
		ImGui.CloseCurrentPopup() -- 10
	end -- 10
	ImGui.TextDisabled("   " .. description) -- 12
end -- 7
local function drawSection(title) -- 15
	ImGui.Spacing() -- 16
	ImGui.TextColored(helperColor, title) -- 17
end -- 15
function ____exports.drawAddNodePopup(state) -- 20
	ImGui.BeginPopup( -- 21
		"AddNodePopup", -- 21
		function() -- 21
			local parentId = resolveAddParentId(state) -- 22
			local selected = state.nodes[state.selectedId] -- 23
			local parent = state.nodes[parentId] -- 24
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 25
			ImGui.TextDisabled(zh and "新节点会挂到下面这个父节点：" or "New node will be created under:") -- 26
			ImGui.Text(parent ~= nil and nodePath(state, parent.id) or "Root") -- 27
			if selected ~= nil and selected.kind == "Camera" then -- 27
				ImGui.TextDisabled(zh and "提示：Camera 不作为父节点，已自动使用它的父节点。" or "Tip: Camera is not used as a parent; its parent is used instead.") -- 29
			end -- 29
			ImGui.Separator() -- 31
			for ____, category in ipairs(nodeCategoryDefinitions) do -- 32
				drawSection(categoryLabel(category, zh)) -- 33
				for ____, definition in ipairs(nodeKindDefinitions) do -- 34
					if definition.category == category.id and canCreateNodeKind(definition.kind) then -- 34
						drawNodeOption( -- 36
							state, -- 37
							definition.kind, -- 38
							definition.icon, -- 39
							zh and definition.labelZh or definition.labelEn, -- 40
							zh and definition.descriptionZh or definition.descriptionEn -- 41
						) -- 41
					end -- 41
				end -- 41
			end -- 41
		end -- 21
	) -- 21
end -- 20
return ____exports -- 20