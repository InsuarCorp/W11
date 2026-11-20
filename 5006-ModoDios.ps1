# ==============================================================================
# Configuracion del titulo de la ventana
# ==============================================================================
$host.UI.RawUI.WindowTitle = "InsuarCorp - Modo Dios W11"

# Define la ruta del Escritorio del usuario actual
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Define el nombre de la carpeta con el CLSID del Modo Dios
$FolderName = "Modo Dios.{ED7BA470-8E54-465E-825C-99712043E01C}"
$FullPath = Join-Path -Path $DesktopPath -ChildPath $FolderName

do {
    Clear-Host

    # Carga ejecutable directo desde el repositorio
    irm https://raw.githubusercontent.com/InsuarCorp/W11/main/info.ps1 | iex
    Write-Host ""

    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host "                               [       Modo Dios W11       ]                            " -ForegroundColor Magenta
    Write-Host "========================================================================================" -ForegroundColor Magenta
    Write-Host ""

    # Estado actual en el Escritorio
    if (Test-Path -Path $FullPath) {
        Write-Host "Estado actual: " -NoNewline
        Write-Host "[ACTIVADO en Escritorio]" -ForegroundColor Green
    } else {
        Write-Host "Estado actual: " -NoNewline
        Write-Host "[NO CREADO]" -ForegroundColor Yellow
    }
    Write-Host ""

    # Opciones alineadas y limpias
    Write-Host "[1] " -NoNewline -ForegroundColor Cyan; Write-Host "Crear acceso directo Modo Dios en el Escritorio"
    Write-Host "[2] " -NoNewline -ForegroundColor Cyan; Write-Host "Eliminar acceso directo Modo Dios del Escritorio"
    Write-Host "[3] " -NoNewline -ForegroundColor Cyan; Write-Host "Abrir carpeta Modo Dios"

    Write-Host ""
    Write-Host "[100] " -NoNewline -ForegroundColor Cyan; Write-Host "Analizar este Github"
    Write-Host "[A] "   -NoNewline -ForegroundColor Cyan; Write-Host "Ayuda"
    Write-Host ""
    Write-Host "[00] VOLVER AL MENU ANTERIOR" -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "INGRESE COMANDO"

    switch ($choice) {
        { $_ -in '1' } {
            Write-Host "`n[+] Creando carpeta Modo Dios..." -ForegroundColor Cyan
            if (-not (Test-Path -Path $FullPath)) {
                New-Item -Path $FullPath -ItemType Directory | Out-Null
                Write-Host "Carpeta 'Modo Dios' creada correctamente en el Escritorio." -ForegroundColor Green
            } else {
                Write-Host "La carpeta 'Modo Dios' ya existe en el Escritorio." -ForegroundColor Yellow
            }
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '2' } {
            Write-Host "`n[+] Eliminando carpeta Modo Dios..." -ForegroundColor Cyan
            if (Test-Path -Path $FullPath) {
                Remove-Item -Path $FullPath -Force -Recurse
                Write-Host "Carpeta 'Modo Dios' eliminada correctamente del Escritorio." -ForegroundColor Green
            } else {
                Write-Host "La carpeta 'Modo Dios' no existe en el Escritorio." -ForegroundColor Yellow
            }
            Read-Host "Presione Enter para continuar..."
        }
        { $_ -in '3' } {
            Write-Host "`n[+] Abriendo Modo Dios..." -ForegroundColor Cyan
            if (-not (Test-Path -Path $FullPath)) {
                New-Item -Path $FullPath -ItemType Directory | Out-Null
                Write-Host "Carpeta creada automaticamente." -ForegroundColor Green
            }
            Start-Process "explorer.exe" -ArgumentList "`"$FullPath`""
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
