#$getDNSInfo = Read-Host
#Resolve-DnsName $getDNSInfo -Type SOA

#Resolve-DnsName -Server 8.8.8.8 -Type NS -Name www.disenza.com


clear-host
$a = Resolve-DnsName dlapiper.com -type A
$a
$a | gm 

# Type A - www will return nicely $a.address
$a.Address
# Type A - Non-www will return nicely the nameserver like $a.server
$a.Server

#IP, address, NameServers, Administrat



foreach($i in $a){
if($i.Type -eq "A"){
Write-host $i.Address -ForegroundColor DarkCyan
}
if($i.Type -eq "NS"){
Write-host $i.Type -ForegroundColor DarkGreen}
}


$n.Server
$n.Type

# IN USING www recorE: 
$n = Resolve-DnsName www.dlapiper.com -type NS
# Type NS - www  $n.PrimaryServer, $n.NameAdministrator
# Type NS - non-www returns nameservers - $n.NameHost
$n.NameHost

clear-host
$Domain = "dlapiper.com"
$ARecord = Resolve-DnsName $Domain -Type A
$NSRecord = Resolve-DnsName $Domain -Type NS
$address = $ARecord.Address
$MaxPrimaryServer = $NSRecord.PrimaryServer
Write-host $address -ForegroundColor Yellow
Write-host $MaxPrimaryServer -ForegroundColor Yellow

if($Domain -match "www."){
#$MaxPrimaryServer = $NSRecord.PrimaryServer
$MaxNameAdmin = $NSRecord.NameAdministrator
#Write-host $MaxPrimaryServer -ForegroundColor Yellow
Write-Host $MaxNameAdmin -ForegroundColor Yellow
}

if($Domain -notcontains "www."){
$MaxServer = $NSRecord.Server
Write-Host $MaxServer -ForegroundColor DarkGreen
}
