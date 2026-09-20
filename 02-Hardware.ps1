# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // DIAGNOSTICO DE HARDWARE Y SISTEMA"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [ Diagnostico de Sistema V 26.09 ]                         " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menu en 3 Columnas (Horizontal)
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Resumen del Sistema       " -NoNewline
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion del BIOS      " -NoNewline
    Write-Host "[09] " -NoNewline -ForegroundColor Cyan; Write-Host "Estado del Sistema"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion de CPU        " -NoNewline
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion de Discos     " -NoNewline
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "Generar Reporte Completo"
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion de RAM        " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion de Red        " -NoNewline
    Write-Host "[11] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir Carpeta de Reportes"
    
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Informacion de GPU        " -NoNewline
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Tiempo de Actividad (Uptime)"
    Write-Host ""
    
    Write-Host "[0]  VOLVER AL MENU PRINCIPAL" -ForegroundColor Yellow
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Red
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Obteniendo Resumen del Sistema..." -ForegroundColor Cyan
            Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, RegisteredUser | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Obteniendo Informacion del Procesador (CPU)..." -ForegroundColor Cyan
            Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Obteniendo Informacion de Memoria RAM..." -ForegroundColor Cyan
            Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed, DeviceLocator | Format-Table -AutoSize
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Obteniendo Informacion de la Tarjeta Grafica (GPU)..." -ForegroundColor Cyan
            Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion, VideoProcessor | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Obteniendo Informacion del BIOS..." -ForegroundColor Cyan
            Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Name, ReleaseDate, SMBIOSBIOSVersion | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Obteniendo Informacion de Discos de Almacenamiento..." -ForegroundColor Cyan
            Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, OperationalStatus, Size | Format-Table -AutoSize
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '7', '07' } {
            Write-Host "`n[+] Obteniendo Informacion de Adaptadores de Red..." -ForegroundColor Cyan
            Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed | Format-Table -AutoSize
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '8', '08' } {
            Write-Host "`n[+] Calculando tiempo de actividad de Windows (Uptime)..." -ForegroundColor Cyan
            $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $uptime = (Get-Date) - $bootTime
            Write-Host "El sistema inicio el: $bootTime" -ForegroundColor Yellow
            Write-Host "Tiempo encendido: $($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos" -ForegroundColor Green
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '9', '09' } {
            Write-Host "`n[+] Ejecutando Verificacion de Estado del Sistema..." -ForegroundColor Cyan
            Get-ComputerInfo | Select-Object OsName, OsVersion, CsModel, CsPhyPowerState | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        '10' {
            Write-Host "`n[+] Generando Reporte Completo del Sistema..." -ForegroundColor Cyan
            
            # Detecta la ubicacion real del Escritorio (soporta OneDrive/Google Drive)
            $desktopFolder = [Environment]::GetFolderPath("Desktop")
            $reportPath = Join-Path -Path $desktopFolder -ChildPath "Reporte_Sistema.txt"
            
            Get-ComputerInfo | Out-File -FilePath $reportPath -Encoding utf8
            Write-Host "[!] Reporte guardado con exito en: $reportPath" -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        '11' {
            Write-Host "`n[+] Abriendo carpeta del Escritorio..." -ForegroundColor Cyan
            
            # Abre la ruta real del Escritorio
            $desktopFolder = [Environment]::GetFolderPath("Desktop")
            Start-Process explorer.exe $desktopFolder
        }
        '0' {
            Write-Host "`n[+] Regresando al menu principal..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/00-Menu.ps1 | iex
            return
        }
        '00' {
            Write-Host "`n[+] Finalizando sesion..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            exit
        }
        Default {
            Write-Host "Opcion no valida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)