# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // HERRAMIENTAS DE MANTENIMIENTO"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                           [ Menu Mantenimiento  V 26.09 ]                              " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menú alineado en 3 columnas
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpiar Archivos Temporales   " -NoNewline
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Limpieza de Disco (Auto)     " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir Administrador de Tareas"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Caché DNS              " -NoNewline
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Comprobar Archivos (SFC)     " -NoNewline
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Bloquear Equipo"
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Papelera de Reciclaje  " -NoNewline
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Probar Conexión a Internet   " -NoNewline
    Write-Host "[09] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar Explorer"
    Write-Host ""
    
    Write-Host "[00] VOLVER AL MENÚ PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Limpiando archivos temporales..." -ForegroundColor Cyan
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[!] Archivos temporales eliminados." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Vaciando caché DNS..." -ForegroundColor Cyan
            Clear-DnsClientCache
            Write-Host "[!] Caché DNS restablecida con éxito." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Vaciando Papelera de Reciclaje..." -ForegroundColor Cyan
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "[!] Papelera de reciclaje vaciada." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Ejecutando Limpieza de Disco automática..." -ForegroundColor Cyan
            cleanmgr /sagerun:1
            Write-Host "[!] Proceso de limpieza finalizado." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Iniciando comprobación del sistema (SFC /ScanNow)..." -ForegroundColor Cyan
            sfc /scannow
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Comprobando conexión a Internet..." -ForegroundColor Cyan
            Test-Connection -ComputerName google.com -Count 4
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '7', '07' } {
            Write-Host "`n[+] Abriendo Administrador de Tareas..." -ForegroundColor Cyan
            Start-Process taskmgr
        }
        { $_ -in '8', '08' } {
            Write-Host "`n[+] Bloqueando el equipo..." -ForegroundColor Cyan
            rundll32.exe user32.dll,LockWorkStation
        }
        { $_ -in '9', '09' } {
            Write-Host "`n[+] Reiniciando Explorador de Windows..." -ForegroundColor Cyan
            Stop-Process -Name explorer -Force
            Start-Process explorer
            Write-Host "[!] Explorador reiniciado." -ForegroundColor Magenta
            Start-Sleep -Seconds 1
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