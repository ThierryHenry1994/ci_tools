rem @echo off
set WorkSpace=%1%
rd /s /q code_build_target
rd /s /q code_build_target_release
set COMPILE_KIND=%2%
set CGI_ROOT_PATH=%3%

cd %WorkSpace%
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

if (%3)==() (
	echo "without cgi_path"
    
) else (
	cd code
	cd cgi
	cd AssetLibraries
	call AssetPartition.bat
)
