# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp"

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
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "SoftWare   " -NoNewline
    Write-Host "[20] " -NoNewline -ForegroundColor Cyan; Write-Host "Hardware   " -NoNewline
    Write-Host "[30] " -NoNewline -ForegroundColor Cyan; Write-Host "Driver   "  -NoNewline
    Write-Host "[40] " -NoNewline -ForegroundColor Cyan; Write-Host "Windows   "  -NoNewline
    Write-Host "[50] " -NoNewline -ForegroundColor Cyan; Write-Host "Tweak"
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "  -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '10' } {
            Write-Host "`n[+] Cargando modulo 01 (Software)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/10-Software.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '20' } {
            Write-Host "`n[+] Cargando modulo 02 (Hardware)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/20-Hardware.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '30' } {
            Write-Host "`n[+] Cargando modulo 03 (Drivers)..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/30-Driver.ps1 | iex
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
     { $_ -in 'A' } {
            Write-Host "`n[+] Verificando y cargando Ayuda..." -ForegroundColor Cyan
            $AyudaPath = Join-Path $PSScriptRoot "Ayuda.txt"
            $helpContent = ""

            # Si no existe localmente, lo descarga de la web (autoinstalación/recuperación)
            if (-not (Test-Path $AyudaPath)) {
                try {
                    $helpContent = (irm https://raw.githubusercontent.com/InsuarCorp/W11/main/Ayuda.txt)
                    # Opcional: lo guarda localmente para futuras ejecuciones
                    $helpContent | Out-File -FilePath $AyudaPath -Encoding utf8 -ErrorAction SilentlyContinue
                } catch {
                    $helpContent = "No se pudo descargar el archivo de ayuda desde el repositorio."
                }
            } else {
                $helpContent = Get-Content $AyudaPath -Raw
            }

            # Abre una NUEVA ventana de PowerShell independiente mostrando la ayuda
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "
                `$host.UI.RawUI.WindowTitle = 'Ayuda - InsuarCorp';
                Clear-Host;
                Write-Host '========================================================================' -ForegroundColor Cyan;
                Write-Host '                         [  AYUDA DEL SISTEMA  ]                        ' -ForegroundColor Cyan;
                Write-Host '========================================================================' -ForegroundColor Cyan;
                Write-Host '';
                Write-Host '$helpContent';
                Write-Host '';
                Write-Host '========================================================================' -ForegroundColor Cyan;
                Read-Host 'Presione Enter para cerrar esta ventana...'
            "
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
