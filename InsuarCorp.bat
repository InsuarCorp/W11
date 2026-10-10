@echo off
powershell -Command "Start-Process powershell -ArgumentList '-NoExit', '-Command', 'irm https://raw.githubusercontent.com/InsuarCorp/W11/main/00-Menu.ps1 | iex' -Verb RunAs"
