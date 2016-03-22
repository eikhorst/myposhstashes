$subscriptionName = 'B_disenza-EastUS2-bacon5755'
#Remove-Azuresubscription -subscriptionname $subscriptionName
# Retrieve with Get-AzureSubscription

#$serviceName = 'bald-osushizju'

# Retreive with Get-AzureStorageAccount
# bds1apjump1lrs or skiapjump2lrs
$storageAccountName = 'bdsbpu2lrs'

# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName
Set-AzureStorageAccount -StorageAccountName $storageAccountName

#get-azuresubscription -current
# ExtraSmall, Small, Medium, Large, ExtraLarge, Basic_A0, Basic_A1, Basic_A2, Basic_A3, Basic_A4
$instanceSize = 'Small'
$vnetName = 'VN-disenza-EastUS2'
$affinityGroup = "AG-disenza-EastUS2"

# Domain join settings
$Domain = 'disenza.com'
$authDomain = 'disenza.com'
$credential = Get-Credential
$authuser = $credential.GetNetworkCredential().Username;  write-host $authuser -f Yellow
$authpass = $credential.GetNetworkCredential().Password
$ou = 'OU=Priveleged,DC=disenza,DC=com'

#Antimalware Config
$AntimalwareConfig = "C:\git\repos\azure\VMcreation\antimalware.json"
#$AntimalwareB64Config = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($AntimalwareConfigFile))
#$AntimalwareConfig = [string]::Format("{{""xmlCfg"":""{0}""}}",$AntimalwareB64Config)

##################################################
$adminCreds = Get-Credential
$adminuser = $adminCreds.GetNetworkCredential().UserName;
$adminpwd = $adminCreds.GetNetworkCredential().Password;

#$images = Get-AzureVMImage
get-azurevmimage | ?{$_.ImageName -like '*Windows-Server-2012-R2*'} | %{$_.ImageName}
$imagename = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201502.01-en.us-127GB.vhd"

$newvms = Import-Csv "C:\DSE\scripts\VM\newvms2.txt"

foreach($m in $newvms){
$i++; write-host $i;

$cloudSvcName = $m.serviceName

if((Get-AzureService -ServiceName $cloudSvcName).Status -ne "Created"){
    New-AzureService -ServiceName $cloudSvcName # -AffinityGroup $affinityGroup
}

$vm1 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
	Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -Domain $authDomain -DomainUsername $authuser -DomainPassword $authpass -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint
	$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'Scratch' -LUN 0
	Set-AzureSubnet -SubnetNames $m.subnet -VM $vm1
	Set-AzureStaticVNetIP -IPAddress $m.ipaddy -VM $vm1
	Set-AzureAvailabilitySet -AvailabilitySetName AS-ADMIN -VM $vm1
#*** only need anti malware on Jumps, Fileservers and SFTP
#Set-AzureVMExtension -Publisher Microsoft.Azure.Security -ExtensionName  -PublicConfiguration $AntimalwareConfig -Version 1.* -VM $vm1

New-AzureVM -ServiceName $cloudSvcName -VMs $vm1 -VNetName $vnetName

}

$createlog = "C:\DSE\scripts\VM\created1.txt"
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
#sp $createlog IsReadOnly $true