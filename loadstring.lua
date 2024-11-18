-- 将文本代码转换为\+数字的格式, 带来更加震撼的视觉体验
return function (str, env)
	if #str == 0 then
		return str
	end

	env = env or "env"
	assert (env == "env" or env == "_G")
	local rt = nil
	if env == "env" then
		rt = "_ = GLOBAL.loadstring\""
	elseif env == "_G" then
		rt = "local _ = loadstring\""
	end

	-- rt = rt .. "\\" .. table.concat({string.byte(str, 1, #str)}, "\\")
	-- string.byte函数不能处理太长的字符串

	local step = 1024
	for i = 0, (#str-1)/step do
		rt = rt .. "\\" .. table.concat({string.byte(str, i*step + 1, (i+1)*step)}, "\\")
	end
	
	if env == "env" then
		rt = rt .. "\";GLOBAL.setfenv(_, "..env..");_()"
	else
		rt = rt .. "\";setfenv(_, "..env..");_()"
	end

	return rt
end