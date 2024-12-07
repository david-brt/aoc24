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

local function tonumbers(t)
	local numtable = {}
	for _, str in ipairs(t) do
		table.insert(numtable, tonumber(str))
	end
	return numtable
end

local function parse(path)
	local content = read(path)
	local lines = content:split("\n")

	local equations = {}
	for _, line in ipairs(lines) do
		if line == "" then
			goto continue
		end
		local terms = line:split(": ")
		local result = tonumber(terms[1])
		local numbers = tonumbers(terms[2]:split(" "))
		table.insert(equations, { result, numbers })
		::continue::
	end
	return equations
end

local function recurse(current, index, equation, with_concat)
	local numbers = equation[2]
	local result = equation[1]
	if index > #numbers then
		if current == result then
			return true
		end
		return false
	end
	if with_concat then
		local concatted = tonumber(current .. numbers[index])
		return (
			recurse(current + numbers[index], index + 1, equation, true)
			or recurse(current * numbers[index], index + 1, equation, true)
			or recurse(concatted, index + 1, equation, true)
		)
	end
	return (
		recurse(current + numbers[index], index + 1, equation, false)
		or recurse(current * numbers[index], index + 1, equation, false)
	)
end

local function possibly_true(equation, with_concat)
	local numbers = equation[2]
	return recurse(numbers[1], 2, equation, with_concat)
end

local function total_calibration_result(path, with_concat)
	local total = 0
	for _, equation in ipairs(parse(path)) do
		if possibly_true(equation, with_concat) then
			total = total + equation[1]
		end
	end
	return total
end

print("part 1:", total_calibration_result("in.txt", false))
print("part 2:", total_calibration_result("in.txt", true))
