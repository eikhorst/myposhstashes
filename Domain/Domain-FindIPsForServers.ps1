cd c:\git\repos\azure\maintenance\
Import-Module ActiveDirectory
$servers = @(Get-ADComputer -Filter 'ObjectClass -eq "Computer"' | Sort-Object Name -descending | Select -Expand Name)
$outHostfile = "IPsForHosts$($env:UserDomain).txt" ;  write-host $outHostfile
clear-content $outHostfile ##  So you can clear the old file
$ErrorActionPreference = "SilentlyContinue"
$Domain = $env:UserDNSDomain

foreach($server in $servers){ 
    $serv = $server+'.'+$Domain
    write-host $serv
    $ip = ([System.Net.DNS]::GetHostAddresses($serv)).IPAddressToString
    if($ip.Count -gt 1){
    	$ip = $ip[0]
    }
    "$ip $server" >> $outHostfile
}
