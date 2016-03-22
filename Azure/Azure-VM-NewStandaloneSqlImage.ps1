$subscriptionName = 'B_sushiFork-5755'
#Remove-Azuresubscription -subscriptionname $subscriptionName
# Retrieve with Get-AzureSubscription  
   
#$serviceName = 'bald-osushizju'
 
# Retreive with Get-AzureStorageAccount 
$storageAccountName = 'bds1apu3lrs'    

# Enumerate available locations with Get-AzureLocation.  
# Must be the same as your virtual network affinity group. 
$affinityGroup = 'AG-USEast-disenza' 

# Specify the storage account location to store the newly created VHDs  
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName  
   
# Select the correct subscription (allows multiple subscription support)  
Select-AzureSubscription -SubscriptionName $subscriptionName  
 
# ExtraSmall, Small, Medium, Large, ExtraLarge, Basic_A0, Basic_A1, Basic_A2, Basic_A3, Basic_A4
$instanceSize = 'Medium'  
$vnetName = 'vn-useast-disenza'  
 
# Domain join settings 
$Domain = 'disenza.com'
$authDomain = 'disenza.com'
$credential = Get-Credential
$authuser = $credential.GetNetworkCredential().Username;  write-host $authuser -f Yellow
$authpass = $credential.GetNetworkCredential().Password
$ou = 'OU=Priveleged,DC=disenza,DC=com'

#Antimalware Config
$AntimalwareConfigFile = Get-Content "C:\git\repos\azure\vmcreation\AntimalwareConfig.xml"
$AntimalwareB64Config = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($AntimalwareConfigFile))
$AntimalwareConfig = [string]::Format("{{""xmlCfg"":""{0}""}}",$AntimalwareB64Config)

################################################## 
$adminCreds = Get-Credential
$adminuser = $adminCreds.GetNetworkCredential().UserName;
$adminpwd = $adminCreds.GetNetworkCredential().Password;

##*** Run this to get the latest sql image: 
##    get-azurevmimage | ?{$_.ImageName -like '*sql*'} | %{$_.ImageName}
$imagename = "fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014RTM-12.0.2000.8-Web-ENU-WS2012R2-AprilGA" 
#fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014RTM-12.0.2000.8-Web-ENU-WS2012R2-AprilGA   # Windows Server 2012 a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201404.01-en.us-127GB.vhd
#$imagename = $images[99].ImageName # Ubuntu 14.04 LTS     b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB
#$imagename = $images[81].ImageName # Ubuntu 12.04
#$imagename = "DSEJump01"

$newvms = Import-Csv "C:\git\repos\azure\vmcreation\newvms.txt"

foreach($m in $newvms){
#$i++; write-host $i;

$cloudSvcName = $m.serviceName
$affinityGroup = "AG-USEast-disenza"
if((Get-AzureService -ServiceName $cloudSvcName).Status -ne "Created"){
    write-host "creating: $cloudSvcName"
    New-AzureService -ServiceName $cloudSvcName -AffinityGroup $affinityGroup
}
#sleep 300
$vm1 = New-AzureVMConfig -Name $m.machinename -InstanceSize $m.instanceSize -ImageName $imagename |
#	Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -Domain $authDomain -DomainUsername $authuser -DomainPassword $authpass -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint
Add-AzureProvisioningConfig -WindowsDomain -JoinDomain $Domain -MachineObjectOU $ou -AdminUsername $adminuser -Password $adminpwd -NoRDPEndpoint -NoWinRMEndpoint	
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB 250 -DiskLabel 'Data for PASM ad SQL System Databases' -LUN 0
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB 250 -DiskLabel 'Data for FOGLIGHT' -LUN 1
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB 150 -DiskLabel 'Log for all Databases' -LUN 2
$vm1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB 500 -DiskLabel 'Backup for stansaction logs and databases' -LUN 3
	Set-AzureSubnet -SubnetNames $m.subnet -VM $vm1
	Set-AzureStaticVNetIP -IPAddress $m.ipaddy -VM $vm1
	#Set-AzureAvailabilitySet -AvailabilitySetName AS-ADMIN -VM $vm1
	Set-AzureVMExtension -Publisher Microsoft.Azure.Security -ExtensionName IaaSAntimalware -PublicConfiguration $AntimalwareConfig -Version 1.* -VM $vm1

New-AzureVM -ServiceName $cloudSvcName -VMs $vm1 -VNetName $vnetName 

}

$createlog = "C:\git\repos\azure\vmcreation\created1.txt" 
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#sp $createlog IsReadOnly $false
$date | out-file -append $createlog
$newvms | out-file -append $createlog
#sp $createlog IsReadOnly $true

Write-host '*** Ensure that you grant Domain Admins the sysadmin role in sql before you reboot the machine to complete joining the machine to the Domain ***' -F WHITE -B Red 