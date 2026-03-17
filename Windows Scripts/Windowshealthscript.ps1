Write-Host ""
Write-Host "==============================="
Write-Host "        SYSTEM HEALTH"
Write-Host "==============================="

# Computer Name
$computer = $env:COMPUTERNAME
Write-Host ""
Write-Host "Computer Name : $computer"

# Uptime
$os = Get-CimInstance Win32_OperatingSystem
$boot = $os.LastBootUpTime
$uptime = (Get-Date) - $boot
Write-Host "Last Boot     : $boot"
Write-Host "Uptime        : $($uptime.Days) days $($uptime.Hours) hours $($uptime.Minutes) minutes"

# CPU Usage
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpu = [math]::Round($cpu,2)
Write-Host ""
Write-Host "CPU Usage     : $cpu %"

# Memory Usage
$totalMem = $os.TotalVisibleMemorySize
$freeMem = $os.FreePhysicalMemory

$totalGB = [math]::Round($totalMem/1MB,2)
$freeGB = [math]::Round($freeMem/1MB,2)
$usedGB = [math]::Round($totalGB-$freeGB,2)

Write-Host ""
Write-Host "Memory Total  : $totalGB GB"
Write-Host "Memory Used   : $usedGB GB"
Write-Host "Memory Free   : $freeGB GB"

# Disk Usage
Write-Host ""
Write-Host "Disk Usage"
Write-Host "-----------"

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $used = [math]::Round($_.Used/1GB,2)
    $free = [math]::Round($_.Free/1GB,2)
    Write-Host "$($_.Name): Used $used GB | Free $free GB"
}

Write-Host ""
Write-Host "==============================="
Write-Host "        CHECK COMPLETE"
Write-Host "==============================="
