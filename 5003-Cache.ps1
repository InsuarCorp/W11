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

            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza completa: $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            Write-Host " -> Borrando archivos de $WinTemp..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos de $WinTemp"
            $CountWin = Clear-TempFolder -TargetPath $WinTemp -LogPath $LogFile

            Write-Host " -> Borrando archivos Temp de todos los usuarios..." -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value "Borrando archivos Temp de todos los perfiles locales"
            $CountUser = Clear-AllUsersTemp -LogPath $LogFile

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
            Write-Host "`n[+] Limpiando AppData\Local\Temp de todos los usuarios..." -ForegroundColor Cyan
            $FechaInicio = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            Add-Content -Path $LogFile -Value "==============================================="
            Add-Content -Path $LogFile -Value "Inicio de limpieza (Temp todos los usuarios): $FechaInicio"
            Add-Content -Path $LogFile -Value "==============================================="

            $CountUser = Clear-AllUsersTemp -LogPath $LogFile

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
