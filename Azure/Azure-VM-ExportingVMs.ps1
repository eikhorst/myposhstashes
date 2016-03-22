$VM = 'sushihelix-01'
$xmlloc = 'c:\temp\exports\PETS\'+$VM+'.xml'
$CloudService = 'bald-isushihelix'

Get-AzureVM -ServiceName $CloudService -Name $VM | Export-AzureVM -Path $xmlloc