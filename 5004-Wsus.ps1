# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Delivery Optimization W11"

# Ruta de politicas en el Registro
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"

# Valores objetivo
$DesiredMode     = 2
$DesiredDownload = 30
$DesiredUpload   = 30

# Funcion auxiliar para leer valores actuales del Registro
function Get-DOStatus {
    $Props = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
    return [PSCustomObject]@{
        Mode     = if ($null -ne $Props.DODownloadMode)                 { $Props.DODownloadMode }                 else { "No configurado" }
        Download = if ($null -ne $Props.MaxDownloadBandwidthPercentage) { $Props.MaxDownloadBandwidthPercentage } else { "No configurado" }
        Upload   = if ($null -ne $Props.MaxUploadBandwidthPercentage)   { $Props.MaxUploadBandwidthPercentage }   else { "No configurado" }
    }
}

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                          [       Delivery Optimization       ]                         " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    $Status = Get-DOStatus
    Write-Host "Estado actual en Registro:" -ForegroundColor DarkGray
    Write-Host " - DODownloadMode                 : " -NoNewline -ForegroundColor DarkGray
    Write-Host $Status.Mode -ForegroundColor $(if ($Status.Mode -eq $DesiredMode) { "Green" } else { "Yellow" })

    Write-Host " - MaxDownloadBandwidthPercentage : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($Status.Download) $(if ($Status.Download -is [int]) { '%' })" -ForegroundColor $(if ($Status.Download -eq $DesiredDownload) { "Green" } else { "Yellow" })

    Write-Host " - MaxUploadBandwidthPercentage   : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($Status.Upload) $(if ($Status.Upload -is [int]) { '%' })" -ForegroundColor $(if ($Status.Upload -eq $DesiredUpload) { "Green" } else { "Yellow" })
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Aplicar limite recomendado (Modo LAN=2, Descarga=30%, Subida=30%)"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Configurar porcentajes personalizados"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Restaurar valores por defecto de Windows (Eliminar politicas)"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Verificando y aplicando politicas de Delivery Optimization..." -ForegroundColor Cyan
            if (-not (Test-Path -Path $RegPath)) {
                New-Item -Path $RegPath -Force | Out-Null
            }

            $Status = Get-DOStatus

            if ($Status.Mode -eq $DesiredMode) {
                Write-Host " - DODownloadMode ya esta configurado correctamente ($DesiredMode)." -ForegroundColor Green
            } else {
                Set-ItemProperty -Path $RegPath -Name "DODownloadMode" -Type DWord -Value $DesiredMode
                Write-Host " - DODownloadMode actualizado de [$($Status.Mode)] a [$DesiredMode]." -ForegroundColor Green
            }

            if ($Status.Download -eq $DesiredDownload) {
                Write-Host " - MaxDownloadBandwidthPercentage ya esta configurado correctamente ($DesiredDownload%)." -ForegroundColor Green
            } else {
                Set-ItemProperty -Path $RegPath -Name "MaxDownloadBandwidthPercentage" -Type DWord -Value $DesiredDownload
                Write-Host " - MaxDownloadBandwidthPercentage actualizado de [$($Status.Download)] a [$DesiredDownload%]." -ForegroundColor Green
            }

            if ($Status.Upload -eq $DesiredUpload) {
                Write-Host " - MaxUploadBandwidthPercentage ya esta configurado correctamente ($DesiredUpload%)." -ForegroundColor Green
            } else {
                Set-ItemProperty -Path $RegPath -Name "MaxUploadBandwidthPercentage" -Type DWord -Value $DesiredUpload
                Write-Host " - MaxUploadBandwidthPercentage actualizado de [$($Status.Upload)] a [$DesiredUpload%]." -ForegroundColor Green
            }

            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host ""
            $InputDown = Read-Host "Ingrese porcentaje maximo de DESCARGA (5 - 100)"
            $InputUp   = Read-Host "Ingrese porcentaje maximo de SUBIDA (5 - 100)"

            if (($InputDown -as [int]) -in 5..100 -and ($InputUp -as [int]) -in 5..100) {
                if (-not (Test-Path -Path $RegPath)) {
                    New-Item -Path $RegPath -Force | Out-Null
                }
                Set-ItemProperty -Path $RegPath -Name "DODownloadMode" -Type DWord -Value 2
                Set-ItemProperty -Path $RegPath -Name "MaxDownloadBandwidthPercentage" -Type DWord -Value ([int]$InputDown)
                Set-ItemProperty -Path $RegPath -Name "MaxUploadBandwidthPercentage" -Type DWord -Value ([int]$InputUp)
                Write-Host "`n[+] Politicas aplicadas: Modo=2 (LAN), Descarga=$InputDown%, Subida=$InputUp%." -ForegroundColor Green
            } else {
                Write-Host "`nERROR: Ingrese valores numericos validos entre 5 y 100." -ForegroundColor Red
            }
            Read-Host "`nPresione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Eliminando politicas personalizadas de Delivery Optimization..." -ForegroundColor Cyan
            if (Test-Path -Path $RegPath) {
                Remove-ItemProperty -Path $RegPath -Name "DODownloadMode" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $RegPath -Name "MaxDownloadBandwidthPercentage" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $RegPath -Name "MaxUploadBandwidthPercentage" -ErrorAction SilentlyContinue
                Write-Host "Politicas eliminadas. Windows usara los valores predeterminados." -ForegroundColor Green
            } else {
                Write-Host "No habia politicas personalizadas configuradas." -ForegroundColor Yellow
            }
            Read-Host "`nPresione Enter para continuar..."
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
