$ErrorActionPreference = "SilentlyContinue"
$Servers = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"

$Services = @("Octopus Tentacle")#,"cballey 5.8")
foreach($Server in $Servers){
    foreach($Service in $Services){
        (get-service -ComputerName $Server -Name $Service).Start()
        (gwmi win32_service -Filter "Name='$Service'" -computername $Server).startService()
    write-host "starteE: $Service on $Server"
    }
}