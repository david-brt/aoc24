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

local content = read("in.txt")
local lines = content:split("\n")

local first_column, second_column = {}, {}

for _, line in ipairs(lines) do
	local pair = line:split("   ")
	table.insert(first_column, pair[1])
	table.insert(second_column, pair[2])
end

table.sort(first_column)
table.sort(second_column)

local total = 0

for i, _ in ipairs(first_column) do
	local diff = math.abs(first_column[i] - second_column[i])
	total = total + diff
end

print("part 1:", total)

local function count_occurences(tbl)
	local occurences = {}
	for _, numstr in ipairs(tbl) do
		local num = tonumber(numstr)
		if num == nil then
			goto continue
		end
		if occurences[num] == nil then
			occurences[num] = 1
		else
			occurences[num] = occurences[num] + 1
		end
		::continue::
	end
	return occurences
end

local occurences = count_occurences(second_column)

local similarity = 0

for _, numstr in ipairs(first_column) do
	local num = tonumber(numstr)
	local num_occurences = occurences[num]
	if num_occurences == nil then
		num_occurences = 0
	end
	similarity = similarity + num * num_occurences
end

print("part 2:", similarity)
