$alldgs = get-distributiongroup | Where-Object Alias -match "CN_" #| set-mailbox $_.Alias -emailaddress $_.Alias+@disenzaswamy.com,SMTP:$_.Alias+"@disenza.com"

foreach($dg in $alldgs){
$cur = Get-DistributionGroup -Identity $dg.Name
$newemail = $dg.Alias+"@disenza.com"
$cur.emailAddresses  += $newemail
Set-DistributionGroup -Identity $dg.Name -EmailAddresses $cur.emailAddresses
Write-host -foregroundcolor green $dg has now had $cur.emailAddresses added to thier SMTP
}