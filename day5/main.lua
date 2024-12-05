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

local function parseRules(chunk)
	local parsedChunk = {}
	for _, update in ipairs(chunk:split("\n")) do
		local numbers = tonumbers(update:split("|"))
		table.insert(parsedChunk, numbers)
	end
	return parsedChunk
end

local function parseUpdates(chunk)
	chunk = string.gsub(chunk, "\n$", "")
	local update_maps = {}
	local updates = {}
	for _, update in ipairs(chunk:split("\n")) do
		local numbers = tonumbers(update:split(","))
		table.insert(updates, numbers)
		local number_map = {}
		for i, number in ipairs(numbers) do
			number_map[number] = i
		end
		table.insert(update_maps, number_map)
	end
	return update_maps, updates
end

local content = read("example.txt")
local sections = content:split("\n\n")
local order_rules = parseRules(sections[1])
local update_maps, updates = parseUpdates(sections[2])

local function isOrdered(update_map)
	for _, rule in ipairs(order_rules) do
		local smaller = rule[1]
		local greater = rule[2]
		local smaller_index = update_map[smaller]
		local greater_index = update_map[greater]
		if smaller_index ~= nil and greater_index ~= nil then
			if not (smaller_index < greater_index) then
				return false
			end
		end
	end
	return true
end

local function less_than(a, b)
	for _, rule in ipairs(order_rules) do
		local smaller = rule[1]
		local greater = rule[2]
		if a == smaller and b == greater then
			return true
		end
		if a == greater and b == smaller then
			return false
		end
	end
	return false
end

function table:length()
	local length = 0
	for _, _ in pairs(self) do
		length = length + 1
	end
end

local function add_middle_numbers(sort)
	local sum = 0
	for i, update in ipairs(update_maps) do
		if isOrdered(update) and not sort then
			local middle_index = (#updates[i] + 1) / 2
			sum = sum + updates[i][middle_index]
		end
		if not isOrdered(update) and sort then
			table.sort(updates[i], less_than)
			local middle_index = (#updates[i] + 1) / 2
			sum = sum + updates[i][middle_index]
		end
	end
	return sum
end

print("part 1:", add_middle_numbers(false))
print("part 2:", add_middle_numbers(true))
