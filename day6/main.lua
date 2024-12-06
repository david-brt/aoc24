function string:split(inSplitPattern)
	local outResults = {}
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
	while theSplitStart do
		table.insert(outResults, string.sub(self, theStart, theSplitStart - 1))
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
	end
	table.insert(outResults, string.sub(self, theStart))
	return outResults
end

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*all")
	file:close()
	return content
end

local function char_at(lines, position)
	local line = lines[position.y]
	if line == nil then
		return nil
	end
	local char = string.sub(line, position.x, position.x)
	if char == "" then
		return nil
	end
	return char
end

local function findStart(lines)
	for y, line in ipairs(lines) do
		local x = string.find(line, "%^")
		if x ~= nil then
			return { x = x, y = y }
		end
	end
	return nil
end

local function step(position, direction_index)
	local directions = {
		{ x = 0, y = -1 },
		{ x = 1, y = 0 },
		{ x = 0, y = 1 },
		{ x = -1, y = 0 },
	}
	return {
		x = position.x + directions[direction_index].x,
		y = position.y + directions[direction_index].y,
	}
end

local function turn90degs(direction_index)
	return direction_index % 4 + 1
end

local function position_string(position)
	return string.format("%d;%d", position.x, position.y)
end

local function walk(lines)
	local visited = {}
	local position = findStart(lines)
	visited[position_string(position)] = true
	local direction_index = 1
	local next_position = step(position, direction_index)

	while char_at(lines, next_position) ~= nil do
		if char_at(lines, next_position) == "#" then
			direction_index = turn90degs(direction_index)
		end
		position = step(position, direction_index)
		visited[position_string(position)] = true
		next_position = step(position, direction_index)
	end
	return visited
end

local function count_visited(lines)
	local count = 0
	for _ in pairs(walk(lines)) do
		count = count + 1
	end
	return count
end

local content = read("example.txt")
local lines = content:split("\n")

print("part 1:", count_visited(lines))
