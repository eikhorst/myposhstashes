$owners = "ripshoe@disenzaswamy.com"
$members = "ggerwing@stratexpartners.com","equinn@stratexpartners.com","ripshoe@disenzaswamy.com"

#this creates the distribution group with the owner and other params
import-csv "E:\powershell\o365\distributionlists\stratex.csv" | foreach{New-DistributionGroup -Name $_.name -displayName $_.name -Type $_.type -primarysmtpaddress $_.email -managedBy $owners -confirm:$false; Set-DistributionGroup -Identity $_.name -RequireSenderAuthenticationEnabled $false; }

#this adds the members
Import-Csv "E:\powershell\o365\distributionlists\stratexMembers.csv" | foreach{Add-DistributionGroupMember -Identity "StratEx HR" -Member $_.email}