#Parameters from command line
#----------------------------

[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=1)]
[string]$Pet
)

#Set preferences
#---------------

$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Continue'

#Parse out the command line input
#--------------------------------

$BackThisUp = $Pet.ToUpper()
$BackThisUpArray = $BackThisUp.Split("-")
$BackThisUpArrayCount = $BackThisUpArray.Count

if ($BackThisUpArrayCount -lt 4) {
	$ThisIsPartOfABasket = "False"
}

else {
	$ThisIsPartOfABasket = "True"
}

#Set primary variables that may change per pet
#---------------------------------------------

$DSEEnvironmentLabel = $BackThisUpArray[0]

if ($ThisIsPartOfABasket -eq "True") {
	$DSEBasket = $BackThisUpArray[1]
	$DSEArray = $BackThisUpArray[2]
	$ServerNamePrefix = $DSEEnvironmentLabel + "-" + $DSEBasket + "-" + $DSEArray
	$LogFileName = $ServerNamePrefix
}

else {
	$DSEArray = $BackThisUpArray[1]
	$ServerNamePrefix = $DSEEnvironmentLabel + "-" + $DSEArray
	$LogFileName = $BackThisUp
}

Switch ($DSEEnvironmentLabel) {
	AP {$DSEEnvironment = 'disenza'
		$Location = 'CentralUS'
		$DREnvironmentLabel = 'BP'}
	BP {$DSEEnvironment = 'disenza'
		$Location = 'EastUS2'}
	AT {$DSEEnvironment = 'disenza'
		$Location = 'CentralUS'
		$DREnvironmentLabel = 'BT'}
	BT {$DSEEnvironment = 'disenza'
		$Location = 'EastUS2'}
}

#Set primary variables that do not change
#----------------------------------------

$LiveSubscription = "B_" + $DSEEnvironment + "-" + $Location + "-" + $DSEEnvironmentLabel + "-5755"
$RAGRSStorageSubscription = "B_" + $DSEEnvironment + "-" + $Location + "-STOR-5755"
$PublishSettingsFilePath = 'C:\Admin\TaskScripts\PROD.publishsettings'
$LogFilePathDateTime = Get-Date -format yyyyMMddHHmm
$LogFilePath = "C:\Admin\Logs\" + $LogFileName + "-" + "DSEPetBackup" + $LogFilePathDateTime + ".log"
$LiveContainer = 'vhds'
$TempBackupContainer = 'tempbackups'
$RAGRSContainer = 'vhdbackups'

#Start a log file
#----------------

$DateTimeForFirstLogEntry = Get-Date
$WriteToLog = "`r" + $DateTimeForFirstLogEntry + " Starting log file at " + $LogFilePath + " for pet backup of " + $LogFileName + "`n"
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

WriteToLog "The server requested at the command line to be backed up is $BackThisUp"
WriteToLog "The server is a part of the $DSEEnvironmentLabel environment."

if ($ThisIsPartOfABasket -eq "True") {
	WriteToLog "The server is part of the basket $DSEBasket"
}

else {
	WriteToLog "The server is not part of a basket."
}

WriteToLog "The server has an array of $DSEArray"
WriteToLog "The Live Subscription is $LiveSubscription"
WriteToLog "The RAGRS Subscription is $RAGRSStorageSubscription"
WriteToLog "The RAGRS storage account is $RAGRSStorageAccount"
WriteToLog "The server name prefix is $ServerNamePrefix"


#Import the publishsettings file to connect to the subscriptions
#---------------------------------------------------------------

WriteToLog "Importing the publishsettings file..."

Import-AzurePublishSettingsFile $PublishSettingsFilePath

#Select the live subscription
#------------------------------------

WriteToLog "Selecting the live subscription of $LiveSubscription ..."

Select-AzureSubscription $LiveSubscription

#Variables for event logging
#---------------------------

$LogErrorMessage = "The Azure Copy Blob backup of the VHD files for " + $LogFileName + " had errors.  Please check the detailed log file at " + $LogFilePath + "."
$LogSuccessMessage = "The Azure Copy Blob backup of the VHD files for " + $LogFileName + " was successful."

