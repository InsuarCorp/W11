# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // HERRAMIENTAS DE RED"

# Bucle principal para mantener el menú abierto
do {
    Clear-Host

    # Carga y ejecuta info.ps1 directamente desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""
  
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [     Menu Principal        ]                              " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Opciones alineadas
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "SoftWare   " -NoNewline
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Hardware   " -NoNewline
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Driver   "  -NoNewline
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Windows   "  -NoNewline
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Tweak"
   
    Write-Host ""
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Cargando modulo 01 (Software)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/01-Software.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Cargando modulo 02 (Hardware)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/02-Hardware.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Cargando modulo 03 (Drivers)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/03-Driver.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Cargando modulo 04 (Windows)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/04-Windows.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Cargando modulo 05 (Tweak)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/05-Tweak.ps1 | iex
            Read-Host "Presione Enter para continuar..."
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
