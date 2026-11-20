# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Limpieza de Cache y Temporales W11"

# Definir ruta del log (usa el directorio actual o $PSScriptRoot si se ejecuta local)
$BaseDir = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) { $PSScriptRoot } else { (Get-Location).Path }
$LogFile = Join-Path -Path $BaseDir -ChildPath "limpieza_temp.log"

# Rutas de temporales
$WinTemp  = "C:\Windows\Temp"
$UserTemp = $env:TEMP

# Funcion auxiliar para limpiar carpetas y registrar en log
function Clear-TempFolder {
    param (
        [string]$TargetPath,
        [string]$LogPath
    )

    if (-not (Test-Path -Path $TargetPath)) {
        Add-Content -Path $LogPath -Value "Ruta no encontrada: $TargetPath"
        return 0
    }

    $DeletedCount = 0

    # Eliminar archivos recursivamente
    $Files = Get-ChildItem -Path $TargetPath -File -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($File in $Files) {
        try {
            Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            Add-Content -Path $LogPath -Value "Eliminado: $($File.FullName)"
            $DeletedCount++
        } catch {
            Add-Content -Path $LogPath -Value "En uso / Omitido: $($File.FullName)"
        }
    }

    # Eliminar subcarpetas vacias o residuales
    $Folders = Get-ChildItem -Path $TargetPath -Directory -Force -ErrorAction SilentlyContinue
    foreach ($Folder in $Folders) {
        try {
            Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction Stop
            Add-Content -Path $LogPath -Value "Eliminando carpeta: $($Folder.FullName)"
            $DeletedCount++
        } catch {
            Add-Content -Path $LogPath -Value "Carpeta en uso / Omitida: $($Folder.FullName)"
        }
    }

    return $DeletedCount
}

# Funcion para vaciar la Papelera de reciclaje
function Clear-RecycleBinSafe {
    param (
        [string]$LogPath
    )

    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Add-Content -Path $LogPath -Value "Papelera de reciclaje vaciada correctamente."
        return $true
    } catch {
        Add-Content -Path $LogPath -Value "Papelera vacia o con elementos omitidos: $($_.Exception.Message)"
        return $false
    }
}

# Funcion para limpiar accesos directos de Recientes del Explorador de archivos
function Clear-RecentItems {
    param (
        [string]$LogPath
    )

    $RecentDirs = @(
        "$env:APPDATA\Microsoft\Windows\Recent",
        "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations",
        "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"
    )

    $DeletedCount = 0

    foreach ($Dir in $RecentDirs) {
        if (-not (Test-Path -Path $Dir)) {
            Add-Content -Path $LogPath -Value "Ruta de recientes no encontrada: $Dir"
            continue
        }

        $Items = Get-ChildItem -Path $Dir -Force -File -ErrorAction SilentlyContinue
        foreach ($Item in $Items) {
            try {
                Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                Add-Content -Path $LogPath -Value "Reciente eliminado: $($Item.FullName)"
                $DeletedCount++
            } catch {
                Add-Content -Path $LogPath -Value "Reciente en uso / Omitido: $($Item.FullName)"
            }
        }
    }

    return $DeletedCount
}

# Funcion para reiniciar el Explorador de archivos (explorer.exe)
function Restart-ExplorerSafe {
    param (
        [string]$LogPath
    )

    try {
        Write-Host " -> Reiniciando Explorador de archivos (explorer.exe)..." -ForegroundColor Yellow
        Add-Content -Path $LogPath -Value "Reiniciando explorer.exe..."

        Get-Process -Name "explorer" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction Stop
        Start-Sleep -Seconds 1

        if (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath "$env:WINDIR\explorer.exe"
        }

        Add-Content -Path $LogPath -Value "Explorador de archivos reiniciado correctamente."
        Write-Host " -> Explorador reiniciado." -ForegroundColor Green
    } catch {
        Add-Content -Path $LogPath -Value "Error al reiniciar explorer.exe: $($_.Exception.Message)"
        Write-Host " -> Advertencia al reiniciar explorer.exe: $($_.Exception.Message)" -ForegroundColor Red
    }
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                         [       Limpieza de Cache y Temp       ]                       " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "Rutas objetivo:" -ForegroundColor DarkGray
    Write-Host " - $WinTemp" -ForegroundColor DarkGray
    Write-Host " - $UserTemp" -ForegroundColor DarkGray
    Write-Host " - Papelera de reciclaje + Recientes del Explorador" -ForegroundColor DarkGray
    Write-Host "Log: $LogFile" -ForegroundColor DarkGray
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpieza COMPLETA (Temp + Papelera + Recientes) y reiniciar Explorador"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo C:\Windows\Temp"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo AppData\Local\Temp del usuario"
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Papelera de reciclaje y limpiar Recientes (+ reiniciar Explorador)"
    Write-Host "[5] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver archivo de log (limpieza_temp.log)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Iniciando limpieza completa..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza completa: $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host " -> Borrando archivos de $WinTemp..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos de $WinTemp"
            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            Write-Host " -> Borrando archivos de $UserTemp..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos de $UserTemp"
            $CountUser = Clear-TempFolder -TargetPath $UserTemp -LogPath $LogFile

            Write-Host " -> Vaciando Papelera de reciclaje..." -ForegroundColor Yellow
            $null = Clear-RecycleBinSafe -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Limpiando accesos directos de Recientes"
            $CountRecent = Clear-RecentItems -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Fin de limpieza: $FechaFin"
            Add-Content -Path $LogFile -Value "==============================================="

            $TotalElementos = $CountWin + $CountUser + $CountRecent
            Write-Host "`nLimpieza completada ($TotalElementos archivos/carpetas eliminados + Papelera procesada)." -ForegroundColor Green
            Write-Host "Revisa el archivo de log: $LogFile" -ForegroundColor DarkGray
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Limpiando $WinTemp..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza ($WinTemp): $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountWin elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Limpiando $UserTemp..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza ($UserTemp): $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            $CountUser = Clear-TempFolder -TargetPath $UserTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountUser elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host "`n[+] Vaciando Papelera y limpiando Recientes..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza (Papelera y Recientes): $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host " -> Vaciando Papelera de reciclaje..." -ForegroundColor Yellow
            $null = Clear-RecycleBinSafe -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes..." -ForegroundColor Yellow
            $CountRecent = Clear-RecentItems -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Fin de limpieza: $FechaFin"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host "`nProceso completado ($CountRecent elementos de Recientes eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5' } {
            if (Test-Path -Path $LogFile) {
                Start-Process "notepad.exe" -ArgumentList "`"$LogFile`""
            } else {
                Write-Host "`nAun no se ha generado el archivo limpieza_temp.log" -ForegroundColor Yellow
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
        { $_ -in '0', '00' } {
            return
        }
        Default {
            Write-Host "Opcion invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
