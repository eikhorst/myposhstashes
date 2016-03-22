
#Create the owners list  - for managedby
#$owners = "dmichalak@disenzaswamy.com","bnelson@disenzaswamy.com","bvesprini@disenzaswamy.com","jbernstein@disenzaswamy.com","jwoodson@disenzaswamy.com","afieldman@disenzaswamy.com","efrus@disenzaswamy.com","molaughlin@disenzaswamy.com","pamundson@disenzaswamy.com"
$owners = "jwoodson@disenza.com"


#Bulk add distribution groups & setting outside mail in bulk
import-csv "E:\today\11\DGFull.csv" | foreach{New-DistributionGroup -Name $_.name -displayName $_.name -alias $_.name -Type $_.type -primarysmtpaddress $_.email -managedBy $owners -confirm:$false -memberjoinrestriction open -members $_.member; Set-DistributionGroup -Identity $_.name -RequireSenderAuthenticationEnabled $false; }


#Bulk add members
Add-DistributionGroup -Identity $_.name -member 

#bulk
import-csv "E:\today\11\dgnameonly.csv" | Set-DistributionGroup -Identity $_.name -RequireSenderAuthenticationEnabled $false

#this did not work
Get-DistributionGroup | Where-Object{$_.Name -match "CN_"} | Set-DistributionGroup -Identity $_.name -MemberJoinRestriction Open

import-csv "E:\today\11\dgnameonly.csv" | Set-DistributionGroup $_.name -BypassSecurityGroupManagerCheck -MemberJoinRestriction Open


