@echo off
REM DR Cost Projection Batch Script
REM This script is a placeholder for future cost projection functionality

echo Banking DR Solution - Cost Projection Tool
echo ----------------------------------------
echo.
echo This is a Windows batch script wrapper.
echo For cost projections, please use:
echo   - dr-cost-projection.ps1 (PowerShell)
echo   - dr-cost-projection.sh (Bash)
echo.
echo Please refer to the docs/cost-comparison.md document for cost estimates.
echo.

REM Launch PowerShell version if available
where powershell >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    powershell -ExecutionPolicy Bypass -File "%~dp0dr-cost-projection.ps1" %*
)