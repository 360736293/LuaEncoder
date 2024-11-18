-- 标准洗牌算法
math.randomseed(os.time())

local function GetTableSize(t)
	local i = 0
	for k in pairs(t)do
		i = i + 1
	end
	return i
end

local function shuffle(a)
	local t = {}
	for i = 1, a do
		t[i] = i
	end
	for i = 1, a - 1 do
		local pos = math.random(i+1, a)
		t[i], t[pos] = t[pos], t[i]
	end
	return t
end

-- 生成变量集
local function genvartable(data)
	local n = #data
	local t = {}
	local rt = {}
	for i = 1, n do t[i] = 0 end
	
	local function str()
		local s = ''
		for i,v in ipairs(t)do
			s = s .. data[i][v+1]
		end
		return s
	end
	while 1 do
		table.insert(rt, str())
		t[1] = t[1] + 1
		for i = 1, n do
			if t[i] == #data[i] then
				if i == n then return rt end
				t[i] = 0
				t[i+1] = t[i+1]+1				
			end
		end
	end
end

local delimiter = {"","_","__"}
local key = "bug" -- 该字符串用于生成混淆的变量名, 字符串越长, 变量数量越多, 但会增加加密的耗时（不影响饥荒运行效率）
local data = {delimiter}
for i = 1, #key do
	local c = string.sub(key, i, i)
	if c:upper() ~= c then
		table.insert(data, {c, c:upper()})
	else
		table.insert(data, {c})
	end
	table.insert(data, delimiter)
end

local vars = genvartable(data)

print("混淆后的变量名:")
print(table.concat(vars, "\n", 1, 6)) -- 将6删去后即可查看所有变量名
print("... (total = "..#vars..")\n")

local index = shuffle(#vars)
local NUM = 0
local function GetVarName()
	NUM = NUM + 1
	assert(NUM <= #vars, "变量数量溢出! @ran.lua Line 52.")
	return vars[index[NUM]]
end

return GetVarName




