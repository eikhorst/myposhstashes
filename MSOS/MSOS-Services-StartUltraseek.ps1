$ErrorActionPreference = "SilentlyContinue"
$cballeys = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"
#$Serv = "cballey 5.8"
$Serv = "Octopus Tentacle"
foreach($Server in $Servers){
    (get-service -ComputerName $Server -Name $Service).Start()
}