#Determine if we are backing up a SQL server
#-------------------------------------------

if ($DSEArray -ne "SQL") {
	WriteToLog "This is not a SQL server.  Continuing without determining the mirror..."
}

else {
	WriteToLog "This is a SQL server..."

#Determine which SQL server in the cell is the mirror so we don't shutdown the principle
#---------------------------------------------------------------------------------------

WriteToLog "Determining which SQL server is the mirror..."

[string]$partner1 = $ServerNamePrefix + "-01"

If ($partner1.EndsWith("-01")){
    $partner2 = $partner1.Replace("-01", "-02")
    $witness = $partner1.Replace("-01", "-WI")
}
ElseIf ($partner1.EndsWith("-02")){
    $partner2 = $partner1.Replace("-02", "-01")
    $witness = $partner1.Replace("-02", "-WI")
}
Else{
    throw "Server name does not end in ""-01"" or ""-02""."
}

"Partner1 is: {0}" -f $partner1
"Partner2 is: {0}" -f $partner2
"Witness is: {0}" -f $witness

$connectionString = “Server=$partner1;Database=Master;Integrated Security=True;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

#Get the list of DBs that need to have DB Mirroring setup
$query = @“
/*
The purpose of this script is to determine if the server is the secondary or not.
In other words, we check to see if all the databases that are configured for mirroring are a mirror.
(In our environment, all DBs that are configured for mirroring should either all be a mirror, or all be a principle.)
*/
set nocount on

declare @total int, @mirror int, @principle int, @tot int, @curr int, @cmd varchar(5000), @jobname varchar (500)
create table #jobs (rowid int identity(1,1), name varchar(500))

--Get total number of DBs that are configured for DB mirroring
select @total = count(*)
from sys.database_mirroring 
where mirroring_guid IS NOT NULL

--Get number of 'mirror' DBs
select @mirror = count(*)
from sys.database_mirroring 
where mirroring_guid IS NOT NULL and mirroring_role_desc = 'MIRROR'

--Get number of 'princple' DBs
select @principle = count(*)
from sys.database_mirroring 
where mirroring_guid IS NOT NULL and mirroring_role_desc = 'PRINCIPAL'

if @total = @mirror
begin
	select 'M' [result]
end
else if @total = @principle
begin
	select 'P' [result]
end
else
begin
	select 'ERR' [result]
end

drop table #jobs

"@

$SQLMirror = $null
$sqlcmd = New-Object System.Data.SqlClient.SqlCommand($query,$connection)
$reader = $sqlcmd.ExecuteReader()

While($reader.Read()) {
    $result = $reader["result"].ToString()

    if ($result -eq "P"){
        "{0} is the primary/principle" -f $partner1
        "...and this means {0} must be the secondary/mirror" -f $partner2
		$SQLMirror = $partner2
		WriteToLog "$SQLMirror is the current mirror and will be backed up."
    }
    elseif ($result -eq "M"){
        "{0} is the secondary/mirror" -f $partner1
        "...and this means {0} must be the primary/principle" -f $partner2
		$SQLMirror = $partner1
		WriteToLog "$SQLMirror is the current mirror and will be backed up."
    }
    else{
        "It seems we do not have a clear secondary/mirror"
		$SQLMirror = $null
		WriteToLog "Unable to determine the mirror so the backup job will error now and should exit..."
    }
}

$connection.Close()

#Exit the script if we were not able to successfully determine the mirror
#------------------------------------------------------------------------

$SQLMirrorCheck1 = $ServerNamePrefix + "-01"
$SQLMirrorCheck2 = $ServerNamePrefix + "-02"

if ($SQLMirror -eq "$SQLMirrorCheck1") {
	WriteToLog "The mirror is $SQLMirror and has been checked."
	}
elseif ($SQLMirror -eq "$SQLMirrorCheck2") {
	WriteToLog "The mirror is $SQLMirror and has been checked."	
	}
else {
	WriteToLog "Failed to determine the mirror.  Writing an error to the Application Log and exiting..."
	Write-EventLog -LogName 'Application' -Source 'Disenza Inc. Custom' -EventId '5' -EntryType 'Error' -Message $LogErrorMessage
	exit 1
}
}

