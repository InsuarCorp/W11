# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // HERRAMIENTAS DE RED"

# Bucle principal para mantener el menú abierto
do {
    Clear-Host

    # Carga y ejecuta info.ps1 directamente desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [ Menu Principal  V 26.09   ]                              " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Opciones alineadas
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "SoftWare   " -NoNewline
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Hardware   " -NoNewline
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Windows   "  -NoNewline
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Tweak"
   
    Write-Host ""
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Cargando modulo 01 (Software)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/0001.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Cargando modulo 02 (Hardware)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/0002.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Cargando modulo 03 (Windows)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/0003.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Cargando modulo 04 (Tweak)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/0004.ps1 | iex
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