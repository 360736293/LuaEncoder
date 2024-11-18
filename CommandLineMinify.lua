
--
-- CommandlineMinify.lua
--
-- A command line utility for minifying lua source code using the minifier.
--

-- 基于 github 上的 LuaMinify

-- 不支持文件夹遍历, 简易的批处理脚本见 batch.lua

if _VERSION == "Lua 5.1" then
	load = loadstring
end

if _VERSION == "Lua 5.4" then
	require "prefix"
end

LOADSTRING = false
ENV = nil
local _arg = {}
for i,v in ipairs(arg)do
	if v == "--env" then
		ENV = "env"
	elseif v == "-G" then
		ENV = "_G"
	elseif v == "--loadstring" then
		LOADSTRING = true
	else
		table.insert(_arg, v)
	end
end
arg = _arg
if ENV == nil then
	-- 你必须显式地指定被加密文件的运行环境
	-- env: mod加载环境, 包括 modmain.lua, modworldgenmain.lua 以及被 modimport 函数加载的所有文件
	-- _G:  全局环境, 除了env以外的所有文件都是全局环境, 包括 prefabs/, stategraphs/, widgets/, components/, 以及被 require 函数加载的所有文件（无论require函数写在什么位置）
	print("Error: environment not deleared! (--env or -G)")
	os.exit(1)
end

local util = require'Util'
local Parser = require'ParseLua'
local Format_Mini = require'FormatMini'
local ParseLua = Parser.ParseLua
local PrintTable = util.PrintTable

local function splitFilename(name)
	-- table.foreach(arg, print)
	if name:find(".") then
		local p, ext = name:match("()%.([^%.]*)$")
		if p and ext then
			if #ext == 0 then
				return name, nil
			else
				local filename = name:sub(1,p-1)
				return filename, ext
			end
		else
			return name, nil
		end
	else
		return name, nil
	end
end

local ls = LOADSTRING and require "loadstring" or function(s) return s end

local function writefile(ast, outf)
	outf:write(require"prefix")
	outf:write(ls( Format_Mini(ast), ENV ))
	-- outf:write(Format_Mini(ast, ENV))
	outf:close()
end


if #arg == 1 then
	local name, ext = splitFilename(arg[1])
	local outname = name.."_min"
	if ext then outname = outname.."."..ext end
	--
	local inf = io.open(arg[1], 'r')
	if not inf then
		print("Failed to open `"..arg[1].."` for reading")
		os.exit(1)
		return
	end
	--
	local sourceText = inf:read('*all')
	inf:close()
	--
	local st, ast = ParseLua(sourceText)
	if not st then
		--we failed to parse the file, show why
		print(ast)
		os.exit(1)
		return
	end
	--
	local outf = io.open(outname, 'w')
	if not outf then
		print("Failed to open `"..outname.."` for writing")
		os.exit(1)
		return
	end
	writefile(ast, outf)
	--
	-- outf:write(Format_Mini(ast))
	-- outf:write((require"loadstring")(Format_Mini(ast, ENV)))
	-- outf:close()
	--
	print("complete")

elseif #arg == 2 then
	--keep the user from accidentally overwriting their non-minified file with 
	if arg[1]:find("_min") then
		print("Did you mix up the argument order?\n"..
		      "Current command will minify `"..arg[1].."` and OVERWRITE `"..arg[2].."` with the results")
		while true do
			io.write("Confirm (yes/cancel): ")
			local msg = io.read('*line')
			if msg == 'yes' then
				break
			elseif msg == 'cancel' then
				return
			end
		end
	end
	local inf = io.open(arg[1], 'r')
	if not inf then
		print("Failed to open `"..arg[1].."` for reading")
		os.exit(1)
		return
	end
	--
	local sourceText = inf:read('*all')
	inf:close()
	--
	local st, ast = ParseLua(sourceText)
	if not st then
		--we failed to parse the file, show why
		print(ast)
		os.exit(1)
		return
	end
	--
	-- if arg[1] == arg[2] then
	-- 	print("Are you SURE you want to overwrite the source file with a minified version?\n"..
	-- 	      "You will be UNABLE to get the original source back!")
	-- 	while true do
	-- 		io.write("Confirm (yes/cancel): ")
	-- 		local msg = io.read('*line')
	-- 		if msg == 'yes' then
	-- 			break
	-- 		elseif msg == 'cancel' then
	-- 			return
	-- 		end
	-- 	end		
	-- end
	local outf = io.open(arg[2], 'w')
	if not outf then
		print("Failed to open `"..arg[2].."` for writing")
		os.exit(1)
		return
	end
	writefile(ast, outf)
	--
	-- outf:write(require"prefix")
	-- -- outf:write(Format_Mini(ast))
	-- outf:write((require"loadstring")(Format_Mini(ast)))
	-- outf:close()
	--
	print("Minification complete")

else
	print("Invalid arguments, Usage:\nLuaMinify source [destination]")
end
