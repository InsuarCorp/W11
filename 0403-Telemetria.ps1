# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Telemetria para W11"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                               [       Telemetria para W11       ]                          " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    # === COMPROBACION DE ESTADO ACTUAL ===
    Write-Host " [ Estado Actual del Sistema ]" -ForegroundColor Yellow

    # 1. Verificar AllowTelemetry en el Registro
    $pathTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $telemetryValue = (Get-ItemProperty -Path $pathTelemetry -Name "AllowTelemetry" -ErrorAction SilentlyContinue).AllowTelemetry
    
    if ($null -eq $telemetryValue) {
        Write-Host "  * Telemetria General: " -NoNewline; Write-Host "No definida (Predeterminada de Windows)" -ForegroundColor DarkGray
    } elseif ($telemetryValue -eq 0) {
        Write-Host "  * Telemetria General: " -NoNewline; Write-Host "Deshabilitada (Segura)" -ForegroundColor Green
    } else {
        Write-Host "  * Telemetria General: " -NoNewline; Write-Host "Activa (Nivel $telemetryValue)" -ForegroundColor Red
    }

    # 2. Verificar Estado del Servicio DiagTrack
    $serviceDiag = Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    if ($serviceDiag) {
        if ($serviceDiag.Status -eq "Running") {
            Write-Host "  * Servicio DiagTrack: " -NoNewline; Write-Host "En ejecucion (Activo)" -ForegroundColor Red
        } else {
            Write-Host "  * Servicio DiagTrack: " -NoNewline; Write-Host "Detenido / Deshabilitado" -ForegroundColor Green
        }
    }

    # 3. Verificar Busqueda en la nube y Cortana / Copilot
    $pathSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $searchWebValue = (Get-ItemProperty -Path $pathSearch -Name "DisableWebSearch" -ErrorAction SilentlyContinue).DisableWebSearch
    if ($searchWebValue -eq 1) {
        Write-Host "  * Busqueda Web / Nube: " -NoNewline; Write-Host "Deshabilitada" -ForegroundColor Green
    } else {
        Write-Host "  * Busqueda Web / Nube: " -NoNewline; Write-Host "Activa" -ForegroundColor Red
    }

    $pathExplorerHKLM = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    $pathExplorerHKCU = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
    $copilotHKLM = (Get-ItemProperty -Path $pathExplorerHKLM -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue).TurnOffWindowsCopilot
    $copilotHKCU = (Get-ItemProperty -Path $pathExplorerHKCU -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue).TurnOffWindowsCopilot

    if ($copilotHKLM -eq 1 -or $copilotHKCU -eq 1) {
        Write-Host "  * Windows Copilot: " -NoNewline; Write-Host "Deshabilitado" -ForegroundColor Green
    } else {
        Write-Host "  * Windows Copilot: " -NoNewline; Write-Host "Activo / No definido" -ForegroundColor Red
    }

    Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    # Opciones del Menu
    Write-Host " [1] Deshabilitar Telemetria general y Diagnostico de Windows" -ForegroundColor Cyan
    Write-Host " [2] Deshabilitar Experiencias de Usuario Personalizadas y Sugerencias" -ForegroundColor Cyan
    Write-Host " [3] Desactivar Cortana / Copilot y Busqueda en la nube" -ForegroundColor Cyan
    Write-Host " [4] Revertir / Restaurar valores predeterminados de Telemetria" -ForegroundColor Yellow
    Write-Host " [0] Volver al menu principal / Salir" -ForegroundColor Red
    Write-Host ""

    $opcion = Read-Host " Seleccione una opcion"

    switch ($opcion) {
        "1" {
            Write-Host "`n[+] Aplicando configuracion de Telemetria y Diagnostico..." -ForegroundColor Green
            if (!(Test-Path $pathTelemetry)) {
                New-Item -Path $pathTelemetry -Force | Out-Null
            }
            Set-ItemProperty -Path $pathTelemetry -Name "AllowTelemetry" -Value 0 -Force
            
            # Metodo agresivo para desactivar y detener DiagTrack
            Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
            
            # Matar el proceso svchost asociado si sigue colgado en memoria
            $diags = Get-CimInstance Win32_Service -Filter "Name='DiagTrack'"
            if ($diags.ProcessId -gt 0) {
                Stop-Process -Id $diags.ProcessId -Force -ErrorAction SilentlyContinue
            }

            Start-Sleep -Seconds 2
        }
        "2" {
            Write-Host "`n[+] Deshabilitando experiencias personalizadas..." -ForegroundColor Green
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Force
            Start-Sleep -Seconds 2
        }
        "3" {
            Write-Host "`n[+] Desactivando caracteristicas basadas en la nube, Cortana y Copilot..." -ForegroundColor Green
            
            if (!(Test-Path $pathSearch)) {
                New-Item -Path $pathSearch -Force | Out-Null
            }
            Set-ItemProperty -Path $pathSearch -Name "DisableWebSearch" -Value 1 -Force
            Set-ItemProperty -Path $pathSearch -Name "ConnectedSearchUseWeb" -Value 0 -Force

            if (!(Test-Path $pathExplorerHKLM)) {
                New-Item -Path $pathExplorerHKLM -Force | Out-Null
            }
            Set-ItemProperty -Path $pathExplorerHKLM -Name "TurnOffWindowsCopilot" -Value 1 -Force

            if (!(Test-Path $pathExplorerHKCU)) {
                New-Item -Path $pathExplorerHKCU -Force | Out-Null
            }
            Set-ItemProperty -Path $pathExplorerHKCU -Name "TurnOffWindowsCopilot" -Value 1 -Force

            Write-Host "[+] Actualizando el entorno grafico..." -ForegroundColor Yellow
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
        "4" {
            Write-Host "`n[!] Restaurando valores por defecto..." -ForegroundColor Yellow
            Remove-ItemProperty -Path $pathTelemetry -Name "AllowTelemetry" -ErrorAction SilentlyContinue
            Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $pathSearch -Name "DisableWebSearch" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $pathSearch -Name "ConnectedSearchUseWeb" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $pathExplorerHKLM -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $pathExplorerHKCU -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
        "0" {
            Write-Host "`nSaliendo del script de telemetria..." -ForegroundColor Magenta
            break
        }
        default {
            Write-Host "`n[X] Opcion no valida. Por favor, intente de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }

    if ($opcion -ne "0") {
        Write-Host ""
        Read-Host "Presione Enter para continuar..."
    }

} while ($opcion -ne "0")