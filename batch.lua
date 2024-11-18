-- 批处理脚本
-- 可以一次性处理多个文件，得手动指定路径
-- 主要是lua语言对文件夹迭代/创建/删除等操作的支持很差，必须依赖第三方库，我就不实现了

-- 运行方法:
-- lua batch.lua

local batch = {
	-- lua 命令名字
	lua = "lua",

	-- 是否将源代码完全转码
	loadstring = false,

	-- 需要被加密的文件夹，请自行填写
	indir = "/Users/Wzh/Desktop/mami/", 

	-- 输出的文件夹，请自行填写，注意 indir 和 outdir 不能是同一个文件夹
	-- 这个文件夹必须先搭建好“框架”
	-- 假设原本的 mod 里有 scripts 文件夹， scripts 里面还有 components 和 prefabs，
	-- 那么输出文件夹就得先创建 scripts/，scripts/prefabs/ 和 scripts/components/ 三个文件夹，否则会失败
	outdir = "/Users/Wzh/Desktop/mami-encode/", 

	-- 需要以 env 环境加密的文件路径
	e = {
		-- modinfo不能被本脚本加密, 会崩（这个文件真的有加密的必要吗）
		
		-- 下面这3个文件一定是 env 环境
		"modmain.lua",
		"modworldgenmain.lua",
		"modservercreationmain.lua",

		-- 最后再列出所有被 modimport 函数加载的文件
		-- "modimport/util.lua",
		-- "modimport/api.lua",
		-- "modimport/sg.lua",
		-- "modimport/language.lua",
	},

	-- 需要以 _G 环境加密的文件路径
	g = {
		-- modinfo不能被本脚本加密, 会崩（这个文件真的有加密的必要吗）

		-- 所有除了 env 环境的代码文件都在 _G 环境下，如需加密，将路径列出
		-- "scripts/prefabs/homura_stickbang.lua",
		-- "scripts/widgets/my_text_ui.lua",
		-- "scripts/components/mami_reader.lua",
	},
}

assert(batch.indir ~= batch.outdir, "indir and outdir must be different!") 

local success = 0 
local failed = 0

local sys = function(path, env)
	local inpath = batch.indir .. path
	local outpath = batch.outdir .. path
	if io.open(inpath) == nil then
		print("[Error] File not found: ", inpath)
		failed = failed + 1
		return
	end
	local cmd = "%s CommandLineMinify.lua \"%s\" \"%s\" %s %s"
	cmd = string.format(cmd, batch.lua or "lua", inpath, outpath, batch.loadstring and "--loadstring" or "", env)

	local code, status, signal = os.execute(cmd)
	if type(code) ~= "number" then
		code = signal
	end
	-- print(code)
	print((code == 0 and "[Success] " or "[Error] ").. cmd, "["..code.."]")
	
	if code == 0 then
		success = success + 1
	else
		failed = failed + 1
	end
end

for _,v in ipairs(batch.e) do
	sys(v, "--env")
end

for _,v in ipairs(batch.g) do
	sys(v, "-G")
end

print("\n\n")
print("---------- batch done ----------")
print("success: "..success.. "\tfailed: ".. failed)
