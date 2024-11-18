chcp 65001
@echo off

set "folder=%~1"

for /r "%folder%" %%f in (*.lua) do (
    echo 正在处理文件：%%f
    lua54 CommandLineMinify.lua "%%f" "%%f" -G
)

echo 所有lua文件混淆完成！
pause
