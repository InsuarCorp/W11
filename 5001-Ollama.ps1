# ==============================================================================
# Script Maestro: WSL + Docker + Ollama (Portátil en C:\Ollama) + Open WebUI
# ==============================================================================

$RutaOllama = "C:\Ollama"
$RutaModelos = "$RutaOllama\models"

Write-Host "[*] Verificando requisitos del sistema..." -ForegroundColor Cyan

# 0. Verificar e instalar WSL si no está presente
if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Host "[+] WSL no está instalado. Instalando WSL (requiere reinicio posterior)..." -ForegroundColor Yellow
    wsl --install
    Write-Host "[!] WSL instalado. ADVERTENCIA: Es muy probable que necesites reiniciar la PC al finalizar este script." -ForegroundColor Magenta
} else {
    Write-Host "[*] WSL ya se encuentra instalado." -ForegroundColor Green
}

# 1. Verificar e instalar Docker Desktop si no está presente
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Docker no está instalado. Descargando instalador..." -ForegroundColor Cyan
    $DockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $DockerInstaller

    Write-Host "[+] Instalando Docker Desktop..." -ForegroundColor Cyan
    Start-Process -FilePath $DockerInstaller -ArgumentList "install", "--quiet", "--accept-license" -Wait
    Remove-Item -Path $DockerInstaller -Force
    Write-Host "[!] Docker instalado correctamente." -ForegroundColor Green
} else {
    Write-Host "[*] Docker ya se encuentra instalado." -ForegroundColor Green
}

# 2. Crear estructura de carpetas en C:\Ollama para hacerlo portátil
if (-not (Test-Path -Path $RutaModelos)) {
    New-Item -ItemType Directory -Path $RutaModelos -Force | Out-Null
    Write-Host "[+] Carpeta creada: $RutaModelos" -ForegroundColor Green
}

# 3. Configurar la variable de entorno global para que Ollama use C:\Ollama\models
[System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $RutaModelos, [System.EnvironmentVariableTarget]::Machine)
$env:OLLAMA_MODELS = $RutaModelos
Write-Host "[+] Variable de entorno OLLAMA_MODELS configurada en: $RutaModelos" -ForegroundColor Green

# 4. Descargar e instalar Ollama (Ventana visible para ver el proceso)
Write-Host "[+] Descargando instalador de Ollama..." -ForegroundColor Cyan
$InstaladorExe = "$RutaOllama\OllamaSetup.exe"
Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $InstaladorExe

Write-Host "[+] Abriendo el instalador de Ollama..." -ForegroundColor Yellow
Start-Process -FilePath $InstaladorExe -Wait
Remove-Item -Path $InstaladorExe -Force

# Actualizar variable PATH de la sesión actual
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Start-Sleep -Seconds 5

# 5. Descargar modelo inicial (se guardará en C:\Ollama\models)
Write-Host "[+] Descargando modelo llama3.2:3b..." -ForegroundColor Cyan
ollama run llama3.2:3b ""

# 6. Desplegar Open WebUI en Docker (Puerto 3000)
Write-Host "[+] Desplegando Open WebUI en Docker..." -ForegroundColor Cyan
docker run -d -p 3000:8080 `
  --add-host=host.docker.internal:host-gateway `
  -v open-webui:/app/backend/data `
  --name open-webui `
  --restart always `
  ghcr.io/open-webui/open-webui:main

# 7. Abrir Firewall para la LAN
New-NetFirewallRule -DisplayName "OpenWebUI-LAN" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

Write-Host "`n==================================================================" -ForegroundColor Green
Write-Host " ¡PROCESO FINALIZADO CON ÉXITO!" -ForegroundColor Green
Write-Host " Si el script instaló WSL por primera vez, REINICIA LA PC." -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Green
