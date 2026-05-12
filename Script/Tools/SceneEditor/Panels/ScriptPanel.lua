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
local function loadScriptIntoEditor(state, node, scriptPath, attachScriptToNode) -- 29
	if node ~= nil then -- 29
		attachScriptToNode(state, node, scriptPath) -- 36
	else -- 36
		state.activeScriptNodeId = nil -- 38
	end -- 38
	state.scriptPathBuffer.text = scriptPath -- 40
	local scriptFile = workspacePath(scriptPath) -- 41
	if Content:exist(scriptFile) then -- 41
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 43
	elseif Content:exist(scriptPath) then -- 43
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 45
	else -- 45
		state.scriptContentBuffer.text = scriptTemplate(node) -- 47
	end -- 47
	state.mode = "Script" -- 49
end -- 29
function ____exports.openScriptForNode(state, node, attachScriptToNode) -- 52
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 53
	loadScriptIntoEditor(state, node, path, attachScriptToNode) -- 54
end -- 52
local function saveScriptFile(state, node, attachScriptToNode) -- 57
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 58
	state.scriptPathBuffer.text = path -- 59
	local scriptFile = workspacePath(path) -- 60
	Content:mkdir(Path:getPath(scriptFile)) -- 61
	local statusAlreadyLogged = false -- 62
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 62
		if node ~= nil then -- 62
			attachScriptToNode(state, node, path, (zh and "脚本已保存并挂载：" or "Script saved and attached: ") .. path) -- 65
			statusAlreadyLogged = true -- 66
		else -- 66
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 68
		end -- 68
		if state.selectedAsset ~= path then -- 68
			state.selectedAsset = path -- 70
		end -- 70
		local exists = false -- 71
		for ____, asset in ipairs(state.assets) do -- 72
			if asset == path then -- 72
				exists = true -- 72
			end -- 72
		end -- 72
		if not exists then -- 72
			local ____state_assets_0 = state.assets -- 72
			____state_assets_0[#____state_assets_0 + 1] = path -- 73
		end -- 73
	else -- 73
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 75
	end -- 75
	if not statusAlreadyLogged then -- 75
		pushConsole(state, state.status) -- 77
	end -- 77
end -- 57
local function currentScriptPath(state, node) -- 80
	if state.scriptPathBuffer.text ~= "" then -- 80
		return state.scriptPathBuffer.text -- 81
	end -- 81
	if node ~= nil and node.script ~= "" then -- 81
		return node.script -- 82
	end -- 82
	if node ~= nil then -- 82
		return ("Script/" .. node.name) .. ".lua" -- 83
	end -- 83
	return "Script/NewScript.lua" -- 84
end -- 80
local function sendWebIDEMessage(payload) -- 87
	local text = json.encode(payload) -- 88
	if text ~= nil then -- 88
		emit("AppWS", "Send", text) -- 89
	end -- 89
end -- 87
local function openScriptInWebIDE(state, node, attachScriptToNode) -- 92
	local scriptPath = currentScriptPath(state, node) -- 93
	state.scriptPathBuffer.text = scriptPath -- 94
	if state.scriptContentBuffer.text == "" then -- 94
		state.scriptContentBuffer.text = scriptTemplate(node) -- 96
	end -- 96
	saveScriptFile(state, node, attachScriptToNode) -- 98
	local title = Path:getFilename(scriptPath) or scriptPath -- 99
	local root = workspaceRoot() -- 100
	local rootTitle = Path:getFilename(root) or "Workspace" -- 101
	local fullScriptPath = workspacePath(scriptPath) -- 102
	local openWorkspaceMessage = { -- 103
		name = "OpenFile", -- 104
		file = root, -- 105
		title = rootTitle, -- 106
		folder = true, -- 107
		workspaceView = "agent" -- 108
	} -- 108
	local updateScriptMessage = {name = "UpdateFile", file = fullScriptPath, exists = true, content = state.scriptContentBuffer.text} -- 110
	local openScriptMessage = { -- 116
		name = "OpenFile", -- 117
		file = fullScriptPath, -- 118
		title = title, -- 119
		folder = false, -- 120
		position = {lineNumber = 1, column = 1} -- 121
	} -- 121
	local function sendOpenMessages() -- 123
		sendWebIDEMessage(openWorkspaceMessage) -- 124
		sendWebIDEMessage(updateScriptMessage) -- 125
		sendWebIDEMessage(openScriptMessage) -- 126
	end -- 123
	local editingInfo = {index = 1, files = {{key = root, title = rootTitle, folder = true, workspaceView = "agent"}, {key = fullScriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 128
	local editingText = json.encode(editingInfo) -- 145
	if editingText ~= nil then -- 145
		Content:mkdir(workspacePath(".dora")) -- 147
		Content:save( -- 148
			workspacePath(Path(".dora", "open-script.editing.json")), -- 148
			editingText -- 148
		) -- 148
		pcall(function() -- 149
			local Entry = require("Script.Dev.Entry") -- 150
			local config = Entry.getConfig() -- 151
			if config ~= nil then -- 151
				config.editingInfo = editingText -- 152
			end -- 152
		end) -- 149
	end -- 149
	App:openURL("http://127.0.0.1:8866/") -- 155
	sendOpenMessages() -- 156
	thread(function() -- 157
		do -- 157
			local i = 0 -- 158
			while i < 4 do -- 158
				sleep(0.5) -- 159
				sendOpenMessages() -- 160
				i = i + 1 -- 158
			end -- 158
		end -- 158
	end) -- 157
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 163
	pushConsole(state, state.status) -- 164
end -- 92
local function drawScriptAssetList(state, node, attachScriptToNode) -- 167
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 168
	for ____, asset in ipairs(state.assets) do -- 169
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 169
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 169
				state.selectedAsset = asset -- 172
				loadScriptIntoEditor(state, node, asset, attachScriptToNode) -- 173
			end -- 173
		end -- 173
	end -- 173
end -- 167
function ____exports.drawScriptPanel(state, attachScriptToNode) -- 179
	local activeId = state.activeScriptNodeId or state.selectedId -- 180
	local node = state.nodes[activeId] -- 181
	ImGui.TextColored(themeColor, zh and "脚本编辑器" or "Script Editor") -- 182
	ImGui.SameLine() -- 183
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 184
	ImGui.Separator() -- 185
	ImGui.BeginChild( -- 186
		"ScriptSidebar", -- 186
		Vec2(220, 0), -- 186
		{}, -- 186
		noScrollFlags, -- 186
		function() -- 186
			drawScriptAssetList(state, node, attachScriptToNode) -- 187
			ImGui.Separator() -- 188
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 188
				local scriptName = node ~= nil and node.name or "NewScript" -- 190
				local path = ("Script/" .. scriptName) .. ".lua" -- 191
				state.scriptPathBuffer.text = path -- 192
				state.scriptContentBuffer.text = scriptTemplate(node) -- 193
				if node ~= nil then -- 193
					attachScriptToNode(state, node, path, (zh and "已新建脚本并挂载：" or "New script attached and saved: ") .. path) -- 195
				end -- 195
			end -- 195
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 195
				importFileDialog(state) -- 198
			end -- 198
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 198
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 198
					loadScriptIntoEditor(state, node, state.selectedAsset, attachScriptToNode) -- 201
				end -- 201
			end -- 201
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 201
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text, attachScriptToNode) -- 205
			end -- 205
		end -- 186
	) -- 186
	ImGui.SameLine() -- 208
	ImGui.PushStyleColor( -- 209
		"ChildBg", -- 209
		scriptPanelBg, -- 209
		function() -- 209
			ImGui.BeginChild( -- 210
				"ScriptEditorPane", -- 210
				Vec2(0, 0), -- 210
				{}, -- 210
				noScrollFlags, -- 210
				function() -- 210
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 211
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 212
					ImGui.SameLine() -- 213
					if ImGui.Button(zh and "保存" or "Save") then -- 213
						saveScriptFile(state, node, attachScriptToNode) -- 214
					end -- 214
					ImGui.SameLine() -- 215
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 215
						openScriptInWebIDE(state, node, attachScriptToNode) -- 216
					end -- 216
					if node ~= nil then -- 216
						ImGui.SameLine() -- 218
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 218
							attachScriptToNode(state, node, state.scriptPathBuffer.text, (zh and "脚本已挂载并保存到节点：" or "Script attached and saved to node: ") .. node.name) -- 220
						end -- 220
					end -- 220
					ImGui.Separator() -- 223
					ImGui.InputTextMultiline( -- 224
						"##ScriptEditor", -- 224
						state.scriptContentBuffer, -- 224
						Vec2(0, -4), -- 224
						{} -- 224
					) -- 224
				end -- 210
			) -- 210
		end -- 209
	) -- 209
end -- 179
return ____exports -- 179