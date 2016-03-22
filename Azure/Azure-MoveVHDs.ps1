
	#1. Document VM configuration

#https://bds1apu1lrs.blob.core.windows.net/vhds/bald-osushiocto-sushiOCTO-2014-7-24-15-43-48-433-0.vhd
#Example:  
 
#https://bds1apu1lrs.blob.core.windows.net/vhds/bald-osushiocto-sushiOCTO-2014-7-24-15-43-48-433-1.vhd

$VM = 'sushihelix-01'
$CloudService = 'bald-baconhelix'
#$RsvpIPName =  'bald-sushiSFTP'
$SourceCurrentStorageAccount =  'bdsbpjump1lrs'
$SourceCurrentSAKey =  'OzWjKmNyNcmP9NRm3XZguygWvS4LWI4EHMC0GAl+nHInE4jf+PjIj7MM8XPD1B7L8Vlyg47+g3GJtyvHVSyDBQ=='
<#
$OSDisk =  (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureOSDisk).DiskName  
$Disk2 = (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureDataDisk).DiskName  
#>
#Custom
$OSDisk = "bald-isushihelix-sushihelix-01-0-201407242029540947"
#$Disk2 = "bald-osushiocto-sushiOCTO-0-201407242043550515"
#$blob1 = "onikbox-primkeybox-02-2014-10-8-14-43-25-608-0.vhd"
#$blob2 = "bald-osushiocto-sushiOCTO-2014-7-24-15-43-48-433-1.vhd"

#https://bds1apjump2lrs.blob.core.windows.net/vhds/bald-oapz-ju-sushiJU-ramper-2014-7-24-15-56-56-604-0.vhd
#https://bds1apjump2lrs.blob.core.windows.net/vhds/bald-oapz-ju-sushiJU-ramper-2014-7-24-15-56-56-604-1.vhd
#https://bds1apu1lrs.blob.core.windows.net/vhds/bald-oAPZ-JU-sushiJU-ramper-0818-2.vhd


<#
Write-host (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureOSDisk).MediaLink.AbsoluteUri
$blob1 = (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureOSDisk).MediaLink.AbsolutePath -replace '/vhds/','' 

Write-host (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureDataDisk).MediaLink.AbsoluteUri
$blob2 = (get-azurevm -Name $VM -ServiceName $CloudService | Get-AzureDataDisk).MediaLink.AbsolutePath -replace '/vhds/','' 
#>
$DestinationStorageAccount =  'bdsbpu1lrs'
$DestinationSAKey = '+A8wOKUWaqmcgbmEt1XnqN23YG1F9Qv/P5eGWbKPqC23lR+MUKhNpq56XAf+js9B6wfQzkexDx5VI8lBQ6jvVA==' 

#$xmlloc = 'C:\Temp\'+$VM+'.xml'
$xmlloc = 'C:\Temp\sushihelix-11.xml'
$DestinationVHDOS = 'https://'+$($DestinationStorageAccount)+'.blob.core.windows.net/vhds/'+$blob1
#$DestinationVHDDisk2 = 'https://'+$($DestinationStorageAccount)+'.blob.core.windows.net/vhds/'+$blob2

#	1. Take an export of the VM
# Example:  
# Get-AzureVM -ServiceName bald-xsushiwaf-1st -Name sushiWAF-1STHOURLY-X | Export-AzureVM -Path C:\Temp\exports\ForStorageReAlign\sushiWAF-1STHOURLY-X.xml
 
#Get-AzureVM -ServiceName $CloudService -Name $VM | Export-AzureVM -Path $xmlloc

# 
#VALIDATE YOUR EXPORT BEFORE CONTINUING!
# 

