#. \GetAvailableVNETStaticIP.ps1

## Admin
get-azurevm -ServiceName "bald-isushiuword" -Name "sushiuword-01" | Set-AzureStaticVNetIP -IPAddress 10.10.40.7 | Update-AzureVM
# get-azurevm -ServiceName "bald-oprimzju" -Name "primju-hgtv" | Set-AzureStaticVNetIP -IPAddress 10.20.4.12 | Update-AzureVM
get-azurevm -ServiceName "bald-sushiwaf-2nd" -Name "sushiwaf-2ndhourly-u" | Set-AzureStaticVNetIP -IPAddress 30.50.3.21 | Update-AzureVM
get-azurevm -ServiceName "bald-sushiwaf-2nd" -Name "sushiwaf-2ndhourly-v" | Set-AzureStaticVNetIP -IPAddress 30.50.3.22 | Update-AzureVM

## utility
get-azurevm -ServiceName "bald-oprimzju" -Name "sushihelix-01" | Set-AzureStaticVNetIP -IPAddress 10.20.40.7 | Update-AzureVM

