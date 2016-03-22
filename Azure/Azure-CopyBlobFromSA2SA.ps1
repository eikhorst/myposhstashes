#Select-AzureSubscription 'B_disenza-EastUS2-bacon5755'
Select-AzureSubscription 'B_disenza-CentralUS-sushi5755'

### Source VHD (West US) - authenticated container ###
#$srcUri = "https://bdsbpu1lrs.blob.core.windows.net/vhds/sushiImage-helix-os-2014-09-23.vhd"
$srcUri = "https://skiapu2lrs.blob.core.windows.net/vhds/sushiImage-helix-os-2014-09-23.vhd"

### Source Storage Account (West US) ###
#$srcStorageAccount = "bdsbpu1lrs"
$srcStorageAccount = "skiapu2lrs"
$srcStorageKey = "aVxCKvKYZqTL3P6CVNfwoUvs1CDvvC/+BX8pglG9VaZnlrqamLdKpyfdPMiQE+XOfFcfcAOQ6mvYXb3Nl1SXAg=="

### Target Storage Account (West US) ###
#$destStorageAccount = "bdsbpu3lrs"
$destStorageAccount = "skiapu3lrs"
$destStorageKey = "fIEwM7MZ4LVPkprWHskEFcCqZBFqjLyyolRGMxVD2VhL7Bgyxl+ddNJMCY/55Qxs2xgSDGKy3MkTU4khA4Bs8g=="

### Create the source storage account context ###
$srcContext = New-AzureStorageContext  -StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey

### Create the destination storage account context ###
$destContext = New-AzureStorageContext  -StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey

### Destination Container Name ###
$containerName = "vhds"

### Create the container on the destination ###
#New-AzureStorageContainer -Name $containerName -Context $destContext

### Start the asynchronous copy - specify the source authentication with -SrcContext ###
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer "vhds" `
                                    -DestBlob "sushiImage-helix-os-2014-09-23.vhd" `
                                    -DestContext $destContext

### Loop until complete ###
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState
  Start-Sleep 10
  ### Print out status ###
  $status
}

Write-host "CompleteE: "$status