param(
   
    [Parameter(Mandatory = $false)]
    [string]$name = $env:servicename
)

# start the service
Write-Output "Starting SQL Server - $name"

$arrService = Get-Service -Name $name
Write-Output $name " status " $arrService.status

if ($arrService.status -ne 'Running')
{
    Start-Service $name
    Write-Output 'Service starting'
    do
    {
        Start-Sleep -seconds 1
        $arrService.Refresh()
    
    } while ($arrService.Status -ne 'Running') 
}
Write-Output $name " status " $arrService.status
