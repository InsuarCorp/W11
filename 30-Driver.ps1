function Mostrar-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "      MENU DE GESTION Y DIAGNOSTICO DE DRIVERS     " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    
    Write-Host "=========================================================" -ForegroundColor white
    Write-Host "      Si Windows bloquea la ejecucion del script por     " -ForegroundColor white
    Write-Host "       politicas de seguridad, abre PowerShell como      " -ForegroundColor white
    Write-Host "             Administrador y ejecuta primero             " -ForegroundColor white
    Write-Host "           Set-ExecutionPolicy Unrestricted -Scope       " -ForegroundColor green
    Write-Host "=========================================================" -ForegroundColor white   

    Write-Host "[01]. Instalar drivers (via Windows Update)" -ForegroundColor White
    Write-Host "[02]. Realizar Backup de drivers (en C:\DriverBackup)" -ForegroundColor White
    Write-Host "[03]. Mostrar estado actual en tiempo real (verifier /volatile /query)" -ForegroundColor White
    Write-Host "[05]. Mostrar configuracion guardada (verifier /querysetting)" -ForegroundColor White
    Write-Host "[06]. Mostrar informacion general del estado (verifier /query)" -ForegroundColor White
    Write-Host "[07]. Restablecer / Desactivar Driver Verifier (verifier /reset)" -ForegroundColor White
    Write-Host "[00]. Salir" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opcion [0-7]"

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
            Write-Host "[+] Ejecutando: verifier /volatile /query" -ForegroundColor Cyan
            verifier /volatile /query
            Pause
        }

        "5" {
            Write-Host ""
            Write-Host "[+] Ejecutando: verifier /querysetting" -ForegroundColor Cyan
            verifier /querysetting
            Pause
        }

        "6" {
            Write-Host ""
            Write-Host "[+] Ejecutando: verifier /query" -ForegroundColor Cyan
            verifier /query
            Pause
        }

        "7" {
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
