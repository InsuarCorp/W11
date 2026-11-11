<#
.SYNOPSIS
    Script integral de gestión, backup, diagnóstico y administración de controladores para Windows 11.
.DESCRIPTION
    Permite actualizar drivers mediante PSWindowsUpdate, realizar backups locales, escanear errores de hardware, abrir el Administrador de dispositivos y gestionar Driver Verifier.
#>

function Mostrar-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "      MENU INTEGRAL DE GESTION DE DRIVERS         " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    

    Write-Host "[1]. Instalar drivers (via Windows Update)" -ForegroundColor White
    Write-Host "[2]. Realizar Backup de drivers (en C:\DriverBackup)" -ForegroundColor White
    Write-Host "[3]. Buscar dispositivos con problemas de hardware" -ForegroundColor White
    Write-Host "[4]. Abrir Administrador de Dispositivos (Device Manager)" -ForegroundColor White
    Write-Host "[5]. Mostrar estado actual de Driver Verifier (en tiempo real)" -ForegroundColor White
    Write-Host "[6]. Mostrar configuracion guardada de Driver Verifier" -ForegroundColor White
    Write-Host "[7]. Mostrar informacion general de Driver Verifier" -ForegroundColor White
    Write-Host "[8]. Restablecer / Desactivar Driver Verifier (verifier /reset)" -ForegroundColor White
    Write-Host "[00]. Salir" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opcion [0-8]"

    switch ($opcion) {
        "1" {
            Write-Host ""
            Write-Host "[+] Verificando requisitos del sistema para drivers..." -ForegroundColor Cyan
            
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                Write-Host "[+] Instalando proveedor NuGet de forma automática..." -ForegroundColor Yellow
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ForceBootstrap -Scope CurrentUser -ErrorAction SilentlyContinue
            }

            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue

            if (-not (Get-Module -Name PSWindowsUpdate)) {
                if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                    Write-Host "[+] Instalando módulo PSWindowsUpdate..." -ForegroundColor Yellow
                    Install-Module PSWindowsUpdate -Force -Scope CurrentUser -SkipPublisherCheck -Confirm:$false
                }
                Import-Module PSWindowsUpdate
            }

            Write-Host "[+] Habilitando servicio de Microsoft Update para Drivers..." -ForegroundColor Cyan
            Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false -ErrorAction SilentlyContinue

            Write-Host "[+] Buscando e instalando Drivers..." -ForegroundColor Cyan
            Get-WindowsUpdate -MicrosoftUpdate -Category "Drivers" -Install -AcceptAll
            Write-Host ""
            Write-Host "[OK] Finalizada la actualización de Drivers." -ForegroundColor Green
            Pause
        }

        "2" {
            Write-Host ""
            $rutaBackup = "C:\DriverBackup"
            
            if (-not (Test-Path -Path $rutaBackup)) {
                Write-Host "[+] Creando carpeta $rutaBackup..." -ForegroundColor Yellow
                New-Item -ItemType Directory -Path $rutaBackup -Force | Out-Null
            }

            Write-Host "[+] Exportando controladores de terceros a $rutaBackup..." -ForegroundColor Cyan
            Export-WindowsDriver -Online -Destination $rutaBackup
            Write-Host ""
            Write-Host "[OK] Backup completado exitosamente en $rutaBackup" -ForegroundColor Green
            Pause
        }

        "3" {
            Write-Host ""
            Write-Host "[+] Escaneando dispositivos en busca de conflictos o errores..." -ForegroundColor Cyan
            $dispositivosConError = Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $_.ConfigManagerErrorCode -ne $null }
            
            if ($dispositivosConError) {
                Write-Host "[!] Se encontraron los siguientes dispositivos con problemas:" -ForegroundColor Yellow
                $dispositivosConError | Select-Object Name, DeviceID, ConfigManagerErrorCode | Format-Table -AutoSize
            } else {
                Write-Host "[OK] ¡Excelente! No se encontraron dispositivos con errores activos en el sistema." -ForegroundColor Green
            }
            Write-Host ""
            Pause
        }

        "4" {
            Write-Host ""
            Write-Host "[+] Abriendo el Administrador de Dispositivos..." -ForegroundColor Cyan
            Start-Process "devmgmt.msc"
            Start-Sleep -Seconds 1
        }

        "5" {
            Write-Host ""
            Write-Host "[+] Ejecutando: verifier /volatile /query" -ForegroundColor Cyan
            verifier /volatile /query
            Pause
        }

        "6" {
            Write-Host ""
            Write-Host "[+] Ejecutando: verifier /querysetting" -ForegroundColor Cyan
            verifier /querysetting
            Pause
        }

        "7" {
            Write-Host ""
            Write-Host "[+] Ejecutando: verifier /query" -ForegroundColor Cyan
            verifier /query
            Pause
        }

        "8" {
            Write-Host ""
            Write-Host "[+] Restableciendo Driver Verifier (verifier /reset)..." -ForegroundColor Yellow
            verifier /reset
            Write-Host ""
            Write-Host "[OK] Driver Verifier ha sido desactivado. Se recomienda reiniciar la PC." -ForegroundColor Green
            Pause
        }

        "0" {
            Write-Host "`nSaliendo..." -ForegroundColor Yellow
        }

        default {
            Write-Host "`n[!] Opción no válida. Intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($opcion -ne "0")
