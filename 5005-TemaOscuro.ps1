# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Tema Oscuro y Claro W11"

# Ruta de personalizacion en el Registro
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# Funcion auxiliar para consultar el estado actual
function Get-ThemeStatus {
    $Props = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
    $Apps  = if ($null -ne $Props.AppsUseLightTheme)   { if ($Props.AppsUseLightTheme -eq 0)   { "Oscuro (0)" } else { "Claro (1)" } } else { "No configurado" }
    $Sys   = if ($null -ne $Props.SystemUsesLightTheme) { if ($Props.SystemUsesLightTheme -eq 0) { "Oscuro (0)" } else { "Claro (1)" } } else { "No configurado" }

    return [PSCustomObject]@{
        Apps   = $Apps
        System = $Sys
    }
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                            [       Tema Oscuro W11       ]                             " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    $Status = Get-ThemeStatus
    Write-Host "Estado actual en Registro:" -ForegroundColor DarkGray
    Write-Host " - Apps (AppsUseLightTheme)      : " -NoNewline -ForegroundColor DarkGray
    Write-Host $Status.Apps -ForegroundColor $(if ($Status.Apps -like "Oscuro*") { "Green" } else { "Yellow" })

    Write-Host " - Sistema (SystemUsesLightTheme): " -NoNewline -ForegroundColor DarkGray
    Write-Host $Status.System -ForegroundColor $(if ($Status.System -like "Oscuro*") { "Green" } else { "Yellow" })
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Aplicar Tema Oscuro (Apps y Sistema)"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Aplicar Tema Claro (Apps y Sistema)"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Reiniciar Explorador de Windows (Aplicar cambios al instante)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Aplicando Tema Oscuro (apps y sistema)..." -ForegroundColor Cyan
            if (-not (Test-Path -Path $RegPath)) {
                New-Item -Path $RegPath -Force | Out-Null
            }
            Set-ItemProperty -Path $RegPath -Name "AppsUseLightTheme" -Type DWord -Value 0
            Set-ItemProperty -Path $RegPath -Name "SystemUsesLightTheme" -Type DWord -Value 0

            Write-Host "Tema oscuro aplicado. Reinicia sesion o usa la opcion [3] para ver los cambios." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Aplicando Tema Claro (apps y sistema)..." -ForegroundColor Cyan
            if (-not (Test-Path -Path $RegPath)) {
                New-Item -Path $RegPath -Force | Out-Null
            }
            Set-ItemProperty -Path $RegPath -Name "AppsUseLightTheme" -Type DWord -Value 1
            Set-ItemProperty -Path $RegPath -Name "SystemUsesLightTheme" -Type DWord -Value 1

            Write-Host "Tema claro aplicado. Reinicia sesion o usa la opcion [3] para ver los cambios." -ForegroundColor Green
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Reiniciando Explorador de Windows..." -ForegroundColor Cyan
            Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            if (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
                Start-Process "explorer.exe"
            }
            Write-Host "Explorador reiniciado correctamente." -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        { $_ -in '100' } {
            Write-Host "`n[+] Analizando Repositorio..." -ForegroundColor Cyan
            irm https://raw.githubusercontent.com/InsuarCorp/W11/main/Analisis.ps1 | iex
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in 'a', 'A' } {
            Get-Content https://raw.githubusercontent.com/InsuarCorp/W11/main/Ayuda.txt | Out-GridView
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