#Set the server to backup
#------------------------

if ($DSEBasket -eq "SCHED") {
	$ServerToBackup = $BackThisUp
}

else {

Switch ($DSEArray) {
	SQL {$ServerToBackup = $SQLMirror}
	FIL {$ServerToBackup = $ServerNamePrefix + "-01"}
	DEPLOY {$ServerToBackup = $BackThisUp}
	OCTO {$ServerToBackup = $BackThisUp}
	SFTP {$ServerToBackup = $BackThisUp}
	helix {$ServerToBackup = $BackThisUp}
	UWORD {$ServerToBackup = $ServerNamePrefix + "-01"}
	ZDS {$ServerToBackup = $ServerNamePrefix + "-01"}
	FOGLIGHT {$ServerToBackup = $BackThisUp}
	PASM {$ServerToBackup = $BackThisUp}
	UTILSQL {$ServerToBackup = $BackThisUp}
}
}

if ($ServerToBackup -eq $null) {
	WriteToLog "Unable to determine or validate the server that should be backed up so this script will exit now and write an error to the Application Event Log..."
	Write-EventLog -LogName 'Application' -Source 'Disenza Inc. Custom' -EventId '5' -EntryType 'Error' -Message $LogErrorMessage
	exit 1
}

else {
	WriteToLog "The server that will be backed up is $ServerToBackup ..."
}

#Get the VM and set related variable
#-----------------------------------

$Server = Get-AzureVM | where {$_.Name -eq "$ServerToBackup"}

#Get the OS disk to set the current "live" storage account
#---------------------------------------------------------

$OSDisk = $Server | Get-AzureOSDisk
$OSDiskStorageAccountFQDN = $OSDisk.MediaLink.DnsSafeHost.Split(".")
$OSDiskStorageAccount = $OSDiskStorageAccountFQDN[0]

WriteToLog "The live storage account is $OSDiskStorageAccount ..."

#Set the current storage account for the live subscription
#---------------------------------------------------------

$LiveStorageAccount = $OSDiskStorageAccount

#Use the live storage account to determine the RAGRS storage account
#-------------------------------------------------------------------

WriteToLog "Using the Live Storage Account to determine the RAGRS Storage Account..."

$RAGRSStorageAccountPrefix = "bds" + $DSEEnvironmentLabel.ToLower()
$RAGRSStorageAccountSuffixSub = $OSDiskStorageAccount.Substring(5)
$RAGRSStorageAccountSuffix = $RAGRSStorageAccountSuffixSub.Replace("lrs", "ragrs")
$RAGRSStorageAccount = $RAGRSStorageAccountPrefix + $RAGRSStorageAccountSuffix

WriteToLog "The RAGRS Storage Account is $RAGRSStorageAccount"

#Get the storage account key for the RAGRS storage account
#---------------------------------------------------------

Select-AzureSubscription $RAGRSStorageSubscription

WriteToLog "Selecting the RAGRS subscription of $RAGRSStorageSubscription and getting the storage account key for the RAGRS storage account of $RAGRSStorageAccount ..."

$RAGRSStorageAccountKey = (Get-AzureStorageKey -StorageAccountName $RAGRSStorageAccount).Secondary

#Get the storage account key for the live storage account
#--------------------------------------------------------

WriteToLog "Setting the CurrentStorageAccount of $LiveStorageAccount on the Live Subscription of $LiveSubscription and then selecting the Live Subscription..."

Set-AzureSubscription -SubscriptionName $LiveSubscription -Currentstorageaccount $LiveStorageAccount
Select-AzureSubscription $LiveSubscription

WriteToLog "Getting the Storage Account Key for the Live Storage Account of $LiveStorageAccount ..."

