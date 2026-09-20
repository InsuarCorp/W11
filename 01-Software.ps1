# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Instalacion de Software para W11"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [ Instalacion de SoftWare V 26.09 ]                        " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menu principal
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Actualizar Aplicaciones instaladas" 
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Actualizar Driver" 
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Instalar Visual C++ (VCRedist)"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Instalar DirectX Runtime"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Activar .NET 3.5, DirectPlay e instalar .NET 8 Desktop"
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Instalar Java Runtime Environment (JRE)"
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Tiempo de Actividad (Uptime)"
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Green
    Write-Host "                                            [ Nuevos ]                                  " -ForegroundColor Green
    Write-Host "========================================================================================" -ForegroundColor Green
    Write-Host ""

    # Menu Nuevos
    Write-Host "[09] " -NoNewline -ForegroundColor Green; Write-Host "Resumen" -ForegroundColor Green
    Write-Host ""
    Write-Host ""

    Write-Host "[00] VOLVER AL MENU PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""

    # Lectura de opciones multiples
    $inputRaw = Read-Host "INGRESE COMANDO(S) (ej: 1 3 5 o 01,03,05)"

    # Limpia ceros a la izquierda y espacios para normalizar la entrada (ej: '02' -> '2')
    $choices = $inputRaw -split '[\s,]+' | Where-Object { $_ -ne "" } | ForEach-Object { $_.TrimStart('0').Trim() }

    foreach ($choice in $choices) {

        switch ($choice) {
            "1" {
                Write-Host ""
                Write-Host "[+] Actualizando Aplicaciones..." -ForegroundColor Cyan
                winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                Write-Host ""
                Write-Host "[OK] Finalizada la actualizacion de Aplicaciones." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
         
            "2" {
                Write-Host ""
                Write-Host "[+] Verificando requisitos del sistema para drivers..." -ForegroundColor Cyan
                
                # Habilitar TLS 1.2
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

                # Verifica e instala NuGet silenciosamente sin pedir confirmacion
                if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                    Write-Host "[+] Instalando proveedor NuGet de forma automatica..." -ForegroundColor Yellow
                    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ForceBootstrap -Scope CurrentUser -ErrorAction SilentlyContinue
                }

                # Configura repositorio PSGallery como confiable
                Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue

                # Instala o importa PSWindowsUpdate
                if (-not (Get-Module -Name PSWindowsUpdate)) {
                    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                        Write-Host "[+] Instalando modulo PSWindowsUpdate..." -ForegroundColor Yellow
                        Install-Module PSWindowsUpdate -Force -Scope CurrentUser -SkipPublisherCheck -Confirm:$false
                    }
                    Import-Module PSWindowsUpdate
                }

                Write-Host "[+] Habilitando servicio de Microsoft Update para Drivers..." -ForegroundColor Cyan
                Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false -ErrorAction SilentlyContinue

                Write-Host "[+] Buscando e instalando Drivers..." -ForegroundColor Cyan
                Get-WindowsUpdate -MicrosoftUpdate -Category "Drivers" -Install -AcceptAll
                Write-Host ""
                Write-Host "[OK] Finalizada la actualizacion de Drivers." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "3" {
                Write-Host ""
                Write-Host "[+] Instalando paquetes Microsoft Visual C++ Redistributables (x86 y x64)..." -ForegroundColor Cyan
                
                $vcPackages = @(
                    "Microsoft.VCRedist.2005.x86", "Microsoft.VCRedist.2005.x64",
                    "Microsoft.VCRedist.2008.x86", "Microsoft.VCRedist.2008.x64",
                    "Microsoft.VCRedist.2010.x86", "Microsoft.VCRedist.2010.x64",
                    "Microsoft.VCRedist.2012.x86", "Microsoft.VCRedist.2012.x64",
                    "Microsoft.VCRedist.2013.x86", "Microsoft.VCRedist.2013.x64",
                    "Microsoft.VCRedist.2015+.x86", "Microsoft.VCRedist.2015+.x64"
                )

                foreach ($package in $vcPackages) {
                    Write-Host "[+] Procesando: $package" -ForegroundColor Yellow
                    winget install --id $package --silent --accept-package-agreements --accept-source-agreements
                }

                Write-Host ""
                Write-Host "[OK] Instalacion de paquetes VCRedist completada." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "4" {
                Write-Host ""
                Write-Host "[+] Instalando DirectX End-User Runtimes (June 2010)..." -ForegroundColor Cyan
                winget install --id Microsoft.DirectX --silent --accept-package-agreements --accept-source-agreements
                Write-Host ""
                Write-Host "[OK] Instalacion de DirectX completada." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "5" {
                Write-Host ""
                Write-Host "[+] Asegurando servicio de Windows Update..." -ForegroundColor Cyan
                Start-Service wuauserv -ErrorAction SilentlyContinue

                Write-Host "[+] Activando .NET Framework 3.5 mediante DISM..." -ForegroundColor Cyan
                dism /online /enable-feature /featurename:NetFx3 /All /NoRestart

                Write-Host ""
                Write-Host "[+] Activando DirectPlay mediante DISM..." -ForegroundColor Cyan
                dism /online /enable-feature /featurename:DirectPlay /All /NoRestart

                Write-Host ""
                Write-Host "[+] Instalando Microsoft .NET Desktop Runtime 8 (Moderna)..." -ForegroundColor Cyan
                winget install --id Microsoft.DotNet.DesktopRuntime.8 --silent --accept-package-agreements --accept-source-agreements

                Write-Host ""
                Write-Host "[OK] Configuracion de entornos .NET y DirectPlay completada." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "6" {
                Write-Host ""
                Write-Host "[+] Instalando Java Runtime Environment (Oracle JRE)..." -ForegroundColor Cyan
                winget install --id Oracle.JavaRuntimeEnvironment --silent --accept-package-agreements --accept-source-agreements
                Write-Host ""
                Write-Host "[OK] Instalacion de Java completada." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "7" {
                Write-Host ""
                Write-Host "[+] Calculando tiempo de actividad de Windows (Uptime)..." -ForegroundColor Cyan
                $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                $uptime = (Get-Date) - $bootTime
                Write-Host "El sistema inicio el: $bootTime" -ForegroundColor Yellow
                Write-Host "Tiempo encendido: $($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos" -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "9" {
                Write-Host ""
                Write-Host "[+] Generando Resumen General del Sistema..." -ForegroundColor Cyan
                Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, CsModel, CsProcessors | Format-List
                Start-Sleep -Seconds 1
            }

            "" {
                return
            }

            Default {
                Write-Host "Opcion '$choice' no valida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "   Todas las tareas seleccionadas han finalizado.         " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Yellow
    Read-Host "Presione Enter para volver al menu..."

} while ($true)