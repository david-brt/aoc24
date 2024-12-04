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

local function evalMul(str)
	local pattern = "mul%((%d+),(%d+)%)"
	local a, b = string.match(str, pattern)
	return a * b
end

local function part_one(lines)
	local total = 0
	for _, line in ipairs(lines) do
		local pattern = "mul%(%d+,%d+%)"

		line.gsub(line, pattern, function(mul)
			total = total + evalMul(mul)
		end)
	end
	return total
end

local function insert_matches(t, s, pattern)
	local i = 0
	local j
	while true do
		i, j = string.find(s, pattern, i + 1)
		if i == nil then
			break
		end

		local match = string.sub(s, i, j)
		t[i] = match
	end
end

local function get_ops_table(line)
	local ops = {}
	local mul_pattern = "mul%(%d+,%d+%)"
	local do_pattern = "do%(%)"
	local dont_pattern = "don't%(%)"

	insert_matches(ops, line, mul_pattern)
	insert_matches(ops, line, do_pattern)
	insert_matches(ops, line, dont_pattern)
	return ops
end

local function part_two(lines)
	local total = 0
	local enabled = true
	for _, line in ipairs(lines) do
		local ops = get_ops_table(line)

		local indexes = {}
		for k in pairs(ops) do
			table.insert(indexes, k)
		end
		table.sort(indexes)

		for _, index in ipairs(indexes) do
			if ops[index] == "do()" then
				enabled = true
			elseif ops[index] == "don't()" then
				enabled = false
			elseif enabled then
				total = total + evalMul(ops[index])
			end
		end
	end
	return total
end

local content = read("example.txt")
local lines = content:split("\n")
print("part 1:", part_one(lines))

content = read("example2.txt")
lines = content:split("\n")

print("part 2:", part_two(lines))
