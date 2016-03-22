#Select Subscription, Set Subscription and Storage Account
#For Prod
#Set-AzureSubscription -SubscriptionName B_sushiFork-5755
#Select-AzureSubscription B_sushiFork-5755
#For TEST
#Set-AzureSubscription -SubscriptionName B_disenza-CentralUS-sushi5755
Set-AzureSubscription -SubscriptionName B_disenza-EastUS2-bacon5755
#Set-AzureSubscription -SubscriptionName B_disenza-CentralUS-prim5755

#Select-AzureSubscription B_disenza-CentralUS-sushi5755
Select-AzureSubscription B_disenza-EastUS2-bacon5755
#Select-AzureSubscription B_disenza-CentralUS-prim5755

#VNET and Subnet
#$vnet = 'VN-disenza-CENTRALUS'
$vnet = 'VN-disenza-EastUS2'
$subnet = 'UTILITY'

#VNET Address Spaces
$ATIPSpace = "10.20"
$BTIPSpace = "10.21"
$APIPSpace = "10.10"
$BPIPSpace = "10.11"
$APCentIPS = "30.50"
$BPUSE2IPS = "30.51"
$ATCentIPS = "10.40"
$BTUSE2IPS = "10.41"

#GetStaticDIP Function
Function GetStaticDIP {
	
Switch ($vnet) {
	VN-USEast-disenza {$VNETAddressSpace = $ATIPSpace}
	VN-USWest-disenza {$VNETAddressSpace = $BTIPSpace}
	VN-USEast-disenza {$VNETAddressSpace = $APIPSpace}
	VN-USWest-disenza {$VNETAddressSpace = $BPIPSpace}
    VN-disenza-CENTRALUS {$VNETAddressSpace = $ATCentIPS}
	VN-disenza-EASTUS2 {$VNETAddressSpace = $BTUSE2IPS}
	VN-disenza-CENTRALUS {$VNETAddressSpace = $APCentIPS}
	VN-disenza-EASTUS2 {$VNETAddressSpace = $BPUSE2IPS}
	}
	
	Write-Host The detected address space based on the VNET of $vnet is $VNETAddressSpace

Switch ($subnet) {
	ACTIVEDIRECTORY {$TestIP = $VNETAddressSpace + ".2.3"}
    FIREWALL {$TestIP = $VNETAddressSpace + ".3.3"}
	ADMIN {$TestIP = $VNETAddressSpace + ".4.3"}
	WEB {$TestIP = $VNETAddressSpace + ".20.3"}
	SQL {$TestIP = $VNETAddressSpace + ".30.3"}
	UTILITY {$TestIP = $VNETAddressSpace + ".40.3"}
	FILE {$TestIP = $VNETAddressSpace + ".6.3"}
	}

	Write-Host The detected IP address to test based on the subnet of $subnet is $TestIP
	
#Assigned Static DIP
	
$availipaddy = Test-AzureStaticVNetIP -VNetName $vnet -IPAddress $TestIP
$ipaddy = $availipaddy.AvailableAddresses[0]

Write-Host "Next VM will get a static DIP of" $ipaddy
}

#Determine if a static DIP should be used
#$XMLStaticDIP will need to come from the XML file
#For testing and until the XML file is ready I am manually populating it
$XMLStaticDIP = "True"

#Here we will see if a static DIP was requested or not and then act appropriately
#We will force the use of a Static DIP for specific subnets that only use static DIPs, even if a static DIP wasn't requested
If ($XMLStaticDIP -ne "True"){

Switch ($subnet) {
	ACTIVEDIRECTORY {$ForceStaticDIP = "True"}
	ADMIN {$ForceStaticDIP = "True"}
	SQL {$ForceStaticDIP = "True"}
	FILE {$ForceStaticDIP = "True"}
	default {$ForceStaticDIP = "False"}
	}
	Write-Host Based on the subnet of $subnet ForceStaticDIP is set to $ForceStaticDIP
	If ($ForceStaticDIP -eq "False"){
	Write-Host Static DIP is not required for this Virual Machine
	}
	Else {
	GetStaticDIP
	}
}
Else {
	GetStaticDIP
}



