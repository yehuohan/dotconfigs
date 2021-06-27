@echo off

if not exist %APPS_HOME%\dotvim (
    echo Is NOT in %APPS_HOME%\dotconfigs\vim\setup
    exit
)

:: .vim
xcopy %APPS_HOME%\dotconfigs\vim\.vim           %APPS_HOME%\dotvim\ /E /R /Y

:: nvim
if not exist %LOCALAPPDATA%\nvim (
    md %LOCALAPPDATA%\nvim
)
copy %APPS_HOME%\dotconfigs\vim\nvim\init.vim   %LOCALAPPDATA%\nvim\

echo Dotvim setup was completed!
pause
