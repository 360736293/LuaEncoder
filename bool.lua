-- 混淆布尔值
-- 将布尔值常量转换为表达式
math.randomseed(os.time())

-- 1.数学表达式
-- 1x1 == 1 --> true
-- 1+1 == 1 --> false
local function rannum(is_true)
	local s = ""
	for i = 1, math.random(3, 5)do
		if #s > 0 then
			s = s .. ({"+","-","*"})[math.random(1,3)]
		end
		s = s .. math.random(0,500)
	end
	local num = load("return "..s)()
	local num2 = num + math.random(2,10)
	local equal = math.random() < 0.5

	if is_true then
		return s ..(equal and ("=="..num) or ("~="..num2))
	else
		return s ..(equal and ("=="..num2) or ("~="..num))
	end
end

-- 2.字符串
-- string.sub("ab", 2) == "b" --> true
-- #"abcde" < 5  --> false
local function ranstr(is_true)
	-- 暂时还没想好怎么随机生成 
end


-- 3.布尔串
-- true or false --> true
-- false and false --> false
local function ranbool(is_true)
	while true do
		local s = ""
		for i = 1, math.random(9,14)do
			if #s > 0 then
				s = s .. " " .. (math.random() < 0.75 and "and" or "or")
				s = s .. " " .. (math.random() < 0.5 and "not" or "")
			end
			s = s .. " " .. (math.random() < 0.25 and "true" or "false")
		end
		if load("return "..s)() == is_true then
			return s
		end
	end
end

local function Ran(is_true)
	assert(is_true == true or is_true == false)
	return "(" .. (math.random() < 0.1 and ranbool(is_true) or rannum(is_true)) .. ")"
end

return Ran

