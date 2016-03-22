		$oniaccountowners = Get-DistributionGroupMember -Identity accountpeople@disenza.com | %{$_.Name} 
		$oniaccountowners += "pamundson"; $oniaccountowners += "efrus"; $oniaccountowners += "molaughlin";	
		<#
        $CNDistributionGroups = Get-DistributionGroup | ?{$_.Name -match "CN_*"}         
		foreach($CNDistributionGroup in $CNDistributionGroups){			
			write-host "updating $CNDistributionGroup.Name" -f darkRed -b blue
			Set-DistributionGroup -identity "$($CNDistributionGroup)" -ManagedBy $oniaccountowners 			
		}
        #>
		Set-DistributionGroup -identity "support-oncall@disenza.com" -ManagedBy $oniaccountowners 