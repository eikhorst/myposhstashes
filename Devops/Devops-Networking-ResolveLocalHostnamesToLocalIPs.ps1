$ErrorActionPreference = "SilentlyContinue"
$Domains = gc "\\ctyfs-a01s\dsw\mypow\AlldisenzaServersInAll3Domains.txt"
foreach($Domain in $Domains){
    $Domain = $Domain.Split('.')[0].Split(' ')[0]
    $Domain2 = $Domain+".ETDsoya.com"
    $res = $null
    #$res = Resolve-DnsName $Domain2 -type A -QuickTimeout
    $res =  [System.Net.Dns]::GetHostByName($Domain2)
    if($res -eq $null){
        $Domain2 = $Domain+".disenzahost.com"
        $res = [System.Net.Dns]::GetHostByName($Domain2) #Resolve-DnsName $Domain2 -type A -QuickTimeout
    }
    if($res -eq $null){
        $Domain2 = $Domain+".tlr.disenza.com"
        $res = [System.Net.Dns]::GetHostByName($Domain2) #Resolve-DnsName $Domain2 -type A -QuickTimeout
    }
    if($res -eq $null){
        $Domain2 = $Domain+".int.disenza.com"
        $res = [System.Net.Dns]::GetHostByName($Domain2) #Resolve-DnsName $Domain2 -type A -QuickTimeout
    }
    if($res -ne $null){    
     $res.HostName + ", " + $res.Aliases + ", " +$res.AddressList[0].IPAddressToString | Out-File "E:\disenza\scripts\in\internalips3.txt" -Append
    }
    else{write-host $Domain -ForegroundColor Red}
}

