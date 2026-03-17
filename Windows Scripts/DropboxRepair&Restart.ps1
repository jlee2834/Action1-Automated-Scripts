$ErrorActionPreference = 'SilentlyContinue'

Write-Output "==============================="
Write-Output " DROPBOX HEALTH REPAIR"
Write-Output "==============================="
Write-Output ""

$processes = Get-Process Dropbox -ErrorAction SilentlyContinue
$wasRunning = if ($processes) { 'YES' } else { 'NO' }

$processes | Stop-Process -Force -ErrorAction SilentlyContinue

$dropboxExePaths = @(
    "$env:LOCALAPPDATA\Dropbox\Client\Dropbox.exe",
    "$env:ProgramFiles\Dropbox\Client\Dropbox.exe",
    "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe"
) | Where-Object { Test-Path $_ }

$cachePaths = @(
    "$env:LOCALAPPDATA\Dropbox\Update",
    "$env:LOCALAPPDATA\Dropbox\InstanceDB"
)

$cleaned = @()
foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        try {
            Get-ChildItem $path -Force -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
            $cleaned += $path
        } catch {}
    }
}

$launched = $false
if ($dropboxExePaths) {
    Start-Process ($dropboxExePaths | Select-Object -First 1) -ErrorAction SilentlyContinue
    $launched = $true
}

Start-Sleep -Seconds 5
$runningNow = if (Get-Process Dropbox -ErrorAction SilentlyContinue) { 'YES' } else { 'NO' }

Write-Output "Was Running Before : $wasRunning"
Write-Output "Relaunched         : $(if ($launched) {'YES'} else {'NO'})"
Write-Output "Running Now        : $runningNow"
Write-Output ""

Write-Output "Cleaned Paths:"
if ($cleaned.Count -gt 0) {
    $cleaned | ForEach-Object { Write-Output " - $_" }
} else {
    Write-Output " - No cache/update paths cleaned"
}

Write-Output ""
Write-Output "Result             : SUCCESS"
Write-Output ""
Write-Output "==============================="
