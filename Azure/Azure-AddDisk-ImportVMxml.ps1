Add-AzureDisk -DiskName bald-osushiocto-sushiOCTO-0-201407242043540224 -MediaLocation https://bds1bpu1lrs.blob.core.windows.net/vhds/bald-osushiocto-sushiOCTO-2014-7-24-15-43-48-433-0.vhd -Label bald-osushiocto-sushiOCTO-0-201407242043540224 -OS Windows

Add-AzureDisk -DiskName bald-osushiocto-sushiOCTO-0-201407242043550515 -MediaLocation https://bds1bpu1lrs.blob.core.windows.net/vhds/bald-osushiocto-sushiOCTO-2014-7-24-15-43-48-433-1.vhd -Label bald-osushiocto-sushiOCTO-0-201407242043550515

Import-AzureVM -Path C:\Temp\sushi1st-sbc-02-Import.xml | New-AzureVM -ServiceName bald-sushi1ST-SBCzz -DeploymentName 1st-SBC -AffinityGroup AG-disenza-CentralUS -VNetName vn-disenza-centralus



## for

Add-AzureDisk -DiskName bald-sushi1ST-SBC-sushi1ST-SBC-02-0-201409161840240365 -MediaLocation https://skiap1stweb01lrszz.blob.core.windows.net/vhds/bald-sushi1ST-SBC-sushi1ST-SBC-01-2014-9-16-12-6-10-116-0.vhd -Label bald-sushi1ST-SBC-sushi1ST-SBC-01-0-201409161706170608 -OS Windows
