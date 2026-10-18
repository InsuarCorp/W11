# Configuracion del titulo de la ventana
$host.UI.RawUI.WindowTitle = "InsuarCorp - Configuracion para W11"

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                             [     Configuracion para W11     ]                         " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Menu principal
