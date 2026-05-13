-- [ts]: ScriptPanel.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local emit = ____Dora.emit -- 1
local json = ____Dora.json -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local inputTextFlags = ____Theme.inputTextFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local scriptPanelBg = ____Theme.scriptPanelBg -- 5
local themeColor = ____Theme.themeColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local isFolderAsset = ____Model.isFolderAsset -- 6
local isScriptAsset = ____Model.isScriptAsset -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 11
local function workspacePath(path) -- 12
	return SceneModel.workspacePath(path) -- 12
end -- 12
local function workspaceRoot() -- 13
	return SceneModel.workspaceRoot() -- 13
end -- 13
local function scriptTemplate(node) -- 17
	local name = node ~= nil and node.name or "Script" -- 18
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 17
local function gameMainTemplate() -- 29
	return ((((((((((((((((((((((((((("-- Game main script\n" .. "-- This file runs after the scene nodes are created.\n") .. "-- Use A/D or Left/Right to move the first Sprite node.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then\n") .. "\t\t\t\tplayer = node\n") .. "\t\t\tend\n") .. "\t\tend\n") .. "\t\tif player == nil then\n") .. "\t\t\tprint(\"[GameMain] no playable node found\")\n") .. "\t\t\treturn\n") .. "\t\tend\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then\n") .. "\t\t\t\tplayer.x = player.x - speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then\n") .. "\t\t\t\tplayer.x = player.x + speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 29
local function loadScriptIntoEditor(state, node, scriptPath, attachScriptToNode) -- 61
	if node ~= nil then -- 61
		attachScriptToNode(state, node, scriptPath) -- 68
	else -- 68
		state.activeScriptNodeId = nil -- 70
	end -- 70
	state.scriptPathBuffer.text = scriptPath -- 72
	local scriptFile = workspacePath(scriptPath) -- 73
	if Content:exist(scriptFile) then -- 73
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 75
	elseif Content:exist(scriptPath) then -- 75
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 77
	else -- 77
		state.scriptContentBuffer.text = scriptTemplate(node) -- 79
	end -- 79
	state.mode = "Script" -- 81
end -- 61
local function loadGameMainIntoEditor(state) -- 84
	state.activeScriptNodeId = "__game_main__" -- 85
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 86
	state.gameScript = scriptPath -- 87
	state.gameScriptBuffer.text = scriptPath -- 88
	state.scriptPathBuffer.text = scriptPath -- 89
	local scriptFile = workspacePath(scriptPath) -- 90
	if Content:exist(scriptFile) then -- 90
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 92
	elseif Content:exist(scriptPath) then -- 92
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 94
	else -- 94
		state.scriptContentBuffer.text = gameMainTemplate() -- 96
	end -- 96
	state.mode = "Script" -- 98
end -- 84
function ____exports.openScriptForNode(state, node, attachScriptToNode) -- 101
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 102
	loadScriptIntoEditor(state, node, path, attachScriptToNode) -- 103
end -- 101
local function saveScriptFile(state, node, attachScriptToNode) -- 106
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 107
	state.scriptPathBuffer.text = path -- 108
	local scriptFile = workspacePath(path) -- 109
	Content:mkdir(Path:getPath(scriptFile)) -- 110
	local statusAlreadyLogged = false -- 111
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 111
		if node ~= nil then -- 111
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 114
			statusAlreadyLogged = true -- 115
		else -- 115
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 117
		end -- 117
		if state.selectedAsset ~= path then -- 117
			state.selectedAsset = path -- 119
		end -- 119
		local exists = false -- 120
		for ____, asset in ipairs(state.assets) do -- 121
			if asset == path then -- 121
				exists = true -- 121
			end -- 121
		end -- 121
		if not exists then -- 121
			local ____state_assets_0 = state.assets -- 121
			____state_assets_0[#____state_assets_0 + 1] = path -- 122
		end -- 122
	else -- 122
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 124
	end -- 124
	if not statusAlreadyLogged then -- 124
		pushConsole(state, state.status) -- 126
	end -- 126
end -- 106
local function useCurrentScriptAsGameMain(state) -- 129
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/Main.lua" -- 130
	state.gameScript = path -- 131
	state.gameScriptBuffer.text = path -- 132
	state.status = (zh and "已设置游戏主脚本：" or "Game main script set: ") .. path -- 133
	pushConsole(state, state.status) -- 134
end -- 129
local function currentScriptPath(state, node) -- 137
	if state.scriptPathBuffer.text ~= "" then -- 137
		return state.scriptPathBuffer.text -- 138
	end -- 138
	if node ~= nil and node.script ~= "" then -- 138
		return node.script -- 139
	end -- 139
	if node ~= nil then -- 139
		return ("Script/" .. node.name) .. ".lua" -- 140
	end -- 140
	return "Script/NewScript.lua" -- 141
end -- 137
local function sendWebIDEMessage(payload) -- 144
	local text = json.encode(payload) -- 145
	if text ~= nil then -- 145
		emit("AppWS", "Send", text) -- 146
	end -- 146
end -- 144
local function openScriptInWebIDE(state, node, attachScriptToNode) -- 149
	local scriptPath = currentScriptPath(state, node) -- 150
	state.scriptPathBuffer.text = scriptPath -- 151
	if state.scriptContentBuffer.text == "" then -- 151
		state.scriptContentBuffer.text = scriptTemplate(node) -- 153
	end -- 153
	saveScriptFile(state, node, attachScriptToNode) -- 155
	local title = Path:getFilename(scriptPath) or scriptPath -- 156
	local root = workspaceRoot() -- 157
	local rootTitle = Path:getFilename(root) or "Workspace" -- 158
	local fullScriptPath = workspacePath(scriptPath) -- 159
	local openWorkspaceMessage = { -- 160
		name = "OpenFile", -- 161
		file = root, -- 162
		title = rootTitle, -- 163
		folder = true, -- 164
		workspaceView = "agent" -- 165
	} -- 165
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 167
	local openScriptMessage = { -- 173
		name = "OpenFile", -- 174
		file = fullScriptPath, -- 175
		title = title, -- 176
		folder = false, -- 177
		position = {lineNumber = 1, column = 1} -- 178
	} -- 178
	local function sendOpenMessages() -- 180
		sendWebIDEMessage(openWorkspaceMessage) -- 181
		sendWebIDEMessage(updateScriptMessage) -- 182
		sendWebIDEMessage(openScriptMessage) -- 183
	end -- 180
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 185
	local editingText = json.encode(editingInfo) -- 202
	if editingText ~= nil then -- 202
		Content:mkdir(workspacePath(".dora")) -- 204
		Content:save( -- 205
			workspacePath(Path(".dora", "open-script.editing.json")), -- 205
			editingText -- 205
		) -- 205
		pcall(function() -- 206
			local Entry = require("Script.Dev.Entry") -- 207
			local config = Entry.getConfig() -- 208
			if config ~= nil then -- 208
				config.editingInfo = editingText -- 209
			end -- 209
		end) -- 206
	end -- 206
	App:openURL("http://127.0.0.1:8866/") -- 212
	sendOpenMessages() -- 213
	thread(function() -- 214
		do -- 214
			local i = 0 -- 215
			while i < 4 do -- 215
				sleep(0.5) -- 216
				sendOpenMessages() -- 217
				i = i + 1 -- 215
			end -- 215
		end -- 215
	end) -- 214
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 220
	pushConsole(state, state.status) -- 221
end -- 149
local function drawScriptAssetList(state, node, attachScriptToNode) -- 224
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 225
	for ____, asset in ipairs(state.assets) do -- 226
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 226
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 226
				state.selectedAsset = asset -- 229
				loadScriptIntoEditor(state, node, asset, attachScriptToNode) -- 230
			end -- 230
		end -- 230
	end -- 230
end -- 224
function ____exports.drawScriptPanel(state, attachScriptToNode) -- 236
	local activeId = state.activeScriptNodeId or state.selectedId -- 237
	local node = state.nodes[activeId] -- 238
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 239
	ImGui.SameLine() -- 240
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 241
	ImGui.Separator() -- 242
	ImGui.BeginChild( -- 243
		"ScriptSidebar", -- 243
		Vec2(220, 0), -- 243
		{}, -- 243
		noScrollFlags, -- 243
		function() -- 243
			ImGui.TextColored(themeColor, zh and "游戏入口" or "Game Entry") -- 244
			ImGui.TextDisabled(state.gameScript ~= "" and state.gameScript or "Script/Main.lua") -- 245
			if ImGui.Button(zh and "打开主脚本" or "Open Main") then -- 245
				loadGameMainIntoEditor(state) -- 246
			end -- 246
			if ImGui.Button(zh and "当前脚本设为主入口" or "Use Current As Main") then -- 246
				useCurrentScriptAsGameMain(state) -- 247
			end -- 247
			ImGui.Separator() -- 248
			drawScriptAssetList(state, node, attachScriptToNode) -- 249
			ImGui.Separator() -- 250
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 250
				local scriptName = node ~= nil and node.name or "NewScript" -- 252
				local path = ("Script/" .. scriptName) .. ".lua" -- 253
				state.scriptPathBuffer.text = path -- 254
				state.scriptContentBuffer.text = scriptTemplate(node) -- 255
				if node ~= nil then -- 255
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 257
				end -- 257
			end -- 257
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 257
				importFileDialog(state) -- 260
			end -- 260
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 260
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 260
					loadScriptIntoEditor(state, node, state.selectedAsset, attachScriptToNode) -- 263
				end -- 263
			end -- 263
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 263
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text, attachScriptToNode) -- 267
			end -- 267
		end -- 243
	) -- 243
	ImGui.SameLine() -- 270
	ImGui.PushStyleColor( -- 271
		"ChildBg", -- 271
		scriptPanelBg, -- 271
		function() -- 271
			ImGui.BeginChild( -- 272
				"ScriptEditorPane", -- 272
				Vec2(0, 0), -- 272
				{}, -- 272
				noScrollFlags, -- 272
				function() -- 272
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 273
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 274
					ImGui.SameLine() -- 275
					if ImGui.Button(zh and "保存" or "Save") then -- 275
						saveScriptFile(state, node, attachScriptToNode) -- 276
					end -- 276
					ImGui.SameLine() -- 277
					if ImGui.Button(zh and "设为主入口" or "Set Main") then -- 277
						useCurrentScriptAsGameMain(state) -- 278
					end -- 278
					ImGui.SameLine() -- 279
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 279
						openScriptInWebIDE(state, node, attachScriptToNode) -- 280
					end -- 280
					if node ~= nil then -- 280
						ImGui.SameLine() -- 282
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 282
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 284
						end -- 284
					end -- 284
					ImGui.Separator() -- 287
					ImGui.InputTextMultiline( -- 288
						"##ScriptEditor", -- 288
						state.scriptContentBuffer, -- 288
						Vec2(0, -4), -- 288
						{} -- 288
					) -- 288
				end -- 272
			) -- 272
		end -- 271
	) -- 271
end -- 236
return ____exports -- 236