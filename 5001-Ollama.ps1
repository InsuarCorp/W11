# ==============================================================================
# Script de Instalación Centralizada en C:\Ollama (100% Portátil para migrar)
# ==============================================================================

$RutaOllama = "C:\Ollama"
$RutaModelos = "$RutaOllama\models"

# 0. Verificar e instalar Docker Desktop si no está presente
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Docker no está instalado. Descargando instalador..." -ForegroundColor Cyan
    $DockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $DockerInstaller

    Write-Host "[+] Instalando Docker Desktop..." -ForegroundColor Cyan
    Start-Process -FilePath $DockerInstaller -ArgumentList "install", "--quiet", "--accept-license" -Wait
    Remove-Item -Path $DockerInstaller -Force
    Write-Host "[!] Docker instalado. Recuerda reiniciar la PC al terminar si te lo solicita." -ForegroundColor Yellow
} else {
    Write-Host "[*] Docker ya se encuentra instalado." -ForegroundColor Green
}

# 1. Crear estructura de carpetas en C:\Ollama
if (-not (Test-Path -Path $RutaModelos)) {
    New-Item -ItemType Directory -Path $RutaModelos -Force | Out-Null
    Write-Host "[+] Carpeta creada: $RutaModelos" -ForegroundColor Green
}

# 2. Configurar la variable de entorno global para que Ollama use C:\Ollama\models
[System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $RutaModelos, [System.EnvironmentVariableTarget]::Machine)
$env:OLLAMA_MODELS = $RutaModelos
Write-Host "[+] Variable de entorno OLLAMA_MODELS configurada en: $RutaModelos" -ForegroundColor Green

# 3. Descargar e instalar Ollama nativo
Write-Host "[+] Descargando instalador de Ollama..." -ForegroundColor Cyan
$InstaladorExe = "$RutaOllama\OllamaSetup.exe"
Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $InstaladorExe

Write-Host "[+] Instalando Ollama..." -ForegroundColor Cyan
Start-Process -FilePath $InstaladorExe -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
Remove-Item -Path $InstaladorExe -Force

# Actualizar variable PATH de la sesión actual
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Dar un respiro para que el servicio de Ollama inicie correctamente
Start-Sleep -Seconds 5

# 4. Descargar el modelo liviano (se guardará automáticamente en C:\Ollama\models)
Write-Host "[+] Descargando modelo llama3.2:3b..." -ForegroundColor Cyan
ollama run llama3.2:3b ""

# 5. Desplegar Open WebUI en Docker (Puerto 3000)
Write-Host "[+] Desplegando Open WebUI en Docker..." -ForegroundColor Cyan
docker run -d -p 3000:8080 `
  --add-host=host.docker.internal:host-gateway `
  -v open-webui:/app/backend/data `
  --name open-webui `
  --restart always `
  ghcr.io/open-webui/open-webui:main

# 6. Abrir Firewall para la LAN
New-NetFirewallRule -DisplayName "OpenWebUI-LAN" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

Write-Host "`n==================================================================" -ForegroundColor Green
Write-Host " ¡TODO LISTO Y CENTRALIZADO EN C:\Ollama!" -ForegroundColor Green
Write-Host " Tus modelos físicos vivirán dentro de C:\Ollama\models" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Green
