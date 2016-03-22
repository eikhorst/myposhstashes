## Followed this guide:  http://blogs.technet.com/b/keithmayer/archive/2014/02/04/step-by-step-perform-cloud-restores-of-windows-azure-virtual-machines-using-powershell-part-2.aspx 
## Ensure each Region is completed before you start the next.

#region Setup Variables and azure powershell
## Configurations for your shell setup
$subscriptionname = "B_disenza-CentralUS-prim5755"
$storageaccount = "bdsatu1lrs"
$servicename = "bald-primocto"
$vm = "primocto"

set-azuresubscription -SubscriptionName $subscriptionname -CurrentStorageAccountName $storageaccount
Select-AzureSubscription -SubscriptionName $subscriptionname

$vmobject = Get-AzureVM -ServiceName $servicename -Name $vm
break;
#endregion

#region Export the VM to xml file
#### Export the VM to xml file

$exportFolder = "c:\temp\export"
$exportPath = $exportFolder + "\" + $vm + ".xml"
$vmobject | Export-AzureVM -Path C:\Temp\export\$($vm).xml
break;
#endregion Export the VM to xml file

#region Stop the VM
$vmobject | Stop-AzureVM -StayProvisioned -Verbose
break;
#endregion Stop the VM

#region Identify Each VHD to be restored
## copy results of the VM Disk info to here:
$vmOSDisk = $vmobject | get-azureosdisk
#region results of OSDisk
<#


HostCaching     : ReadWrite
DiskLabel       : 
DiskName        : bald-primOCTO-primOCTO-0-201506261929440873
MediaLink       : https://bdsatu1lrs.blob.core.windows.net/vhds/bald-primOCTO-primOCTO-2015-6-26-14-29-24-192-0.vhd
SourceImageName : a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201505.01-en.us-127GB.vhd
OS              : Windows
IOType          : Standard
ResizedSizeInGB : 
ExtensionData   : 


#>
#endregion

$vmDataDisks = $vmobject | get-azuredatadisk
#region results of DataDisk
<#


HostCaching         : None
DiskLabel           : nuGetStore
DiskName            : bald-primOCTO-primOCTO-1-201506261929470613
Lun                 : 1
LogicalDiskSizeInGB : 500
MediaLink           : https://bdsatu1lrs.blob.core.windows.net/vhds/bald-primOCTO-primOCTO-2015-6-26-14-29-24-192-1.vhd
SourceMediaLink     : 
IOType              : Standard
ExtensionData       : 


#>
#endregion
#endregion Identify Each VHD to be restored

#region Now deprovision the OS Disk
$vmObject | Remove-AzureVM 
#endregion 

#region Setup variables to use with restore
$vmOSDiskName = $vmOSDisk.DiskName

$vmOSDiskuris = $vmOSDisk.MediaLink

$StorageAccountName = $vmOSDiskuris.Host.Split('.')[0]

## >> update this to the backup blob name otherwise this just takes the existing name of the original
#$vmOSBlobName = $vmOSDiskuris.Segments[-1]  ## this is the original name
$vmOSBlobName = $vmOSDiskuris.Segments[-1]

$vmOSOrigContainerName = $vmOSDiskuris.Segments[-2].Split('/')[0]

$backupContainerName = "restore"
#endregion

#region Check that the disks are detached after deprovisioning
While ( (Get-AzureDisk -DiskName $vmOSDiskName).AttachedTo ) { Start-Sleep 5 }
#endregion Check that the disks are detached after deprovisioning

#region Delete the OS Disk VHDS
Remove-AzureDisk -DiskName $vmOSDiskName -DeleteVHD
#endregion Delete the OS Disk VHDS


#region Now copy over the VHDS from the temp location to the original
Start-AzureStorageBlobCopy -SrcContainer $backupContainerName -SrcBlob $vmOSBlobName -DestContainer $vmOSOrigContainerName –Force

Get-AzureStorageBlobCopyState -Container $vmOSOrigContainerName -Blob $vmOSBlobName –WaitForComplete
#endregion Now copy over the VHDS from the temp location to the original

#region once the disk is copied over we can add the disk back
Add-AzureDisk -DiskName $vmOSDiskName -MediaLocation $vmOSDiskuris.AbsoluteUri -OS Windows
#endregion once the disk is copied over we can add the disk back


#region now for all the data disks - there happens to be only 1 for primocto
ForEach ( $vmDataDisk in $vmDataDisks ) {

        $vmDataDiskName = $vmDataDisk.DiskName

        $vmDataDiskuris = $vmDataDisk.MediaLink

        $vmDataBlobName = $vmDataDiskuris.Segments[-1]

        $vmDataOrigContainerName = $vmDataDiskuris.Segments[-2].Split('/')[0]

        While ( (Get-AzureDisk -DiskName $vmDataDiskName).AttachedTo ) { Start-Sleep 5 }

        Remove-AzureDisk -DiskName $vmDataDiskName –DeleteVHD

        Start-AzureStorageBlobCopy -SrcContainer $backupContainerName -SrcBlob $vmDataBlobName -DestContainer $vmDataOrigContainerName –Force

        Get-AzureStorageBlobCopyState -Container $vmDataOrigContainerName -Blob $vmDataBlobName –WaitForComplete

        Add-AzureDisk -DiskName $vmDataDiskName -MediaLocation $vmDataDiskuris.AbsoluteUri

    }

#endregion  now for all the data disks - there happens to be only 1 for primocto

#region Reprovision the VM
Import-AzureVM -Path $exportPath | New-AzureVM -ServiceName $vmobject.ServiceName -VNetName $vmobject.VirtualNetworkName -Verbose
#endregion  Reprovision the VM