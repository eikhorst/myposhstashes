$servicename = "bald-baconju"
$servers = GET-azureservice | ?{$_.ServiceName -match $servicename} | Get-AzureVM # %{$_.ResourceExtensionStatusList; $vm2=$_.InstanceName} | ?{$_.Status -match "NotReady"} | %{$vm2, $_.HandlerName}
#$servers = @("baconju-firep","baconju-dmouse","baconju-mhopkins","baconju-ramper","baconju-ninja","baconju-dvespo","baconju-hgtv","baconju-msnbc")
#$storageaccount = "skiapjump1lrs"

$AntimalwareConfigFile = "C:\git\repos\azure\vmcreation\antimalware.json"
$notapplied = @("baconju-01","baconju-02")
#@("sushihelix-18","sushihelix-17","sushihelix-16","sushihelix-15","sushihelix-12","sushihelix-13","sushihelix-14","sushihelix-11")
#$applyto = @("sushihelix-04")
foreach($server in $servers){
write-host $server.Name
    #foreach($prob in $server.ResourceExtensionStatusList){
    #write-host $prob.HandlerName
     #   if($prob.status -match "NotReady"){
            $storageaccount = ($server | Get-AzureOSDisk).MediaLink.DnsSafeHost.Split(".")[0]
            $StorageContext = New-AzureStorageContext -StorageAccountName $storageaccount -StorageAccountKey (Get-AzureStorageKey -StorageAccountName $storageaccount).Primary

            write-host "Removing extension: $($server.HostName): $($prob.HandlerName)"
            #$server | Remove-AzureVMMicrosoftAntimalwareExtension | Remove-AzureVMAccessExtension | Update-AzureVM
            $server | Remove-AzureVMMicrosoftAntimalwareExtension  | Update-AzureVM -Debug

            if($notapplied -notcontains $server.Name){
            #if($applyto -contains $server.HostName){
                write-host "Adding new diagnostic info for : $($server.HostName) to $($storageaccount) StorageAccount"
                $server | Set-AzureVMMicrosoftAntimalwareExtension -AntimalwareConfigFile $AntimalwareConfigFile -Monitoring ON -Version '1.*' -StorageContext $StorageContext  | Update-AzureVM
            }
      #  }
    #}
}

<#
$vm = Get-AzureVM -ServiceName $servicename -Name $name
$vm | Get-AzureVMExtension

$vm.ResourceExtensionStatusList | ?{$_.Status -match "NotReady"} | %{$vm.Name, $_.HandlerName}

#uninstall
$vm | Remove-AzureVMMicrosoftAntimalwareExtension | Update-AzureVM

#install
$StorageContext = New-AzureStorageContext -StorageAccountName $storageaccount -StorageAccountKey (Get-AzureStorageKey -StorageAccountName $storageaccount).Primary
$vm | Set-AzureVMMicrosoftAntimalwareExtension  -AntimalwareConfigFile  "C:\git\repos\azure\vmcreation\antimalware.json" -Monitoring ON -Version '1.*' -StorageContext $StorageContext  | Update-AzureVM

$vm | Get-AzureVMExtension
#>