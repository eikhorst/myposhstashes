$newuserscsv = "c:\git\repos\ds-scripts\o365\newusers.txt"
if(!(Test-path $newuserscsv)){$newuserscsv = "c:\git\repos\ds-scripts\o365\newusers.txt"
}
$newbies = Import-Csv $newuserscsv

#Add-RecipientPermission vintage-oncall@disenzaswamy.com -AccessRights SendAs -Trustee $_.email

foreach($newby in $newbies){
	Add-DistributionGroupMember -Identity AllEmployees -Member $newby.email

	if($newby.remote -eq "1") {
		Add-DistributionGroupMember -Identity AllEmployeesRemote -Member $newby.email
	}
	else{
		Add-DistributionGroupMember -Identity AllEmployeesChicago -Member $newby.email
	}
	## add user to ContentMangementAdmins
	if(($newby.account -eq "1") -or ($newby.strategy -eq "1")){		
		## this may not be working b/c this is a security group, possibly different cmdlet.
		write-host "Added to Content Management Admins - you will need to add the Central Auth users manually this is not scripted to add Security group members" 
		Add-DistributionGroupMember -Identity "ContentMangementAdmins" -Member $newby.email

		## "CentralAuth-Users" security group add
		##  76cbcc9b-a5b9-4f1b-bfba-2b169bcb069e
		Add-MsolGroupMember -GroupObjectId 76cbcc9b-a5b9-4f1b-bfba-2b169bcb069e -groupmembertype 'User' -groupmemberobjectid 
		Add-DistributionGroupMember -Identity CentralAuth-Users -Member $newby.email
	}
	if($newby.feds -eq "1") {
		write-host "Added to Fed Team" 
		Add-DistributionGroupMember -Identity FEDs@disenza.com -Member $newby.email
	}	
	if($newby.ladies -eq "1") {
		write-host "Added to Ladies of Disenza Inc." 
		Add-DistributionGroupMember -Identity Ladies@disenza.com -Member $newby.email
	}	
	if($newby.dev -eq "1") {
		write-host "Added to AllTechnologyGroup" 
		Add-DistributionGroupMember -Identity AllTechnologyGroup@disenza.com -Member $newby.email
	}
	if($newby.strategy -eq "1") {
		write-host "Added to Strategy" 
		Add-DistributionGroupMember -Identity Strategy@disenza.com -Member $newby.email
	}
	if($newby.creative -eq "1") {
		write-host "Added to Creative" 
		Add-DistributionGroupMember -Identity creative@disenza.com -Member $newby.email
	}		
	if($newby.Michalak -eq "1") {
		write-host "Added to Team Michalak" 
		Add-DistributionGroupMember -Identity teammichalak@disenza.com -Member $newby.email
	}
	if($newby.Fieldman -eq "1") {
		write-host "Added to Team Fieldman" 
		Add-DistributionGroupMember -Identity TeamFieldman@disenza.com -Member $newby.email
	}
	if($newby.Nelson -eq "1") {
		write-host "Added to Team Nelson" 
		Add-DistributionGroupMember -Identity team_nelson@disenza.com -Member $newby.email
	}
	if(($newby.account -eq "1") -or ($newby.addtodistributions -eq "1")) {
		if($newby.account -eq "1"){
			write-host "Added to Account People" 
			Add-DistributionGroupMember -Identity accountpeople@disenza.com -Member $newby.email		
		}
		## Loop through all CN distribution groups to add this account person to be an owner
		# now get all the account folks
		$oniaccountowners = Get-DistributionGroupMember -Identity accountpeople@disenza.com | %{$_.Name} 
		$oniaccountowners += "pamundson"; $oniaccountowners += "efrus"; $oniaccountowners += "molaughlin"		
		if($newby.account -ne "1"){
			$CNDistributionGroups = Get-DistributionGroup
		}else{
			$CNDistributionGroups = Get-DistributionGroup | ?{$_.Name -match "CN_*"} 
		}
		<#
		foreach($CNDistributionGroup in $CNDistributionGroups){			
			write-host "updating $CNDistributionGroup.Name" -f darkRed -b blue
			$addnewby = $false
			Set-DistributionGroup -identity "$($CNDistributionGroup)" -ManagedBy $oniaccountowners 			
			
			if($newby.buddy -ne "") {
				
				Get-DistributionGroupMember -identity "$($CNDistributionGroup)" | ?{$_.Name -match ($newby.buddy)} | %{$addnewby = $true}				
				if($addnewby){
					write-host "Adding " $newby.email $CNDistributionGroup.Name
					Add-DistributionGroupMember -identity "$($CNDistributionGroup)" -Member $newby.email					
				}
			}
		}
		#>
		Set-DistributionGroup -identity "support-oncall@disenza.com" -ManagedBy $oniaccountowners 
	}
}

