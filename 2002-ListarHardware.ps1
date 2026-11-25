# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "SISTEMA // LISTAR HARDWARE Y LOGS"

$LogDir = "C:\InsuarCorp"
$LatestLogPath = Join-Path -Path $LogDir -ChildPath "Ultimo_Hardware.log"

function Ensure-LogDirectory {
    if (-not (Test-Path -Path $LogDir)) {
        try {
            New-Item -Path $LogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-Host "[+] Carpeta creada: $LogDir" -ForegroundColor Green
        } catch {
            Write-Host "[!] No se pudo crear $LogDir : $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Save-HardwareLog {
    param (
        [string]$SectionTitle,
        [string]$Content
    )

    if (-not (Ensure-LogDirectory)) { return }

    $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ReadableDate = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $HostName = $env:COMPUTERNAME
    $FilePath = Join-Path -Path $LogDir -ChildPath "Hardware_${HostName}_${Stamp}.log"

    $Header = @"
================================================================================
INSUAR CORP - REGISTRO DE HARDWARE
Fecha/Hora : $ReadableDate
Equipo     : $HostName
Seccion    : $SectionTitle
================================================================================

"@

    $FullText = $Header + $Content
    $FullText | Out-File -FilePath $FilePath -Encoding utf8 -Force
    $FullText | Out-File -FilePath $LatestLogPath -Encoding utf8 -Force

    Write-Host ""
    Write-Host "[OK] Log guardado en: $FilePath" -ForegroundColor Green
    Write-Host "[OK] Ultimo log actualizado en: $LatestLogPath" -ForegroundColor Green
}

function Get-CpuRamGpuReport {
    $Cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue |
        Select-Object Name, Manufacturer, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
        Format-List | Out-String

    $Ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue |
        Select-Object DeviceLocator, Manufacturer, PartNumber, Capacity, Speed |
        Format-Table -AutoSize | Out-String

    $Gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue |
        Select-Object Name, AdapterRAM, DriverVersion, VideoProcessor |
        Format-List | Out-String

    return "=== CPU ===`n$Cpu`n=== RAM ===`n$Ram`n=== GPU ===`n$Gpu"
}

function Get-StorageReport {
    $Disks = Get-PhysicalDisk -ErrorAction SilentlyContinue |
        Select-Object DeviceId, FriendlyName, MediaType, BusType, OperationalStatus, HealthStatus, Size |
        Format-Table -AutoSize | Out-String

    $Volumes = Get-Volume -ErrorAction SilentlyContinue |
        Where-Object { $_.DriveLetter } |
        Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size |
        Format-Table -AutoSize | Out-String

    return "=== DISCOS FISICOS ===`n$Disks`n=== VOLUMENES ===`n$Volumes"
}

function Get-BiosBoardReport {
    $Bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue |
        Select-Object Manufacturer, Name, SMBIOSBIOSVersion, ReleaseDate, SerialNumber |
        Format-List | Out-String

    $Board = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue |
        Select-Object Manufacturer, Product, SerialNumber, Version |
        Format-List | Out-String

    return "=== BIOS ===`n$Bios`n=== PLACA BASE ===`n$Board"
}

function Get-NetworkReport {
    $Net = Get-NetAdapter -ErrorAction SilentlyContinue |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
        Format-Table -AutoSize | Out-String

    return "=== ADAPTADORES DE RED ===`n$Net"
}

function Get-ConnectedDevicesReport {
    $Pnp = pnputil /enum-devices /connected /deviceids 2>&1 | Out-String
    return "=== DISPOSITIVOS CONECTADOS (PNPUTIL) ===`n$Pnp"
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                          [     Listar Hardware y Logs     ]                          " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Listar todo el hardware y guardar log (C:\InsuarCorp)"
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "CPU, RAM y GPU + guardar log"
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Discos y volumenes + guardar log"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "BIOS y placa base + guardar log"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Adaptadores de red + guardar log"
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Dispositivos conectados e IDs (pnputil) + guardar log"
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver ultimo log guardado en C:\InsuarCorp"
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir carpeta C:\InsuarCorp"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[0]  VOLVER AL MENU PRINCIPAL" -ForegroundColor Yellow
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Red
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Listando todo el hardware del sistema..." -ForegroundColor Cyan
            $FullReport = (Get-CpuRamGpuReport) + "`n" +
                          (Get-StorageReport) + "`n" +
                          (Get-BiosBoardReport) + "`n" +
                          (Get-NetworkReport) + "`n" +
                          (Get-ConnectedDevicesReport)
            Write-Host $FullReport
            Save-HardwareLog -SectionTitle "Hardware Completo" -Content $FullReport
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Consultando CPU, RAM y GPU..." -ForegroundColor Cyan
            $Report = Get-CpuRamGpuReport
            Write-Host $Report
            Save-HardwareLog -SectionTitle "CPU, RAM y GPU" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Consultando discos y volumenes..." -ForegroundColor Cyan
            $Report = Get-StorageReport
            Write-Host $Report
            Save-HardwareLog -SectionTitle "Discos y Volumenes" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Consultando BIOS y placa base..." -ForegroundColor Cyan
            $Report = Get-BiosBoardReport
            Write-Host $Report
            Save-HardwareLog -SectionTitle "BIOS y Placa Base" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Consultando adaptadores de red..." -ForegroundColor Cyan
            $Report = Get-NetworkReport
            Write-Host $Report
            Save-HardwareLog -SectionTitle "Adaptadores de Red" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Consultando dispositivos conectados e IDs..." -ForegroundColor Cyan
            $Report = Get-ConnectedDevicesReport
            Write-Host $Report
            Save-HardwareLog -SectionTitle "Dispositivos Conectados (pnputil)" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '7', '07' } {
            if (Test-Path -Path $LatestLogPath) {
                Start-Process "notepad.exe" -ArgumentList "`"$LatestLogPath`""
            } else {
                Write-Host "`n[!] Aun no existe Ultimo_Hardware.log en $LogDir." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
        }
        { $_ -in '8', '08' } {
            if (Ensure-LogDirectory) {
                Start-Process explorer.exe $LogDir
            }
        }
        { $_ -in '100' } {
            Write-Host "`n[+] Analizando Repositorio..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/Analisis.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in 'a', 'A' } {
            Get-Content https://raw.githubusercontent.com/InsuarCorp/W11/main/Ayuda.txt | Out-GridView
        }
        { $_ -in '0' } {
            Write-Host "`n[+] Regresando al menu principal..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/00-Menu.ps1 | iex
            return
        }
        { $_ -in '00' } {
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