$LiveStorageAccountKey = (Get-AzureStorageKey -StorageAccountName $LiveStorageAccount).Secondary
$LiveContext = New-AzureStorageContext -StorageAccountName $LiveStorageAccount -StorageAccountKey $LiveStorageAccountKey

#Set various other variables
#---------------------------

WriteToLog "Setting various other variables..."

$OSBlobName = $OSDisk.MediaLink.Segments[-1]
$DataDisksToBackup = $Server | Get-AzureDataDisk | Where-Object {$_.MediaLink.DnsSafeHost -like "*lrs.blob*"}
$RAGRSContext = New-AzureStorageContext -StorageAccountName $RAGRSStorageAccount -StorageAccountKey $RAGRSStorageAccountKey
$DateTimeForRAGRSOSBlob = Get-Date -Format yyyyMMddHHmm
$RAGRSOSBlobName = $DateTimeForRAGRSOSBlob + "\" + $OSBlobName
$PurgeDate = [DateTime]::Now.AddDays(-3)
$PurgeNameFilter = $ServerNamePrefix
$BlobsToPurge = Get-AzureStorageBlob -Container $RAGRSContainer -Context $RAGRSContext | Where-Object {$_.LastModified.ToLocalTime() -lt $PurgeDate -and $_.BlobType -eq "PageBlob" -and $_.Name -like "*$PurgeNameFilter*"}

#Shutdown the Server to get a clean copy of the VHDs
#---------------------------------------------------

WriteToLog "Shutting down the OS on $ServerToBackup ..."

$Server | Stop-AzureVM -StayProvisioned

#Copy the blobs to a temporary container within the same subscription
#--------------------------------------------------------------------

WriteToLog "Scheduling copy of blobs to temporary container - the fast copy..."

$TempCopyDateTimeLog = Get-Date

WriteToLog "Scheduling copy of $OSBlobName ..."

$TempCopyOSBlob = Start-AzureStorageBlobCopy -SrcBlob $OSBlobName -SrcContainer $LiveContainer -DestContainer $TempBackupContainer -force

ForEach ( $DataDisk in $DataDisksToBackup ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	WriteToLog "Scheduling copy of $DataDiskBlobName ..."
	$TempCopyDataBlob = Start-AzureStorageBlobCopy -SrcBlob $DataDiskBlobName -SrcContainer $LiveContainer -DestContainer $TempBackupContainer -force
}

#Don't do anything else until the copies are complete and then log copy status
#-----------------------------------------------------------------------------

WriteToLog "Waiting for the temporary copies to complete..."

$TempCopyStatusOSBlob = $TempCopyOSBlob | Get-AzureStorageBlobCopyState -WaitForComplete

$TempCopyOSBlobCompletionTimeForLog = $TempCopyStatusOSBlob.CompletionTime.ToLocalTime()
$TempCopyOSBlobStatusForLog = $TempCopyStatusOSBlob.Status
WriteToLog "$TempCopyOSBlobCompletionTimeForLog - $OSBlobName copy status is $TempCopyOSBlobStatusForLog ..."

ForEach ( $DataDisk in $DataDisksToBackup ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	$TempCopyStatusDataBlob = Get-AzureStorageBlobCopyState -Container $TempBackupContainer -Blob $DataDiskBlobName -WaitForComplete
	$TempCopyDataBlobCompletionTimeForLog = $TempCopyStatusDataBlob.CompletionTime.ToLocalTime()
	$TempCopyDataBlobStatusForLog = $TempCopyStatusDataBlob.Status
	WriteToLog "$TempCopyDataBlobCompletionTimeForLog - $DataDiskBlobName copy status is $TempCopyDataBlobStatusForLog ..."
}

WriteToLog "Temporary copies are complete!"

#Initial copies are complete, now safely Start the Server
#--------------------------------------------------------

WriteToLog "Booting $ServerToBackup back up..."

$Server | Start-AzureVM

#Now copy the blobs from the temp copies to the RA GRS storage account
#---------------------------------------------------------------------

WriteToLog "Scheduling the blob copies to RAGRS..."

$RAGRSCopyDateTimeLog = Get-Date

