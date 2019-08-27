param(
    [Parameter(Mandatory = $false)]
    [string]$data = $env:sqldata,

    [Parameter(Mandatory = $false)]
    [string]$temp = $env:datatemp
)

Write-Output "Backing up data $data $temp"

copy-item $data $temp -recurse