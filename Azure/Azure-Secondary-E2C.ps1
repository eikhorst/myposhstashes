﻿#Parameters from command line
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
$ImpOnly = $true
#Alter the command line input to avoid issues
#--------------------------------6is;v*

$NewStorageAccount = $CentralStorageAccount.ToLower()

#Set primary variables that do not change
#----------------------------------------

$EastSubscription = 'B_primFork-5755'
$CentralSubscription = 'B_disenza-CentralUS-prim5755'
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
if($ImpOnly -eq $false){
#Stop Deallocate the Server in the current East subscription
#-----------------------------------------------------------

WriteToLog "Stop Deallocating $VMToMove in $EastSubscription ..."

$Server | Stop-AzureVM

#Get an export of the VM's config so it can be imported later
#------------------------------------------------------------

$Server | Export-AzureVM -Path $XMLExportPath

#Now copy the VHD blobs for the VM from East to Central
#------------------------------------------------------
}
$CentralCopyDateTimeLog = Get-Date
WriteToLog "$CentralCopyDateTimeLog - Scheduling the copies of the VHDs for $VMToMove from East storage account of $EastStorageAccount to Central storage account of $NewStorageAccount ..."

WriteToLog "Scheduling copy of $OSBlobName ..."
$CentralCopyOSBlob = Start-AzureStorageBlobCopy -SrcBlob $OSBlobName -SrcContainer vhds -Context $EastContext -DestContainer vhds -DestBlob $OSBlobName -DestContext $CentralContext -Force -ErrorAction Inquire

if ($DataDisksToMove -ne $null) {
	ForEach ( $DataDisk in $DataDisksToMove ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	WriteToLog "Scheduling copy of $DataDiskBlobName from $EastStorageAccount to $CentralStorageAccount ..."
	$CentralCopyDataBlob = Start-AzureStorageBlobCopy -SrcBlob $DataDiskBlobName -SrcContainer vhds -Context $EastContext -DestContainer vhds -DestBlob $DataDiskBlobName -DestContext $CentralContext -Force -ErrorAction Inquire
	}
}
if($ImpOnly -eq $false){
#Don't do anything else until the copies are complete and then log the status
#----------------------------------------------------------------------------

$CentralCopyStatusOSBlob = $CentralCopyOSBlob | Get-AzureStorageBlobCopyState -WaitForComplete

$CentralCopyCompletionTimeOSBlobForLog = $CentralCopyStatusOSBlob.CompletionTime.ToLocalTime()
$CentralCopyStatusOSBlobForLog = $CentralCopyStatusOSBlob.Status
WriteToLog "$CentralCopyCompletionTimeOSBlobForLog - $OSBlobName copy status is $CentralCopyStatusOSBlobForLog"

if ($DataDisksToMove -ne $null) {
	ForEach ( $DataDisk in $DataDisksToMove ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	$CentralCopyStatusDataBlob = Get-AzureStorageBlobCopyState -Container vhds -Blob $DataDiskBlobName -Context $CentralContext -WaitForComplete
	$CentralCopyCompletionTimeOSBlobForLog = $CentralCopyStatusDataBlob.CompletionTime.ToLocalTime()
	$CentralCopyStatusOSBlobForLog = $CentralCopyStatusDataBlob.Status
	WriteToLog "$CentralCopyCompletionTimeOSBlobForLog - $DataDiskBlobName copy status is $CentralCopyStatusOSBlobForLog"
	}
}

WriteToLog "East to Central VHD copies for $VMToMove are complete!"
}
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

if($ImpOnly -eq $false){
#GetStaticDIP Function
Function GetStaticDIP {
	
Switch ($subnet) {
	ACTIVEDIRECTORY {$TestIP = "10.40.2.3"}
    FIREWALL {$TestIP = "10.40.3.3"}	
    ADMIN {$TestIP = "10.40.4.3"}
	SFTP {$TestIP = "10.40.5.3"}
	WEB {$TestIP = "10.40.20.3"}
	SQL {$TestIP = "10.40.30.3"}
	UTILITY {$TestIP = "10.40.40.3"}
	FILE {$TestIP = "10.40.6.3"}
    
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
}
#Import the VM into Central
#--------------------------

WriteToLog "Importing the VM of $VMToMove into the Central subscription of $CentralSubscription ..."
WriteToLog "xmlimpot path is $XMLImportPath ..."
Set-AzureSubscription $CentralSubscription -CurrentStorageAccountName bdsatu3lrs
Select-AzureSubscription $CentralSubscription 
$XMLImportPath = "C:\temp\primpasm-02-Import.xml"
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

