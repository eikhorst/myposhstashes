# get VMs in LB set

$avm = Get-AzureVM -ServiceName bald-baconocto -Name "baconOCTO"

 

# create ACL

$acl = New-AzureAclConfig

Set-AzureAclConfig -AddRule -ACL $acl -Order 0 -Action Permit -RemoteSubnet "23.101.134.182/32" -Description "primQA1-SAB"

Set-AzureAclConfig -AddRule -ACL $acl -Order 1 -Action Permit -RemoteSubnet "23.101.134.246/32" -Description "primRQA-SAB"

Set-AzureAclConfig -AddRule -ACL $acl -Order 2 -Action Permit -RemoteSubnet "23.100.86.95/32" -Description "primQA1-WEB-01"

Set-AzureAclConfig -AddRule -ACL $acl -Order 3 -Action Permit -RemoteSubnet "23.101.113.173/32" -Description "primRQA-SZZ"

Set-AzureAclConfig -AddRule -ACL $acl -Order 4 -Action Permit -RemoteSubnet "38.140.55.234/32" -Description "222 1N Employee Network"

Set-AzureAclConfig -AddRule -ACL $acl -Order 5 -Action Permit -RemoteSubnet "104.43.230.84/32" -Description "primTEAMCITY-01"

 

# create new load balanced endpoint
### sushiOCTO/baconOCTO
$avm | Add-AzureEndpoint -Name "OD-API" -ACL $acl -Protocol TCP -PublicPort 10943 -LocalPort 10943 | Update-AzureVM

$avm | Add-AzureEndpoint -Name "OCTO-URL" -ACL $acl -Protocol TCP -PublicPort 9443 -LocalPort 80 | Update-AzureVM

$avm | Add-AzureEndpoint -Name "OD-COMM" -ACL $acl -Protocol TCP -PublicPort 10933 -LocalPort 10933 | Update-AzureVM

$avm | Add-AzureEndpoint -Name "OD-MGMT" -ACL $acl -Protocol TCP -PublicPort 9933 -LocalPort 9933 | Update-AzureVM



### Octopus
#$avm | Add-AzureEndpoint -Name "OD" -ACL $acl -Protocol TCP -PublicPort 10933 -LocalPort 10933 | Update-AzureVM



