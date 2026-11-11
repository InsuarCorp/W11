# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Configuracion de Firewall"

do {
    Clear-Host
    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex

    Write-Host ""
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [     Configuracion de Firewall    ]                         " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    # Opciones del menu
    Write-Host "[1]  " -NoNewline -ForegroundColor Cyan; Write-Host "Comprobar estado del Firewall"
    Write-Host "[2]  " -NoNewline -ForegroundColor Cyan; Write-Host "Activar Firewall de Windows"
    Write-Host "[3]  " -NoNewline -ForegroundColor Cyan; Write-Host "Desactivar Firewall de Windows"
    Write-Host "[4]  " -NoNewline -ForegroundColor Cyan; Write-Host "Bloquear puerto de red entrante"
    Write-Host "[5]  " -NoNewline -ForegroundColor Cyan; Write-Host "Permitir puerto de red entrante"
    Write-Host "[6]  " -NoNewline -ForegroundColor Cyan; Write-Host "Eliminar regla personalizada"
    Write-Host "[7]  " -NoNewline -ForegroundColor Cyan; Write-Host "Mostrar reglas del Firewall"
    Write-Host "[8]  " -NoNewline -ForegroundColor Cyan; Write-Host "Copia de seguridad de la configuracion"
    Write-Host "[9]  " -NoNewline -ForegroundColor Cyan; Write-Host "Restaurar configuracion predeterminada"
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "Importar configuracion del Firewall"
    Write-Host "[11] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver perfiles de red del Firewall"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU PRINCIPAL" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Comprobando estado del Firewall..." -ForegroundColor Cyan
            netsh advfirewall show allprofiles
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Activando Firewall de Windows..." -ForegroundColor Cyan
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Desactivando Firewall de Windows..." -ForegroundColor Cyan
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '4' } {
            Write-Host "`n[+] Bloquear puerto entrante..." -ForegroundColor Cyan
            $port = Read-Host "Ingrese el numero de puerto a bloquear"
            $name = Read-Host "Ingrese el nombre para la regla"
            New-NetFirewallRule -DisplayName $name -Direction Inbound -LocalPort $port -Protocol TCP -Action Block
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '5' } {
            Write-Host "`n[+] Permitir puerto entrante..." -ForegroundColor Cyan
            $port = Read-Host "Ingrese el numero de puerto a permitir"
            $name = Read-Host "Ingrese el nombre para la regla"
            New-NetFirewallRule -DisplayName $name -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '6' } {
            Write-Host "`n[+] Eliminar regla de Firewall..." -ForegroundColor Cyan
            $name = Read-Host "Ingrese el nombre exacto de la regla a eliminar"
            Remove-NetFirewallRule -DisplayName $name
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '7' } {
            Write-Host "`n[+] Mostrando todas las reglas activas..." -ForegroundColor Cyan
            Get-NetFirewallRule | Out-GridView
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '8' } {
            Write-Host "`n[+] Exportando configuracion del Firewall..." -ForegroundColor Cyan
            netsh advfirewall export "$env:USERPROFILE\Desktop\FirewallConfig_Backup.wfw"
            Write-Host "Respaldo guardado en el Escritorio como FirewallConfig_Backup.wfw" -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '9' } {
            Write-Host "`n[!] Restaurando configuracion por defecto..." -ForegroundColor Red
            netsh advfirewall reset
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '10' } {
            Write-Host "`n[+] Importando configuracion del Firewall..." -ForegroundColor Cyan
            $path = Read-Host "Ingrese la ruta completa del archivo .wfw"
            if (Test-Path $path) {
                netsh advfirewall import $path
            } else {
                Write-Host "El archivo especificado no existe." -ForegroundColor Red
            }
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '11' } {
            Write-Host "`n[+] Mostrando perfiles de red..." -ForegroundColor Cyan
            Get-NetFirewallProfile
            Read-Host "`nPresione Enter para continuar..."
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
