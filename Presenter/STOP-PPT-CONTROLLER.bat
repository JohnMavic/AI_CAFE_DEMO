@echo off
title Stop PowerPoint Controller - AI Cafe
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "stop-ppt-controller.ps1"
