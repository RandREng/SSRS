param(
    [Parameter(Mandatory = $false)]
    [string]$password = $env:sa_password,

    [Parameter(Mandatory = $false)]
    [string]$password_path = $env:sa_password_path
)

# updating sa password
Write-Output "Updating sa password $password $password_path"
start-service MSSQLSERVER

if($password -eq "_") {
    if (Test-Path $password_path) {
        $password = Get-Content -Raw $password_path
    }
    else {
        Write-Output "WARN: Using default SA password, secret file not found at: $password_path"
    }
}

if($password -ne "_")
{
    Write-Output "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $password + "'" + ";ALTER LOGIN sa ENABLE;"
    & sqlcmd -Q $sqlcmd
}
