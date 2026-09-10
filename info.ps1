# Obtener CPU
$cpu = (Get-CimInstance Win32_Processor).Name.Trim()

# Obtener RAM en GB
$ramBytes = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum
$ram = [math]::Round($ramBytes / 1GB, 1)

# Obtener Host e IP
$hostName = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne "127.0.0.1" } | Select-Object -First 1).IPAddress

# Mostrar en 2 líneas
Write-Host "Procesador: $cpu | RAM: ${ram} GB" -ForegroundColor Cyan
Write-Host "Host: $hostName | IP: $ip" -ForegroundColor Magenta