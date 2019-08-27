param(
   
    [Parameter(Mandatory = $false)]
    [string]$name = $env:servicename
)

# stop the service
Write-Output "Stopping - $name"

$arrService = Get-Service -Name $name
Write-Output $name " status " $arrService.status
do
{
    Start-Sleep -seconds 1
    $arrService.Refresh()

} while ($arrService.Status -eq 'StartPending') 

Write-Output $name " status " $arrService.status

if ($arrService.Status -ne 'Stopped')
{

    Stop-Service $name
    Write-Output $arrService.status
    Write-Output 'Service stopping'
    do
    {
        Start-Sleep -seconds 1
        $arrService.Refresh()
    
    } while ($arrService.Status -ne 'Stopped') 

}
Write-Output $name " status " $arrService.status
