@echo off
title PowerPoint Controller - AI Cafe
cd /d "%~dp0"
rem Optional: allow additional web origins (exact origin incl. port), e.g.:
rem set "PPT_ALLOWED_ORIGINS=http://localhost:3000;https://localhost:4443"
powershell -NoProfile -ExecutionPolicy Bypass -File "stop-ppt-controller.ps1" -Silent
powershell -NoExit -STA -ExecutionPolicy Bypass -File "ppt-controller.ps1"