if((Test-Path $xmlloc) -and (get-itemproperty $xmlloc).length -gt 0){
	#1. Stop deallocate the VM
<#
#Example:  
#Get-AzureVM -ServiceName bald-xsushiwaf-1st -Name sushiWAF-1STHOURLY-X | Stop-AzureVM
 Get-AzureVM -ServiceName $CloudService -Name $VM | Stop-AzureVM
 sleep 300

#	2. Remove the VM 
#Example:  
#Get-AzureVM -ServiceName bald-xsushiwaf-1st -Name sushiWAF-1STHOURLY-X | Remove-AzureVM
Get-AzureVM -ServiceName $CloudService -Name $VM | Remove-AzureVM
Sleep 800
 
#  3. Remove the disks
#Example:  
#Remove-AzureDisk -DiskName $OSDisk
 Remove-AzureDisk -DiskName $OSDisk; sleep 120;
 Remove-AzureDisk -DiskName $Disk2; sleep 120;
 

#	4. Copy the VHD(s) to the new storage account 
#Example:
 #>
$SrcContext = New-AzureStorageContext -StorageAccountName $SourceCurrentStorageAccount -StorageAccountKey $SourceCurrentSAKey
$DestContext = New-AzureStorageContext -StorageAccountName $DestinationStorageAccount -StorageAccountKey $DestinationSAKey
$blob1 = 'sushiImage-helix-os-2014-09-23.vhd'

Start-AzureStorageBlobCopy -SrcBlob $blob1 -SrcContainer vhds -Context $SrcContext -DestBlob $blob1 -DestContainer vhds -DestContext $DestContext
#Start-AzureStorageBlobCopy -SrcBlob $blob2 -SrcContainer vhds -Context $SrcContext -DestBlob $blob2 -DestContainer vhds -DestContext $DestContext
 
#Check Status:
Get-AzureStorageBlobCopyState -Blob $blob1 -Container vhds -Context $DestContext
#Get-AzureStorageBlobCopyState -Blob $blob2 -Container vhds -Context $DestContext 
#Check Status and Wait for Complete:
Get-AzureStorageBlobCopyState -Blob $blob1 -Container vhds -Context $DestContext -WaitForComplete
#Get-AzureStorageBlobCopyState -Blob $blob2 -Container vhds -Context $DestContext -WaitForComplete 
 
 
#sleep 1800
}
#>
#	5. Create the disk(s) from the VHD in the new storage location
#Example:
#Add-AzureDisk -DiskName bald-xsushiWAF-1ST-sushiWAF-1STHOURLY-X-0-201408220454530923 -MediaLocation https://bds1apu4lrs.blob.core.windows.net/vhds/bald-xsushiWAF-1ST-sushiWAF-1STHOURLY-X-2014-8-21-23-54-47-857-0.vhd -Label bald-xsushiWAF-1ST-sushiWAF-1STHOURLY-X-0-201408220454530923 -OS Linux
<#
if((Get-AzureStorageBlobCopyState -Blob $blob1 -Container vhds -Context $DestContext -WaitForComplete).Status -eq 'Success'){
Add-AzureDisk -DiskName $OSDisk -MediaLocation $DestinationVHDOS -Label $OSDisk -OS Windows
}
sleep 120
if((Get-AzureStorageBlobCopyState -Blob $blob2 -Container vhds -Context $DestContext -WaitForComplete).Status -eq 'Success'){
Add-AzureDisk -DiskName $Disk2 -MediaLocation $DestinationVHDDisk2 -Label $Disk2 }
sleep 120

#	6. Import the VM
#Example:
#Import-AzureVM -Path C:\Temp\exports\ForStorageReAlign\sushiWAF-1STHOURLY-X.xml | New-AzureVM -ServiceName  bald-xsushiwaf-1st -ReservedIPName $RsvpIPName -AffinityGroup AG-USEast-disenza -VNetName VN-USEast-disenza
Import-AzureVM -Path "c:\temp\primkeybox-02.xml" | New-AzureVM -ServiceName  "bald-sushiWAFCMD" -AffinityGroup AG-disenza-CentralUS -VNetName vn-disenza-centralus #-ReservedIPName $RsvpIPName -ErrorAction Inquire 

}
#>