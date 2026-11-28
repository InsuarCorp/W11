# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "SISTEMA // ENERGIA Y REINICIO (4007)"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                         [     Energia y Reinicio Windows     ]                       " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "[01] " -NoNewline -ForegroundColor Cyan; Write-Host "Apagar equipo"
    Write-Host "[02] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar normal"
    Write-Host "[03] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar en modo Recovery (WinRE)"
    Write-Host "[04] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar a BIOS / UEFI"
    Write-Host "[05] " -NoNewline -ForegroundColor Cyan; Write-Host "Hibernar equipo (extra)"
    Write-Host "[06] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar en Modo Seguro (sugerencia)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[0]  VOLVER AL MENU PRINCIPAL" -ForegroundColor Yellow
    Write-Host "[00] FINALIZAR SESION" -ForegroundColor Red
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1', '01' } {
            Write-Host "`n[+] Apagando el equipo..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            shutdown /s /t 0
            return
        }
        { $_ -in '2', '02' } {
            Write-Host "`n[+] Reiniciando el equipo de forma normal..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            shutdown /r /t 0
            return
        }
        { $_ -in '3', '03' } {
            Write-Host "`n[+] Reiniciando en modo Recovery (Entorno de recuperacion de Windows)..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            shutdown /r /o /t 0
            return
        }
        { $_ -in '4', '04' } {
            Write-Host "`n[+] Reiniciando directamente hacia BIOS / UEFI..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            shutdown /r /fw /t 0
            return
        }
        { $_ -in '5', '05' } {
            Write-Host "`n[+] Hibernando el equipo..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            shutdown /h
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '6', '06' } {
            Write-Host "`n[+] Configurando arranque en Modo Seguro y reiniciando..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            bcdedit /set "{current}" safeboot minimal
            shutdown /r /t 0
            return
        }
        { $_ -in '100' } {
            Write-Host "`n[+] Analizando Repositorio..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/Analisis.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in 'a', 'A' } {
            Get-Content https://raw.githubusercontent.com/InsuarCorp/W11/main/Ayuda.txt | Out-GridView
        }
        { $_ -in '0' } {
            Write-Host "`n[+] Regresando al menu principal..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/00-Menu.ps1 | iex
            return
        }
        { $_ -in '00' } {
            Write-Host "`n[+] Finalizando sesion..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            exit
        }
        Default {
            Write-Host "Opcion no valida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
