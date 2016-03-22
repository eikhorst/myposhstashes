
# Retrieve with Get-AzureSubscription  
$subscriptionName = 'D_disenza-Redirects-Prod-5755'   
$serviceName = 'onisorryserverscs'
 
# Retrieve with Get-AzureStorageAccount 
$storageAccountName = 'onisorryservers'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
#$affinityGroup = 'AG-USEast-disenza' 
$affinityGroup = 'West US'
# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName
 
# ExtraSmall, Small, Medium, Large, ExtraLarge 
#$instanceSize = 'Small'  

#$images = Get-AzureVMImage
#$imagename = $images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
$imagename = "b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_4-LTS-amd64-server-20140717-en-us-30GB"

$newvms = Import-Csv "C:\DSE\scripts\VM\newvmslinux.txt"

## how do i get this fingerprint?
$sshkey = New-AzureSSHKey -PublicKey -Fingerprint 3A8026B9EEA059FB41C35CA3FCE7F667F55B4FD0 -Path '/home/oniadmin/.ssh/authorized_keys'
#$i=0
#Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountname $storageAccountName

foreach($m in $newvms){
    $vm1 = New-AzureVMConfig -ImageName $imagename -InstanceSize $m.instanceSize -Name $m.machinename  -AvailabilitySetName "AS-Sorryservers" | `
#    Add-AzureProvisioningConfig -Linux -LinuxUser 'oniadmin' -Password '1d262797Br4bhYwF0d!xvf$ov3b0yO' 	   
 Add-AzureProvisioningConfig -Linux -LinuxUser 'oniadmin' -SSHPublicKeys $sshKey -Password '1d262797Br4bhYwF0d!xvf$ov3b0yO' 
    write-host $m.serviceName 
	New-AzureService -ServiceName $m.serviceName -AffinityGroup $affinityGroup

	## Add Certificate to the store on the cloud service (.cer or .pfx with -Password)
	Add-AzureCertificate -CertToDeploy 'c:\DSE\oniredirects\redirects_rsa.cer' -ServiceName $m.serviceName

#write-host $vm1; write-host $vm2

	New-AzureVM -ServiceName $m.serviceName -VMs $vm1 -Location $affinityGroup # -ReservedIPName DSESorryServers
}