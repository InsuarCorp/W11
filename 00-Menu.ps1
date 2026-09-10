# Configuración del título de la ventana
$host.UI.RawUI.WindowTitle = "SISTEMA // HERRAMIENTAS DE RED"

# Función helper para intentar descargar y ejecutar módulos remotos de forma segura
function Cargar-Modulo ($nombreArchivo) {
    Write-Host "`n[+] Cargando $nombreArchivo..." -ForegroundColor Cyan
    try {
        irm "https://raw.githubusercontent.com/InsuarCorp/W11/main/$nombreArchivo" -ErrorAction Stop | iex
    }
    catch {
        Write-Host "`n[!] MÓDULO NO DISPONIBLE" -ForegroundColor Red
    }
    Read-Host "`nPresione Enter para continuar..."
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Yellow
    Write-Host "                                     Insuar Corp                                        " -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Yellow

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [ Menu Principal  V 26.09   ]                              " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "             Análisis                      Hardware                       Windows" -ForegroundColor Magenta
    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Análisis de Redes         " -NoNewline
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Diagnóstico de Hardware    " -NoNewline
    Write-Host "[11] " -NoNewline -ForegroundColor Cyan; Write-Host "Mantenimiento"
    
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 02                 " -NoNewline
    Write-Host "[07] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 07                 " -NoNewline
    Write-Host "[12] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 12"
    
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 03                 " -NoNewline
    Write-Host "[08] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 08                 " -NoNewline
    Write-Host "[13] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 13"
    
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 04                 " -NoNewline
    Write-Host "[09] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 09                 " -NoNewline
    Write-Host "[14] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 14"
    
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 05                 " -NoNewline
    Write-Host "[10] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 10                 " -NoNewline
    Write-Host "[15] " -NoNewline -ForegroundColor Cyan; Write-Host "Módulo 15"
    Write-Host ""
    
    Write-Host "[00] FINALIZAR SESIÓN" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        # --- COLUMNA 1 ---
        { $_ -in '1', '01' } { Cargar-Modulo "01-Redes.ps1" }
        { $_ -in '2', '02' } { Cargar-Modulo "02.ps1" }
        { $_ -in '3', '03' } { Cargar-Modulo "03.ps1" }
        { $_ -in '4', '04' } { Cargar-Modulo "04.ps1" }
        { $_ -in '5', '05' } { Cargar-Modulo "05.ps1" }

        # --- COLUMNA 2 ---
        { $_ -in '6', '06' } { Cargar-Modulo "01-Hardware.ps1" } # O puedes nombrarlo 06.ps1 según prefieras
        { $_ -in '7', '07' } { Cargar-Modulo "07.ps1" }
        { $_ -in '8', '08' } { Cargar-Modulo "08.ps1" }
        { $_ -in '9', '09' } { Cargar-Modulo "09.ps1" }
        '10'                 { Cargar-Modulo "10.ps1" }

        # --- COLUMNA 3 ---
        '11'                 { Cargar-Modulo "11-Mantenimiento.ps1" }
        '12'                 { Cargar-Modulo "12.ps1" }
        '13'                 { Cargar-Modulo "13.ps1" }
        '14'                 { Cargar-Modulo "14.ps1" }
        '15'                 { Cargar-Modulo "15.ps1" }

        # --- SALIR ---
        { $_ -in '10', '0', '00' } {
            return
        }
        Default {
            Write-Host "Opción inválida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
