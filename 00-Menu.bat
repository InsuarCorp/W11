@echo off
chcp 65001 > nul
title SISTEMA // HERRAMIENTAS DE RED
cls

:: Obtener el carácter de ESC (Escape ANSI) de forma nativa
for /f "tokens=1-2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

:: Definición de colores
set "MAG=%ESC%[95m"
set "CYN=%ESC%[96m"
set "YEL=%ESC%[93m"
set "RST=%ESC%[0m"

:menu
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0info.ps1"
echo.
  
echo %YEL%========================================================================================%RST%
echo %YEL%                                     Insuar Corp                                        %RST%
echo %YEL%========================================================================================%RST%

echo %MAG%========================================================================================%RST%
echo %MAG%                             [ Menu Principal  V 26.09   ]                              %RST%
echo %MAG%========================================================================================%RST%
echo.
echo %MAG%             Analisis                      Hardware                       Windows%RST%
echo %CYN%[01]%RST% Análisis de Redes         %CYN%[06]%RST% Restablecer TCP/IP         %CYN%[11]%RST% Restablecer TCP/IP
echo %CYN%[02]%RST% Liberar Dirección IP      %CYN%[07]%RST% Conexiones de Red          %CYN%[12]%RST% Restablecer TCP/IP
echo %CYN%[03]%RST% Renovar Dirección IP      %CYN%[08]%RST% Ping Continuo (Google)     %CYN%[13]%RST% Restablecer TCP/IP
echo %CYN%[04]%RST% Vaciar Caché DNS          %CYN%[09]%RST% Ajustes de Red Windows     %CYN%[14]%RST% Restablecer TCP/IP
echo %CYN%[05]%RST% Restablecer Winsock       %CYN%[10]%RST% Salir del Programa         %CYN%[15]%RST% Restablecer TCP/IP
echo.
echo %YEL%[00] FINALIZAR SESIÓN%RST%
echo.
set /p choice=INGRESE COMANDO ^> 

if "%choice%"=="1" goto redes
if "%choice%"=="01" goto redes
if "%choice%"=="2" goto release
if "%choice%"=="02" goto release
if "%choice%"=="3" goto renew
if "%choice%"=="03" goto renew
if "%choice%"=="4" goto dns
if "%choice%"=="04" goto dns
if "%choice%"=="5" goto winsock
if "%choice%"=="05" goto winsock
if "%choice%"=="6" goto tcpip
if "%choice%"=="06" goto tcpip
if "%choice%"=="7" goto ncpa
if "%choice%"=="07" goto ncpa
if "%choice%"=="8" goto ping
if "%choice%"=="08" goto ping
if "%choice%"=="9" goto settings
if "%choice%"=="09" goto settings
if "%choice%"=="10" exit
if "%choice%"=="0" exit
if "%choice%"=="00" exit
goto menu

:redes
echo.
echo %CYN%[+] Cargando módulo de Análisis de Redes...%RST%
call "%~dp000-Redes.bat"
goto menu

:release
echo.
echo %CYN%[+] Liberando dirección IP actual...%RST%
ipconfig /release
echo %MAG%[!] Dirección IP liberada.%RST%
pause
goto menu

:renew
echo.
echo %CYN%[+] Solicitando renovación de dirección IP...%RST%
ipconfig /renew
echo %MAG%[!] Dirección IP renovada exitosamente.%RST%
pause
goto menu

:dns
echo.
echo %CYN%[+] Vaciando la caché del DNS...%RST%
ipconfig /flushdns
echo %MAG%[!] Caché DNS restablecida con éxito.%RST%
pause
goto menu

:winsock
echo.
echo %CYN%[+] Restableciendo catálogo Winsock...%RST%
netsh winsock reset
echo %MAG%[!] Catálogo Winsock restablecido. (Requiere reiniciar el equipo).%RST%
pause
goto menu

:tcpip
echo.
echo %CYN%[+] Restableciendo pila de protocolos TCP/IP...%RST%
netsh int ip reset
echo %MAG%[!] Protocolo TCP/IP restablecido.%RST%
pause
goto menu

:ncpa
echo.
echo %CYN%[+] Abriendo panel de Conexiones de Red (ncpa.cpl)...%RST%
start ncpa.cpl
goto menu

:ping
echo.
echo %CYN%[+] Iniciando prueba de latencia continua (Ctrl + C para detener)...%RST%
ping google.com -t
pause
goto menu

:settings
echo.
echo %CYN%[+] Abriendo la Configuración de Red de Windows...%RST%
start ms-settings:network
goto menu