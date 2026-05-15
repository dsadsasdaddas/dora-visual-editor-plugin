-- [ts]: SceneGraph.ts
local ____exports = {} -- 1
local ____NodeCatalog = require("Script.Tools.SceneEditor.NodeCatalog") -- 2
local canNodeKindHaveChildren = ____NodeCatalog.canNodeKindHaveChildren -- 2
local nodeKindIcon = ____NodeCatalog.nodeKindIcon -- 2
local nodeKindLabel = ____NodeCatalog.nodeKindLabel -- 2
local function ensureTreeExpanded(state) -- 18
	if state.treeExpanded.root == nil then -- 18
		state.treeExpanded.root = true -- 19
	end -- 19
end -- 18
local function isValidNode(state, id) -- 22
	return id ~= "" and state.nodes[id] ~= nil -- 23
end -- 22
function ____exports.canNodeHaveChildren(node) -- 26
	return node ~= nil and canNodeKindHaveChildren(node.kind) -- 27
end -- 26
function ____exports.isAncestorOf(state, ancestorId, nodeId) -- 30
	local visited = {} -- 31
	local cursor = state.nodes[nodeId] -- 32
	while cursor ~= nil do -- 32
		if cursor.id == ancestorId then -- 32
			return true -- 34
		end -- 34
		if visited[cursor.id] then -- 34
			return false -- 35
		end -- 35
		visited[cursor.id] = true -- 36
		if cursor.parentId == nil or cursor.parentId == "" or cursor.parentId == cursor.id then -- 36
			return false -- 37
		end -- 37
		cursor = state.nodes[cursor.parentId] -- 38
	end -- 38
	return false -- 40
