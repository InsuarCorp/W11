# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "SISTEMA // DIAGNOSTICO DE PANTALLAZOS AZULES (BSOD)"

$LogDir = "C:\InsuarCorp"
$LatestBsodLog = Join-Path -Path $LogDir -ChildPath "Ultimo_BSOD.log"

function Ensure-BsodLogDirectory {
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

function Save-BsodLog {
    param (
        [string]$SectionTitle,
        [string]$Content
    )

    if (-not (Ensure-BsodLogDirectory)) { return }

    $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ReadableDate = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $HostName = $env:COMPUTERNAME
    $FilePath = Join-Path -Path $LogDir -ChildPath "BSOD_${HostName}_${Stamp}.log"

    $Header = @"
================================================================================
INSUAR CORP - DIAGNOSTICO BSOD Y VOLCADOS
Fecha/Hora : $ReadableDate
Equipo     : $HostName
Seccion    : $SectionTitle
================================================================================

"@

    $FullText = $Header + $Content
    $FullText | Out-File -FilePath $FilePath -Encoding utf8 -Force
    $FullText | Out-File -FilePath $LatestBsodLog -Encoding utf8 -Force

    Write-Host ""
    Write-Host "[OK] Log guardado en: $FilePath" -ForegroundColor Green
    Write-Host "[OK] Ultimo log actualizado en: $LatestBsodLog" -ForegroundColor Green
}

function Get-CriticalSystemEvents {
    param ([int]$Max = 15)

    $Events = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1 } -MaxEvents $Max -ErrorAction SilentlyContinue
    if (-not $Events) {
        return "No se encontraron eventos criticos (Level=1) en el registro System."
    }

    return ($Events | Select-Object TimeCreated, Id, ProviderName, Message | Format-List | Out-String)
}

function Get-BsodAndRestartEvents {
    param ([int]$Max = 25)

    $Events = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1001, 6008 } -MaxEvents $Max -ErrorAction SilentlyContinue
    if (-not $Events) {
        return "No se encontraron eventos de BugCheck (1001), Kernel-Power (41) ni apagado inesperado (6008)."
    }

    return ($Events | Select-Object TimeCreated, Id, ProviderName, Message | Format-List | Out-String)
}

function Get-MinidumpReport {
    $DumpDir = "C:\Windows\Minidump"
    $MemDump = "C:\Windows\MEMORY.DMP"

    $Lines = New-Object System.Collections.Generic.List[string]
    $Lines.Add("=== CARPETA MINIDUMP ($DumpDir) ===")

    if (Test-Path -Path $DumpDir) {
        $Files = Get-ChildItem -Path $DumpDir -Filter "*.dmp" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending
        if ($Files) {
            $Table = $Files | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String
            $Lines.Add($Table.TrimEnd())
        } else {
            $Lines.Add("No hay archivos .dmp en $DumpDir.")
        }
    } else {
        $Lines.Add("La carpeta $DumpDir no existe.")
    }

    $Lines.Add("")
    $Lines.Add("=== VOLCADO COMPLETO ($MemDump) ===")
    if (Test-Path -Path $MemDump) {
        $FullDumpInfo = Get-Item -Path $MemDump -ErrorAction SilentlyContinue |
            Select-Object FullName, Length, LastWriteTime | Format-List | Out-String
        $Lines.Add($FullDumpInfo.TrimEnd())
    } else {
        $Lines.Add("No existe $MemDump.")
    }

    return ($Lines -join "`n")
}

function Get-CrashDumpConfigReport {
    $CrashReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -ErrorAction SilentlyContinue
    if (-not $CrashReg) {
        return "No se pudo leer la clave CrashControl en el registro."
    }

    $DumpMode = switch ($CrashReg.CrashDumpEnabled) {
        0 { "0 - Ninguno" }
        1 { "1 - Volcado de memoria completo" }
        2 { "2 - Volcado de memoria del kernel" }
        3 { "3 - Volcado de memoria pequenio (Minidump)" }
        7 { "7 - Volcado de memoria automatico" }
        default { "$($CrashReg.CrashDumpEnabled) - Otro" }
    }

    $Obj = [PSCustomObject]@{
        ModoVolcado          = $DumpMode
        CarpetaMinidump      = $CrashReg.MinidumpDir
        ArchivoVolcado       = $CrashReg.DumpFile
        ReinicioAutomatico   = $CrashReg.AutoReboot
        SobrescribirArchivo  = $CrashReg.Overwrite
    }

    return ($Obj | Format-List | Out-String)
}

