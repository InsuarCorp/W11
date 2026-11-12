# ==============================================================================
# Script de Reparación de Impresora Wi-Fi colgada por Suspensión - InsuarCorp
# ==============================================================================

# 1. Comprobar permisos de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Este script debe ejecutarse como ADMINISTRADOR." -ForegroundColor Red
    Write-Host "[*] Haz clic derecho sobre el archivo .ps1 y selecciona 'Ejecutar con PowerShell como administrador'." -ForegroundColor Yellow
    Pause
    Exit
}

Clear-Host
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "               REPARANDO Y REINICIANDO EL SUBSISTEMA DE IMPRESIÓN               " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# 2. Detener el servicio de cola de impresión (Spooler)
Write-Host "[1/5] Deteniendo el servicio de impresión (Spooler)..." -ForegroundColor Yellow
Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 3. Limpiar la caché de archivos temporales de impresión (.SHD y .SPL atascados)
Write-Host "[2/5] Limpiando la caché de trabajos atascados..." -ForegroundColor Yellow
$printerCachePath = "$env:SystemRoot\System32\Spool\Printers\*"
if (Test-Path "$env:SystemRoot\System32\Spool\Printers") {
    Remove-Item -Path $printerCachePath -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "      -> Caché de impresión limpiada correctamente." -ForegroundColor Green
} else {
    Write-Host "      -> No se encontraron archivos temporales pendientes." -ForegroundColor Cyan
}

# 4. Reiniciar componentes de red (ayuda a despertar la interfaz Wi-Fi para impresoras de red)
Write-Host "[3/5] Refrescando interfaces de red locales..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
arp -d * 2>$null

# 5. Volver a iniciar el servicio de impresión
Write-Host "[4/5] Reiniciando el servicio Spooler..." -ForegroundColor Yellow
Start-Service -Name Spooler
Start-Sleep -Seconds 2

# 6. Forzar la actualización de dispositivos y puertos WSD/TCP de red
Write-Host "[5/5] Forzando detección de dispositivos conectados..." -ForegroundColor Yellow
# Opcional: Reiniciar también el servicio de puerta de enlace de capa de aplicación si usa WSD
Stop-Service -Name "AppIDSvc" -ErrorAction SilentlyContinue
Start-Service -Name "AppIDSvc" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "                      ¡PROCESO COMPLETADO CON ÉXITO!                            " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host " La cola se ha vaciado y los servicios de red e impresión se reiniciaron.        " -ForegroundColor Yellow
Write-Host " Ya puedes volver a enviar tu documento a imprimir.                             " -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

Pause
