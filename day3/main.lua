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

local content = read("example.txt")
local lines = content:split("\n")

local total = 0

for _, line in ipairs(lines) do
	local pattern = "mul%(%d+,%d+%)"

	line.gsub(line, pattern, function(mul)
		total = total + evalMul(mul)
	end)
end

print(total)
