rem @echo off
rd /s /q code
rd /s /q code_build_target
rd /s /q code_build_target_release
set Version=%1%
set COMPILE_KIND=%2%

git clone "ssh://10.179.48.85:29418/projects/chery/8155_convergence/mcu" -b %Version% code
cd code

echo "#### build.log start ####"

if "%COMPILE_KIND%"=="release" (
    call .\cmake.bat release
) else (
    call .\cmake.bat 
)
set ret=%errorlevel%
echo "#### build.log end ####"


if %ret% neq 0 (
    echo "exec cmake.bat failed, please check it"
    exit 1
)