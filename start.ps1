param(
   
    [Parameter(Mandatory = $true)]
    [string]$ssrs_user,

    [Parameter(Mandatory = $true)]
    [string]$ssrs_password
    
)

.\stopserver -Verbose
.\restoredata -Verbose
.\startserver -Verbose
.\updatesapassword -Verbose
.\attachdatabases -Verbose


Write-Output "SSRS Config"
.\configureSSRS2017 -Verbose

Write-Output "SSRS Config2"
.\newadmin -username $ssrs_user -password $ssrs_password -Verbose
Write-Output "SSRS Config3"

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) { 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 
   
    $lastCheck = Get-Date
    Start-Sleep -Seconds 2 
}
