
# Retrieve with Get-AzureSubscription  
$subscriptionName = 'B_primFork-5755'   
$serviceName = 'disenzaCloudSvc01'
 
# Retreive with Get-AzureStorageAccount 
$storageAccountName = 'bds1atu1lrs'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
#$affinityGroup = 'AG-USWest' 

Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
<#   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName  
 
  #>
# ExtraSmall, Small, Medium, Large, ExtraLarge 
$instanceSize = 'Small'  

$vnetName = 'vn-uswest-disenza'  
 
# Domain join settings 
$Domain = 'disenza' 
$Domainjoin = 'disenza.com' 
$Domainuser = 'da-firep' 
$Domainpwd = '2#33e93VCvkwSr'  

################################################## 
$adminPassword = "G0G0DSE4321!"

$images = Get-AzureVMImage
$imagename = $images[44].ImageName #"a699494373c04fc0bc8f2bb1389d6106__Win2K8R2SP1-Datacenter-201404.01-en.us-127GB.vhd" #windows2k8r2 a699494373c04fc0bc8f2bb1389d6106__Win2K8R2SP1-Datacenter-201404.01-en.us-127GB.vhd
#$imagename = $images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB

$newvms = Import-Csv "E:\git\Repos\Azure\VMcreation\newvms.txt"
$sshkey = New-AzureSSHKey -PublicKey -Fingerprint 3A8026B9EEA059FB41C35CA3FCE7F667F55B4FD0 -Path '/home/oniadmin/.ssh/authorized_keys'
$i=0
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountname $storageAccountName
$Location = "AG-USEast-disenza"
$vnetName = "VN-USEast-disenza"
$vmArray = @()
$affinityGroupName = "AG-USEast-disenza"

foreach($m in $newvms){

<##  FOR WINDOWS BOX ##>
$cloudSvcName = $m.serviceName

#if((Get-AzureAffinityGroup -Name $m.affinitygroup) -eq $null){ New-AzureAffinityGroup -Name $affinityGroup }

$vmOne = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
Add-AzureProvisioningConfig -WindowsDomain -AdminUserName 'oniadmin' -Password $adminPassword -Domain $Domain -DomainUserName $Domainuser -DomainPassword $Domainpwd -JoinDomain $Domainjoin -MachineObjectOU 'OU=Computers,DC=disenza,DC=com' -DisableWinRMHttps |
Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'datadisk1' -LUN 0 |
Add-AzureEndpoint -Protocol tcp -LocalPort $m.lport -PublicPort $m.pport -Name $m.epointname |
Set-AzureSubnet -SubnetNames $m.subnet 

$service = Get-AzureService -ServiceName $cloudSvcName -ErrorAction SilentlyContinue             
     
    if ($service -eq $null) 
    { 
        # Deploy Virtual Machines to Virtual Network 
        New-AzureVM -ServiceName $cloudSvcName -AffinityGroup $affinityGroupName -VMs $vmOne -VNetName $vnetName -WaitForBoot
    } 
    else 
    { 
        New-AzureVM -ServiceName $cloudSvcName -VMs $vmOne -VNetName $vnetName -WaitForBoot
    } 
} 

#New-AzureService -ServiceName $serviceName -Location "West US"
 
## Add Certificate to the store on the cloud service (.cer or .pfx with -Password)
#Add-AzureCertificate -CertToDeploy 'c:\users\oniadmin\.ssh\redirects_rsa.cer' -ServiceName $serviceName

#write-host $vm1; write-host $vm2

# -VMs $vm1,$vm2 # -ReservedIPName DSERedirectIP	


$createlog = "E:\git\Repos\Azure\VMcreation\created.log" 
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
sp $createlog IsReadOnly $true