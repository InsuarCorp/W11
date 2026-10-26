# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Configuracion para W11"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [     Configuracion para W11     ]                         " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
     # Opciones alineadas
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "S   " -NoNewline
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "H   " -NoNewline
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Telemetria   "  -NoNewline
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "W   "  -NoNewline
    Write-Host "[5] " -NoNewline -ForegroundColor Cyan; Write-Host "T"
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "  -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '10' } {
            Write-Host "`n[+] Cargando modulo 01 (Software)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/1-Software.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '20' } {
            Write-Host "`n[+] Cargando modulo 02 (Hardware)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/2-Hardware.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '30' } {
            Write-Host "`n[+] Cargando modulo 03 (Drivers)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/0403-Telemetria.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '40' } {
            Write-Host "`n[+] Cargando modulo 04 (Windows)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/40-Windows.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '50' } {
            Write-Host "`n[+] Cargando modulo 05 (Tweak)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/50-Tweak.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '100' } {
            Write-Host "`n[+] Analizando Repositorio..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/Analisis.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }

{ $_ -in 'a', 'A' } {
          Get-Content  https://raw.githubusercontent.com/InsuarCorp/W11/main/Ayuda.txt | Out-GridView
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
