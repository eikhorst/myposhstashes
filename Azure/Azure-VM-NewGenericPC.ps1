
# Retrieve with Get-AzureSubscription
$subscriptionName = 'B_disenza-Centralus-sushi5755'
$serviceName = 'bald-sushiju'

# Retreive with Get-AzureStorageAccount
$storageAccountName = 'skiapjump2lrs'

# Enumerate available locations with Get-AzureLocation.
# Must be the same as your virtual network affinity group.
$affinityGroup = 'AG-disenza-AP'

# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName

# ExtraSmall, Small, Medium, Large, ExtraLarge, Basic_A0, Basic_A1, Basic_A2, Basic_A3, Basic_A4
$instanceSize = 'Small'
$vnetName = 'VN-disenza-Centralus'

# Domain join settings
$Domain = 'disenza.com'
$authDomain = 'disenza.com'
$credential = Get-Credential
$authuser = $credential.GetNetworkCredential().Username;  write-host $authuser -f Yellow
$authpass = $credential.GetNetworkCredential().Password
$ou = 'OU=Privileged,DC=disenza,DC=com'

<#
#Antimalware Config
$AntimalwareConfigFile = Get-Content "C:\git\repos\azure\vmcreation\AntimalwareConfig.xml"
$AntimalwareB64Config = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($AntimalwareConfigFile))
$AntimalwareConfig = [string]::Format("{{""xmlCfg"":""{0}""}}",$AntimalwareB64Config)
#>
##################################################
$adminCreds = Get-Credential
$adminuser = $adminCreds.GetNetworkCredential().UserName;
$adminpwd = $adminCreds.GetNetworkCredential().Password;

$images = Get-AzureVMImage
$imagename = 'a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201412.01-en.us-127GB.vhd' #$images[49].ImageName  # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
#$imagename = $images[81].ImageName # Ubuntu 12.04
#$imagename = "TSHhot01"

$newvms = Import-Csv "C:\git\repos\azure\vmcreation\newvms2.txt"

foreach($m in $newvms){
$i++; write-host $i;

$cloudSvcName = $m.serviceName
$AntimalwareConfigFile = "C:\git\repos\azure\vmcreation\antimalware.json"

if((Get-AzureService -ServiceName $cloudSvcName).Status -ne "Created"){
    New-AzureService -ServiceName $cloudSvcName # -AffinityGroup $affinityGroup
}

$vm1 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
	Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -Domain $authDomain -DomainUsername $authuser -DomainPassword $authpass -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint
	$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $m.diskSize1 -DiskLabel 'Scratch' -LUN 0
	Set-AzureSubnet -SubnetNames $m.subnet -VM $vm1
	Set-AzureStaticVNetIP -IPAddress $m.ipaddy -VM $vm1
    Set-AzureAvailabilitySet -AvailabilitySetName AS-Word -VM $vm1
	#Set-AzureVMExtension -Publisher Microsoft.Azure.Security -ExtensionName IaaSAntimalware -PublicConfiguration $AntimalwareConfig -Version 1.* -VM $vm1
    #Set-AzureVMMicrosoftAntimalwareExtension -AntimalwareConfigFile  $AntimalwareConfigFile -Monitoring ON -Version '1.*' -StorageContext $StorageContext # | Update-AzureVM
    New-AzureVM -ServiceName $cloudSvcName -VMs $vm1 -VNetName $vnetName

}

$createlog = "C:\DSE\scripts\VM\created1.txt"
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
#sp $createlog IsReadOnly $true