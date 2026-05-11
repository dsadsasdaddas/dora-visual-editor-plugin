-- [ts]: AssetsPanel.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 4
local themeColor = ____Theme.themeColor -- 4
local ____Model = require("Script.Tools.SceneEditor.Model") -- 5
local importFileDialog = ____Model.importFileDialog -- 5
local importFolderDialog = ____Model.importFolderDialog -- 5
local isFolderAsset = ____Model.isFolderAsset -- 5
local isScriptAsset = ____Model.isScriptAsset -- 5
local isTextureAsset = ____Model.isTextureAsset -- 5
local lowerExt = ____Model.lowerExt -- 5
local pushConsole = ____Model.pushConsole -- 5
local zh = ____Model.zh -- 5
local function assetIcon(asset) -- 13
	if isFolderAsset(asset) then -- 13
		return "📁" -- 14
	end -- 14
	if isTextureAsset(asset) then -- 14
		return "🖼" -- 15
	end -- 15
	if isScriptAsset(asset) then -- 15
		return "◇" -- 16
	end -- 16
	local ext = lowerExt(asset) -- 17
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 17
		return "♪" -- 18
	end -- 18
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 18
		return "F" -- 19
	end -- 19
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 19
		return "{}" -- 20
	end -- 20
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 20
		return "◆" -- 21
	end -- 21
	return "·" -- 22
end -- 13
local function startsWith(text, prefix) -- 25
	return string.sub( -- 26
		text, -- 26
		1, -- 26
		string.len(prefix) -- 26
	) == prefix -- 26
end -- 25
local function drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 29
	if isFolderAsset(asset) then -- 29
		ImGui.TreeNode( -- 36
			(assetIcon(asset) .. "  ") .. asset, -- 36
			function() -- 36
				for ____, child in ipairs(state.assets) do -- 37
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 37
						drawAssetRow(state, child, bindTextureToSprite, attachScriptToNode) -- 39
					end -- 39
				end -- 39
			end -- 36
		) -- 36
		return -- 43
	end -- 43
	if ImGui.Selectable( -- 43
		(assetIcon(asset) .. "  ") .. asset, -- 45
		state.selectedAsset == asset -- 45
	) then -- 45
		state.selectedAsset = asset -- 46
		local node = state.nodes[state.selectedId] -- 47
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 47
			bindTextureToSprite(state, node, asset) -- 49
			return -- 50
		elseif node ~= nil and isScriptAsset(asset) then -- 50
			attachScriptToNode(state, node, asset, (zh and "已绑定脚本并保存：" or "Script assigned and saved: ") .. asset) -- 52
			return -- 53
		else -- 53
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 55
		end -- 55
		pushConsole(state, state.status) -- 57
	end -- 57
end -- 29
function ____exports.drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) -- 61
	ImGui.TextColored(themeColor, zh and "资源" or "Assets") -- 67
	ImGui.SameLine() -- 68
	if ImGui.SmallButton(zh and "＋ 文件" or "＋ File") then -- 68
		importFileDialog(state) -- 69
	end -- 69
	ImGui.SameLine() -- 70
	if ImGui.SmallButton(zh and "＋ 文件夹" or "＋ Folder") then -- 70
		importFolderDialog(state) -- 71
	end -- 71
	ImGui.Separator() -- 72
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 73
	ImGui.Separator() -- 74
	if #state.assets == 0 then -- 74
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 76
		return -- 77
	end -- 77
	for ____, asset in ipairs(state.assets) do -- 79
		if isFolderAsset(asset) then -- 79
			drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 81
		end -- 81
	end -- 81
	for ____, asset in ipairs(state.assets) do -- 84
		local insideFolder = false -- 85
		for ____, folder in ipairs(state.assets) do -- 86
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 86
				insideFolder = true -- 87
			end -- 87
		end -- 87
		if not insideFolder and not isFolderAsset(asset) then -- 87
			drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 89
		end -- 89
	end -- 89
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 89
		ImGui.Separator() -- 92
		ImGui.TextColored(themeColor, zh and "贴图预览" or "Texture Preview") -- 93
		local ok = pcall(function() return ImGui.Image( -- 94
			state.selectedAsset, -- 94
			Vec2(160, 120) -- 94
		) end) -- 94
		if not ok then -- 94
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 95
		end -- 95
		local selectedNode = state.nodes[state.selectedId] -- 96
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 96
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 96
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 98
			end -- 98
			ImGui.SameLine() -- 99
		end -- 99
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 99
			createSpriteFromTexture(state, state.selectedAsset) -- 101
		end -- 101
	end -- 101
end -- 61
return ____exports -- 61