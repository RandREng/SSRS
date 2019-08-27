param(
    [Parameter(Mandatory = $false)]
    [string]$data = $env:sqldata,

    [Parameter(Mandatory = $false)]
    [string]$temp = $env:datatemp,

    [Parameter(Mandatory = $false)]
    [string]$path = $env:datapath
)

Write-Output "Restoring data $data $temp $path"

if ( test-path $data) {
    # host
    if ( ! (test-path (join-path $data ($path) ) ) ) {
      # host data does not yet exist - bootstrap scenario
      copy-item $temp"/*" $data -recurse
    }
  }
  else {
    # local
    copy-item $temp"/*" $data -recurse
  }
