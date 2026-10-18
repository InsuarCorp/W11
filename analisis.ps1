<# 
.SYNOPSIS
    Analizador estático de seguridad para los scripts del repositorio W11.
#>

$files = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1, *.bat
$totalFiles = 0
$riskFound = 0

Write-Host "`n[+] Analizando seguridad y confiabilidad del repositorio W11...`n" -ForegroundColor Cyan

foreach ($file in $files) {
    $totalFiles++
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    $issues = @()

    # Patrones comunes de riesgo o comandos delicados a revisar
    if ($content -match 'Invoke-WebRequest.*http://' -or $content -match 'curl.*http://') {$issues += "Uso de HTTP inseguro (descarga sin cifrado TLS)."
    }
    if ($content -match 'Remove-Item.*-Recurse' -or $content -match 'rmdir.*/s') {$issues += "Contiene comandos de borrado recursivo masivo (verificar rutas)."
    }
    if ($content -match '-WindowStyle Hidden' -or $content -match 'Start-Process.*-WindowStyle Hidden') {$issues += "Ejecución oculta en segundo plano (Ventana oculta)."
    }
    if ($content -match 'Invoke-Expression' -or $content -match '\s*iex\s+') {$issues += "Uso potencial de IEX (Invoke-Expression) con entradas externas."
    }
    if ($content -match 'Bypass.*ExecutionPolicy' -or $content -match 'ExecutionPolicy\s+Bypass') {$issues += "Modificación de la política de ejecución (Bypass)."
    }

    # Resultado por archivo
    if ($issues.Count -eq 0) {
        Write-Host " [SEGURO] $($file.Name) -> Sin patrones de alto riesgo detectados." -ForegroundColor Green
    } else {
        $riskFound++
        Write-Host " [ATENCIÓN] $($file.Name) -> Contiene elementos que requieren revisión:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "    - $issue" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "`n----------------------------------------"
Write-Host "Resumen del análisis:" -ForegroundColor Cyan
Write-Host " Archivos analizados: $totalFiles"
Write-Host " Archivos con alertas a revisar: $riskFound"
Write-Host "----------------------------------------`n"
