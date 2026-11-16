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
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Mostrar Wi-Fi y sus contraseñas en texto plano" 
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Buscar redes Wi-Fi cercanas (Cercanias)"
    Write-Host ""

    Write-Host "[00] SALIR / VOLVER" -ForegroundColor Yellow
    Write-Host ""

    # Lectura de opciones multiples o individuales
    $inputRaw = Read-Host "INGRESE COMANDO (ej: 1, 2 o 3)"

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
                Start-Sleep -Seconds 1
            }
         
            "2" {
                Write-Host ""
                Write-Host "[+] Recuperando perfiles y contraseñas de Wi-Fi..." -ForegroundColor Cyan
                
                # Obtiene cada perfil y extrae su clave en texto plano
                (netsh wlan show profiles) | Select-String "\:(.+)$" | ForEach-Object {
                    $ssid = $_.Matches.Groups[1].Value.Trim()
                    $pass = (netsh wlan show profile name="$ssid" key=clear) | Select-String "Contenido de la clave\W+\:(.+)$"
                    
                    [PSCustomObject]@{
                        Red        = $ssid
                        Contrasena = if ($pass) { $pass.Matches.Groups[1].Value.Trim() } else { "Sin clave / Abierta" }
                    }
                } | Format-Table -AutoSize

                Write-Host ""
                Write-Host "[OK] Proceso finalizado." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }

            "3" {
                Write-Host ""
                Write-Host "[+] Escaneando redes Wi-Fi cercanas en el area..." -ForegroundColor Cyan
                netsh wlan show networks mode=bssid
                Write-Host ""
                Write-Host "[OK] Escaneo de cercanias finalizado." -ForegroundColor Green
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
    Write-Host "   Tarea de red finalizada.                               " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Yellow
    Read-Host "Presione Enter para volver al menu..."

} while ($true)
