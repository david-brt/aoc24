function string:split(sep)
	local tbl = {}
	for str in string.gmatch(self, "([^" .. sep .. "]+)") do
		table.insert(tbl, str)
	end
	return tbl
end

function table.shallow_copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*all")
	file:close()
	return content
end

local function tonumbers(stringseq)
	local numtable = {}
	for _, str in ipairs(stringseq) do
		table.insert(numtable, tonumber(str))
	end
	return numtable
end

local function is_monotonous(seq, dampener)
	local first_comparison = seq[1] < seq[2]
	for i = 2, #seq - 1 do
		local comparison = seq[i] < seq[i + 1]
		if comparison ~= first_comparison then
			if dampener then
				local seq1 = table.shallow_copy(seq)
				table.remove(seq1, i)
				local monotonous, _, _ = is_monotonous(seq1, false)
				if monotonous then
					return true, false, seq1
				end
				local seq2 = table.shallow_copy(seq)
				table.remove(seq2, i + 1)
				return is_monotonous(seq2, false)
			end
			return false, dampener, seq
		end
	end
	return true, dampener, seq
end

local function is_within_tolerance(seq, tolerance, dampener)
	for i = 1, #seq - 1 do
		local diff = math.abs(seq[i] - seq[i + 1])
		if diff < 1 or diff > tolerance then
			if dampener then
				local seq1 = table.shallow_copy(seq)
				local seq2 = table.shallow_copy(seq)
				table.remove(seq1, i)
				table.remove(seq2, i + 1)
				return is_within_tolerance(seq1, 3, false) or is_within_tolerance(seq2, 3, false)
			end
			return false
		end
	end
	return true
end

local function is_safe(seq, dampener)
	local monotonous
	monotonous, dampener, seq = is_monotonous(seq, dampener)
	return monotonous and is_within_tolerance(seq, 3, dampener)
end

local function count_safes(lines, dampener)
	local count = 0
	for _, line in ipairs(lines) do
		local seq = tonumbers(line:split(" "))
		if is_safe(seq, dampener) then
			count = count + 1
		end
	end
	return count
end

local content = read("example.txt")
local lines = content:split("\n")
print("part 1:", count_safes(lines, false))

print("part 2:", count_safes(lines, true))
