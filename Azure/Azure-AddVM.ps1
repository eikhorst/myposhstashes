$XMLImportPath = 'C:\temp\sushiocto-Import.xml'
$CentralCloudService = 'bald-sushideploy'
$vnet = 'vn-disenza-centralus'
$ag = 'ag-disenza-centralus'
$RSVP = "bald-sushisftp"

<#
$OSDiskName = "bald-osushiocto-sushiOCTO-0-201407242043540224"
$OSDiskVHDPath = "https://skiapjump2lrs.blob.core.windows.net/vhds/bald-oapz-ju-sushiJU-ramper-2014-7-24-15-56-56-604-0.vhd."
#>

#Add-AzureDisk -DiskName $OSDiskName -MediaLocation $OSDiskVHDPath -Label $OSDiskName -OS Windows
#New-AzureService -ServiceName $CentralCloudService -Location $vnet #-AffinityGroup $ag

Import-AzureVM -Path $XMLImportPath | New-AzureVM -ServiceName $CentralCloudService -AffinityGroup $ag -VNetName $vnet # -ReservedIPName $RSVP -ErrorAction Inquire

#new-azurevm -ServiceName "bald-test-Kiyi" -VNetName -$vnet -ErrorAction Inquire
