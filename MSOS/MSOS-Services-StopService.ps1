$ErrorActionPreference = "SilentlyContinue"
$cballeys = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"
#$Serv = "cballey 5.8"
$Service = @("Octopus Tentacle","cballey 5.8")
foreach($Server in $Servers){
    (get-service -ComputerName $Server -Name $Service).Stop()
}