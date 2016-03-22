# region check removed users in distribution groups

$aliases = Import-Csv c:\git\repos\ds-scripts\o365\termusers.txt 

# $aliases = @("bkline","wcotey","mliepitz","mbehrens") # Ran 8/13/2013
# kvekaria 11/4/13

$DGs = Get-DistributionGroup
foreach($alias in $aliases){

	foreach($DG in $DGs){
		write-host $DG.Identity "looking for " $alias.upn -f darkgreen
		foreach ($member in Get-DistributionGroupMember -Identity $DG.Identity) 
		{
			write-host $member -f darkcyan
			if($member -match $alias.upn){
				write-host "removing " $member $DG.Identity
				Remove-DistributionGroupMember -Identity $DG.Identity -Member $alias.upn -Confirm:$False
			} 
		}
	}

# this sends to an external mailbox 
#	Set-Mailbox -Identity $alias.upn -DeliverToMailboxAndForward $true -ForwardingSMTPAddress $alias.fwd

	## this sends to the o365 Disenza Inc. mailbox.
	Set-Mailbox -Identity $alias.upn -DeliverToMailboxAndForward $true -ForwardingAddress $alias.fwd
}

