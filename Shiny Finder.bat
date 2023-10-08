@echo off
setlocal enabledelayedexpansion

REM Get the directory of the batch script
set "batchScriptDir=%~dp0"

title Shiny Finder Launcher

REM Check if an argument (file) is provided
if "%~1"=="" (
    echo Please launch this script by dropping a .png file onto it.
    pause
    exit /b
)

REM Store the file path in a variable
set "filePath=%~1"

REM Now you can use the 'filePath' variable to do something with the dropped file
echo Batch script directory: %batchScriptDir%
echo You dropped the following file: %filePath%
echo Starting 'Shiny Finder.exe' on the dropped file.

REM Example: Open the dropped file with the default program
start "ini" "%batchScriptDir%\Shiny Finder.exe" --pxd="%filePath%"