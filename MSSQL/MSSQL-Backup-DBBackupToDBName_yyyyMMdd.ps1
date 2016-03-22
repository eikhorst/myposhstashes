function BackItUp{
    param([string]$dbserver, [string]$catalog)

#### Bakup the db listed below
#$dbserver = "ctysql-a07r"
#$catalog = "aDTtest"
#####################################
#create a new server object
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $dbserver
$backupDirectory = $server.Settings.BackupDirectory
 
#display default backup directory
"Default Backup Directory: " + $backupDirectory
 
$db = $server.Databases[$catalog]
$dbName = $db.Name
 
$timestamp = Get-Date -format yyyy-MM-dd
$yesterday = ((Get-Date).AddDays(-1)).ToString("yyyy-MM-dd")
$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
$newdbname = $dbName + "_" + $timestamp + ".bak" 
$yesterdaysDB = $dbName + "_" + $yesterday + ".bak"

#BackupActionType specifies the type of backup.
#Options are Database, Files, Log
#This belongs in Microsoft.SqlServer.SmoExtended assembly
 
$smoBackup.Action = "Database"
$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
$smoBackup.BackupSetName = $dbName + " Backup"
$smoBackup.Database = $dbName
$smoBackup.MediaDescription = "Disk"
$smoBackup.Devices.AddDevice($backupDirectory + "\" + $newdbname, "File")
$smoBackup.SqlBackup($server)
 
#let's confirm, let's list  all backup files
$backupDirectory = $backupDirectory -replace(":","$")
$backupDirectory = "\\"+$dbserver+"\"+ $backupDirectory
write-host $backupDirectory 
$directory = Get-ChildItem $backupDirectory

#list only files that end in .bak, assuming this is your convention for all backup files
$backupFilesList = $directory | where {$_.extension -eq ".bak"}
$output = $backupFilesList | where { $_.Name -like $newdbname } | FormprimTable Name, LastWriteTime
Write-Output "Backup created here: " $output

$RemoveYesterdayDBbak = $backupDirectory + "\"+$yesterdaysDB
Remove-item $RemoveYesterdayDBbak
Write-output "Removed yesterday's backup: " $RemoveYesterdayDBbak

}

#BackItUp -dbserver "ctysql-a07r" -catalog "DBName"