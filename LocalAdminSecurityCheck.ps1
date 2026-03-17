$approved = @(
    'Administrator',
    'Domain Admins',
    'Helpdesk Admins'
)

$unauthorized = @()

try {
    $group = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group"

    $group.psbase.Invoke("Members") | ForEach-Object {
        $name = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        $path = $_.GetType().InvokeMember("ADsPath", 'GetProperty', $null, $_, $null)

        if ($name -notin $approved) {
            $unauthorized += "$name"
        }
    }

    Write-Output "==============================="
    Write-Output " LOCAL ADMIN SECURITY CHECK"
    Write-Output "==============================="
    Write-Output ""
    Write-Output "Computer : $env:COMPUTERNAME"
    Write-Output "Status   : $(if ($unauthorized.Count -gt 0) {'UNAUTHORIZED FOUND'} else {'CLEAN'})"
    Write-Output ""

    if ($unauthorized.Count -gt 0) {
        Write-Output "Unauthorized Accounts:"
        Write-Output "----------------------"
        $unauthorized | ForEach-Object { Write-Output " - $_" }
    } else {
        Write-Output "No unauthorized local administrators detected."
    }

    Write-Output ""
    Write-Output "==============================="

} catch {
    Write-Output "ERROR: Unable to check local administrators"
    Write-Output $_.Exception.Message
}
