#Parameters from command line
#----------------------------

[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=0)][string]$VMToMove,
[Parameter(Mandatory=$True,Position=1)][string]$CentralStorageAccount,
[Parameter(Mandatory=$True,Position=2)][string]$CentralCloudService,
[Parameter(Mandatory=$True,Position=3)][ValidateSet("Linux", "Windows")][string]$VMOS,
[Parameter(Mandatory=$False,Position=4)][string]$CloudServiceReservedIPName
)

Write-Host "The storage account you requested of $CentralStorageAccount must already exist in the Central subscription.  This script will not create it."
Write-Host "Press any key to continue once you have confirmed the storage account exists..."
$anykey = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

If ([string]::IsNullOrWhiteSpace($CloudServiceReservedIPName)) {
}
	
Else {
	Write-Host "You have specified a Cloud Service Reserved IP Name of $CloudServiceReservedIPName"
	Write-Host "Please ensure you have properly acquired the reserved IP in the Central subscription prior to continuing this script."
	Write-Host "Press any key to continue..."
	$anykey = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
}

#Set preferences
#---------------

$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

#Alter the command line input to avoid issues
#--------------------------------

$NewStorageAccount = $CentralStorageAccount.ToLower()

#Set primary variables that do not change
#----------------------------------------

$EastSubscription = 'B_sushiFork-5755'
$CentralSubscription = 'B_disenza-CentralUS-sushi5755'
#$PublishSettingsFilePath = 'C:\Admin\TaskScripts\PROD.publishsettings'
$LogFilePathDateTime = Get-Date -format yyyyMMddHHmm
$LogFilePath = "C:\Temp\" + $LogFilePathDateTime + "-disenza-EastToCentral-" + $VMToMove + ".log"
$XMLExportPath = "C:\Temp\" + $VMToMove + ".xml"

#Start a log file
#----------------

$DateTimeForFirstLogEntry = Get-Date
$WriteToLog = "`r" + $DateTimeForFirstLogEntry + " Starting log file at " + $LogFilePath + " for disenza East to Central move of " + $VMToMove + "`n"
$WriteToLog | Out-File -FilePath $LogFilePath -Append

#Logging Function
#----------------

Function WriteToLog($StringToLog,$StringToLogColor) {
	if ($StringToLogColor -eq $null) {
	$StringToLogColor = "White"
	}
	$WriteToLogDateTime = Get-Date
	Write-Host $WriteToLogDateTime $StringToLog -ForegroundColor $StringToLogColor
	$LogFileStringToLog = "`r" + $WriteToLogDateTime + " - " + $StringToLog + "`n"
	$LogFileStringToLog | Out-File $LogFilePath -Append
}

#Write out the basics to the log
#-------------------------------

WriteToLog "The server requested at the command line to be moved is $VMToMove"
WriteToLog "The storage account the server will be moved to is $NewStorageAccount"
WriteToLog "The cloud service the server will be moved to is $CentralCloudService"

#Import the publishsettings file to connect to the subscriptions
#---------------------------------------------------------------

#WriteToLog "Importing the publishsettings file..."

#Import-AzurePublishSettingsFile $PublishSettingsFilePath

#Get the storage account key for the new Central storage account and set the context
#-----------------------------------------------------------------------------------

Select-AzureSubscription $CentralSubscription

WriteToLog "Selecting the Central subscription of $CentralSubscription and getting the storage account key for the new storage account of $NewStorageAccount ..."

$NewStorageAccountKey = (Get-AzureStorageKey -StorageAccountName $NewStorageAccount).Secondary
$CentralContext = New-AzureStorageContext -StorageAccountName $NewStorageAccount -StorageAccountKey $NewStorageAccountKey

#Set and select the current East subscription
#--------------------------------------------

WriteToLog "Selecting the current East subscription of $EastSubscription ..."

Select-AzureSubscription $EastSubscription

#Get the VM and set related variables
#------------------------------------

$Server = Get-AzureVM | where {$_.Name -eq "$VMToMove"}

#Get the OS disk to set the current East storage account
#---------------------------------------------------------

$OSDisk = $Server | Get-AzureOSDisk
$OSDiskStorageAccountFQDN = $OSDisk.MediaLink.DnsSafeHost.Split(".")
$OSDiskStorageAccount = $OSDiskStorageAccountFQDN[0]
$OSDiskAbsolutePath = $OSDisk.MediaLink.AbsolutePath

WriteToLog "The current East storage account is $OSDiskStorageAccount ..."

#Set the current East storage account for the East subscription
#--------------------------------------------------------------

$EastStorageAccount = $OSDiskStorageAccount

WriteToLog "Setting the CurrentStorageAccount of $EastStorageAccount on the East Subscription of $EastSubscription and then selecting the East Subscription..."

Set-AzureSubscription -SubscriptionName $EastSubscription -currentstorageaccount $EastStorageAccount
Select-AzureSubscription $EastSubscription

WriteToLog "Getting the Storage Account Key for the East Storage Account of $EastStorageAccount ..."

