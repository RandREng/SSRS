param(
    [Parameter(Mandatory = $true)]
    [string]$username,

    [Parameter(Mandatory = $true)]
    [string]$password,

    [Parameter(Mandatory = $false)]
    [string]$securepath = $env:ssrs_password_path
)

Write-Output "newadmin starting"

if ($username -eq "_") {
   
    Write-Output "ERR: No SSRS user specified"
    exit 1
}


if ($password -eq "_") {
    if (Test-Path $securepath) {
        $password = Get-Content -Raw $secretPath
    }
    else {
        Write-Output "ERR: No SSrs user password specified and secret file not found at: $secretPath"
        exit 1
    }
}
$secpass = ConvertTo-SecureString  -AsPlainText $password -Force
New-LocalUser "$username" -Password $secpass -FullName "$username" -Description "Local admin $username"
Add-LocalGroupMember -Group "Administrators" -Member "$username"
#net user %$username%/expires:never
Get-LocalGroupMember -Group "Administrators"

Write-Output "newadmin ended"