@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Update Index File
::  - Archives current index.html with a timestamp
::  - Moves latest download into the project folder
:: ============================================================

set PROJECT=G:\My Drive\_AI Projects\To Do List App
set ARCHIVE=%PROJECT%\archive
set DOWNLOADS=%USERPROFILE%\Downloads

:: ── Create archive folder if it doesn't exist ───────────────
if not exist "%ARCHIVE%" mkdir "%ARCHIVE%"

:: ── Step 1: Archive the current index.html ──────────────────
if exist "%PROJECT%\index.html" (
    for /f "tokens=1-6 delims=/:. " %%a in ("%date% %time%") do (
        set MM=%%a
        set DD=%%b
        set YYYY=%%c
        set HH=%%d
        set MIN=%%e
    )
    :: Pad hour with leading zero if needed
    if "!HH!" LSS "10" set HH=0!HH: =!
    set STAMP=!YYYY!-!MM!-!DD!_!HH!!MIN!
    set DEST=%ARCHIVE%\index_!STAMP!.html
    move "%PROJECT%\index.html" "!DEST!" >nul
    echo [1/2] Archived current index.html to:
    echo       !DEST!
) else (
    echo [1/2] No existing index.html found in project folder, skipping archive.
)

:: ── Step 2: Move newest index.html from Downloads ───────────
:: Find the most recently modified index.html in Downloads
set NEWEST=
for /f "delims=" %%f in ('dir "%DOWNLOADS%\index*.html" /b /o:-d /a:-d 2^>nul') do (
    if not defined NEWEST set NEWEST=%%f
)

if not defined NEWEST (
    echo.
    echo [2/2] ERROR: No index*.html found in Downloads folder.
    echo       Please download the file first, then re-run this script.
    echo.
    pause
    exit /b 1
)

move "%DOWNLOADS%\!NEWEST!" "%PROJECT%\index.html" >nul
echo [2/2] Moved "%DOWNLOADS%\!NEWEST!" to project folder.

echo.
echo  Done! index.html is ready in:
echo  %PROJECT%
echo.
pause
