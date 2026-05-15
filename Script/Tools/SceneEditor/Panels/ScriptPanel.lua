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
local workspacePath = ____Model.workspacePath -- 6
local workspaceRoot = ____Model.workspaceRoot -- 6
local zh = ____Model.zh -- 6
local function scriptTemplate(node) -- 22
	local name = node ~= nil and node.name or "Script" -- 23
	return (((((((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] ") .. name) .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n") .. "\tend\n") .. "\t-- write behavior here\n") .. "end\n"
end -- 22
local function gameMainTemplate() -- 34
	return ((((((((((((((((((((((((((("-- Game main script\n" .. "-- This file runs after the scene nodes are created.\n") .. "-- Use A/D or Left/Right to move the first Sprite node.\n") .. "local _ENV = Dora\n\n") .. "return {\n") .. "\tstart = function(scene, nodes, world)\n") .. "\t\tlocal player = nil\n") .. "\t\tfor _, node in pairs(nodes) do\n") .. "\t\t\tlocal tag = tostring(node.tag or \"\")\n") .. "\t\t\tif node ~= scene and player == nil and string.find(tag, \"Camera\") == nil then\n") .. "\t\t\t\tplayer = node\n") .. "\t\t\tend\n") .. "\t\tend\n") .. "\t\tif player == nil then\n") .. "\t\t\tprint(\"[GameMain] no playable node found\")\n") .. "\t\t\treturn\n") .. "\t\tend\n") .. "\t\tscene:schedule(function(deltaTime)\n") .. "\t\t\tlocal speed = 220\n") .. "\t\t\tif Keyboard:isKeyPressed(\"A\") or Keyboard:isKeyPressed(\"Left\") then\n") .. "\t\t\t\tplayer.x = player.x - speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\tif Keyboard:isKeyPressed(\"D\") or Keyboard:isKeyPressed(\"Right\") then\n") .. "\t\t\t\tplayer.x = player.x + speed * deltaTime\n") .. "\t\t\tend\n") .. "\t\t\treturn false\n") .. "\t\tend)\n") .. "\tend\n") .. "}\n"
end -- 34
local function loadScriptIntoEditor(state, node, scriptPath, attachScriptToNode) -- 66
	if node ~= nil then -- 66
		attachScriptToNode(state, node, scriptPath) -- 73
	else -- 73
		state.activeScriptNodeId = nil -- 75
	end -- 75
	state.scriptPathBuffer.text = scriptPath -- 77
	local scriptFile = workspacePath(scriptPath) -- 78
	if Content:exist(scriptFile) then -- 78
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 80
	elseif Content:exist(scriptPath) then -- 80
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 82
	else -- 82
		state.scriptContentBuffer.text = scriptTemplate(node) -- 84
	end -- 84
	state.mode = "Script" -- 86
end -- 66
local function loadGameMainIntoEditor(state) -- 89
	state.activeScriptNodeId = "__game_main__" -- 90
	local scriptPath = state.gameScript ~= "" and state.gameScript or "Script/Main.lua" -- 91
	state.gameScript = scriptPath -- 92
	state.gameScriptBuffer.text = scriptPath -- 93
	state.scriptPathBuffer.text = scriptPath -- 94
	local scriptFile = workspacePath(scriptPath) -- 95
	if Content:exist(scriptFile) then -- 95
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 97
	elseif Content:exist(scriptPath) then -- 97
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 99
	else -- 99
		state.scriptContentBuffer.text = gameMainTemplate() -- 101
	end -- 101
	state.mode = "Script" -- 103
end -- 89
function ____exports.openScriptForNode(state, node, attachScriptToNode) -- 106
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 107
	loadScriptIntoEditor(state, node, path, attachScriptToNode) -- 108
end -- 106
local function saveScriptFile(state, node, attachScriptToNode) -- 111
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 112
	state.scriptPathBuffer.text = path -- 113
	local scriptFile = workspacePath(path) -- 114
	Content:mkdir(Path:getPath(scriptFile)) -- 115
	local statusAlreadyLogged = false -- 116
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 116
		if node ~= nil then -- 116
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 119
			statusAlreadyLogged = true -- 120
		else -- 120
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 122
		end -- 122
		if state.selectedAsset ~= path then -- 122
			state.selectedAsset = path -- 124
		end -- 124
		local exists = false -- 125
		for ____, asset in ipairs(state.assets) do -- 126
			if asset == path then -- 126
				exists = true -- 126
			end -- 126
		end -- 126
		if not exists then -- 126
			local ____state_assets_0 = state.assets -- 126
			____state_assets_0[#____state_assets_0 + 1] = path -- 127
		end -- 127
	else -- 127
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 129
	end -- 129
	if not statusAlreadyLogged then -- 129
		pushConsole(state, state.status) -- 131
	end -- 131
end -- 111
local function useCurrentScriptAsGameMain(state) -- 134
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/Main.lua" -- 135
	state.gameScript = path -- 136
	state.gameScriptBuffer.text = path -- 137
	state.status = (zh and "已设置游戏主脚本：" or "Game main script set: ") .. path -- 138
	pushConsole(state, state.status) -- 139
end -- 134
local function currentScriptPath(state, node) -- 142
	if state.scriptPathBuffer.text ~= "" then -- 142
		return state.scriptPathBuffer.text -- 143
	end -- 143
	if node ~= nil and node.script ~= "" then -- 143
		return node.script -- 144
	end -- 144
	if node ~= nil then -- 144
		return ("Script/" .. node.name) .. ".lua" -- 145
	end -- 145
	return "Script/NewScript.lua" -- 146
end -- 142
local function sendWebIDEMessage(payload) -- 149
	local text = json.encode(payload) -- 150
	if text ~= nil then -- 150
		emit("AppWS", "Send", text) -- 151
	end -- 151
end -- 149
local function openScriptInWebIDE(state, node, attachScriptToNode) -- 154
	local scriptPath = currentScriptPath(state, node) -- 155
	state.scriptPathBuffer.text = scriptPath -- 156
	if state.scriptContentBuffer.text == "" then -- 156
		state.scriptContentBuffer.text = scriptTemplate(node) -- 158
	end -- 158
	saveScriptFile(state, node, attachScriptToNode) -- 160
	local title = Path:getFilename(scriptPath) or scriptPath -- 161
	local root = workspaceRoot() -- 162
	local rootTitle = Path:getFilename(root) or "Workspace" -- 163
	local fullScriptPath = workspacePath(scriptPath) -- 164
	local openWorkspaceMessage = { -- 165
		name = "OpenFile", -- 166
		file = root, -- 167
		title = rootTitle, -- 168
		folder = true, -- 169
		workspaceView = "agent" -- 170
	} -- 170
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 172
	local openScriptMessage = { -- 178
		name = "OpenFile", -- 179
		file = fullScriptPath, -- 180
		title = title, -- 181
		folder = false, -- 182
		position = {lineNumber = 1, column = 1} -- 183
	} -- 183
	local function sendOpenMessages() -- 185
		sendWebIDEMessage(openWorkspaceMessage) -- 186
		sendWebIDEMessage(updateScriptMessage) -- 187
		sendWebIDEMessage(openScriptMessage) -- 188
	end -- 185
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 190
	local editingText = json.encode(editingInfo) -- 207
	if editingText ~= nil then -- 207
		Content:mkdir(workspacePath(".dora")) -- 209
		Content:save( -- 210
			workspacePath(Path(".dora", "open-script.editing.json")), -- 210
			editingText -- 210
		) -- 210
		pcall(function() -- 211
			local Entry = require("Script.Dev.Entry") -- 212
			local config = Entry.getConfig() -- 213
			if config ~= nil then -- 213
				config.editingInfo = editingText -- 214
			end -- 214
		end) -- 211
	end -- 211
	App:openURL("http://127.0.0.1:8866/") -- 217
	sendOpenMessages() -- 218
	thread(function() -- 219
		do -- 219
			local i = 0 -- 220
			while i < 4 do -- 220
				sleep(0.5) -- 221
				sendOpenMessages() -- 222
				i = i + 1 -- 220
			end -- 220
		end -- 220
	end) -- 219
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 225
	pushConsole(state, state.status) -- 226
end -- 154
local function drawScriptAssetList(state, node, attachScriptToNode) -- 229
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 230
	for ____, asset in ipairs(state.assets) do -- 231
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 231
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 231
				state.selectedAsset = asset -- 234
				loadScriptIntoEditor(state, node, asset, attachScriptToNode) -- 235
			end -- 235
		end -- 235
	end -- 235
end -- 229
function ____exports.drawScriptPanel(state, attachScriptToNode) -- 241
	local activeId = state.activeScriptNodeId or state.selectedId -- 242
	local node = state.nodes[activeId] -- 243
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 244
	ImGui.SameLine() -- 245
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 246
	ImGui.Separator() -- 247
	ImGui.BeginChild( -- 248
		"ScriptSidebar", -- 248
		Vec2(220, 0), -- 248
		{}, -- 248
		noScrollFlags, -- 248
		function() -- 248
			ImGui.TextColored(themeColor, zh and "游戏入口" or "Game Entry") -- 249
			ImGui.TextDisabled(state.gameScript ~= "" and state.gameScript or "Script/Main.lua") -- 250
			if ImGui.Button(zh and "打开主脚本" or "Open Main") then -- 250
				loadGameMainIntoEditor(state) -- 251
			end -- 251
			if ImGui.Button(zh and "当前脚本设为主入口" or "Use Current As Main") then -- 251
				useCurrentScriptAsGameMain(state) -- 252
			end -- 252
			ImGui.Separator() -- 253
			drawScriptAssetList(state, node, attachScriptToNode) -- 254
			ImGui.Separator() -- 255
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 255
				local scriptName = node ~= nil and node.name or "NewScript" -- 257
				local path = ("Script/" .. scriptName) .. ".lua" -- 258
				state.scriptPathBuffer.text = path -- 259
				state.scriptContentBuffer.text = scriptTemplate(node) -- 260
				if node ~= nil then -- 260
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 262
				end -- 262
			end -- 262
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 262
				importFileDialog(state) -- 265
			end -- 265
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 265
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 265
					loadScriptIntoEditor(state, node, state.selectedAsset, attachScriptToNode) -- 268
				end -- 268
			end -- 268
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 268
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text, attachScriptToNode) -- 272
			end -- 272
		end -- 248
	) -- 248
	ImGui.SameLine() -- 275
	ImGui.PushStyleColor( -- 276
		"ChildBg", -- 276
		scriptPanelBg, -- 276
		function() -- 276
			ImGui.BeginChild( -- 277
				"ScriptEditorPane", -- 277
				Vec2(0, 0), -- 277
				{}, -- 277
				noScrollFlags, -- 277
				function() -- 277
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 278
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 279
					ImGui.SameLine() -- 280
					if ImGui.Button(zh and "保存" or "Save") then -- 280
						saveScriptFile(state, node, attachScriptToNode) -- 281
					end -- 281
					ImGui.SameLine() -- 282
					if ImGui.Button(zh and "设为主入口" or "Set Main") then -- 282
						useCurrentScriptAsGameMain(state) -- 283
					end -- 283
					ImGui.SameLine() -- 284
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 284
						openScriptInWebIDE(state, node, attachScriptToNode) -- 285
					end -- 285
					if node ~= nil then -- 285
						ImGui.SameLine() -- 287
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 287
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 289
						end -- 289
					end -- 289
					ImGui.Separator() -- 292
					ImGui.InputTextMultiline( -- 293
						"##ScriptEditor", -- 293
						state.scriptContentBuffer, -- 293
						Vec2(0, -4), -- 293
						{} -- 293
					) -- 293
				end -- 277
			) -- 277
		end -- 276
	) -- 276
end -- 241
return ____exports -- 241