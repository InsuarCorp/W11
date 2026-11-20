# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Serial y Activacion W11"

# ==============================================================================
# Obtencion de seriales y respaldo inicial
# ==============================================================================
$RegKey  = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "BackupProductKeyDefault" -ErrorAction SilentlyContinue).BackupProductKeyDefault
$BiosKey = (Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction SilentlyContinue).OA3xOriginalProductKey

# Guardar respaldo en C:\codigokey.txt
$RegText  = if (-not [string]::IsNullOrWhiteSpace($RegKey))  { $RegKey }  else { "No disponible" }
$BiosText = if (-not [string]::IsNullOrWhiteSpace($BiosKey)) { $BiosKey } else { "No disponible" }

@(
    "Regedit:"
    $RegText
    ""
    "BIOS:"
    $BiosText
) | Out-File -FilePath "C:\codigokey.txt" -Encoding UTF8 -Force

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [       Serial y Activacion       ]                        " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Mostrar ambos seriales (Regedit y BIOS)"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Aplicar y activar serial de Regedit"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Aplicar y activar serial de BIOS"
    Write-Host "[4] " -NoNewline -ForegroundColor Cyan; Write-Host "Cargar un serial mio (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n==========================================" -ForegroundColor Cyan
            Write-Host "  SERIALES DETECTADOS EN EL EQUIPO" -ForegroundColor Cyan
            Write-Host "==========================================" -ForegroundColor Cyan

            Write-Host "Regedit  : " -NoNewline
            if (-not [string]::IsNullOrWhiteSpace($RegKey)) {
                Write-Host $RegKey -ForegroundColor Green
            } else {
                Write-Host "No disponible" -ForegroundColor Yellow
            }

            Write-Host "BIOS     : " -NoNewline
            if (-not [string]::IsNullOrWhiteSpace($BiosKey)) {
                Write-Host $BiosKey -ForegroundColor Green
            } else {
                Write-Host "No disponible" -ForegroundColor Yellow
            }

            Write-Host "Respaldo : " -NoNewline
            Write-Host "C:\codigokey.txt" -ForegroundColor DarkGray
            Write-Host "==========================================" -ForegroundColor Cyan
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Procesando serial de Regedit..." -ForegroundColor Cyan
            if (-not [string]::IsNullOrWhiteSpace($RegKey)) {
                Write-Host "Aplicando serial de Regedit: $RegKey" -ForegroundColor Green
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ipk $RegKey
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ato
            } else {
                Write-Host "No hay serial disponible en Regedit." -ForegroundColor Yellow
            }
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Procesando serial de BIOS..." -ForegroundColor Cyan
            if (-not [string]::IsNullOrWhiteSpace($BiosKey)) {
                Write-Host "Aplicando serial de BIOS: $BiosKey" -ForegroundColor Green
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ipk $BiosKey
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ato
            } else {
                Write-Host "No hay serial disponible en BIOS." -ForegroundColor Yellow
            }
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host ""
            $UserKey  = (Read-Host "Ingrese el serial (25 caracteres, con o sin guiones)").Trim().ToUpper()
            $CleanKey = $UserKey -replace '-', ''

            if ([string]::IsNullOrWhiteSpace($CleanKey)) {
                Write-Host "ERROR: No se ingreso ningun serial." -ForegroundColor Red
            } elseif ($CleanKey.Length -eq 25) {
                if ($UserKey -match '^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$') {
                    $FinalKey = $UserKey
                } else {
                    $FinalKey = ($CleanKey -replace '(.{5})(?!$)', '$1-')
                }
                Write-Host "`n[+] Aplicando serial ingresado: $FinalKey" -ForegroundColor Green
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ipk $FinalKey
                cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /ato
            } else {
                Write-Host "ERROR: El serial debe tener exactamente 25 caracteres (ingresados: $($CleanKey.Length))." -ForegroundColor Red
            }
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
