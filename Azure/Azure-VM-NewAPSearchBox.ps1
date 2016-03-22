$subscriptionName = 'B_disenza-CentralUS-sushi5755'
#Remove-Azuresubscription -subscriptionname $subscriptionName
# Retrieve with Get-AzureSubscription

#$serviceName = 'bald-osushizju'

# Retreive with Get-AzureStorageAccount
# bds1apjump1lrs or skiapjump2lrs
$storageAccountName = 'skiapu3lrs'

# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName
Set-AzureStorageAccount -StorageAccountName $storageAccountName

#get-azuresubscription -current
# ExtraSmall, Small, Medium, Large, ExtraLarge, Basic_A0, Basic_A1, Basic_A2, Basic_A3, Basic_A4
$instanceSize = 'Small'
$vnetName = 'VN-disenza-CentralUS'
$affinityGroup = "AG-disenza-CentralUS"
# Domain join settings
$Domain = 'disenza.com'
$authDomain = 'disenza.com'
$credential = Get-Credential
$authuser = $credential.GetNetworkCredential().Username;  write-host $authuser -f Yellow
$authpass = $credential.GetNetworkCredential().Password
$ou = 'OU=Servers,DC=disenza,DC=com'

##################################################
$adminCreds = Get-Credential
$adminuser = $adminCreds.GetNetworkCredential().UserName;
$adminpwd = $adminCreds.GetNetworkCredential().Password;

#$images = Get-AzureVMImage;  get-azurevmimage | ?{$_.ImageName -like '*Windows-Server-2012-R2*'} | %{$_.ImageName}
#$imagename = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201409.01-en.us-127GB.vhd"
$imagename = "sushiimage-helix-3"

$newvms = Import-Csv "C:\git\repos\azure\vmcreation\aphelix.txt"
#new-item C:\git\repos\azure\vmcreation\helix.txt -ItemType File
#notepad C:\git\repos\azure\vmcreation\sqlsentry.txt
#notepad C:\git\repos\azure\vmcreation\helix.txt

#get-azuresubscription -current

foreach($m in $newvms){

$cloudSvcName = $m.serviceName

$vm1 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
	Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -Domain $authDomain -DomainUsername $authuser -DomainPassword $authpass -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint
    #Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint
	Set-AzureSubnet -SubnetNames $m.subnet -VM $vm1
	Set-AzureStaticVNetIP -IPAddress $m.ipaddy -VM $vm1
	#Set-AzureAvailabilitySet -AvailabilitySetName AS-helix -VM $vm1
#*** only need anti malware on Jumps, Fileservers and SFTP
#Set-AzureVMExtension -Publisher Microsoft.Azure.Security -ExtensionName IaaSAntimalware -PublicConfiguration $AntimalwareConfig -Version 1.* -VM $vm1

New-AzureVM -ServiceName $cloudSvcName -VMs $vm1 -VNetName $vnetName -AffinityGroup $affinityGroup

sleep 1200
$vm1 | Remove-AzureVMMicrosoftAntimalwareExtension | Update-AzureVM
}
#get-azuresubscription -current

$createlog = "C:\git\repos\azure\vmcreation\created1.txt"
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
#sp $createlog IsReadOnly $true