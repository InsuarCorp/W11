# ==============================================================================
# Script Maestro de Instalación Automatizada: Docker + Ollama + Open WebUI
# ==============================================================================

# 0. Verificar e instalar Docker Desktop si no está presente
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Docker no está instalado. Descargando instalador..." -ForegroundColor Cyan
    $DockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $DockerInstaller

    Write-Host "[+] Instalando Docker Desktop (esto puede tardar unos minutos)..." -ForegroundColor Cyan
    Start-Process -FilePath $DockerInstaller -ArgumentList "install", "--quiet", "--accept-license" -Wait
    Remove-Item -Path $DockerInstaller -Force
    
    Write-Host "[!] Docker se ha instalado. Es probable que necesites reiniciar la PC después de terminar este script para que WSL 2 funcione correctamente." -ForegroundColor Yellow
} else {
    Write-Host "[*] Docker ya se encuentra instalado en el sistema." -ForegroundColor Green
}

# 1. Crear carpeta en la raíz de C:
$RutaOllama = "C:\Ollama"
if (-not (Test-Path -Path $RutaOllama)) {
    New-Item -ItemType Directory -Path $RutaOllama | Out-Null
    Write-Host "[+] Carpeta creada en: $RutaOllama" -ForegroundColor Green
} else {
    Write-Host "[!] La carpeta $RutaOllama ya existe." -ForegroundColor Yellow
}

# 2. Descargar e instalar Ollama nativo
Write-Host "[+] Descargando instalador de Ollama..." -ForegroundColor Cyan
$InstaladorExe = "$RutaOllama\OllamaSetup.exe"
Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $InstaladorExe

Write-Host "[+] Instalando Ollama en segundo plano..." -ForegroundColor Cyan
Start-Process -FilePath $InstaladorExe -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
Remove-Item -Path $InstaladorExe -Force

# Actualizar variable PATH de la sesión actual
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 3. Descargar el modelo liviano para CPU
Write-Host "[+] Descargando e iniciando modelo llama3.2:3b..." -ForegroundColor Cyan
ollama run llama3.2:3b ""

# 4. Desplegar el contenedor Open WebUI en Docker
Write-Host "[+] Desplegando Open WebUI en Docker (Puerto 3000)..." -ForegroundColor Cyan
docker run -d -p 3000:8080 `
  --add-host=host.docker.internal:host-gateway `
  -v open-webui:/app/backend/data `
  --name open-webui `
  --restart always `
  ghcr.io/open-webui/open-webui:main

# 5. Abrir el puerto 3000 en el Firewall de Windows para la LAN
Write-Host "[+] Configurando regla de Firewall para acceso LAN..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "OpenWebUI-LAN" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

Write-Host "`n==================================================================" -ForegroundColor Green
Write-Host " ¡INSTALACIÓN COMPLETADA CON ÉXITO!" -ForegroundColor Green
Write-Host " Puedes acceder a la Web desde tu laptop en: http://<IP-DE-ESTE-CPU>:3000" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Green
