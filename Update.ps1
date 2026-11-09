# ==============================================================================
# Script de Reparación y Reinicio de Windows Update - InsuarCorp
# ==============================================================================

# 1. Comprobar si se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Este script debe ejecutarse como ADMINISTRADOR." -ForegroundColor Red
    Write-Host "[*] Haz clic derecho sobre el archivo .ps1 y selecciona 'Ejecutar con PowerShell como administrador'." -ForegroundColor Yellow
    Pause
    Exit
}

Clear-Host
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "             REPARANDO Y REINICIANDO EL MOTOR DE WINDOWS UPDATE                 " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# 2. Detener servicios críticos de actualización y forzar cierre de procesos bloqueantes
Write-Host "[1/5] Deteniendo servicios y liberando procesos de Windows Update..." -ForegroundColor Yellow
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service -Name cryptSvc -Force -ErrorAction SilentlyContinue
Stop-Service -Name bits -Force -ErrorAction SilentlyContinue
Stop-Service -Name msiserver -Force -ErrorAction SilentlyContinue

# Forzar cierre de procesos residuales que retienen la carpeta SoftwareDistribution
Get-Process -Name "TiWorker", "TrustedInstaller", "MoInstaller" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 3. Limpiar / Renombrar la carpeta SoftwareDistribution para borrar la caché atascada
Write-Host "[2/5] Limpiando la caché de descargas corruptas..." -ForegroundColor Yellow
$swDistPath = "$env:SystemRoot\SoftwareDistribution"
if (Test-Path $swDistPath) {
    $backupPath = "$env:SystemRoot\SoftwareDistribution.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    try {
        Rename-Item -Path $swDistPath -NewName $backupPath -ErrorAction Stop
        Write-Host "      -> Caché anterior respaldada exitosamente." -ForegroundColor Green
    } catch {
        Write-Host "      -> No se pudo renombrar SoftwareDistribution (algun archivo sigue en uso)." -ForegroundColor Red
    }
}

# 4. Volver a iniciar los servicios
Write-Host "[3/5] Reiniciando los servicios de Windows..." -ForegroundColor Yellow
Start-Service -Name wuauserv
Start-Service -Name cryptSvc
Start-Service -Name bits
Start-Service -Name msiserver
Start-Sleep -Seconds 2

# 5. Forzar la detección de red y limpieza del almacén de datos de WU
Write-Host "[4/5] Restableciendo componentes de red..." -ForegroundColor Yellow
netsh winsock reset >$null
netsh int ip reset >$null

Write-Host "[5/5] ¡Proceso completado con éxito!" -ForegroundColor Green
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  La cola de actualizaciones se ha reiniciado. Se abrira la configuracion" -ForegroundColor Yellow
Write-Host "  para que puedas buscar actualizaciones de nuevo sin el bloqueo del 0%." -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Abrir automáticamente la ventana de Windows Update en Configuración
Start-Process "ms-settings:windowsupdate"

Pause
