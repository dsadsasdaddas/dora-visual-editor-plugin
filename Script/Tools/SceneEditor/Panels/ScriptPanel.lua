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
local SceneModel = require("Script.Tools.SceneEditor.Model") -- 26
local function workspacePath(path) -- 27
	return SceneModel.workspacePath(path) -- 27
end -- 27
local function workspaceRoot() -- 28
	return SceneModel.workspaceRoot() -- 28
end -- 28
local function scriptTemplate(node) -- 32
	local name = node ~= nil and node.name or "Script" -- 33
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 32
local function gameMainTemplate() -- 44
	return ((((((((((((((((((((((((((("-- Game main script\n" .. "-- This file runs after the scene nodes are created.\n") .. "-- Use A/D or Left/Right to move the first Sprite node.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then\n") .. "\t\t\t\tplayer = node\n") .. "\t\t\tend\n") .. "\t\tend\n") .. "\t\tif player == nil then\n") .. "\t\t\tprint(\"[GameMain] no playable node found\")\n") .. "\t\t\treturn\n") .. "\t\tend\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then\n") .. "\t\t\t\tplayer.x = player.x - speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then\n") .. "\t\t\t\tplayer.x = player.x + speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 44
local function loadScriptIntoEditor(state, node, scriptPath, attachScriptToNode) -- 76
	if node ~= nil then -- 76
		attachScriptToNode(state, node, scriptPath) -- 83
	else -- 83
		state.activeScriptNodeId = nil -- 85
	end -- 85
	state.scriptPathBuffer.text = scriptPath -- 87
	local scriptFile = workspacePath(scriptPath) -- 88
	if Content:exist(scriptFile) then -- 88
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 90
	elseif Content:exist(scriptPath) then -- 90
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 92
	else -- 92
		state.scriptContentBuffer.text = scriptTemplate(node) -- 94
	end -- 94
	state.mode = "Script" -- 96
end -- 76
local function loadGameMainIntoEditor(state) -- 99
	state.activeScriptNodeId = "__game_main__" -- 100
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 101
	state.gameScript = scriptPath -- 102
	state.gameScriptBuffer.text = scriptPath -- 103
	state.scriptPathBuffer.text = scriptPath -- 104
	local scriptFile = workspacePath(scriptPath) -- 105
	if Content:exist(scriptFile) then -- 105
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 107
	elseif Content:exist(scriptPath) then -- 107
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 109
	else -- 109
		state.scriptContentBuffer.text = gameMainTemplate() -- 111
	end -- 111
	state.mode = "Script" -- 113
end -- 99
function ____exports.openScriptForNode(state, node, attachScriptToNode) -- 116
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 117
	loadScriptIntoEditor(state, node, path, attachScriptToNode) -- 118
end -- 116
local function saveScriptFile(state, node, attachScriptToNode) -- 121
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 122
	state.scriptPathBuffer.text = path -- 123
	local scriptFile = workspacePath(path) -- 124
	Content:mkdir(Path:getPath(scriptFile)) -- 125
	local statusAlreadyLogged = false -- 126
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 126
		if node ~= nil then -- 126
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 129
			statusAlreadyLogged = true -- 130
		else -- 130
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 132
		end -- 132
		if state.selectedAsset ~= path then -- 132
			state.selectedAsset = path -- 134
		end -- 134
		local exists = false -- 135
		for ____, asset in ipairs(state.assets) do -- 136
			if asset == path then -- 136
				exists = true -- 136
			end -- 136
		end -- 136
		if not exists then -- 136
			local ____state_assets_0 = state.assets -- 136
			____state_assets_0[#____state_assets_0 + 1] = path -- 137
		end -- 137
	else -- 137
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 139
	end -- 139
	if not statusAlreadyLogged then -- 139
		pushConsole(state, state.status) -- 141
	end -- 141
end -- 121
local function useCurrentScriptAsGameMain(state) -- 144
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/Main.lua" -- 145
	state.gameScript = path -- 146
	state.gameScriptBuffer.text = path -- 147
	state.status = (zh and "已设置游戏主脚本：" or "Game main script set: ") .. path -- 148
	pushConsole(state, state.status) -- 149
end -- 144
local function currentScriptPath(state, node) -- 152
	if state.scriptPathBuffer.text ~= "" then -- 152
		return state.scriptPathBuffer.text -- 153
	end -- 153
	if node ~= nil and node.script ~= "" then -- 153
		return node.script -- 154
	end -- 154
	if node ~= nil then -- 154
		return ("Script/" .. node.name) .. ".lua" -- 155
	end -- 155
	return "Script/NewScript.lua" -- 156
end -- 152
local function sendWebIDEMessage(payload) -- 159
	local text = json.encode(payload) -- 160
	if text ~= nil then -- 160
		emit("AppWS", "Send", text) -- 161
	end -- 161
end -- 159
local function openScriptInWebIDE(state, node, attachScriptToNode) -- 164
	local scriptPath = currentScriptPath(state, node) -- 165
	state.scriptPathBuffer.text = scriptPath -- 166
	if state.scriptContentBuffer.text == "" then -- 166
		state.scriptContentBuffer.text = scriptTemplate(node) -- 168
	end -- 168
	saveScriptFile(state, node, attachScriptToNode) -- 170
	local title = Path:getFilename(scriptPath) or scriptPath -- 171
	local root = workspaceRoot() -- 172
	local rootTitle = Path:getFilename(root) or "Workspace" -- 173
	local fullScriptPath = workspacePath(scriptPath) -- 174
	local openWorkspaceMessage = { -- 175
		name = "OpenFile", -- 176
		file = root, -- 177
		title = rootTitle, -- 178
		folder = true, -- 179
		workspaceView = "agent" -- 180
	} -- 180
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 182
	local openScriptMessage = { -- 188
		name = "OpenFile", -- 189
		file = fullScriptPath, -- 190
		title = title, -- 191
		folder = false, -- 192
		position = {lineNumber = 1, column = 1} -- 193
	} -- 193
	local function sendOpenMessages() -- 195
		sendWebIDEMessage(openWorkspaceMessage) -- 196
		sendWebIDEMessage(updateScriptMessage) -- 197
		sendWebIDEMessage(openScriptMessage) -- 198
	end -- 195
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 200
	local editingText = json.encode(editingInfo) -- 217
	if editingText ~= nil then -- 217
		Content:mkdir(workspacePath(".dora")) -- 219
		Content:save( -- 220
			workspacePath(Path(".dora", "open-script.editing.json")), -- 220
			editingText -- 220
		) -- 220
		pcall(function() -- 221
			local Entry = require("Script.Dev.Entry") -- 222
			local config = Entry.getConfig() -- 223
			if config ~= nil then -- 223
				config.editingInfo = editingText -- 224
			end -- 224
		end) -- 221
	end -- 221
	App:openURL("http://127.0.0.1:8866/") -- 227
	sendOpenMessages() -- 228
	thread(function() -- 229
		do -- 229
			local i = 0 -- 230
			while i < 4 do -- 230
				sleep(0.5) -- 231
				sendOpenMessages() -- 232
				i = i + 1 -- 230
			end -- 230
		end -- 230
	end) -- 229
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 235
	pushConsole(state, state.status) -- 236
end -- 164
local function drawScriptAssetList(state, node, attachScriptToNode) -- 239
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 240
	for ____, asset in ipairs(state.assets) do -- 241
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 241
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 241
				state.selectedAsset = asset -- 244
				loadScriptIntoEditor(state, node, asset, attachScriptToNode) -- 245
			end -- 245
		end -- 245
	end -- 245
end -- 239
function ____exports.drawScriptPanel(state, attachScriptToNode) -- 251
	local activeId = state.activeScriptNodeId or state.selectedId -- 252
	local node = state.nodes[activeId] -- 253
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 254
	ImGui.SameLine() -- 255
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 256
	ImGui.Separator() -- 257
	ImGui.BeginChild( -- 258
		"ScriptSidebar", -- 258
		Vec2(220, 0), -- 258
		{}, -- 258
		noScrollFlags, -- 258
		function() -- 258
			ImGui.TextColored(themeColor, zh and "游戏入口" or "Game Entry") -- 259
			ImGui.TextDisabled(state.gameScript ~= "" and state.gameScript or "Script/Main.lua") -- 260
			if ImGui.Button(zh and "打开主脚本" or "Open Main") then -- 260
				loadGameMainIntoEditor(state) -- 261
			end -- 261
			if ImGui.Button(zh and "当前脚本设为主入口" or "Use Current As Main") then -- 261
				useCurrentScriptAsGameMain(state) -- 262
			end -- 262
			ImGui.Separator() -- 263
			drawScriptAssetList(state, node, attachScriptToNode) -- 264
			ImGui.Separator() -- 265
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 265
				local scriptName = node ~= nil and node.name or "NewScript" -- 267
				local path = ("Script/" .. scriptName) .. ".lua" -- 268
				state.scriptPathBuffer.text = path -- 269
				state.scriptContentBuffer.text = scriptTemplate(node) -- 270
				if node ~= nil then -- 270
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 272
				end -- 272
			end -- 272
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 272
				importFileDialog(state) -- 275
			end -- 275
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 275
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 275
					loadScriptIntoEditor(state, node, state.selectedAsset, attachScriptToNode) -- 278
				end -- 278
			end -- 278
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 278
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text, attachScriptToNode) -- 282
			end -- 282
		end -- 258
	) -- 258
	ImGui.SameLine() -- 285
	ImGui.PushStyleColor( -- 286
		"ChildBg", -- 286
		scriptPanelBg, -- 286
		function() -- 286
			ImGui.BeginChild( -- 287
				"ScriptEditorPane", -- 287
				Vec2(0, 0), -- 287
				{}, -- 287
				noScrollFlags, -- 287
				function() -- 287
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 288
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 289
					ImGui.SameLine() -- 290
					if ImGui.Button(zh and "保存" or "Save") then -- 290
						saveScriptFile(state, node, attachScriptToNode) -- 291
					end -- 291
					ImGui.SameLine() -- 292
					if ImGui.Button(zh and "设为主入口" or "Set Main") then -- 292
						useCurrentScriptAsGameMain(state) -- 293
					end -- 293
					ImGui.SameLine() -- 294
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 294
						openScriptInWebIDE(state, node, attachScriptToNode) -- 295
					end -- 295
					if node ~= nil then -- 295
						ImGui.SameLine() -- 297
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 297
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 299
						end -- 299
					end -- 299
					ImGui.Separator() -- 302
					ImGui.InputTextMultiline( -- 303
						"##ScriptEditor", -- 303
						state.scriptContentBuffer, -- 303
						Vec2(0, -4), -- 303
						{} -- 303
					) -- 303
				end -- 287
			) -- 287
		end -- 286
	) -- 286
end -- 251
return ____exports -- 251