# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // HERRAMIENTAS DE RED"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                                 [ Menu Redes  V 26.09   ]                              " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Ver Configuración IP      " -NoNewline
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Restablecer TCP/IP"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Liberar Dirección IP      " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Conexiones de Red"
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Renovar Dirección IP      " -NoNewline
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Ping Continuo (Google)"
    
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Vaciar Caché DNS          " -NoNewline
    Write-Host "[09] " -NoNewline -ForegroundColor Cyan; Write-Host "Ajustes de Red Windows"
    
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Restablecer Winsock       " -NoNewline
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "Volver al Menú Principal"
    Write-Host ""
 Write-Host "[00] FINALIZAR SESIÓN" -ForegroundColor Yellow
    Write-Host ""
    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Obteniendo detalles de adaptadores de red..." -ForegroundColor Cyan
            Get-NetIPConfiguration | Out-String
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Liberando dirección IP actual..." -ForegroundColor Cyan
            ipconfig /release
            Write-Host "[!] Dirección IP liberada." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Solicitando renovación de dirección IP..." -ForegroundColor Cyan
            ipconfig /renew
            Write-Host "[!] Dirección IP renovada exitosamente." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Vaciando la caché del DNS..." -ForegroundColor Cyan
            Clear-DnsClientCache
            Write-Host "[!] Caché DNS restablecida con éxito." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '5', '05', '10' } {
            Write-Host "`n[+] Restableciendo catálogo Winsock..." -ForegroundColor Cyan
            netsh winsock reset
            Write-Host "[!] Catálogo Winsock restablecido. (Requiere reiniciar el equipo)." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Restableciendo pila de protocolos TCP/IP..." -ForegroundColor Cyan
            netsh int ip reset
            Write-Host "[!] Protocolo TCP/IP restablecido." -ForegroundColor Magenta
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '7', '07' } {
            Write-Host "`n[+] Abriendo panel de Conexiones de Red (ncpa.cpl)..." -ForegroundColor Cyan
            ncpa.cpl
        }
        { $_ -in '8', '08' } {
            Write-Host "`n[+] Iniciando prueba de latencia continua (Ctrl + C para detener)..." -ForegroundColor Cyan
            ping google.com -t
        }
        { $_ -in '9', '09' } {
            Write-Host "`n[+] Abriendo la Configuración de Red de Windows..." -ForegroundColor Cyan
            Start-Process ms-settings:network
        }
        { $_ -in '0', '00' } {
            return
        }
        Default {
            Write-Host "Opción no válida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)