# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // OPTIMIZACIÓN EXTREMA"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                           [ Menu Optimización V 26.09 ]                                " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menú alineado en 3 Columnas
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Crear Punto de Restauración   " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Caché DNS             " -NoNewline
    Write-Host "[13] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Reportes de Error"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Archivos Temporales   " -NoNewline
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Restablecer Winsock          " -NoNewline
    Write-Host "[14] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Delivery Opt. Cache"
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Caché Windows Update  " -NoNewline
    Write-Host "[09] " -NoNewline -ForegroundColor Cyan; Write-Host "Restablecer TCP/IP           " -NoNewline
    Write-Host "[15] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir Apps de Inicio"
    
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Component Store(Dism) " -NoNewline
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "Plan Alto Rendimiento        " -NoNewline
    Write-Host "[16] " -NoNewline -ForegroundColor Cyan; Write-Host "Ajustes de Almacenamiento"
    
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Optimizar Archivos (SFC)     " -NoNewline
    Write-Host "[11] " -NoNewline -ForegroundColor Cyan; Write-Host "Activar Máximo Rendimiento   " -NoNewline
    Write-Host "[17] " -NoNewline -ForegroundColor Cyan; Write-Host "Generar Reporte Optimización"
    
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Salud del Sistema (DISM)     " -NoNewline
    Write-Host "[12] " -NoNewline -ForegroundColor Cyan; Write-Host "Optimizar / Desfragmentar    " -NoNewline
    Write-Host "[18] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar Equipo"
    Write-Host ""
    
    Write-Host "[00] VOLVER AL MENÚ PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Creando punto de restauración del sistema..." -ForegroundColor Cyan
            Checkpoint-Computer -Description "InsuarCorp_RestorePoint" -RestorePointType "MODIFY_SETTINGS"
            Write-Host "[!] Punto de restauración creado." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Limpiando archivos temporales..." -ForegroundColor Cyan
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[!] Archivos temporales eliminados." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Limpiando caché de Windows Update..." -ForegroundColor Cyan
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
            Write-Host "[!] Caché de Windows Update vaciada." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Limpiando almacén de componentes (DISM Cleanup-Image)..." -ForegroundColor Cyan
            dism /online /cleanup-image /startcomponentcleanup
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Ejecutando comprobación y reparación de archivos (SFC)..." -ForegroundColor Cyan
            sfc /scannow
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Verificando salud de la imagen del sistema (DISM)..." -ForegroundColor Cyan
            dism /online /cleanup-image /restorehealth
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '7', '07' } {
            Write-Host "`n[+] Vaciando caché DNS..." -ForegroundColor Cyan
            Clear-DnsClientCache
            Write-Host "[!] Caché DNS vaciada." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '8', '08' } {
            Write-Host "`n[+] Restableciendo catálogo Winsock..." -ForegroundColor Cyan
            netsh winsock reset
            Write-Host "[!] Catálogo Winsock restablecido." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '9', '09' } {
            Write-Host "`n[+] Restableciendo pila TCP/IP..." -ForegroundColor Cyan
            netsh int ip reset
            Write-Host "[!] Protocolo TCP/IP restablecido." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '10' {
            Write-Host "`n[+] Activando plan de energía Alto Rendimiento..." -ForegroundColor Cyan
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Host "[!] Plan Alto Rendimiento seleccionado." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '11' {
            Write-Host "`n[+] Habilitando plan Máximo Rendimiento (Ultimate Performance)..." -ForegroundColor Cyan
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
            Write-Host "[!] Esquema Máximo Rendimiento agregado y disponible." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '12' {
            Write-Host "`n[+] Optimizando unidades de disco..." -ForegroundColor Cyan
            Optimize-Volume -DriveLetter C -Defrag -Verbose
            Read-Host "Presione Enter para continuar..."
        }
        '13' {
            Write-Host "`n[+] Eliminando archivos de informe de errores de Windows..." -ForegroundColor Cyan
            Remove-Item -Path "$env:LOCALAPPDATA\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[!] Reportes de error eliminados." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '14' {
            Write-Host "`n[+] Limpiando caché de Optimización de distribución..." -ForegroundColor Cyan
            Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
            Write-Host "[!] Caché de Delivery Optimization vaciada." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '15' {
            Write-Host "`n[+] Abriendo Configuración de Apps de Inicio..." -ForegroundColor Cyan
            Start-Process ms-settings:startupapps
        }
        '16' {
            Write-Host "`n[+] Abriendo Configuración de Almacenamiento..." -ForegroundColor Cyan
            Start-Process ms-settings:storagesense
        }
        '17' {
            Write-Host "`n[+] Generando Reporte de Optimización..." -ForegroundColor Cyan
            $reportPath = "$env:USERPROFILE\Desktop\Reporte_Optimizacion.txt"
            Get-ComputerInfo | Out-File -FilePath $reportPath
            Write-Host "[!] Reporte guardado en tu Escritorio: $reportPath" -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '18' {
            Write-Host "`n[!] Reiniciando el equipo en 5 segundos..." -ForegroundColor Red
            Start-Sleep -Seconds 5
            Restart-Computer
        }
        { $_ -in '0', '00' } {
            return
        }
        Default {
            Write-Host "Opción no válida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)