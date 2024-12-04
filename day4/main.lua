function string:split(sep)
	local tbl = {}
	for str in string.gmatch(self, "([^" .. sep .. "]+)") do
		table.insert(tbl, str)
	end
	return tbl
end

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*all")
	file:close()
	return content
end

local directions = {
	up = { x = 0, y = -1 },
	upright = { x = 1, y = -1 },
	right = { x = 1, y = 0 },
	downright = { x = 1, y = 1 },
	down = { x = 0, y = 1 },
	downleft = { x = -1, y = 1 },
	left = { x = -1, y = 0 },
	upleft = { x = -1, y = -1 },
}

local content = read("example.txt")
local lines = content:split("\n")

local function is_xmas(substring, position, direction)
	if substring == "XMAS" then
		return 1
	end
	if #substring == #"XMAS" then
		return 0
	end

	local line = lines[position.y]
	if line == nil then
		return 0
	end

	local next_char = string.sub(line, position.x, position.x)
	if next_char == "" then
		return 0
	end

	substring = substring .. next_char

	local next_position = { x = position.x + direction.x, y = position.y + direction.y }
	return is_xmas(substring, next_position, direction)
end

local function try_all_directions(position)
	local matches = 0
	for _, direction in pairs(directions) do
		local next_position = { x = position.x + direction.x, y = position.y + direction.y }
		matches = matches + is_xmas("X", next_position, direction)
	end
	return matches
end

local function count_occurences()
	local occurences = 0
	for y, line in ipairs(lines) do
		local x = 0
		while true do
			x = string.find(line, "X", x + 1)
			if x == nil then
				break
			else
				occurences = occurences + try_all_directions({ x = x, y = y })
			end
		end
	end
	return occurences
end

print("part 1:", count_occurences())
