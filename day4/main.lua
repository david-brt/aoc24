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

local content = read("in.txt")
local lines = content:split("\n")

local function char_at(position)
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

local function is_xmas(substring, position, direction)
	if substring == "XMAS" then
		return 1
	end
	if #substring == #"XMAS" then
		return 0
	end

	local next_char = char_at(position)
	if next_char == nil then
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

local function part1()
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

print("part 1:", part1())

local corner_directions = { directions.upright, directions.downright, directions.downleft, directions.upleft }

-- checks if the diagonal around an "A" are the same character
local function check_diagonal(position)
	local upleft = directions.upleft
	local downright = directions.downright
	local positions = {
		{ x = position.x + upleft.x, y = position.y + upleft.y },
		{ x = position.x + downright.x, y = position.y + downright.y },
	}
	local upleft_char = char_at(positions[1])
	local downright_char = char_at(positions[2])
	if upleft_char == nil or downright_char == nil then
		return false
	end
	if upleft_char == downright_char then
		return false
	end
	return true
end

-- count occurences of "M" and "S" ("M-A-S") in the corners
local function count_m_s(position)
	local counts = { M = 0, S = 0 }
	for _, direction in ipairs(corner_directions) do
		local char = char_at({ x = position.x + direction.x, y = position.y + direction.y })
		if counts[char] ~= nil then
			counts[char] = counts[char] + 1
		end
	end
	return counts
end

local function part2()
	local occurences = 0
	for y, line in ipairs(lines) do
		local x = 0
		while true do
			x = string.find(line, "A", x + 1)
			if x == nil then
				break
			else
				-- two conditions for X-MAS:
				--    2 Ms and 2 Ss in corners around A
				--    different symbols on diagonal
				local position = { x = x, y = y }
				if not check_diagonal(position) then
					goto continue
				end
				local counts = count_m_s(position)
				if counts.M == 2 and counts.S == 2 then
					occurences = occurences + 1
				end
				::continue::
			end
		end
	end
	return occurences
end

print("part 2:", part2())
