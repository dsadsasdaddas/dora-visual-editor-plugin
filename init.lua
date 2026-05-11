-- Dora Visual Editor package entry.
-- Runtime implementation lives under hidden .tools/ so Web IDE Agent treats this as a clean project.
local Dora = require("Dora")
local Content = Dora.Content
local Path = Dora.Path
local root = Content.searchPaths[1]
if root ~= nil and root ~= "" then
	Content:insertSearchPath(1, Path(root, ".tools"))
end
return require("Script.Tools.SceneImGuiEditor")
