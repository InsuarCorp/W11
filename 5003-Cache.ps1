# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Limpieza de Cache y Temporales W11"

# Definir ruta del log de forma segura (nunca nula)
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

$LogFile = Join-Path -Path $BaseDir -ChildPath "limpieza_temp.log"

# Rutas base
$WinTemp = "C:\Windows\Temp"

function Write-CacheLog {
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

function Get-ActiveInteractiveUserProfile {
    $ActiveUserName = $null

    try {
        $CS = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        if ($CS -and -not [string]::IsNullOrWhiteSpace($CS.UserName)) {
            $ActiveUserName = ($CS.UserName -split '\\')[-1]
        }
    } catch {}

    if ([string]::IsNullOrWhiteSpace($ActiveUserName)) {
        try {
            $ExpProc = Get-CimInstance -ClassName Win32_Process -Filter "Name = 'explorer.exe'" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($ExpProc) {
                $Owner = Invoke-CimMethod -InputObject $ExpProc -MethodName GetOwner -ErrorAction SilentlyContinue
                if ($Owner -and -not [string]::IsNullOrWhiteSpace($Owner.User)) {
                    $ActiveUserName = $Owner.User
                }
            }
        } catch {}
    }

    $RegBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    if (Test-Path -Path $RegBase) {
        foreach ($Key in (Get-ChildItem -Path $RegBase -ErrorAction SilentlyContinue)) {
            $Props = Get-ItemProperty -Path $Key.PSPath -ErrorAction SilentlyContinue
            $Sid = $Key.PSChildName
            $Path = $Props.ProfileImagePath

            if ($Sid -like "S-1-5-21-*" -and -not [string]::IsNullOrWhiteSpace($Path) -and (Test-Path -Path $Path)) {
                $Leaf = Split-Path -Path $Path -Leaf
                if (-not [string]::IsNullOrWhiteSpace($ActiveUserName) -and ($Leaf -ieq $ActiveUserName)) {
                    return [PSCustomObject]@{
                        SID         = $Sid
                        UserName    = $Leaf
                        ProfilePath = $Path
                    }
                }
            }
        }
    }

    $FallbackSid = ""
    try {
        $FallbackSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    } catch {}

    $FallbackPath = if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) { $env:USERPROFILE } else { "C:\Users\Default" }
    $FallbackName = if (-not [string]::IsNullOrWhiteSpace($env:USERNAME)) { $env:USERNAME } else { "Usuario" }

    return [PSCustomObject]@{
        SID         = $FallbackSid
        UserName    = $FallbackName
        ProfilePath = $FallbackPath
    }
}

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

