$CloudServiceReservedIPName = "bald-sushiSFTP"
$vnet = "VN-disenza-CentralUS"
$XMLImportPath = "c:\temp\sushisftp-01-import.xml"
$CentralCloudService = "bald-sushiSFTP"

Import-AzureVM -Path $XMLImportPath | New-AzureVM -ServiceName $CentralCloudService -AffinityGroup AG-disenza-CentralUS -VNetName $vnet -ReservedIPName $CloudServiceReservedIPName -ErrorAction Inquire