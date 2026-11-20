# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Limpieza de Cache y Temporales W11"

# Definir ruta del log (usa $PSScriptRoot si existe, o el directorio actual)
$BaseDir = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} elseif (-not [string]::IsNullOrWhiteSpace($PWD.Path)) {
    $PWD.Path
} else {
    (Get-Location).Path
}

if ([string]::IsNullOrWhiteSpace($BaseDir)) {
    $BaseDir = $env:TEMP
}

$LogFile = Join-Path -Path $BaseDir -ChildPath "limpieza_temp.log"

# Rutas de temporales
$WinTemp  = "C:\Windows\Temp"
$UserTemp = if (-not [string]::IsNullOrWhiteSpace($env:TEMP)) { $env:TEMP } else { "C:\Windows\Temp" }

# Funcion auxiliar segura para escribir en el log sin fallar si $LogPath es nulo
function Write-CacheLog {
    param (
        [string]$LogPath,
        [string]$Message
    )

    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
        try {
            $ParentDir = Split-Path -Path $LogPath -Parent
            if (-not [string]::IsNullOrWhiteSpace($ParentDir) -and -not (Test-Path -Path $ParentDir)) {
                New-Item -Path $ParentDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Add-Content -Path $LogPath -Value $Message -ErrorAction SilentlyContinue
        } catch {
            # Evita romper el flujo principal si el log esta bloqueado
        }
    }
}

# Obtener perfiles de usuario locales reales (admin y no admin)
function Get-LocalUserProfiles {
    $ExcludedNames = @("Public", "Default", "Default User", "All Users", "WDAGUtilityAccount")
    $Profiles = @()

    $RegBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    if (Test-Path -Path $RegBase) {
        Get-ChildItem -Path $RegBase -ErrorAction SilentlyContinue | ForEach-Object {
            $Props = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
            $Sid = $_.PSChildName
            $Path = $Props.ProfileImagePath

            if ($Sid -like "S-1-5-21-*" -and -not [string]::IsNullOrWhiteSpace($Path) -and (Test-Path -Path $Path)) {
                $Leaf = Split-Path -Path $Path -Leaf
                if ($Leaf -notin $ExcludedNames) {
                    $Profiles += [PSCustomObject]@{
                        SID         = $Sid
                        UserName    = $Leaf
                        ProfilePath = $Path
                    }
                }
            }
        }
    }

    return $Profiles
}

# Funcion auxiliar para limpiar carpetas y registrar en log
function Clear-TempFolder {
    param (
        [string]$TargetPath,
        [string]$LogPath
    )

    if ([string]::IsNullOrWhiteSpace($TargetPath) -or -not (Test-Path -Path $TargetPath)) {
        Write-CacheLog -LogPath $LogPath -Message "Ruta no encontrada: $TargetPath"
        return 0
    }

    $DeletedCount = 0

    $Files = Get-ChildItem -Path $TargetPath -File -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($File in $Files) {
        try {
            Remove-Item -Path $File.FullName -Force -ErrorAction Stop
            Write-CacheLog -LogPath $LogPath -Message "Eliminado: $($File.FullName)"
            $DeletedCount++
        } catch {
            Write-CacheLog -LogPath $LogPath -Message "En uso / Omitido: $($File.FullName)"
        }
    }

    $Folders = Get-ChildItem -Path $TargetPath -Directory -Force -ErrorAction SilentlyContinue
    foreach ($Folder in $Folders) {
        try {
            Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction Stop
            Write-CacheLog -LogPath $LogPath -Message "Eliminando carpeta: $($Folder.FullName)"
            $DeletedCount++
        } catch {
            Write-CacheLog -LogPath $LogPath -Message "Carpeta en uso / Omitida: $($Folder.FullName)"
        }
    }

    return $DeletedCount
}

