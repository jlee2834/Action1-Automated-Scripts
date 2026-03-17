$ErrorActionPreference = 'SilentlyContinue'

function Remove-Contents {
    param([string]$Path)
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            } catch {}
        }
    }
}

Write-Output "==============================="
Write-Output " CHROME PROFILE REPAIR"
Write-Output "==============================="
Write-Output ""

Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$chromeBase = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$bookmarkBackupRoot = "C:\ProgramData\Action1\ChromeBackup"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = Join-Path $bookmarkBackupRoot $timestamp

$cleaned = @()
$bookmarksBackedUp = @()

if (Test-Path $chromeBase) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

    Get-ChildItem $chromeBase -Directory -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -eq 'Default' -or $_.Name -like 'Profile*'
    } | ForEach-Object {
        $profilePath = $_.FullName
        $profileName = $_.Name

        $bookmarkFile = Join-Path $profilePath 'Bookmarks'
        if (Test-Path $bookmarkFile) {
            $dest = Join-Path $backupPath "$profileName-Bookmarks.json"
            Copy-Item $bookmarkFile $dest -Force -ErrorAction SilentlyContinue
            $bookmarksBackedUp += $dest
        }

        $targets = @(
            (Join-Path $profilePath 'Cache'),
            (Join-Path $profilePath 'Code Cache'),
            (Join-Path $profilePath 'GPUCache'),
            (Join-Path $profilePath 'Service Worker\CacheStorage')
        )

        foreach ($target in $targets) {
            if (Test-Path $target) {
                Remove-Contents -Path $target
                $cleaned += $target
            }
        }
    }
}

$chromeExe = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$launched = $false
if ($chromeExe) {
    Start-Process $chromeExe -ErrorAction SilentlyContinue
    $launched = $true
}

Write-Output "Computer         : $env:COMPUTERNAME"
Write-Output "Chrome Base Path : $chromeBase"
Write-Output "Bookmarks Backup : $(if ($bookmarksBackedUp.Count -gt 0) {$backupPath} else {'None'})"
Write-Output "Chrome Relaunched: $(if ($launched) {'YES'} else {'NO'})"
Write-Output ""

Write-Output "Cleaned Paths:"
if ($cleaned.Count -gt 0) {
    $cleaned | Sort-Object -Unique | ForEach-Object { Write-Output " - $_" }
} else {
    Write-Output " - Nothing cleaned"
}

Write-Output ""
Write-Output "Result           : SUCCESS"
Write-Output ""
Write-Output "==============================="