end -- 30
function ____exports.rebuildSceneChildren(state) -- 43
	for ____, id in ipairs(state.order) do -- 44
		local node = state.nodes[id] -- 45
		if node ~= nil then -- 45
			node.children = {} -- 46
		end -- 46
	end -- 46
	for ____, id in ipairs(state.order) do -- 48
		do -- 48
			if id == "root" then -- 48
				goto __continue15 -- 49
			end -- 49
			local node = state.nodes[id] -- 50
			if node == nil then -- 50
				goto __continue15 -- 51
			end -- 51
			local parentId = node.parentId or "root" -- 52
			if not isValidNode(state, parentId) or not ____exports.canNodeHaveChildren(state.nodes[parentId]) or ____exports.isAncestorOf(state, id, parentId) then -- 52
				parentId = "root" -- 54
			end -- 54
			node.parentId = parentId -- 56
			local parent = state.nodes[parentId] -- 57
			if parent ~= nil then -- 57
				local ____parent_children_0 = parent.children -- 57
				____parent_children_0[#____parent_children_0 + 1] = id -- 58
			end -- 58
		end -- 58
		::__continue15:: -- 58
	end -- 58
end -- 43
function ____exports.normalizeSceneGraph(state) -- 62
	ensureTreeExpanded(state) -- 63
	local root = state.nodes.root -- 64
	if root ~= nil then -- 64
		root.kind = "Root" -- 66
		root.parentId = "" -- 67
	end -- 67
	____exports.rebuildSceneChildren(state) -- 69
	if not isValidNode(state, state.selectedId) then -- 69
		state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root") -- 70
	end -- 70
	for ____, id in ipairs(state.order) do -- 71
		local node = state.nodes[id] -- 72
		if node ~= nil and state.treeExpanded[id] == nil then -- 72
			state.treeExpanded[id] = true -- 73
		end -- 73
	end -- 73
end -- 62
function ____exports.worldPositionOf(state, id) -- 77
	local x = 0 -- 78
	local y = 0 -- 79
	local visited = {} -- 80
	local cursor = state.nodes[id] -- 81
	while cursor ~= nil do -- 81
		if visited[cursor.id] then -- 81
			break -- 83
		end -- 83
		visited[cursor.id] = true -- 84
		x = x + cursor.x -- 85
		y = y + cursor.y -- 86
		if cursor.parentId == nil or cursor.parentId == "" or cursor.parentId == cursor.id then -- 86
			break -- 87
		end -- 87
		cursor = state.nodes[cursor.parentId] -- 88
	end -- 88
	return {x, y} -- 90
end -- 77
function ____exports.canReparentSceneNode(state, id, newParentId) -- 93
	if id == "root" then -- 93
		return false -- 94
	end -- 94
	local node = state.nodes[id] -- 95
	local newParent = state.nodes[newParentId] -- 96
	if node == nil or newParent == nil then -- 96
		return false -- 97
	end -- 97
	if node.parentId == newParentId then -- 97
		return false -- 98
	end -- 98
	if not ____exports.canNodeHaveChildren(newParent) then -- 98
		return false -- 99
	end -- 99
	if id == newParentId then -- 99
		return false -- 100
	end -- 100
	if ____exports.isAncestorOf(state, id, newParentId) then -- 100
		return false -- 101
	end -- 101
	return true -- 102
end -- 93
function ____exports.reparentSceneNode(state, id, newParentId) -- 105
	if not ____exports.canReparentSceneNode(state, id, newParentId) then -- 105
		return false -- 106
	end -- 106
	local node = state.nodes[id] -- 107
	local newParent = state.nodes[newParentId] -- 108
	if node == nil or newParent == nil then -- 108
		return false -- 109
	end -- 109
	local worldX, worldY = table.unpack( -- 110
		____exports.worldPositionOf(state, id), -- 110
		1, -- 110
		2 -- 110
	) -- 110
	local parentWorldX, parentWorldY = table.unpack( -- 111
		____exports.worldPositionOf(state, newParentId), -- 111
		1, -- 111
		2 -- 111
	) -- 111
	local oldParent = node.parentId ~= nil and node.parentId ~= "" and state.nodes[node.parentId] or nil -- 112
	if oldParent ~= nil then -- 112
		do -- 112
			local i = #oldParent.children -- 114
			while i >= 1 do -- 114
				if oldParent.children[i] == id then -- 114
					table.remove(oldParent.children, i) -- 115
				end -- 115
				i = i - 1 -- 114
			end -- 114
		end -- 114
	end -- 114
	node.parentId = newParentId -- 118
	node.x = worldX - parentWorldX -- 119
	node.y = worldY - parentWorldY -- 120
	local ____newParent_children_1 = newParent.children -- 120
	____newParent_children_1[#____newParent_children_1 + 1] = id -- 121
	state.treeExpanded[newParentId] = true -- 122
	return true -- 123
end -- 105
function ____exports.resolveAddParentId(state) -- 126
	local parentId = state.selectedId or "root" -- 127
	local parent = state.nodes[parentId] -- 128
	if ____exports.canNodeHaveChildren(parent) then -- 128
		return parentId -- 129
	end -- 129
	if parent ~= nil and parent.parentId ~= nil and parent.parentId ~= "" then -- 129
		parentId = parent.parentId -- 131
		parent = state.nodes[parentId] -- 132
		if ____exports.canNodeHaveChildren(parent) then -- 132
			return parentId -- 133
		end -- 133
	end -- 133
	return "root" -- 135
end -- 126
function ____exports.nodePath(state, id) -- 138
	local parts = {} -- 139
	local visited = {} -- 140
	local cursor = state.nodes[id] -- 141
	while cursor ~= nil do -- 141
		if visited[cursor.id] then -- 141
			break -- 143
		end -- 143
		visited[cursor.id] = true -- 144
		parts[#parts + 1] = cursor.name -- 145
		if cursor.parentId == nil or cursor.parentId == "" or cursor.parentId == cursor.id then -- 145
			break -- 146
		end -- 146
		cursor = state.nodes[cursor.parentId] -- 147
	end -- 147
	local path = "" -- 149
	do -- 149
		local i = #parts -- 150
		while i >= 1 do -- 150
			path = path .. (path == "" and "" or " / ") .. parts[i] -- 151
			i = i - 1 -- 150
		end -- 150
	end -- 150
	return path == "" and "Root" or path -- 153
end -- 138
function ____exports.isTreeNodeExpanded(state, id) -- 156
	ensureTreeExpanded(state) -- 157
	return state.treeExpanded[id] ~= false -- 158
end -- 156
function ____exports.toggleTreeNodeExpanded(state, id) -- 161
	state.treeExpanded[id] = not ____exports.isTreeNodeExpanded(state, id) -- 162
end -- 161
local function appendTreeRow(state, rows, id, depth, prefix, isLast, zh, visited) -- 165
	local node = state.nodes[id] -- 166
	if node == nil then -- 166
		return -- 167
	end -- 167
	if visited[id] then -- 167
		return -- 168
	end -- 168
	visited[id] = true -- 169
	local hasChildren = #node.children > 0 -- 170
	local expanded = hasChildren and ____exports.isTreeNodeExpanded(state, id) -- 171
	rows[#rows + 1] = { -- 172
		id = id, -- 173
		depth = depth, -- 174
		connectorPrefix = prefix, -- 175
		connector = id == "root" and "" or (isLast and "└─ " or "├─ "), -- 176
		hasChildren = hasChildren, -- 177
		expanded = expanded, -- 178
		icon = nodeKindIcon(node.kind), -- 179
		name = node.name, -- 180
		kindLabel = nodeKindLabel(node.kind, zh), -- 181
		childCount = #node.children, -- 182
		canHaveChildren = ____exports.canNodeHaveChildren(node) -- 183
	} -- 183
	if not expanded then -- 183
		return -- 185
	end -- 185
	local childPrefix = id == "root" and "" or prefix .. (isLast and "   " or "│  ") -- 186
	do -- 186
		local i = 0 -- 187
		while i < #node.children do -- 187
			appendTreeRow( -- 188
				state, -- 188
				rows, -- 188
				node.children[i + 1], -- 188
				depth + 1, -- 188
				childPrefix, -- 188
				i == #node.children - 1, -- 188
				zh, -- 188
				visited -- 188
			) -- 188
			i = i + 1 -- 187
		end -- 187
	end -- 187
end -- 165
function ____exports.buildSceneTreeRows(state, zh) -- 192
	local rows = {} -- 193
	____exports.normalizeSceneGraph(state) -- 194
	appendTreeRow( -- 195
		state, -- 195
		rows, -- 195
		"root", -- 195
		0, -- 195
		"", -- 195
		true, -- 195
		zh, -- 195
		{} -- 195
	) -- 195
	return rows -- 196
end -- 192
return ____exports -- 192