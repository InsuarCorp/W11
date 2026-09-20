@echo off
powershell -Command "Start-Process powershell -ArgumentList '-NoExit', '-Command', 'irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex' -Verb RunAs"