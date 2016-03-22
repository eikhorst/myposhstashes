# Go to fileserver 01 & 02
$Basket = Read-Host -Prompt "Basket "
$FolderShareName = Read-host -Prompt "ClientShare_%BDSVersion%Environment%InstanceID "


$Servers = @("\\sushi$Basket-fil-01","\\sushi$Basket-fil-02")

foreach($Server in $Servers){
    $NewLocalShare = "\\$Server\`$G\$FolderShareName"

if(!(Test-Path $NewLocalShare)){
    NEW-ITEM $NewLocalShare -type directory
}

# create a folder on the G drive
# # $FolderShareName Clientshortname_BdsversionEnvironmentInstanceid

# Sharing on this $FolderShareName 
New-SmbShare –Name $FolderShareName –Path Z:\Test –Description ‘Test Shared Folder’ –FullAccess Administrator –ReadAccess Everyone

# Share 
}