function Clear-ActiveUserRecent {
    param (
        [PSCustomObject]$TargetProfile,
        [string]$LogPath
    )

    if (-not $TargetProfile -or [string]::IsNullOrWhiteSpace($TargetProfile.ProfilePath)) {
        Write-CacheLog -LogPath $LogPath -Message "Perfil de usuario activo no valido para limpiar Recientes."
        return 0
    }

    $DeletedCount = 0
    $RecentDirs = @(
        (Join-Path -Path $TargetProfile.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent"),
        (Join-Path -Path $TargetProfile.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"),
        (Join-Path -Path $TargetProfile.ProfilePath -ChildPath "AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations")
    )

    foreach ($Dir in $RecentDirs) {
        if ([string]::IsNullOrWhiteSpace($Dir) -or -not (Test-Path -Path $Dir)) { continue }

        $Items = Get-ChildItem -Path $Dir -Force -File -ErrorAction SilentlyContinue
        foreach ($Item in $Items) {
            try {
                Remove-Item -Path $Item.FullName -Force -ErrorAction Stop
                Write-CacheLog -LogPath $LogPath -Message "Reciente eliminado [$($TargetProfile.UserName)]: $($Item.FullName)"
                $DeletedCount++
            } catch {
                Write-CacheLog -LogPath $LogPath -Message "Reciente en uso / Omitido [$($TargetProfile.UserName)]: $($Item.FullName)"
            }
        }
    }

    return $DeletedCount
}

function Clear-ActiveUserRecycleBin {
    param (
        [PSCustomObject]$TargetProfile,
        [string]$LogPath
    )

    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-CacheLog -LogPath $LogPath -Message "Clear-RecycleBin ejecutado."
    } catch {
        Write-CacheLog -LogPath $LogPath -Message "Aviso en Clear-RecycleBin: $($_.Exception.Message)"
    }

    if (-not $TargetProfile -or [string]::IsNullOrWhiteSpace($TargetProfile.SID)) {
        Write-CacheLog -LogPath $LogPath -Message "SID del usuario activo no disponible para revisar `$Recycle.Bin."
        return $false
    }

    $FixedDrives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction SilentlyContinue
    $RemainingTotal = 0

    foreach ($Drive in $FixedDrives) {
        if ([string]::IsNullOrWhiteSpace($Drive.DeviceID)) { continue }

        $SidRecyclePath = Join-Path -Path "$($Drive.DeviceID)\`$Recycle.Bin" -ChildPath $TargetProfile.SID
        if (-not (Test-Path -Path $SidRecyclePath)) { continue }

        $Entries = Get-ChildItem -Path $SidRecyclePath -Force -ErrorAction SilentlyContinue
        foreach ($Entry in $Entries) {
            try {
                Remove-Item -Path $Entry.FullName -Recurse -Force -ErrorAction Stop
                Write-CacheLog -LogPath $LogPath -Message "Eliminado de papelera [$($Drive.DeviceID) | $($TargetProfile.UserName)]: $($Entry.FullName)"
            } catch {
                Write-CacheLog -LogPath $LogPath -Message "No se pudo borrar en papelera [$($Drive.DeviceID) | $($TargetProfile.UserName)]: $($Entry.FullName) -> $($_.Exception.Message)"
            }
        }

        $LeftHere = @(Get-ChildItem -Path $SidRecyclePath -Recurse -Force -ErrorAction SilentlyContinue).Count
        $RemainingTotal += $LeftHere
    }

    if ($RemainingTotal -eq 0) {
        Write-CacheLog -LogPath $LogPath -Message "Estado final papelera [$($TargetProfile.UserName)]: Vacia."
        return $true
    } else {
        Write-CacheLog -LogPath $LogPath -Message "Estado final papelera [$($TargetProfile.UserName)]: Quedan $RemainingTotal elemento(s)."
        return $false
    }
}

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

    $ActiveProfile = Get-ActiveInteractiveUserProfile
    $ActiveUserTemp = Join-Path -Path $ActiveProfile.ProfilePath -ChildPath "AppData\Local\Temp"

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                         [       Limpieza de Cache y Temp       ]                       " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "Usuario activo objetivo: $($ActiveProfile.UserName) ($($ActiveProfile.SID))" -ForegroundColor DarkGray
    Write-Host "Rutas objetivo:" -ForegroundColor DarkGray
    Write-Host " - $WinTemp" -ForegroundColor DarkGray
    Write-Host " - $ActiveUserTemp" -ForegroundColor DarkGray
    Write-Host " - Papelera y Recientes de: $($ActiveProfile.UserName)" -ForegroundColor DarkGray
    Write-Host "Log: $LogFile" -ForegroundColor DarkGray
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpieza COMPLETA (Temp + Papelera + Recientes de $($ActiveProfile.UserName)) y reiniciar Explorador"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo C:\Windows\Temp"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar solo AppData\Local\Temp de $($ActiveProfile.UserName)"
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Papelera y limpiar Recientes de $($ActiveProfile.UserName) (+ reiniciar Explorador)"
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
            Write-Host "`n[+] Iniciando limpieza completa para $($ActiveProfile.UserName)..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Inicio de limpieza completa ($($ActiveProfile.UserName)): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

            Write-Host " -> Borrando archivos de $WinTemp..." -ForegroundColor Yellow
            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            Write-Host " -> Borrando archivos de $ActiveUserTemp..." -ForegroundColor Yellow
            $CountUser = Clear-TempFolder -TargetPath $ActiveUserTemp -LogPath $LogFile

            Write-Host " -> Vaciando Papelera de reciclaje ($($ActiveProfile.UserName))..." -ForegroundColor Yellow
            $null = Clear-ActiveUserRecycleBin -TargetProfile $ActiveProfile -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes ($($ActiveProfile.UserName))..." -ForegroundColor Yellow
            $CountRecent = Clear-ActiveUserRecent -TargetProfile $ActiveProfile -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Fin de limpieza: $FechaFin"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

            $TotalElementos = $CountWin + $CountUser + $CountRecent
            Write-Host "`nLimpieza completada ($TotalElementos archivos/carpetas eliminados)." -ForegroundColor Green
            Write-Host "Revisa el archivo de log: $LogFile" -ForegroundColor DarkGray
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Limpiando $WinTemp..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Inicio de limpieza ($WinTemp): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountWin elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Limpiando $ActiveUserTemp..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Inicio de limpieza ($ActiveUserTemp): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

            $CountUser = Clear-TempFolder -TargetPath $ActiveUserTemp -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "Fin de limpieza: $FechaFin"
            Write-Host "Limpieza completada ($CountUser elementos eliminados)." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host "`n[+] Vaciando Papelera y limpiando Recientes de $($ActiveProfile.UserName)..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Inicio de limpieza (Papelera y Recientes - $($ActiveProfile.UserName)): $FechaInicio"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

            Write-Host " -> Vaciando Papelera de reciclaje..." -ForegroundColor Yellow
            $null = Clear-ActiveUserRecycleBin -TargetProfile $ActiveProfile -LogPath $LogFile

            Write-Host " -> Limpiando accesos directos de Recientes..." -ForegroundColor Yellow
            $CountRecent = Clear-ActiveUserRecent -TargetProfile $ActiveProfile -LogPath $LogFile

            Restart-ExplorerSafe -LogPath $LogFile

            $FechaFin = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="
            Write-CacheLog -LogPath $LogFile -Message "Fin de limpieza: $FechaFin"
            Write-CacheLog -LogPath $LogFile -Message "==============================================="

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
