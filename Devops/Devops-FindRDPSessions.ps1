﻿# Import the Active Directory module for the Get-ADComputer CmdLet
Import-Module ActiveDirectory

# Get today's date for the report
$today = Get-Date

# Setup email parameters
$subject = "ACTIVE SERVER SESSIONS REPORT - " + $today
$priority = "Normal"
$smtpServer = "smtp.disenza.com"
$emailFrom = "sushiju-firep@disenza.com"
$emailTo = "firep@disenza.com"

# Create a fresh variable to collect the results. You can use this to output as desired
$SessionList = "ACTIVE SERVER SESSIONS REPORT - " + $today + "`n`n"

# Query Active Directory for computers running a Server operating system
$filter = "?{$_.Name -match 'sushi'}"
$Servers = Get-ADComputer -searchbase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'bacon'}

# Loop through the list to query each server for login sessions
ForEach ($Server in $Servers) {
	$ServerName = $Server.Name

	# When running swamyly, uncomment the Write-Host line below to show which server is being queried
	Write-Host "Querying $ServerName"

	# Run the qwinsta.exe and parse the output
	$queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv) 
	
	# Pull the session information from each instance
	ForEach ($queryResult in $queryResults) {
		$RDPUser = $queryResult.USERNAME
		$sessionType = $queryResult.SESSIONNAME
		
		# We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number
		If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL)) { 
			# When running swamyly, uncomment the Write-Host line below to show the output to screen
			# Write-Host $ServerName logged in by $RDPUser on $sessionType
			$SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType
		}
	}
}

# Send the report email
Send-MailMessage -To $emailTo -Subject $subject -Body $SessionList -SmtpServer $smtpServer -From $emailFrom -Priority $priority

# When running swamyly, uncomment the Write-Host line below to see the full list on screen
#$SessionList = "Filtered for: $filter `n`n" + $SessionList
$SessionList