WriteToLog "$RAGRSCopyDateTimeLog - Scheduling copy of blobs from temp container to the RA GRS storage account..." 

WriteToLog "Scheduling copy of $RAGRSOSBlobName ..."
$RAGRSCopyOSBlob = Start-AzureStorageBlobCopy -SrcBlob $OSBlobName -SrcContainer $TempBackupContainer -Context $LiveContext -DestContainer $RAGRSContainer -DestBlob $RAGRSOSBlobName -DestContext $RAGRSContext

$DateTimeForRAGRSDataBlobName = Get-Date -Format yyyyMMddHHmm

ForEach ( $DataDisk in $DataDisksToBackup ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	$RAGRSDataDiskBlobName = $DateTimeForRAGRSDataBlobName + "\" + $DataDiskBlobName
	WriteToLog "Scheduling copy of $RAGRSDataDiskBlobName ..."
	$RAGRSCopyDataBlob = Start-AzureStorageBlobCopy -SrcBlob $DataDiskBlobName -SrcContainer $TempBackupContainer -Context $LiveContext -DestContainer $RAGRSContainer -DestBlob $RAGRSDataDiskBlobName -DestContext $RAGRSContext
}

#Don't do anything else until the copies are complete and then log the status
#----------------------------------------------------------------------------

$RAGRSCopyStatusOSBlob = $RAGRSCopyOSBlob | Get-AzureStorageBlobCopyState -WaitForComplete

$RAGRSCopyCompletionTimeOSBlobForLog = $RAGRSCopyStatusOSBlob.CompletionTime.ToLocalTime()
$RAGRSCopyStatusOSBlobForLog = $RAGRSCopyStatusOSBlob.Status
WriteToLog "$RAGRSCopyCompletionTimeOSBlobForLog - $RAGRSOSBlobName copy status is $RAGRSCopyStatusOSBlobForLog"

ForEach ( $DataDisk in $DataDisksToBackup ) {
	$DataDiskBlobName = $DataDisk.MediaLink.Segments[-1]
	$RAGRSDataDiskBlobName = $DateTimeForRAGRSDataBlobName + "\" + $DataDiskBlobName
	$RAGRSCopyStatusDataBlob = Get-AzureStorageBlobCopyState -Container $RAGRSContainer -Blob $RAGRSDataDiskBlobName -Context $RAGRSContext -WaitForComplete
	$RAGRSCopyCompletionTimeOSBlobForLog = $RAGRSCopyStatusDataBlob.CompletionTime.ToLocalTime()
	$RAGRSCopyStatusOSBlobForLog = $RAGRSCopyStatusDataBlob.Status
	WriteToLog "$RAGRSCopyCompletionTimeOSBlobForLog - $RAGRSDataDiskBlobName copy status is $RAGRSCopyStatusOSBlobForLog"
}

WriteToLog "RAGRS copies are complete!"

#Purge backups older than 7 days from the GRS RA storage account as long as there were no errors
#-----------------------------------------------------------------------------------------------

If ($error.Count -eq 0) {

WriteToLog "Looking for backups to purge that are older than $PurgeDate ..."

	If ($BlobsToPurge -ne $null) {
	
	WriteToLog "Purging blobs older than $PurgeDate ... "

	$BlobsToPurge | Remove-AzureStorageBlob
	}
	
	Else {
	
	WriteToLog "No blobs found to purge."
	}
}
	
Else {

WriteToLog "Errors occurred so purging of old backups will be skipped to be on the safe side."

#Write any errors to the log
#---------------------------

WriteToLog "The following errors occurreE: "
WriteToLog $error

}

#Write the results to the event log
#----------------------------------

WriteToLog "Writing the results of this backup to the Application Event Log..."

If ($error.Count -ne 0) {

Write-EventLog -LogName 'Application' -Source 'Disenza Inc. Custom' -EventId '5' -EntryType 'Error' -Message $LogErrorMessage
}

Else {

Write-EventLog -LogName 'Application' -Source 'Disenza Inc. Custom' -EventId '1' -EntryType 'Information' -Message $LogSuccessMessage
}