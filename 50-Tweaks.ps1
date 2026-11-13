# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Tweaks para W11"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                               [       Tweaks para W11       ]                          " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Ollama y Open WebUI" 
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Firewall y Redes" 
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Telemetría y Privacidad" 
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "Windows Update"  
    Write-Host "[5] " -NoNewline -ForegroundColor Cyan; Write-Host "Herramienta de Impresora"
    
    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Cargando modulo 01 (Software)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/5001-Ollama.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Cargando modulo 02 (Hardware)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/5002-Firewall.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Cargando modulo 03 (Drivers)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/5003-Telemetria.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host "`n[+] Cargando modulo 04 (Windows)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/5004-Update.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5' } {
            Write-Host "`n[+] Cargando modulo 05 (Tweak)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/5005-Impresora.ps1 | iex
            Read-Host "Presione Enter para continuar..."
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
