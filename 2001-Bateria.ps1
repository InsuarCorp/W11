# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "SISTEMA // DIAGNOSTICO DE BATERIA Y ENERGIA"

# Definir ruta base segura (nunca nula)
$BaseDir = $null
if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $BaseDir = $PSScriptRoot
} elseif ($PWD -and -not [string]::IsNullOrWhiteSpace($PWD.Path)) {
    $BaseDir = $PWD.Path
} else {
    $BaseDir = (Get-Location).Path
}

if ([string]::IsNullOrWhiteSpace($BaseDir)) {
    $BaseDir = $env:TEMP
}
if ([string]::IsNullOrWhiteSpace($BaseDir)) {
    $BaseDir = "C:\Windows\Temp"
}

$ReportLogFile = Join-Path -Path $BaseDir -ChildPath "diagnostico_bateria.log"

function Write-BatteryLog {
    param (
        [string]$LogPath,
        [string]$Message
    )

    if ([string]::IsNullOrWhiteSpace($LogPath)) { return }

    try {
        $ParentDir = Split-Path -Path $LogPath -Parent
        if (-not [string]::IsNullOrWhiteSpace($ParentDir) -and -not (Test-Path -Path $ParentDir)) {
            New-Item -Path $ParentDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Add-Content -Path $LogPath -Value $Message -ErrorAction SilentlyContinue
    } catch {}
}

function Get-BatteryStatusText {
    param ([int]$Code)

    switch ($Code) {
        1 { return "Descargando" }
        2 { return "CA conectada / Sin carga o completa" }
        3 { return "Completamente cargada" }
        4 { return "Bateria baja" }
        5 { return "Bateria critica" }
        6 { return "Cargando" }
        7 { return "Cargando y alta" }
        8 { return "Cargando y baja" }
        9 { return "Cargando y critica" }
        10 { return "Sin definir" }
        11 { return "Parcialmente cargada" }
        default { return "Desconocido ($Code)" }
    }
}

function Show-CurrentBatteryState {
    $Batteries = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if (-not $Batteries) {
        Write-Host "`n[!] No se detecto bateria en Win32_Battery (equipo sin bateria o desconectada)." -ForegroundColor Red
        return
    }

    foreach ($Bat in $Batteries) {
        $EstadoTexto = Get-BatteryStatusText -Code ([int]$Bat.BatteryStatus)
        [PSCustomObject]@{
            Nombre              = $Bat.Name
            CargaPorcentaje     = "$($Bat.EstimatedChargeRemaining)%"
            Estado              = $EstadoTexto
            TiempoRestanteMin   = $Bat.EstimatedRunTime
            Voltaje_mV          = $Bat.DesignVoltage
            Quimica             = $Bat.Chemistry
            EstadoDispositivo   = $Bat.Status
        } | Format-List
    }
}

function Show-BatteryHealth {
    $StaticList = Get-CimInstance -Namespace root\WMI -ClassName BatteryStaticData -ErrorAction SilentlyContinue
    $FullList   = Get-CimInstance -Namespace root\WMI -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue
    $StatusList = Get-CimInstance -Namespace root\WMI -ClassName BatteryStatus -ErrorAction SilentlyContinue

    if (-not $StaticList -and -not $FullList) {
        Write-Host "`n[!] No se pudieron leer datos WMI de capacidad de bateria en este equipo." -ForegroundColor Yellow
        return
    }

    $Count = [Math]::Max(@($StaticList).Count, @($FullList).Count)
    for ($i = 0; $i -lt $Count; $i++) {
        $DesignCap = if ($StaticList -and $i -lt @($StaticList).Count) { [double]$StaticList[$i].DesignedCapacity } else { 0 }
        $FullCap   = if ($FullList   -and $i -lt @($FullList).Count)   { [double]$FullList[$i].FullChargedCapacity } else { 0 }

        $SaludPct = "N/A"
        $DesgastePct = "N/A"
        if ($DesignCap -gt 0 -and $FullCap -gt 0) {
            $SaludNum = [Math]::Round(($FullCap / $DesignCap) * 100, 1)
            $DesgasteNum = [Math]::Round(100 - $SaludNum, 1)
            if ($DesgasteNum -lt 0) { $DesgasteNum = 0 }
            $SaludPct = "$SaludNum%"
            $DesgastePct = "$DesgasteNum%"
        }

        $VoltajeActualmV = "N/A"
        $EstadoEnergia = "N/A"
        if ($StatusList -and $i -lt @($StatusList).Count) {
            $VoltajeActualmV = $StatusList[$i].Voltage
            $EstadoEnergia = if ($StatusList[$i].ACOnline) { "Conectado a CA (Cargador)" } else { "Solo Bateria" }
        }

        [PSCustomObject]@{
            BateriaIndice        = $i
            CapacidadFabrica_mWh = if ($DesignCap -gt 0) { $DesignCap } else { "N/A" }
            CapacidadActual_mWh  = if ($FullCap -gt 0)   { $FullCap }   else { "N/A" }
            SaludEstimada        = $SaludPct
            DesgasteEstimado      = $DesgastePct
            VoltajeActual_mV     = $VoltajeActualmV
            FuenteEnergia        = $EstadoEnergia
        } | Format-List
    }
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                         [     Diagnostico de Bateria     ]                             " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Estado actual y carga de bateria"
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Salud, capacidad y desgaste"
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Generar reporte oficial Windows (battery-report.html)"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Guardar log de diagnostico en archivo"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver log de diagnostico (si existe)"

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
            Write-Host "`n[+] Consultando estado actual de bateria..." -ForegroundColor Cyan
            Show-CurrentBatteryState
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Consultando salud y desgaste de bateria..." -ForegroundColor Cyan
            Show-BatteryHealth
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Generando reporte oficial de bateria con powercfg..." -ForegroundColor Cyan
            $HtmlPath = Join-Path -Path $BaseDir -ChildPath "battery-report.html"
            try {
                powercfg /batteryreport /output "$HtmlPath" | Out-Null
                if (Test-Path -Path $HtmlPath) {
                    Write-Host "[!] Reporte generado en: $HtmlPath" -ForegroundColor Green
                    $Abrir = Read-Host "Desea abrirlo ahora? (S/N)"
                    if ($Abrir -in 's', 'S') {
                        Start-Process -FilePath $HtmlPath
                    }
                } else {
                    Write-Host "[!] No se pudo verificar el archivo generado." -ForegroundColor Yellow
                }
            } catch {
                Write-Host "[!] Error al ejecutar powercfg: $($_.Exception.Message)" -ForegroundColor Red
            }
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Guardando log de diagnostico de bateria..." -ForegroundColor Cyan
            $Fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-BatteryLog -LogPath $ReportLogFile -Message "==============================================="
            Write-BatteryLog -LogPath $ReportLogFile -Message "Diagnostico de bateria: $Fecha"
            Write-BatteryLog -LogPath $ReportLogFile -Message "==============================================="

            $BatInfo = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Out-String
            $FullInfo = Get-CimInstance -Namespace root\WMI -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue | Out-String
            $DesignInfo = Get-CimInstance -Namespace root\WMI -ClassName BatteryStaticData -ErrorAction SilentlyContinue | Out-String

            Write-BatteryLog -LogPath $ReportLogFile -Message $BatInfo
            Write-BatteryLog -LogPath $ReportLogFile -Message $DesignInfo
            Write-BatteryLog -LogPath $ReportLogFile -Message $FullInfo

            Write-Host "[!] Log guardado en: $ReportLogFile" -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            if (-not [string]::IsNullOrWhiteSpace($ReportLogFile) -and (Test-Path -Path $ReportLogFile)) {
                Start-Process "notepad.exe" -ArgumentList "`"$ReportLogFile`""
            } else {
                Write-Host "`nAun no se ha generado el log de bateria." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
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
