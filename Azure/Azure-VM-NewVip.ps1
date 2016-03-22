
#Reserve a IP

# Retrieve with Get-AzureSubscription 
#. /Get-azureinitialized.ps1

New-AzureReservedIP -ReservedIPName bald-sushiSFTP -Label “SFTP service” -Location “Central US”

## get the info back
Get-AzureReservedIP -ReservedIPName bald-sushiSFTP   ## 

#Use the Reserved IP during deployment
New-AzureService -ServiceName "bald-sushiSFTP" -Location "Central US"

#New-AzureVM -ServiceName “DSESorryServersCloudService” -VMs $web1 -Location “West US” -ReservedIPName DSESorryServers