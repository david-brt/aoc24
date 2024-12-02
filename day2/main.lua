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

function tonumbers(stringseq)
	local numtable = {}
	for _, str in ipairs(stringseq) do
		table.insert(numtable, tonumber(str))
	end
	return numtable
end

local function is_monotonous(seq)
	local first_comparison = seq[1] < seq[2]
	for i = 2, #seq - 1 do
		local comparison = seq[i] < seq[i + 1]
		if comparison ~= first_comparison then
			return false
		end
	end
	return true
end

local function is_within_tolerance(seq, tolerance)
	for i = 1, #seq - 1 do
		local diff = math.abs(seq[i] - seq[i + 1])
		if diff < 1 or diff > tolerance then
			return false
		end
	end
	return true
end

local function is_safe(seq)
	return is_monotonous(seq) and is_within_tolerance(seq, 3)
end

local function count_safes(lines)
	local count = 0
	for _, line in ipairs(lines) do
		local seq = tonumbers(line:split(" "))
		if is_safe(seq) then
			count = count + 1
		end
	end
	return count
end

local content = read("test.txt")
local lines = content:split("\n")
print("part 1:", count_safes(lines))
