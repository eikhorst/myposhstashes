<#  ##To Remove
Set-AzureSubscription -SubscriptionName B_sushiFork-5755 -CurrentStorageAccount bds1apz1lrs
Select-AzureSubscription B_sushiFork-5755

Remove-AzureReservedIP -ReservedIPName DSESorryServers

get-AzureReservedIP
#>
<#
Set-AzureSubscription -SubscriptionName B_disenza-CentralUS-sushi5755 -CurrentStorageAccount skiapu3lrs
Select-AzureSubscription B_disenza-CentralUS-sushi5755

New-AzureReservedIP -Location "Central US" -ReservedIPName IP-sushiWAF-2ND -Label "IP for sushiWAF-2ND"

Get-AzureReservedIP
#>

Set-AzureSubscription -SubscriptionName B_disenza-CentralUS-prim5755 -CurrentStorageAccount bdsatu3lrs
Select-AzureSubscription B_disenza-CentralUS-prim5755

#Set-AzureSubscription -SubscriptionName B_baconFork-5755 -CurrentStorageAccount bds1bpz1lrs
#Select-AzureSubscription B_baconFork-5755

#Specify Virtual Machine Name
#$vmname = 'primWAF-1ST-Q'
$vmname = 'primWAF-1ST-R'
#$vmname = 'baconWAF-1STHOURLY-S'
##$vmname = 'sushiWAF-2NDHOURLY-T'
#$vmname = 'sushiWAF-2NDHOURLY-U'
#$vmname = 'sushiWAF-2NDHOURLY-V'
#$vmname = 'sushiWAF-1STHOURLY-W'
#$vmname = 'sushiWAF-1STHOURLY-X'
#$vmname = 'sushiWAF-1ST-Y'
#$vmname = 'sushiWAF-1ST-Z'

#OS Image to Use
#$image = 'fb83b3509582419d99629ce476bcb5c8__SQL-Server-2008R2SP2-GDR-10.50.4021.0-Standard-ENU-Win2K8R2-CY14SU02'
$image = '810d5f35ce8748c686feabed1344911c__BarracudaWAF-7.8.2.008'
#$image = 'BarracudaWAF-fw7.8.2'


#Cloud Service
#$service = 'bald-xsushiWAF-1ST'
#$service = 'bald-xsushiWAF-2ND'
#$service = 'bald-xbaconWAF-1ST'
$service = 'bald-primWAF-1ST'

#Affinity Group
$AG = 'AG-disenza-CentralUS'
#$AG = 'AG-USWest-disenza'

#VNET and Subnet
$vnet = 'vn-disenza-centralus'
#$vnet = 'vn-uswest-disenza'
$subnet = 'FIREWALL'

#Admin Username and Password
$adminuser = 'localadmin'  #This value user and password is not used by the WAF - but you have to pass these values into Azure for it to deploy the VM
$adminpwd = 'TheLocalAdminPassWordDoesn!tMatter54321'

#Instance Size
$instancesize = 'Medium'

#Reserved IP - ONLY if the cloud service should have a reserved IP
#$RIPName = 'IP-xsushiWAF-1ST'
$RIPName = 'IP-primWAF-R'  #This IP still needs to be reserved
#$RIPName = 'IP-xbaconWAF-1ST'  #This IP still needs to be reserved


#Assigned DIP
$ipaddy = '10.40.3.17'  #The last number of the IP address should be the same as the last letter in the WAF name (i.e. Z=26, Y=25, X=24, W=23, V=22, U=21, T=20, S=19, R=18,  etc)

#VM Configuration
$MyVM = New-AzureVMConfig -name $vmname -InstanceSize $instancesize -ImageName $image

    #Add-AzureProvisioningConfig -Linux -LinuxUser $adminuser -VM $MyVM   -Password $adminpwd -NoSSHPassword

    Add-AzureProvisioningConfig -Linux -VM $MyVM -LinuxUser $adminuser -Password $adminpwd


    Set-AzureSubnet -SubnetNames $subnet -VM $MyVM

    #Set-AzureEndpoint -Name HTTP -VM $MyVM -ACL 10.10.0.0/16 -LocalPort 80 -Protocol tcp -PublicPort 80

    Set-AzureStaticVNetIP -VM $MyVM –IPAddress $ipaddy

    New-AzureVM -ServiceName $service -VMs $MyVM -AffinityGroup $AG -ReservedIPName $RIPName -VNetName $vnet


    #u=21, v=22