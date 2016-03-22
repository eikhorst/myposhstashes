$jsonClients = @()                          

$listofClientsWithChanges = @{}
$listofClientsWithChanges.ClientShortname = "Anders"
$listofClientsWithChanges.id = "1234"
$listofClientsWithChanges.Domains = @{}
$listofClientsWithChanges.Entered = (Get-Date).DateTime 

$cDomain = @()
$cDomain.name = "clienty.com"
$cDomain.a = "192.194.1.1"

$listofClientsWithChanges.Domains += $cDomain
#$listofClientsWithChanges|ConvertTo-Json

$jsonObject.Clients += $listofClientsWithChanges

$listofClientsWithChanges = @{}
$listofClientsWithChanges.ClientShortname = "ClientE"
$listofClientsWithChanges.id = "3235"
$listofClientsWithChanges.Entered = (Get-Date).DateTime 
$listofClientsWithChanges.Domains = @{}
$cDomain = @()
$cDomain.name = "www.cliente.com"
$cDomain.a = "123.45.6.1"

$listofClientsWithChanges.Domains += $cDomain
#$listofClientsWithChanges|ConvertTo-Json
$jsonObject.Clients += $listofClientsWithChanges

$jsonObject | ConvertTO-Json
