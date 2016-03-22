
# Retrieve with Get-AzureSubscription  
$subscriptionName = 'D_disenza-Redirects-Prod-5755'   
 
# Retreive with Get-AzureStorageAccount 
$storageAccountName = 'oniredirects'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
$affinityGroup = 'AG-USEast-disenza' 

<# 

# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
  
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName  
 
  #>
# ExtraSmall, Small, Medium, Large, ExtraLarge 
$instanceSize = 'ExtraSmall'  

$vnetName = 'vn-uswest-disenza'  
 
# Domain join settings 
$Domain = 'disenza' 
$Domainjoin = 'disenza.com' 
$Domainuser = 'da-firep' 
$Domainpwd = '2#33e93VCvkwSr'  

################################################## 
$adminPassword = "Zscxv123#40978!oweJfiv"
$images = Get-AzureVMImage
#$imagename = $images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
$newvms = Import-Csv "E:\git\repos\Azure\VMcreation\newvms.txt"


$createlog = "C:\DSE\VMcreation\created.log" 

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
chmod 700 $createlog
$date | out-file -append $createlog
$newvms | out-file -append $createlog
chmod 400 $createlog

foreach($m in $newvms){

Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountname $storageAccountName

#New-AzureStorageAccount -StorageAccountName "bds1atu1lrs" -AffinityGroup "AG-USEast-disenza" -label "UtilityBackups"
#switched it to locally redundant

$cloudSvcName = $m.serviceName

if((Get-AzureService -ServiceName $cloudSvcName).Status -ne "Created"){
New-AzureService -ServiceName $cloudSvcName -AffinityGroup $affinityGroup
}

$vm2 = New

<##  FOR WINDOWS BOX
$vm2 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
Add-AzureProvisioningConfig -WindowsDomain -AdminUserName 'oniadmin' -Password $adminPassword -JoinDomain $Domainjoin -Domain $Domain -DomainUserName $Domainuser -DomainPassword $Domainpwd -MachineObjectOU 'OU=Computers,DC=disenza,DC=com' |
Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'datadisk1' -LUN 0 |
Add-AzureEndpoint -Protocol tcp -LocalPort $m.lport -PublicPort $m.pport -Name $m.epointname |
Set-AzureSubnet -SubnetNames $m.subnet 
#>

New-AzureVM -ServiceName $cloudSvcName -VMs $vm2 -VNetName $vnetName 

}