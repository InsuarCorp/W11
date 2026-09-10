# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // PROGRAMAS DE INICIO"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [ Menu Apps de Inicio V 26.09 ]                            " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menú alineado en 3 columnas
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver Apps de Inicio        " -NoNewline
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Inicio Todos los Usuarios " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Generar Reporte de Inicio"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir Carpeta Startup     " -NoNewline
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Ajustes de Inicio Windows " -NoNewline
    Write-Host ""
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Inicio Usuario Actual     " -NoNewline
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Pestaña Inicio TaskMgr    " -NoNewline
    Write-Host ""
    Write-Host ""
    
    Write-Host "[00] VOLVER AL MENÚ PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Consultando aplicaciones configuradas en el inicio..." -ForegroundColor Cyan
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User | Format-Table -AutoSize
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Abriendo carpeta de inicio del usuario (Shell:Startup)..." -ForegroundColor Cyan
            Start-Process explorer.exe shell:startup
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Consultando Entradas de Inicio en Registro (HKCU)..." -ForegroundColor Cyan
            Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Consultando Entradas de Inicio en Registro (HKLM - Todos los Usuarios)..." -ForegroundColor Cyan
            Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Format-List
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Abriendo Configuración de Aplicaciones de Inicio..." -ForegroundColor Cyan
            Start-Process ms-settings:startupapps
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Abriendo Administrador de Tareas..." -ForegroundColor Cyan
            Start-Process taskmgr
        }
        { $_ -in '7', '07' } {
            Write-Host "`n[+] Generando Reporte de Programas de Inicio..." -ForegroundColor Cyan
            $reportPath = "$env:USERPROFILE\Desktop\Reporte_Inicio.txt"
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User | Out-File -FilePath $reportPath
            Write-Host "[!] Reporte guardado en tu Escritorio: $reportPath" -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
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