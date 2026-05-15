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
local ____NodeCapabilities = require("Script.Tools.SceneEditor.NodeCapabilities") -- 6
local canNodeKindBindScript = ____NodeCapabilities.canNodeKindBindScript -- 6
local canNodeKindBindTexture = ____NodeCapabilities.canNodeKindBindTexture -- 6
local function assetIcon(asset) -- 14
	if isFolderAsset(asset) then -- 14
		return "📁" -- 15
	end -- 15
	if isTextureAsset(asset) then -- 15
		return "🖼" -- 16
	end -- 16
	if isScriptAsset(asset) then -- 16
		return "◇" -- 17
	end -- 17
	local ext = lowerExt(asset) -- 18
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 18
		return "♪" -- 19
	end -- 19
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 19
		return "F" -- 20
	end -- 20
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 20
		return "{}" -- 21
	end -- 21
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 21
		return "◆" -- 22
	end -- 22
	return "·" -- 23
end -- 14
local function startsWith(text, prefix) -- 26
	return string.sub( -- 27
		text, -- 27
		1, -- 27
		string.len(prefix) -- 27
	) == prefix -- 27
end -- 26
local function drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 30
	if isFolderAsset(asset) then -- 30
		ImGui.TreeNode( -- 37
			(assetIcon(asset) .. "  ") .. asset, -- 37
			function() -- 37
				for ____, child in ipairs(state.assets) do -- 38
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 38
						drawAssetRow(state, child, bindTextureToSprite, attachScriptToNode) -- 40
					end -- 40
				end -- 40
			end -- 37
		) -- 37
		return -- 44
	end -- 44
	if ImGui.Selectable( -- 44
		(assetIcon(asset) .. "  ") .. asset, -- 46
		state.selectedAsset == asset -- 46
	) then -- 46
		state.selectedAsset = asset -- 47
		if state.isPlaying then -- 47
			state.status = zh and "运行中资源只允许选择，不会改场景。点 Stop 后再绑定。" or "Play Mode: asset selection is read-only. Stop to bind assets." -- 49
			pushConsole(state, state.status) -- 50
			return -- 51
		end -- 51
		local node = state.nodes[state.selectedId] -- 53
		if node ~= nil and canNodeKindBindTexture(node.kind) and isTextureAsset(asset) then -- 53
			bindTextureToSprite(state, node, asset) -- 55
			return -- 56
		elseif node ~= nil and canNodeKindBindScript(node.kind) and isScriptAsset(asset) then -- 56
			attachScriptToNode(state, node, asset, (zh and "已绑定脚本并保存：" or "Script assigned and saved: ") .. asset) -- 58
			return -- 59
		else -- 59
			state.status = zh and "已选择资源；选中支持的节点可绑定图片或脚本" or "Asset selected; select a compatible node to bind images or scripts" -- 61
		end -- 61
		pushConsole(state, state.status) -- 63
	end -- 63
end -- 30
function ____exports.drawAssetsPanel(state, bindTextureToSprite, createSpriteFromTexture, attachScriptToNode) -- 67
	ImGui.TextColored(themeColor, zh and "资源" or "Assets") -- 73
	ImGui.SameLine() -- 74
	if ImGui.SmallButton(zh and "＋ 文件" or "＋ File") then -- 74
		importFileDialog(state) -- 75
	end -- 75
	ImGui.SameLine() -- 76
	if ImGui.SmallButton(zh and "＋ 文件夹" or "＋ Folder") then -- 76
		importFolderDialog(state) -- 77
	end -- 77
	ImGui.Separator() -- 78
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 79
	ImGui.Separator() -- 80
	if #state.assets == 0 then -- 80
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 82
		return -- 83
	end -- 83
	for ____, asset in ipairs(state.assets) do -- 85
		if isFolderAsset(asset) then -- 85
			drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 87
		end -- 87
	end -- 87
	for ____, asset in ipairs(state.assets) do -- 90
		local insideFolder = false -- 91
		for ____, folder in ipairs(state.assets) do -- 92
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 92
				insideFolder = true -- 93
			end -- 93
		end -- 93
		if not insideFolder and not isFolderAsset(asset) then -- 93
			drawAssetRow(state, asset, bindTextureToSprite, attachScriptToNode) -- 95
		end -- 95
	end -- 95
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 95
		ImGui.Separator() -- 98
		ImGui.TextColored(themeColor, zh and "贴图预览" or "Texture Preview") -- 99
		local ok = pcall(function() return ImGui.Image( -- 100
			state.selectedAsset, -- 100
			Vec2(160, 120) -- 100
		) end) -- 100
		if not ok then -- 100
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 101
		end -- 101
		local selectedNode = state.nodes[state.selectedId] -- 102
		if state.isPlaying then -- 102
			ImGui.BeginDisabled(function() -- 104
				ImGui.Button(zh and "绑定到当前节点" or "Bind To Node") -- 105
				ImGui.SameLine() -- 106
				ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") -- 107
			end) -- 104
		else -- 104
			if selectedNode ~= nil and canNodeKindBindTexture(selectedNode.kind) then -- 104
				if ImGui.Button(zh and "绑定到当前节点" or "Bind To Node") then -- 104
					bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 111
				end -- 111
				ImGui.SameLine() -- 112
			end -- 112
			if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 112
				createSpriteFromTexture(state, state.selectedAsset) -- 114
			end -- 114
		end -- 114
	end -- 114
end -- 67
return ____exports -- 67