$EastStorageAccountKey = (Get-AzureStorageKey -StorageAccountName $EastStorageAccount).Secondary
$EastContext = New-AzureStorageContext -StorageAccountName $EastStorageAccount -StorageAccountKey $EastStorageAccountKey

#Set various other variables
#---------------------------

WriteToLog "Setting various other variables..."

$OSBlobName = $OSDisk.MediaLink.Segments[-1]
$DataDisksToMove = $Server | Get-AzureDataDisk | Where-Object {$_.MediaLink.DnsSafeHost -like "*lrs.blob*"}


#Everything from here on out is in the Central subscription so we'll select it
#-----------------------------------------------------------------------------

WriteToLog "Selecting the Central subscription of $CentralSubscription ..."
Select-AzureSubscription $CentralSubscription

#Read in the disk names from the xml export file and set variables
#-----------------------------------------------------------------

WriteToLog "Working with the export XML file at $XMLExportPath to prepare for import of the VM into Central..."

[xml]$VMExportXML = Get-Content $XMLExportPath
$OSDiskName = $VMExportXML.PersistentVM.OSVirtualHardDisk.DiskName
$EastSubnet = $VMExportXML.PersistentVM.ConfigurationSets.ConfigurationSet.SubnetNames.String

#Get a new static DIP in Central
#-------------------------------

$vnet = 'VN-disenza-CentralUS' 
$subnet = $EastSubnet

#GetStaticDIP Function
Function GetStaticDIP {
	
Switch ($subnet) {
	ACTIVEDIRECTORY {$TestIP = "30.50.2.3"}
    FIREWALL {$TestIP = "30.50.3.3"}	
    ADMIN {$TestIP = "30.50.4.3"}
	SFTP {$TestIP = "30.50.5.3"}
	WEB {$TestIP = "30.50.20.3"}
	SQL {$TestIP = "30.50.30.3"}
	UTILITY {$TestIP = "30.50.40.3"}
	FILE {$TestIP = "30.50.6.3"}    
	}

	Write-Host The detected IP address to test based on the subnet of $subnet is $TestIP
	
#Assigned Static DIP
	
$availipaddy = Test-AzureStaticVNetIP -VNetName $vnet -IPAddress $TestIP
$script:ipaddy = $availipaddy.AvailableAddresses[0]

Write-Host "Next VM will get a static DIP of" $ipaddy
}

#Run the static DIP function to get a static DIP

GetStaticDIP

#Edit the export xml file with the new static DIP in Central
#-----------------------------------------------------------

$XMLImportPath = "C:\Temp\" + $VMToMove + "-Import" + ".xml"
$VMExportXML.PersistentVM.ConfigurationSets.ConfigurationSet.StaticVirtualNetworkIPAddress = $ipaddy
$VMExportXML.Save($XMLImportPath)

#Create VM disks in the Central subscription
#-------------------------------------------

$OSDiskVHDPath = "https://" + $NewStorageAccount + ".blob.core.windows.net" + $OSDiskAbsolutePath

If ($VMOS -eq "Linux") {

	Add-AzureDisk -DiskName $OSDiskName -MediaLocation $OSDiskVHDPath -Label $OSDiskName -OS Linux
}

Else {

	Add-AzureDisk -DiskName $OSDiskName -MediaLocation $OSDiskVHDPath -Label $OSDiskName -OS Windows
}

WriteToLog "Created a VM disk object in Central for $OSDiskName using the VHD at $OSDiskVHDPath"

If ($DataDisksToMove -ne $null) {
	ForEach ( $DataDisk in $DataDisksToMove ) {
	$DataDiskVHDPath = "https://" + $NewStorageAccount + ".blob.core.windows.net" + $DataDisk.MediaLink.AbsolutePath
	Add-AzureDisk -DiskName $DataDisk.DiskName -MediaLocation $DataDiskVHDPath -Label $DataDisk.DiskName
	WriteToLog "Created a VM disk object in Central for $DataDisk.DiskName using the VHD at $DataDiskVHDPath"
	}
}

#Import the VM into Central
#--------------------------

WriteToLog "Importing the VM of $VMToMove into the Central subscription of $CentralSubscription ..."

If ([string]::IsNullOrWhiteSpace($CloudServiceReservedIPName)) {
	
	Import-AzureVM -Path $XMLImportPath | New-AzureVM -ServiceName $CentralCloudService -AffinityGroup AG-disenza-CentralUS -VNetName $vnet -ErrorAction Inquire
}

Else {

	Import-AzureVM -Path $XMLImportPath | New-AzureVM -ServiceName $CentralCloudService -AffinityGroup AG-disenza-CentralUS -VNetName $vnet -ReservedIPName $CloudServiceReservedIPName -ErrorAction Inquire
}

#Deal with errors
#----------------

If ($error.Count -eq 0) {
	WriteToLog "There were no errors so it appears the move was successful.  Please validate and then delete the VM from the East subscription."
}
	
Else {
	WriteToLog "The following errors occurreE: "
	ForEach ($errorinst in $error) {
	WriteToLog $errorinst
	}
}

