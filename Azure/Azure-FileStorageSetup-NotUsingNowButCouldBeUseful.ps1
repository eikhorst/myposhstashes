# mounting a fileshare in the azure storage account

# create a context for account and key
$ctx=New-AzureStorageContext skiapperfmonlogs rM+hEVsAURETDuviE2W9dv26HdU9diTseUf6NNSYVrM4KseJV/qt2470/Ka//Uq0ISMeHcWnXETX8tFA5d6Kbtw==

# create a new share
$s = New-AzureStorageShare perflogshare -Context $ctx

# create a directory in the share
New-AzureStorageDirectory -Share $s -Path sampledir

# upload a local file to the new directory
Set-AzureStorageFileContent -Share $s -Source C:\temp\samplefile.txt -Path sampledir

# list files in the new directory
Get-AzureStorageFile -Share $s -Path sampledir

cmdkey /adE:<storage-account>.file.core.windows.net /user:<storage-account> /pass:<account-key>

net use z: \\<storage-account>.file.core.windows.net\<share-name>

net use z: \\<storage-account>.file.core.windows.net\<share-name> /u:<storage-account> <account-key>