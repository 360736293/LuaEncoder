-- 字符串
-- 将字符串转换为一连串的表达式
-- 
-- "abc" -> "\97\98\99"
-- "abc" -> string.char(99, 98, 97):reverse()

function table.reverse(tab)
    local size = #tab
    local newTable = {}

    for i,v in ipairs(tab) do
        newTable[size-i+1] = v
    end

    return newTable
end

return function(s)
	assert(type(s) == "string")
	local str = load("return "..s)() -- acutal string in mem

	if str == "" then
		return [[""]]
	end

	local q = "\""
	local result = {}
	local len = #str
	local i = 1
	while i <= len do
		local j = i + math.random(2, 5)
		local bytes = {string.byte(str, i, j)}
		if #bytes == 0 then
			break
		else
			local reverse = math.random() < 0.1
			local raw = math.random() < 0.8
			local sub = ""

			if raw then
				sub = q
			else
				sub = "string.char("
			end

			if reverse then
				bytes = table.reverse(bytes)
			end

			if raw then
				sub = sub .. "\\" .. table.concat(bytes, "\\") .. q
			else
				sub = sub .. table.concat(bytes, ", ") .. ")"
			end

			if reverse then
				if raw then
					sub = "(" .. sub .. ")"
				end
				sub = sub .. ":reverse()"
			end

			table.insert(result, sub)

			i = j + 1
		end
	end

	result = table.concat(result, "..")

	-- print(s)
	-- print("-->")
	-- print(result)

	assert(load("return "..result)() == str, result)

	return result
end