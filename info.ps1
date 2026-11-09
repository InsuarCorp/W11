clear

clear

function Write-GradientText {
    param(
        [string]$Text,
        [int]$StartR = 100, [int]$StartG = 0, [int]$StartB = 255,   # Color inicial (ej: morado/azul)
        [int]$EndR = 0,   [int]$EndG = 255, [int]$EndB = 100    # Color final (ej: verde brillante)
    )

    $lines = $Text -split '\r?\n'
    $maxLen = 0
    foreach ($line in $lines) { 
        if ($line.Length -gt $maxLen) { $maxLen = $line.Length } 
    }
    if ($maxLen -eq 0) { $maxLen = 1 }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        for ($j = 0; $j -lt $line.Length; $j++) {
            # Calcula el porcentaje de avance para el degradé horizontal
            $ratio = $j / $maxLen
            $r = [Math]::Round($StartR + ($EndR - $StartR) * $ratio)
            $g = [Math]::Round($StartG + ($EndG - $StartG) * $ratio)
            $b = [Math]::Round($StartB + ($EndB - $StartB) * $ratio)

            # Usa secuencias de escape ANSI de PowerShell para color RGB personalizado
            $esc = "$([char]033)[38;2;${r};${g};${b}m"
            [Console]::Write("$esc$($line[$j])")
        }
        [Console]::WriteLine("$([char]033)[0m") # Resetea el color al terminar la línea
    }
}

# Tu banner de InsuarCorp con la "I" corregida
$banner = @"
██╗███╗   ██╗███████╗██╗   ██╗█████╗ ██████╗  ██████╗ ██████╗ ██████╗ ██████╗ 
██║████╗  ██║██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝██╔═══██╗██╔══██╗██╔══██╗
██║██╔██╗ ██║███████╗██║   ██║███████║██████╔╝██║     ██║   ██║██████╔╝██████╔╝
██║██║╚██╗██║╚════██║██║   ██║██╔══██║██╔══██╗██║     ██║   ██║██╔══██╗██╔═══╝ 
██║██║ ╚████║███████║╚██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝██║  ██║██║     
╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     
"@

Write-GradientText -Text $banner



# Obtener CPU
$cpu = (Get-CimInstance Win32_Processor).Name.Trim()

# Obtener RAM en GB
$ramBytes = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum
$ram = [math]::Round($ramBytes / 1GB, 1)

# Procesadores Activos
$p = Get-CimInstance Win32_Processor; $numproc = (bcdedit /enum {current} | Select-String "numproc") -replace '[^\d]'; $activos = if ($numproc) { [int]$numproc } else { $p.NumberOfLogicalProcessors }; "Procesadores activos: $activos/$($p.NumberOfLogicalProcessors)"

# Obtener Host e IP
$hostName = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne "127.0.0.1" } | Select-Object -First 1).IPAddress

# Obtener Procesos, Subprocesos (Threads) e Identificadores (Handles)
$allProcesses = Get-Process
$processCount = $allProcesses.Count
$threadCount = ($allProcesses.Threads).Count
$handleCount = ($allProcesses | Measure-Object -Property Handles -Sum).Sum

# Mostrar en consola
Write-Host "Procesador: $cpu | RAM: ${ram} GB" -ForegroundColor Cyan
Write-Host "Host: $hostName | IP: $ip" -ForegroundColor Magenta
Write-Host "Procesos: $processCount | Subprocesos: $threadCount | Identificadores: $handleCount" -ForegroundColor Yellow

                Write-Host " " -ForegroundColor Cyan
                $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                $uptime = (Get-Date) - $bootTime
                Write-Host "El sistema inicio el: $bootTime" -ForegroundColor Yellow
                Write-Host "Tiempo encendido: $($uptime.Days) dias, $($uptime.Hours) horas, $($uptime.Minutes) minutos" -ForegroundColor Green
                Start-Sleep -Seconds 1
                Write-Host " " -ForegroundColor Cyan
                Write-Host " " -ForegroundColor Cyan

                
 Write-Host "========================================================================================" -ForegroundColor Yellow
 Write-Host "                                Insuar Corp        V26.10                                " -ForegroundColor Yellow
 Write-Host "========================================================================================" -ForegroundColor Yellow

Write-Host " " -ForegroundColor Cyan
Write-Host " " -ForegroundColor Cyan


Write-Host "========================================================================================" -ForegroundColor Yellow
Write-Host "Link   irm https://raw.githubusercontent.com/InsuarCorp/W11/main/00-Menu.ps1 | iex      " -ForegroundColor Yellow
Write-Host "========================================================================================" -ForegroundColor Yellow


Write-Host " " -ForegroundColor Cyan
Write-Host " " -ForegroundColor Cyan
Write-Host "========================================================================================" -ForegroundColor Red
Write-Host "                                 Activar Permisos de ejecucion                          " -ForegroundColor Red
Write-Host "          Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser          " -ForegroundColor Red
Write-Host "========================================================================================" -ForegroundColor Red

Write-Host " " -ForegroundColor Cyan
Write-Host " " -ForegroundColor Cyan