# Limpiar Temp de todos los perfiles locales
function Clear-AllUsersTemp {
    param (
        [string]$LogPath
    )

    $TotalDeleted = 0
    $Profiles = Get-LocalUserProfiles

    foreach ($Prof in $Profiles) {
        $UserTempPath = Join-Path -Path $Prof.ProfilePath -ChildPath "AppData\Local\Temp"
        if (Test-Path -Path $UserTempPath) {
            Write-CacheLog -LogPath $LogPath -Message "Limpiando Temp de usuario '$($Prof.UserName)' ($UserTempPath)..."
            $TotalDeleted += Clear-TempFolder -TargetPath $UserTempPath -LogPath $LogPath
        }
    }

    return $TotalDeleted
}

# Limpiar accesos directos de Recientes de todos los perfiles locales
function Clear-RecentItems {
    param (
        [string]$LogPath
    )

    $DeletedCount = 0
    $Profiles = Get-LocalUserProfiles

    foreach ($Prof in $Profiles) {
        $RecentDirs = @(
            (Join-Path -Path $Prof.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent"),
            (Join-Path -Path $Prof.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"),
            (Join-Path -Path $Prof.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations")
        )

        foreach ($Dir in $RecentDirs) {
            if ([string]::IsNullOrWhiteSpace($Dir) -or -not (Test-Path -Path $Dir)) { continue }

            $Items = Get-ChildItem -Path $Dir -Force -File -ErrorAction SilentlyContinue
            foreach ($Item in $Items) {
                try {
                    Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                    Write-CacheLog -LogPath $LogPath -Message "Reciente eliminado [$($Prof.UserName)]: $($Item.FullName)"
                    $DeletedCount++
                } catch {
                    Write-CacheLog -LogPath $LogPath -Message "Reciente en uso / Omitido [$($Prof.UserName)]: $($Item.FullName)"
                }
            }
        }
    }

    return $DeletedCount
}

# Vaciar Papelera de reciclaje en unidades fijas y perfiles locales
function Clear-RecycleBinSafe {
    param (
        [string]$LogPath
    )

    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-CacheLog -LogPath $LogPath -Message "Clear-RecycleBin ejecutado."
    } catch {
        Write-CacheLog -LogPath $LogPath -Message "Aviso en Clear-RecycleBin: $($_.Exception.Message)"
    }

    $Profiles = Get-LocalUserProfiles
    $UserSids = @($Profiles | ForEach-Object { $_.SID })
    $FixedDrives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction SilentlyContinue
    $RemainingTotal = 0

    foreach ($Drive in $FixedDrives) {
        if ([string]::IsNullOrWhiteSpace($Drive.DeviceID)) { continue }

        $RecycleRoot = Join-Path -Path "$($Drive.DeviceID)\" -ChildPath "`$Recycle.Bin"
        if (-not (Test-Path -Path $RecycleRoot)) { continue }

        $SidDirs = Get-ChildItem -Path $RecycleRoot -Force -Directory -ErrorAction SilentlyContinue
        foreach ($SidDir in $SidDirs) {
            if ($SidDir.Name -in $UserSids) {
                $Entries = Get-ChildItem -Path $SidDir.FullName -Force -ErrorAction SilentlyContinue
                foreach ($Entry in $Entries) {
                    try {
                        Remove-Item -Path $Entry.FullName -Recurse -Force -ErrorAction Stop
                        Write-CacheLog -LogPath $LogPath -Message "Eliminado de papelera [$($Drive.DeviceID) | $($SidDir.Name)]: $($Entry.FullName)"
                    } catch {
                        Write-CacheLog -LogPath $LogPath -Message "No se pudo borrar en papelera [$($Drive.DeviceID) | $($SidDir.Name)]: $($Entry.FullName) -> $($_.Exception.Message)"
                    }
                }

                $LeftHere = @(Get-ChildItem -Path $SidDir.FullName -Recurse -Force -ErrorAction SilentlyContinue).Count
                $RemainingTotal += $LeftHere
            }
        }
    }

    if ($RemainingTotal -eq 0) {
        Write-CacheLog -LogPath $LogPath -Message "Estado final papelera (todos los usuarios): Vacia."
        return $true
    } else {
        Write-CacheLog -LogPath $LogPath -Message "Estado final papelera: Quedan $RemainingTotal elemento(s) en alguna unidad/perfil."
        return $false
    }
}

# Reiniciar el Explorador de archivos de forma segura
function Restart-ExplorerSafe {
    param (
        [string]$LogPath
    )

    try {
        Write-Host " -> Reiniciando Explorador de archivos (explorer.exe)..." -ForegroundColor Yellow
        Write-CacheLog -LogPath $LogPath -Message "Reiniciando explorer.exe..."

        Get-Process -Name "explorer" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction Stop
        Start-Sleep -Seconds 1

        if (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath "$env:WINDIR\explorer.exe"
        }

        Write-CacheLog -LogPath $LogPath -Message "Explorador de archivos reiniciado correctamente."
        Write-Host " -> Explorador reiniciado." -ForegroundColor Green
    } catch {
        Write-CacheLog -LogPath $LogPath -Message "Error al reiniciar explorer.exe: $($_.Exception.Message)"
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
    Write-Host " - $UserTemp (todos los perfiles locales)" -ForegroundColor DarkGray
    Write-Host " - Papelera de reciclaje + Recientes del Explorador (todos los perfiles)" -ForegroundColor DarkGray
    Write-Host "Log: $LogFile" -ForegroundColor DarkGray
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpieza COMPLETA (Temp todos + Papelera + Recientes) y reiniciar Explorador"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo C:\Windows\Temp"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar AppData\Local\Temp de todos los usuarios"
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

            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Inicio de limpieza completa: $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            Write-Host " -> Borrando archivos de $WinTemp..." -ForegroundColor Yellow
            Write-CacheLog -LogPath $LogFile -Value "Borrando archivos de $WinTemp"
            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            Write-Host " -> Borrando archivos Temp de todos los usuarios..." -ForegroundColor Yellow
            Write-CacheLog -LogPath $LogFile -Value "Borrando archivos Temp de todos los perfiles locales"
            $CountUser = Clear-AllUsersTemp -LogPath $LogFile

            Write-Host " -> Vaciando Papelera de reciclaje..." -ForegroundColor Yellow
            $null = Clear-RecycleBinSafe -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes..." -ForegroundColor Yellow
            Write-CacheLog -LogPath $LogFile -Value "Limpiando accesos directos de Recientes"
            $CountRecent = Clear-RecentItems -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            $TotalElementos = $CountWin + $CountUser + $CountRecent
            Write-Host "`nLimpieza completada ($TotalElementos archivos/carpetas eliminados + Papelera procesada)." -ForegroundColor Green
            Write-Host "Revisa el archivo de log: $LogFile" -ForegroundColor DarkGray
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Limpiando $WinTemp..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Inicio de limpieza ($WinTemp): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountWin elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Limpiando AppData\Local\Temp de todos los usuarios..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Inicio de limpieza (Temp todos los usuarios): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            $CountUser = Clear-AllUsersTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountUser elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host "`n[+] Vaciando Papelera y limpiando Recientes..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Inicio de limpieza (Papelera y Recientes): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            Write-Host " -> Vaciando Papelera de reciclaje..." -ForegroundColor Yellow
            $null = Clear-RecycleBinSafe -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes..." -ForegroundColor Yellow
            $CountRecent = Clear-RecentItems -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="
            Write-CacheLog -LogPath $LogFile -Value "Fin de limpieza: $FechaFin"
            Write-CacheLog -LogPath $LogFile -Value "==============================================="

            Write-Host "`nProceso completado ($CountRecent elementos de Recientes eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5' } {
            if (-not [string]::IsNullOrWhiteSpace($LogFile) -and (Test-Path -Path $LogFile)) {
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
