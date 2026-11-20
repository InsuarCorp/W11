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
    Write-Host "Log: $LogFile" -ForegroundColor DarkGray
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar TODOS los temporales (Windows + Usuario) con log"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo C:\Windows\Temp"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo AppData\Local\Temp del usuario"
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver archivo de log (limpieza_temp.log)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Iniciando limpieza completa de temporales..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza: $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host " -> Borrando archivos de $WinTemp..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos de $WinTemp"
            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            Write-Host " -> Borrando archivos de $UserTemp..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos de $UserTemp"
            $CountUser = Clear-TempFolder -TargetPath $UserTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Fin de limpieza: $FechaFin"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host "`nLimpieza completada ($($CountWin + $CountUser) elementos eliminados)." -ForegroundColor Green
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
