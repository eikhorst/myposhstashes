#clear-host 

$Max = "cassiday.com" #"cornerstone.com" #"web2.westlaw.com"
$s = Resolve-DnsName $Max -type NS #-QuickTimeout
$s = Resolve-DnsName $Max -type NS
Write-Host $Max -ForegroundColor Blue
Write-host "NS rec: s.NameHost " + $s.NameHost -ForegroundColor Red
 @($s.NameHost) -join " " 
Write-host "NS rec: s[0].NameHost  " + $s[0].NameHost  -ForegroundColor Yellow 
Write-host "NS rec: s.Address  " + $s.Address  -ForegroundColor Red
Write-host "NS rec: s[0].Address  " + $s[0].Address  -ForegroundColor Yellow 
Write-host "NS rec: s.IP4Address  " + $s.IP4Address  -ForegroundColor Red
 @($s.IP4Address) -join " "
Write-host "NS rec: s[0].IP4Address  " + $s[0].IP4Address  -ForegroundColor Yellow 
Write-host "NS rec: s.NameServer  " + $s.NameServer  -ForegroundColor Red
Write-host "NS rec: s[0].NameServer  " + $s[0].NameServer  -ForegroundColor Yellow 
Write-host "NS rec: s.NameAdministrator  " + $s.NameAdministrator  -ForegroundColor Red
Write-host "NS rec: s[0].NameAdministrator  " + $s[0].NameAdministrator  -ForegroundColor Yellow 


$s = Resolve-DnsName $Max -type A ;$s = Resolve-DnsName $Max -type A #-QuickTimeout
Write-Host $Max -ForegroundColor Blue
Write-host "A rec: s.NameHost " + $s.NameHost -ForegroundColor Red
Write-host "A rec: s[0].NameHost  " + $s[0].NameHost  -ForegroundColor Yellow 
Write-host "A rec: s.Address  " + $s.Address  -ForegroundColor White
Write-host "A rec: s[0].Address  " + $s[0].Address  -ForegroundColor White 
Write-host "A rec: s.IP4Address  " + $s.IP4Address  -ForegroundColor Red
Write-host "A rec: s[0].IP4Address  " + $s[0].IP4Address  -ForegroundColor Yellow 
Write-host "A rec: s.NameServer  " + $s.NameServer  -ForegroundColor Red
Write-host "A rec: s[0].NameServer  " + $s[0].NameServer  -ForegroundColor Yellow 
Write-host "A rec: s.NameAdministrator  " + $s.NameAdministrator  -ForegroundColor Red
Write-host "A rec: s[0].NameAdministrator  " + $s[0].NameAdministrator  -ForegroundColor Yellow 
Write-host "A rec: s.PrimaryNameserver  " + $s.PrimaryServer  -ForegroundColor Red
Write-host "A rec: s[0].PrimaryServer  " + $s[0].PrimaryServer  -ForegroundColor Yellow 

<#
$Max = "www." + $Max 
$s = Resolve-DnsName $Max -type NS #-QuickTimeout
$s = Resolve-DnsName $Max -type NS
Write-Host $Max -ForegroundColor Blue
Write-host "wwwNS rec: s.NameHost " + $s.NameHost -ForegroundColor Red
Write-host "wwwNS rec: s[0].NameHost  " + $s[0].NameHost  -ForegroundColor Yellow 
Write-host "wwwNS rec: s.Address  " + $s.Address  -ForegroundColor Red
Write-host "wwwNS rec: s[0].Address  " + $s[0].Address  -ForegroundColor Yellow 
Write-host "wwwNS rec: s.IP4Address  " + $s.IP4Address  -ForegroundColor Red
Write-host "wwwNS rec: s[0].IP4Address  " + $s[0].IP4Address  -ForegroundColor Yellow 
Write-host "wwwNS rec: s.NameServer  " + $s.NameServer  -ForegroundColor Red
Write-host "wwwNS rec: s[0].NameServer  " + $s[0].NameServer  -ForegroundColor Yellow 
Write-host "wwwNS rec: s.NameAdministrator  " + $s.NameAdministrator  -ForegroundColor White
Write-host "wwwNS rec: s[0].NameAdministrator  " + $s[0].NameAdministrator  -ForegroundColor Yellow 
Write-host "wwwNS rec: s.PrimaryNameserver  " + $s.PrimaryServer  -ForegroundColor White
Write-host "wwwNS rec: s[0].PrimaryServer  " + $s[0].PrimaryServer  -ForegroundColor Yellow 


$s = Resolve-DNSName $Max -type A ; $s = Resolve-DnsName $Max -type A  #-QuickTimeout
$s -eq $null ; Write-Host $Max -ForegroundColor Blue
Write-host "wwwA rec: s.NameHost " + $s.NameHost -ForegroundColor Red
Write-host "wwwA rec: s[0].NameHost  " + $s[0].NameHost  -ForegroundColor Yellow 
Write-host "wwwA rec: s.Address  " + $s.Address  -ForegroundColor White
Write-host "wwwA rec: s[0].Address  " + $s[0].Address  -ForegroundColor Yellow 
Write-host "wwwA rec: s.IP4Address  " + $s.IP4Address  -ForegroundColor Red
Write-host "wwwA rec: s[0].IP4Address  " + $s[0].IP4Address  -ForegroundColor Yellow 
Write-host "wwwA rec: s.NameServer  " + $s.NameServer  -ForegroundColor Red
Write-host "wwwA rec: s[0].NameServer  " + $s[ 0].NameServer  -ForegroundColor Yellow 
Write-host "wwwA rec: s.NameAdministrator  " + $s.NameAdministrator  -ForegroundColor Red
Write-host "wwwA rec: s[0].NameAdministrator  " + $s[0].NameAdministrator  -ForegroundColor Yellow 
Write-host "wwwA rec: s.PrimaryNameserver  " + $s.PrimaryServer  -ForegroundColor Red
Write-host "wwwA rec: s[0].PrimaryServer  " + $s[0].PrimaryServer  -ForegroundColor Yellow 
#>