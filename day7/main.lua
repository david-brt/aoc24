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

local function recurse(current, index, equation)
	local numbers = equation[2]
	local result = equation[1]
	if index > #numbers then
		if current == result then
			return true
		end
		return false
	end
	return (
		recurse(current + numbers[index], index + 1, equation)
		or recurse(current * numbers[index], index + 1, equation)
	)
end

local function possibly_true(equation)
	local numbers = equation[2]
	return recurse(numbers[1], 2, equation)
end

local function total_calibration_result(path)
	local total = 0
	for _, equation in ipairs(parse(path)) do
		if possibly_true(equation) then
			total = total + equation[1]
		end
	end
	return total
end

print(total_calibration_result("example.txt"))
