
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | select -Expand Name | sort
#$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushifig-sfa-02'} | select -Expand Name | sort
$servers = $servers -join ','

#$ErrorActionPreference = "SilentlyContinue"
$services = @("Octopusdeploy Tentacle")
$OutServices = "E:\services.txt" 
Clear-Content $OutServices

$AllOurServiceStatus = @{}

foreach($server in $servers.split(',')){
    #foreach($service in $services){
        $Ss =  get-service -ComputerName $server -Name $service #| formprimtable Machinename,Name,Status -autosize
        if($Ss -ne $null){
    
            $ThisRow = New-Object Object 
            $ThisRow | add-member noteproperty -name "Machine" -value $server
            $ThisRow | add-member noteproperty -name "Service" -value $service
            $ThisRow | add-member noteproperty -name "Status" -value $Ss.Status
            '$Ss.MachineName $service $Ss.Status' | out-file $OutServices -Append
            #$AllOurServiceStatus += $ThisRow
        }        
    #}
}

#$AllOurServiceStatus | sort-object Service,Machine | out-file $OutServices