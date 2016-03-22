#==============================================
# Automated SQL Restore of multiple Databases
#==============================================

#clear screen
cls

# load assemblies
[Reflection.Assembly]::Load("Microsoft.SqlServer.Smo, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91") | Out-Null
[Reflection.Assembly]::Load("Microsoft.SqlServer.SqlEnum, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91") | Out-Null
[Reflection.Assembly]::Load("Microsoft.SqlServer.SmoEnum, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91") | Out-Null
[Reflection.Assembly]::Load("Microsoft.SqlServer.ConnectionInfo, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91") | Out-Null
	 
# Some general parameters for restoring into the destination SQL instance

$instance = "SQLServer"
$mdfFilePath = "Path-To-DB-Files"
$ldfFilePath = "Path-To-stanlog_Files"
$ftsFilePath = "Path-To-FullTextSearch-Files"

# This will recursively look for the appropriate .bak files on the cifs share
# where the backups are located.

$filelist = Get-ChildItem \\Path-to-SQL-backups -Recurse | Where-Object {$_.extension -eq ".bak"}

# Start Do While Loop on the $filelist array. Loop will go over each backup file name on the array until the count reaches the value on
# the $filelist.SyncRoot.Count object.

$a = 0

Do {
	# Select database backup filename from the $filelist array and store it as a string
	$restorefile = $filelist.SyncRoot.Get($a) | %{$_.FullName}
	# Print variable for testing
	$restorefile
	
	# Set parameters for restore
	
	# We will query the database name from the backup header later
	$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $instance
	$backupDevice = New-Object("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($restorefile, "File")
	$smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")
	
	#restore settings
	$smoRestore.NoRecovery = $false;
	$smoRestore.ReplaceDatabase = $true;
	$smoRestore.Action = "Database"
	$smoRestore.PercentCompleteNotification = 10;
	$smoRestore.Devices.Add($backupDevice)
	
	#get database name from backup file
	$smoRestoreDetails = $smoRestore.ReadBackupHeader($server)
	
	#Get Database info prior to restore
	"Database Name from Backup Header : " +$smoRestoreDetails.Rows[0]["DatabaseName"]

	# Get Database Logical File Names
	$sourceLogicalNameDT = $smoRestore.ReadFileList($server)

	$FileType = ""
	foreach($Row in $sourceLogicalNameDT) {
		# Put the file type into a local variable.
		# This will be the variable that we use to find out which file
		# we are working with.
		$FileType = $Row["Type"].ToUpper()
	
		# If Type = "D", then we are handling the Database File name.
		If ($FileType.Equals("D")) {
			$sourceDBLogicalName = $Row["LogicalName"]
		}
		# If Type = "L", then we are handling the Log File name.
		elseif ($FileType.Equals("L")) {
			$sourceLogLogicalName = $Row["LogicalName"]		
		}
		# If Type = "F", then we are handling the Full Text Search File name.
		elseif ($FileType.Equals("F")) {
			$sourceFTSLogicalName = $Row["LogicalName"]
   # I also want to grab the full path of the Full Text catalog store in the backup file.
   # I'll need this so I can change the destination path.
			$sourceFTSPhysicalName = $Row["PhysicalName"]
		}
	}

	# Output Values of Database Logical File Names

	"DB Logical Name: " + $sourceDBLogicalName
	"Log Logical Name: " + $sourceLogLogicalName
	"Full Text Catalog Logical Name: " + $sourceFTSLogicalName

	#give a new database name
	$smoRestore.Database =$smoRestoreDetails.Rows[0]["DatabaseName"]

	#specify new data and log files (mdf and ldf)
	$smoRestoreDBFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	$smoRestoreLogFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
		
	#the logical file names should be the logical filename stored in the backup media
	#$smoRestoreFile.LogicalFileName = $datafilename
	
	$smoRestoreDBFile.LogicalFileName = $sourceDBLogicalName
	$smoRestoreDBFile.PhysicalFileName = $mdfFilePath + "\" + $sourceDBLogicalName + ".mdf"
	$smoRestoreLogFile.LogicalFileName = $sourceLogLogicalName
	$smoRestoreLogFile.PhysicalFileName = $ldfFilePath + "\" + $sourceLogLogicalName + ".ldf"
	
	$smoRestore.RelocateFiles.Add($smoRestoreDBFile)
	$smoRestore.RelocateFiles.Add($smoRestoreLogFile)

	# Check to see if the $SourceFTSLogicalName is empty or not. If its not empty
 # then we do have a full text catalog present and thus we add the appropriate
 # entries to restore those files. If the variable is empty we just continue with
 # the restore.
 
	[String]::IsNullOrEmpty($sourceFTSLogicalName)

	if ([String]::IsNullOrEmpty($sourceFTSLogicalName)) {
	"We DO NOT have a full Text Catalog in our Backup"
	}
	else {
	"We DO have a Full Text Catalog in our Backup"
	# Adding full text catalog restore parameters.
	$smoRestoreFTSFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	$smoRestoreFTSFile.LogicalFileName = $sourceFTSLogicalName
 
	# Here I specify the new location by truncating the first 45 characters in the path
 # that is specified on the backup file. This leaves me with just the name of the folder
 # where the full text catalog is, which I'm appending to the new path defined in
 # $ftsFilePath
 $smoRestoreFTSFile.PhysicalFileName = $ftsFilePath + "\" + $sourceFTSPhysicalName.Substring(45)
	$smoRestore.RelocateFiles.Add($smoRestoreFTSFile)
	}
	
	# Begin restoring database
	$smoRestore.SqlRestore($server)
	
	if ($error.Count -eq 0) {
	"Restore of Database " + "[" +$smoRestoreDetails.Rows[0]["DatabaseName"] + "]" + " is complete"
	}	
	else {
	"Restore of Database " + "[" +$smoRestoreDetails.Rows[0]["DatabaseName"] + "]" + " failed!!!"
	$Error[0].exception.message
	}


 # This tells the loop to keep incrementing the value stored on $a
	$a++
 
 # We now clear the variables before the next loop starts
 
	Remove-Variable sourceDBLogicalName
	Remove-Variable sourceLogLogicalName
	Remove-Variable smoRestoreDBFile
	Remove-Variable smoRestoreLogFile

 # If a full text catalog was present, we clear those variables too
 
	if ([String]::IsNullOrEmpty($sourceFTSLogicalName)) {
	"Continue to next restore "
	}
	else {
	"Continue to next restore"
	Remove-Variable sourceFTSLogicalName
	Remove-Variable smoRestoreFTSFile
	}

}

# It will keep incrementing the count value UNTIL it matches the value on the object $backups.SyncRoot.Count
Until ($a -eq $filelist.SyncRoot.Count)


#	$error[0]|formprimlist –force