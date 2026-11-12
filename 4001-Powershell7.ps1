# ==============================================================================
# Actualización de PowerShell a la versión moderna y pausa controlada
# ==============================================================================

$psversiontable
winget install --id Microsoft.powershell --silent --accept-package-agreements --accept-source-agreements

Write-Host ""
Write-Host "[OK] Instalación / Actualización de PowerShell completada." -ForegroundColor Green
Write-Host ""

$psversiontable

# Pausa al final orientada a regresar al menú principal
Write-Host ""
Read-Host "Presione Enter para volver al menú..."
