-- [ts]: SceneImGuiEditor.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local threadLoop = ____Dora.threadLoop -- 2
local ____Model = require("Script.Tools.SceneEditor.Model") -- 3
local createEditorState = ____Model.createEditorState -- 3
local addNode = ____Model.addNode -- 3
local loadSceneFromFile = ____Model.loadSceneFromFile -- 3
local ____Panels = require("Script.Tools.SceneEditor.Panels") -- 4
local drawEditor = ____Panels.drawEditor -- 4
local drawRuntimeError = ____Panels.drawRuntimeError -- 4
local editor = createEditorState() -- 7
if not loadSceneFromFile( -- 7
	editor, -- 8
	Path(Content.writablePath, ".dora", "imgui-editor.scene.json") -- 8
) then -- 8
	addNode(editor, "Root", "MainScene") -- 9
	addNode(editor, "Camera", "Camera2D", "root") -- 10
end -- 10
local runtimeError = nil -- 13
threadLoop(function() -- 15
	if runtimeError ~= nil then -- 15
		drawRuntimeError(runtimeError) -- 17
		return false -- 18
	end -- 18
	local ok, err = pcall(function() return drawEditor(editor) end) -- 20
	if not ok then -- 20
		runtimeError = tostring(err) -- 22
	end -- 22
	return false -- 24
end) -- 15
____exports.default = editor -- 27
return ____exports -- 27