

$ErrorActionPreference = "SilentlyContinue"
$Servers = Get-Content "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt"
$Service = @("Octopus Tentacle","cballey 5.8")
$OutServices = "\\ctyfs-a01s\dsw\mypow\out\services.txt" 

$AllOurServiceStatus = @()

foreach($Server in $Servers){
    $Ss =  get-service -ComputerName $Server -Name $Service #| formprimtable Machinename,Name,Status -autosize
    if($Ss -ne $null){
    $ThisRow = New-Object Object 
    $ThisRow | add-member noteproperty -name "Machine" -value $Ss.MachineName
    $ThisRow | add-member noteproperty -name "Service" -value $Ss.Name
    $ThisRow | add-member noteproperty -name "Status" -value $Ss.Status
    
    $AllOurServiceStatus +=$ThisRow
    
    if($Ss.Status -eq "Stopped"){
        EmailMe  -
    }
    
    }
}

$AllOurServiceStatus | sort-object Service,Machine | out-file $OutServices