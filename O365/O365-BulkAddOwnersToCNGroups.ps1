
#get list of account account members from AccountPeople
$oniaccountowners = Get-DistributionGroupMember -Identity accountpeople@disenza.com | %{$_.Name}
write-host $oniaccountowners -f yellow

## >>  add archs to $oniaccountowners also



#foreach distribution group starting with "CN_" set the managedby list
	
$CNDistributionGroups = Get-DistributionGroup | ?{$_.Name -match "CN_*"} 
foreach($CNDistributionGroup in $CNDistributionGroups){			
write-host "updating $CNDistributionGroup.Name" -f darkRed -b blue
		Set-DistributionGroup -identity "$($CNDistributionGroup)" -ManagedBy $oniaccountowners 

	}


## for testing

$test = Get-distributionGroup | ?{$_.Name -match "CN_*"}
foreach($t in $test){write-host $t.ManagedBy -f green -b darkblue}