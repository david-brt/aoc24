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

local function find_start(lines)
	for y, line in ipairs(lines) do
		local x = string.find(line, "%^")
		if x ~= nil then
			return { x = x, y = y }
		end
	end
	return nil
end

local function position_string(position)
	return string.format("%d;%d", position.x, position.y)
end

local function log_string(position, direction_index)
	return position_string(position) .. ";" .. direction_index
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

local function walk(lines)
	local visited = {}
	local position = find_start(lines)
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

local function same_position(p1, p2)
	return p1.x == p2.x and p1.y == p2.y
end

local function has_loop(lines, new_obstruction, start)
	local visited = {}
	local position = start
	local direction_index = 1
	visited[log_string(position, direction_index)] = true
	local next_position = step(position, direction_index)

	while char_at(lines, next_position) ~= nil do
		local next_char = char_at(lines, next_position)
		if next_char == "#" or same_position(next_position, new_obstruction) then
			direction_index = turn90degs(direction_index)
		end
		position = step(position, direction_index)
		if visited[log_string(position, direction_index)] then
			return true
		end
		visited[log_string(position, direction_index)] = true
		next_position = step(position, direction_index)
	end
	return false
end

local function count_visited(lines)
	local count = 0
	for _ in pairs(walk(lines)) do
		count = count + 1
	end
	return count
end

local function possible_obstacle_positions(lines)
	local visited = walk(lines)
	local possible_positions = {}
	for y = 1, #lines - 1, 1 do
		for x = 0, #lines[y], 1 do
			if not visited[position_string({ x = x, y = y })] then
				goto continue
			end
			local char = string.sub(lines[y], x, x)
			if char == "#" or char == "^" then
				goto continue
			end
			table.insert(possible_positions, { x = x, y = y })
			::continue::
		end
	end
	return possible_positions
end

local function try_obstacles(lines)
	local confirmed_positions = 0
	local possible_positions = possible_obstacle_positions(lines)
	local start = find_start(lines)
	for i, position in ipairs(possible_positions) do
		if has_loop(lines, position, start) then
			confirmed_positions = confirmed_positions + 1
		end
		if i % 1000 == 0 then
			local progress = string.format("%.1f%% done calculating part 2", (i / #possible_positions * 100))
			print(progress)
		end
	end
	return confirmed_positions
end

local content = read("in.txt")
local lines = content:split("\n")

print("part 1:", count_visited(lines))
print("calculating part 2...")
print("part 2:", try_obstacles(lines))