function Clear-PreviousBsodLogs {
    if (-not (Test-Path -Path $LogDir)) {
        Write-Host "`n[!] No existe la carpeta $LogDir." -ForegroundColor Yellow
        return
    }

    $BsodFiles = Get-ChildItem -Path $LogDir -Filter "BSOD_*.log" -ErrorAction SilentlyContinue
    $HasLatest = Test-Path -Path $LatestBsodLog

    if (-not $BsodFiles -and -not $HasLatest) {
        Write-Host "`n[!] No hay registros previos de BSOD en $LogDir." -ForegroundColor Yellow
        return
    }

    Write-Host "`n[!] Esto eliminara los logs BSOD_*.log y Ultimo_BSOD.log en $LogDir." -ForegroundColor Yellow
    $Confirm = Read-Host "Escriba S para confirmar o cualquier otra tecla para cancelar"
    if ($Confirm -notin @("S", "s")) {
        Write-Host "[*] Operacion cancelada." -ForegroundColor Cyan
        return
    }

    if ($BsodFiles) {
        Remove-Item -Path $BsodFiles.FullName -Force -ErrorAction SilentlyContinue
    }
    if ($HasLatest) {
        Remove-Item -Path $LatestBsodLog -Force -ErrorAction SilentlyContinue
    }

    Write-Host "[OK] Registros previos de BSOD eliminados en $LogDir." -ForegroundColor Green
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                      [     Diagnostico de Pantallazos (BSOD)     ]                   " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Eventos BSOD y reinicios inesperados (ID 41, 1001, 6008) + log"
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Ultimos 15 eventos criticos del sistema (Level=1) + log"
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Listar archivos Minidump y MEMORY.DMP + log"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver configuracion de volcado de memoria (CrashControl)"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Guardar reporte completo BSOD en C:\InsuarCorp"
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver ultimo log BSOD guardado (Ultimo_BSOD.log)"
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir carpeta C:\InsuarCorp"
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Eliminar todo registro previo BSOD (C:\InsuarCorp)"

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
            Write-Host "`n[+] Buscando eventos BSOD y reinicios inesperados..." -ForegroundColor Cyan
            $Report = Get-BsodAndRestartEvents -Max 25
            Write-Host $Report
            Save-BsodLog -SectionTitle "Eventos BSOD y Reinicios (41, 1001, 6008)" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Consultando ultimos 15 eventos criticos (Level=1)..." -ForegroundColor Cyan
            $Report = Get-CriticalSystemEvents -Max 15
            Write-Host $Report
            Save-BsodLog -SectionTitle "Eventos Criticos System (Level=1)" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Revisando archivos de volcado (Minidump)..." -ForegroundColor Cyan
            $Report = Get-MinidumpReport
            Write-Host $Report
            Save-BsodLog -SectionTitle "Archivos Minidump" -Content $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Consultando configuracion de volcado de memoria..." -ForegroundColor Cyan
            $Report = Get-CrashDumpConfigReport
            Write-Host $Report
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Generando reporte completo BSOD..." -ForegroundColor Cyan
            $FullReport = (Get-BsodAndRestartEvents -Max 25) + "`n`n" +
                          (Get-CriticalSystemEvents -Max 15) + "`n`n" +
                          (Get-MinidumpReport) + "`n`n" +
                          "=== CONFIGURACION VOLCADO ===`n" + (Get-CrashDumpConfigReport)
            Write-Host $FullReport
            Save-BsodLog -SectionTitle "Reporte Completo BSOD" -Content $FullReport
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            if (Test-Path -Path $LatestBsodLog) {
                Start-Process "notepad.exe" -ArgumentList "`"$LatestBsodLog`""
            } else {
                Write-Host "`n[!] Aun no existe Ultimo_BSOD.log en $LogDir." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            }
        }
        { $_ -in '7', '07' } {
            if (Ensure-BsodLogDirectory) {
                Start-Process explorer.exe $LogDir
            }
        }
        { $_ -in '8', '08' } {
            Clear-PreviousBsodLogs
            Read-Host "`nPresione Enter para continuar..."
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
