
# Retrieve with Get-AzureSubscription  
$subscriptionName = 'B_primFork-5755'   
$serviceName = 'bald-PA-01'
 
# Retreive with Get-AzureStorageAccount 
$storageAccountName = 'bds1atu1lrs'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
#$affinityGroup = 'AG-USWest' 

# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName  
 
# ExtraSmall, Small, Medium, Large, ExtraLarge 
$instanceSize = 'Small'  
$vnetName = 'vn-uswest-disenza'  
 
# Domain join settings 
$Domain = 'disenza' 
$Domainjoin = 'disenza.com' 


################################################## 
$adminPassword = ""

$images = Get-AzureVMImage
$imagename = $images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
#$imagename = $images[81].ImageName # Ubuntu 12.04

$newvms = Import-Csv "C:\DSE\VM\newvms.txt"
#$sshkey = New-AzureSSHKey -PublicKey -Fingerprint 3A8026B9EEA059FB41C35CA3FCE7F667F55B4FD0 -Path '/home/oniadmin/.ssh/authorized_keys'
$i=0
#Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountname $storageAccountName

foreach($m in $newvms){
$i++; write-host $i;
<#
if($i -eq 1){
    $vm1 = New-AzureVMConfig -ImageName $imagename -InstanceSize $m.instanceSize -Name $m.machinename  -AvailabilitySetName "bacononiredirects" | `
	    Add-AzureProvisioningConfig -Linux -LinuxUser 'oniadmin' -SSHPublicKeys $sshKey -NoSSHPassword 
}
if($i -eq 2){
    $vm2 = New-AzureVMConfig -ImageName $imagename -InstanceSize $m.instanceSize -Name $m.machinename  -AvailabilitySetName "bacononiredirects" | `
	    Add-AzureProvisioningConfig -Linux -LinuxUser 'oniadmin' -SSHPublicKeys $sshKey -NoSSHPassword 
} #>
<##  FOR WINDOWS BOX #>
$cloudSvcName = $m.serviceName

if((Get-AzureService -ServiceName $cloudSvcName).Status -ne "Created"){
    New-AzureService -ServiceName $cloudSvcName -AffinityGroup $affinityGroup
}

$vm2 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
Add-AzureProvisioningConfig -WindowsDomain -AdminUserName 'oniadmin' -Password $adminPassword -JoinDomain $Domainjoin -Domain $Domain -DomainUserName $Domainuser -DomainPassword $Domainpwd -MachineObjectOU 'OU=Servers,DC=disenza,DC=com' |
Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'ScratchForSkutta' -LUN 0 |
#Add-AzureEndpoint -Protocol tcp -LocalPort 3889 -PublicPort 52973 -Name 'RDP' |
Set-AzureSubnet -SubnetNames $m.subnet 

New-AzureVM -ServiceName $cloudSvcName -VMs $vm2 -VNetName $vnetName 


}

<# ## for linux boxes creation
New-AzureService -ServiceName $serviceName -Location "West US"
 
## Add Certificate to the store on the cloud service (.cer or .pfx with -Password)
Add-AzureCertificate -CertToDeploy 'c:\users\oniadmin\.ssh\redirects_rsa.cer' -ServiceName $serviceName

write-host $vm1; write-host $vm2

New-AzureVM -ServiceName $serviceName -DeploymentName DSEredirectDeployment -VMs $vm1,$vm2 -ReservedIPName DSERedirectIP	
#>

$createlog = "C:\DSE\VM\created.log" 
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
sp $createlog IsReadOnly $true