
# Retrieve with Get-AzureSubscription  
$subscriptionName = 'B_primFork-5755'   
$serviceName = 'onikbox'
 
# Retreive with Get-AzureStorageAccount 
$storageAccountName = 'bds1atu1lrs'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
$affinityGroup = 'AG-USEast-disenza' 

Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
<#   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName  
 
  #>
# ExtraSmall, Small, Medium, Large, ExtraLarge 
$instanceSize = 'Medium'  
<#
$vnetName = 'vn-uswest-disenza'  
 
# Domain join settings 
$Domain = 'disenza' 
$Domainjoin = 'disenza.com' 
$Domainuser = 'da-firep' 
$Domainpwd = '2#33e93VCvkwSr'  

################################################## 
$adminPassword = "Zscxv123#40978!oweJfiv"
#>
#$images = Get-AzureVMImage # get-azurevmimage | ?{$_.ImageName -like '*Ubuntu-14_*LTS*'} | %{$_.ImageName}
#$imagename = $images[44].ImageName #"a699494373c04fc0bc8f2bb1389d6106__Win2K8R2SP1-Datacenter-201404.01-en.us-127GB.vhd" #windows2k8r2 a699494373c04fc0bc8f2bb1389d6106__Win2K8R2SP1-Datacenter-201404.01-en.us-127GB.vhd
#$imagename = $images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
$imagename= "b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_1-LTS-amd64-server-20140927-en-us-30GB"
$newvms = Import-Csv "c:\git\Repos\Azure\VMcreation\newvms.txt"
# this fingerprint can be found in the certificate screen on the cloud service
$sshkey = New-AzureSSHKey -PublicKey -Fingerprint AD58F7C7FC40DE6F4724FAC954F01040BDBB13A0 -Path '/home/oniadmin/.ssh/authorized_keys'
$i=0
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountname $storageAccountName

foreach($m in $newvms){
$i++; write-host $i;

if($i -eq 1){
    $vm1 = New-AzureVMConfig -ImageName $imagename -InstanceSize $m.instanceSize -Name $m.machinename  -AvailabilitySetName "AS-Linux" | `
	    Add-AzureProvisioningConfig -Linux -LinuxUser 'oniadmin' -SSHPublicKeys $sshKey -NoSSHPassword 
}

}

New-AzureService -ServiceName $serviceName -Location "East US"
 
## Add Certificate to the store on the cloud service (.cer or .pfx with -Password)
#Add-AzureCertificate -CertToDeploy 'c:\users\da-firep\.ssh\redirects_rsa.cer' -ServiceName $serviceName
Add-AzureCertificate -CertToDeploy 'c:\users\da-firep\.ssh\keybox4.cer' -ServiceName $serviceName

write-host $vm1; write-host $vm2

#New-AzureVM -ServiceName $serviceName -DeploymentName DSEredirectDeployment -VMs $vm1 #-ReservedIPName DSERedirectIP	
New-AzureVM -ServiceName $serviceName -DeploymentName DSEredirectDeployment -VMs $vm1 #-ReservedIPName DSERedirectIP	


$createlog = "C:\git\repos\azure\vmcreation\created.log" 
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
sp $createlog IsReadOnly $true



#3A8026B9EEA059FB41C35CA3FCE7F667F55B4FD0 
#ae6898ee652f49d51aa37b00b84ee842f2be179a

#AD58F7C7FC40DE6F4724FAC954F01040BDBB13A0