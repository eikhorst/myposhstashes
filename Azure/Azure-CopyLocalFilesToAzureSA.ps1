$context = New-AzureStorageContext -StorageAccountName bds1atu1lrs -StorageAccountKey 44N2pziH0X5ZjLAXD7GAPky6Mua+dZotAMWqUnFOtkZoD14GjerfM4AH5RhVr2CO3G/BRp5SuQRojKI/NE5Taw== 

cd K:
$folder = "K:\~PostDeployScripts\Subscripts\Tools\adsiedit.msc"

ls -File $folder  | Set-AzureStorageBlobContent -Container "media" -Context $context -Force