#$ErrorActionPreference = "SilentlyContinue"
#$Servers = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"
$Servers = @("paleo-chqaws12","paleo-chqaws11")
#$Service = "Net.Msmq Listener Adapter"
$failedtoStart = ""; $successfulStarts = "";
$Services = @("Octopus Tentacle","cballey 5.8","Message Queuing","Net.Msmq Listener Adapter")
foreach($Server in $Servers){
    foreach($Service in $Services){
    (get-service -ComputerName $Server -Name $Service).Start()
    (gwmi win32_service -Filter "Name='$Service'" -computername $server).startService()
    $ServiceState = (get-wmiobject win32_service -ComputerName $Server -filter "name= '$Service'").State
    if($ServiceState -ne "Running"){
        $failedtoStart += "`r`n$Server,$Service"
        }
        else
        {
            $successfulStarts += "`r`n$Server,$Service"
        }
    }
}

Write-host $failedtoStart -ForegroundColor Red

Write-host $successfulStarts -ForegroundColor Green

