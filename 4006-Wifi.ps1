# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Administracion y Redes Wi-Fi"

do {
    Clear-Host

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [      Utilidades de Wi-Fi      ]                        " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menu principal de Redes
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver redes Wi-Fi guardadas (Perfiles)" 
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Mostrar Wi-Fi y sus contrasenas en texto plano" 
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Buscar redes Wi-Fi cercanas (Cercanias)"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Eliminar un perfil de red Wi-Fi guardado"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Exportar perfiles Wi-Fi con clave (C:\InsuarCorp)"
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Importar perfiles Wi-Fi desde (C:\InsuarCorp)"
    Write-Host ""

    Write-Host "[00] SALIR / VOLVER" -ForegroundColor Yellow
    Write-Host ""

    # Lectura de opciones multiples o individuales
    $inputRaw = Read-Host "INGRESE COMANDO (ej: 1, 2, 3 o 4)"

    # Limpia ceros a la izquierda y espacios para normalizar la entrada
    $choices = $inputRaw -split '[\s,]+' | Where-Object { $_ -ne "" } | ForEach-Object { $_.TrimStart('0').Trim() }

    foreach ($choice in $choices) {

        switch ($choice) {
            "1" {
                Write-Host ""
                Write-Host "[+] Listando perfiles de redes Wi-Fi guardadas..." -ForegroundColor Cyan
                netsh wlan show profiles
                Write-Host ""
                Write-Host "[OK] Listado completado." -ForegroundColor Green
            }
            "2" {
                Write-Host ""
                Write-Host "[+] Mostrando perfiles Wi-Fi y contraseñas..." -ForegroundColor Cyan
                $profiles = (netsh wlan show profiles) | Select-String "Perfil de todos los usuarios\s*:\s*(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                if (-not $profiles) {
                    $profiles = (netsh wlan show profiles) | Select-String "All User Profile\s*:\s*(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                }
                foreach ($p in $profiles) {
                    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
                    netsh wlan show profile name="$p" key=clear
                }
                Write-Host ""
                Write-Host "[OK] Consulta finalizada." -ForegroundColor Green
            }
            "3" {
                Write-Host ""
                Write-Host "[+] Buscando redes Wi-Fi cercanas..." -ForegroundColor Cyan
                netsh wlan show networks mode=bssid
                Write-Host ""
                Write-Host "[OK] Escaneo completado." -ForegroundColor Green
            }
            "4" {
                Write-Host ""
                $perfilEliminar = Read-Host "Ingrese el nombre exacto del perfil Wi-Fi a eliminar"
                if (-not [string]::IsNullOrWhiteSpace($perfilEliminar)) {
                    netsh wlan delete profile name="$perfilEliminar"
                    Write-Host "[OK] Operacion de eliminacion ejecutada." -ForegroundColor Green
                } else {
                    Write-Host "[!] Nombre de perfil vacio." -ForegroundColor Yellow
                }
            }
            "5" {
                Write-Host ""
                Write-Host "[+] Exportando perfiles Wi-Fi (key=clear) a C:\InsuarCorp..." -ForegroundColor Cyan
                $WifiDir = "C:\InsuarCorp"
                if (-not (Test-Path -Path $WifiDir)) {
                    New-Item -Path $WifiDir -ItemType Directory -Force | Out-Null
                }
                netsh wlan export profile key=clear folder="$WifiDir"
                Write-Host ""
                Write-Host "[OK] Exportacion finalizada en $WifiDir." -ForegroundColor Green
            }
            "6" {
                Write-Host ""
                Write-Host "[+] Importando perfiles Wi-Fi desde C:\InsuarCorp..." -ForegroundColor Cyan
                $WifiDir = "C:\InsuarCorp"
                if (-not (Test-Path -Path $WifiDir)) {
                    Write-Host "[!] No existe la carpeta $WifiDir." -ForegroundColor Yellow
                } else {
                    $XmlFiles = Get-ChildItem -Path $WifiDir -Filter "*.xml" -ErrorAction SilentlyContinue
                    if (-not $XmlFiles) {
                        Write-Host "[!] No se encontraron archivos .xml en $WifiDir." -ForegroundColor Yellow
                    } else {
                        foreach ($Xml in $XmlFiles) {
                            Write-Host "[*] Importando: $($Xml.Name)" -ForegroundColor Cyan
                            netsh wlan add profile filename="$($Xml.FullName)"
                        }
                        Write-Host ""
                        Write-Host "[OK] Importacion completada." -ForegroundColor Green
                    }
                }
            }
            "0" {
                return
            }
            default {
                Write-Host "[!] Opcion no valida: $choice" -ForegroundColor Red
            }
        }
    }

    if ($choices -contains "0") {
        break
    }

    Write-Host ""
    Read-Host "Presione Enter para continuar..."

} while ($true)
