function EmailIt{
    param([string]$subject, [string]$body)
    $smtp = "relay-disenza.disenza.com"
    $to = "DSE-vintage@disenza.com"; 
    $from = "MonthlyBackupsOnA02@disenza.com"
    $failedItem = $_.Exception.ItemName
    
    $body += "
Failed item(s): " + $failedItem + " 
Exception Message" + $_.Exception.Message
    Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp

}

#Taking backup of a websites wapp folder, filesystem folder, and database and zips the folder up
#Only have to call the GetFilePath function with the parameters that pass into it to run everything
# GetFilePath -webserver ctyws-a69.ETDsoya.com -Domain www.Clienta.com -tempBackupPath \\ctyfs-a01t.ETDsoya.com\www\ -sqlSrvBackupLocal E:\ -sqlSrvBackupShare \\ctysql-a11r\d$\ -finalBackupPath \\prod-soya-f0071.disenza.com\iislogETD$\MonthlyArchives\Clienta\



#The parameters are the server that the website is on, the Domain of the website, the path that the files will temporarily be backed up to, the sql local backup server path, the sql server's shared backup path, and the final path that will keep the zipped up files
function GetFilePath
{
    param ([string]$webserver, [string]$Domain, [string]$tempBackupPath, [string]$sqlSrvBackupLocal, [string]$sqlSrvBackupShare, [string]$finalBackupPath)   
    
    $DomainFound = $false;
    $sites = get-wmiobject -computer $webserver -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Authentication 6 
$exactSiteServerComment = ""; $filepath = ""; $sitePath = ""
    #get-wmiobject -computer $webserver -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Authentication 6 | %{$_.ServerBindings} | ?{$_.Hostname -eq "$Domain"}
    foreach($site in $sites){    
    #write-host $site.ServerState -ForegroundColor DarkMagenta
        foreach($binding in $site.ServerBindings)#.Tostring() -ForegroundColor darkgreen
        {
            if($binding.hostname -eq $Domain){##>> check if site is running too?            
            Write-host $site.ServerComment $site.Name  $binding.hostname -ForegroundColor DarkMagenta
            #find this Site's VirDirs.
            $exactSiteServerComment = $site.ServerComment    
            
            $filepath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/files'").Path
            ## - this is much slower than the other way gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" | ? {$_.Name -eq "$site.Name`/ROOT`/files"} | %{$_.Path}
            write-host $filepath -ForegroundColor DarkMagenta
            $sitePath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root'").Path
            write-host $sitePath -ForegroundColor DarkMagenta
            }
        }                        
    }
    if($filepath -ne "" -and $sitePath -ne ""){       
        $filepath = $filepath -replace("FileSystem\\files","FileSystem") 
        if($sitePath -like "E:*"){write-host "making local filepath UNC accessible"
            $sitePath = $sitePath -replace("E:","\\$webserver\D$")           
        }
     Write-Host $sitePath  $filepath -ForegroundColor DarkGreen
     GetWebConfig -rootPath $sitePath -filepath $filepath -siteDomain $Domain -tempBackupPath $tempBackupPath -sqlSrvBackupLocal $sqlSrvBackupLocal -sqlSrvBackupShare $sqlSrvBackupShare -finalBackupPath $finalBackupPath    
    }else{ Write-Host "No site found with $Domain on $Server" -ForegroundColor DarkRed }
            
    ###### outputs:  rootpath for web.config, filepath of files siteDomain, #####
    
 }
 
 #GetFilePath -webserver "ctyws-a77" -Domain "www.hunton.com" -tempBackupPath "E:\disenza\scripts\StoringBackups\temp" -sqlSrvBackupLocal "E:\backups" -sqlSrvBackupShare "\\ctysql-a01s\backups\"

 
 #Called from function GetFilePath which passes in the site root path, the site Domain, and the path that the files will temporarily be backedup to, the server's local backup path, the server's shared backup path, and the final loaction for the zipped files
 function GetWebConfig
 {
    param ([string]$rootPath, [string]$filepath, [string]$siteDomain, [string]$tempBackupPath, [string]$sqlSrvBackupLocal, [string]$sqlSrvBackupShare, [string]$finalBackupPath)
    $filesystem = $filepath
    #The path where the webconfig is located
    $wcfile = $rootPath + "\web.config"
    
    #selecting the nodes that contain the server, the database name
    if (test-path $wcfile)
    {
        [xml]$configfile = Get-Content $wcfile
        $nm = new-object Xml.XmlNamespaceManager($configfile.Psbase.NameTable)
        $nm.AddNamespace("wc",$configfile.configuration.xmlns)
        $expression = $configfile.SelectNodes("//wc:connectionStrings/wc:add",$nm)
                
        foreach ($exp in $expression)
        {
            $db = $exp.getAttribute("connectionString").split(";")
            $dbs = $db[0].split("=")
            $dbserver = $dbs[1]
            $clog = $db[1].split("=")
            $catalog = $clog[1]
            write-host "Connection: " $clog
            write-host "Catalog: " $catalog
        }
        
        $date = Get-Date -format yyyy-MM-dd    
        $newfolder = $siteDomain + "_" + $date
        $newPath = Join-Path $tempBackupPath -childpath $newfolder
        New-Item $newPath -type directory
        
        #calling function to do the entire backup 
        #takes in parameters for the site Domain, the path of the temporary folder that will contain backup, the database server, the database, the filesystem path, codebase path, the path of where the temp folder is located, server local backup, server shared backup, and final backup path
        EntireBackup -siteDomain $siteDomain -newfolder $newPath -dbserver $dbserver -catalog $catalog -filesystem $filesystem -codebasepath $rootPath -tempBackupPath $tempBackupPath -sqlSrvBackupLocal $sqlSrvBackupLocal -sqlSrvBackupShare $sqlSrvBackupShare -finalBackupPath $finalBackupPath
    }
 }
 
 #Being called from GetWebConfig which passes in the site Domain, the path of the temporary folder that will contain backup, the database server, the database, the filesystem path, codebase path, the path of where the temp folder is located, server local backup, server shared backup, and final backup path

function EntireBackup
 {
    param ([string]$siteDomain, [string]$newfolder, [string]$dbserver, [string]$catalog, [string]$filesystem, [string]$codebasepath, [string]$tempBackupPath, [string]$sqlSrvBackupLocal, [string]$sqlSrvBackupShare, [string]$finalBackupPath)
try{
    #copy the filesystem folder 
    $pathFS = Join-Path $newfolder -childpath "FS\filesystem"
    New-Item $pathFS -type directory
        $children = get-childitem $filesystem
        foreach($child in $children)
        {
            $subfolder = Join-Path $filesystem -ChildPath $child                
            if($child.Name -ne "files"){                        
                copy-item $subfolder $pathFS -recurse -ErrorAction Stop
            }
            else
            {   
                #$pathfiles = Join-Path $pathFS -childpath "files"                          
                #New-Item $pathfiles -type directory
                try{
                    New-PSDrive -name E -psprovider FileSystem -root $pathFS        
                    Copy-Item $subfolder E:\ -Recurse -ErrorAction SilentlyContinue
                    rdr E
                    write-host "Created Copy"
                }
                catch{
                    $subject = "Failure to copy FS: $siteDomain."
                    $failedItem = $_.Exception.ItemName
                    $body = $failedItem + "  -  " + $_.Exception.Message
                    EmailIt -subject $subject  -body $body                 
                              
                }
                
            }           
        }
   
    try{
    #copy the codebase folder
    $pathCB = Join-Path $newfolder -childpath "CB"
    New-Item $pathCB -type directory
    New-PSDrive -name H -psprovider FileSystem -root $pathCB 
    copy-item $codebasepath H:\ -recurse -ErrorAction Stop
    }
    catch{
        $subject = "Failure to copy CB: $siteDomain."
        $failedItem = $_.Exception.ItemName
        $body = $failedItem + "  -  " + $_.Exception.Message
       EmailIt –subject $subject –body $body
    }
    try{
    $date = Get-Date -format yyyy-MM-dd
    
    #Determining which SQL server is being used
    $v = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $p = $v.FullName.Split(',') 
    $p1 = $p[1].Split('=') 
    $p2 = $p1[1].Split('.') 
    if ($p2[0] -ne '9') 
    {
     [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended')  | out-null
     [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement')  | out-null
    }

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
    
    #whether the database server from the webconfig matches the serverpaths in the parameter

            #the copy of the database backup local location
    $sqlSrvBackupLocal = "E:\backups"
    switch($dbserver)
    {
        ctysql-a01r {$sqlSrvBackupLocal = "E:\disenza\backups"} 
        ctysql-a07r {$sqlSrvBackupLocal = "E:\disenza\backups"}
        ctysql-a11r {$sqlSrvBackupLocal = "E:\backups"}
        ctysql-a14r {$sqlSrvBackupLocal = "E:\backups"}
        paleo-chproddb7\dev {$sqlSrvBackupLocal = "E:\DBmove"}
        paleo-chproddb10\dev {$sqlSrvBackupLocal = "E:\DBBackups"}
        default {$sqlSrvBackupLocal = "E:\disenza\backups"}
    }
        $datapath = $sqlSrvBackupLocal + "\" + $catalog + "_" + $date + ".bak"      
            #Backing up the database   
            $s = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $dbserver 
            $dbBackup = new-object ("Microsoft.SqlServer.Management.Smo.Backup") 
            $dbBackup.Action="Database"
            $dbBackup.Database = $catalog 
            $dbBackup.Devices.AddDevice($datapath, "File")
            $dbBackup.SqlBackup($s)
        
            #copying the database backup to the backup folder and removing from the original backup location

        $sqlSrvBackupShares = @("\\ctysql-a01\backups", "\\ctysql-a07\backups", "\\C111MMRETDHS09\Backups", "\\ctysql-a02\backups", "\\ctysql-a08\backups","\\C111DKXETDHS10\backups","\\ctysql-a14r\backups")
        foreach($sqlSrvBackupShare in $sqlSrvBackupShares){
            $copydb = $sqlSrvBackupShare + "\" + $catalog + "_" + $date + ".bak"            
            if(Test-Path $copydb){
                $pathDB = Join-Path $newfolder -childpath "DB"
                New-Item $pathDB -type directory
                copy-item $copydb $pathDB -recurse
                Remove-Item $copydb -force
            
            #Calling function to compress the backup folder that passes in the new folder path, the root path where the new folder is located, and the path for the final backup location
                ZipBackup -newfolder $newfolder -tempBackupPath $tempBackupPath -finalBackupPath $finalBackupPath
            }
        #}
        }
    }
    Catch{
        $subject = "Failure: DB backup: $siteDomain."
        $failedItem = $_.Exception.ItemName
        $body = $failedItem + "  -  " + $_.Exception.Message
        EmailIt –subject $subject –body $body
    }

}    
Catch{
        #if the servers don't match then email will be sent and backup will be canceled
        $subject = "Failure: Entirebackup $siteDomain."
        $failedItem = $_.Exception.ItemName
        $body = $failedItem + "  -  " + $_.Exception.Message
        EmailIt –subject $subject –body $body
}
Finally
{
    $Time=Get-Date
    $out = join-path $finalBackupPath -childpath "backups.log"
    "DB finished attempt at $Time" | out-file $out -append  
}
}
 
 #Function to compress the backup folder which is called in Entire Backup. Passing the newfolder path, the backup path that the temporary new folder is in, and the final path where the backup will officialy be located
 function ZipBackup
 {
    param ([string]$newfolder, [string]$tempBackupPath, [string]$finalBackupPath)
    try{    
    #Checks server for requirement 7-zip program
    if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) 
    {
   d     throw "$env:ProgramFiles\7-Zip\7z.exe needed"
    }  
    
    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
    
    #if the directory in the main path is equal to the new folder that had backup files, then compress and remove original folder 
    foreach($dir in Get-ChildItem -Path $tempBackupPath)  
    {
        if ($dir.fullname -eq $newfolder)
        {
            $zipFile = $newfolder + ".7z"
            #sz a -tzip "$zipfile" $dir.FullName
            sz a -mx=9 -mmt=on "$zipfile" $dir.FullName
            Remove-Item $dir.FullName -Recurse -Force
            
            #Move zip file to final location
            copy-Item $zipFile $finalBackupPath -recurse
            Remove-Item $zipfile -recurse -force   
            write-host "Finished Zipping"
            
        }
    }
    }
    Catch{
        $subject = "Failed ZipBackup for: $siteDomain."
        $failedItem = $_.Exception.ItemName
        $body = $failedItem + "  -  " + $_.Exception.Message
        EmailIt –subject $subject –body $body
    }
    Finally
    {       
        $subject = "ZipBackup for: $siteDomain succeeded."
        $failedItem = $_.Exception.ItemName
        $body = $failedItem + "  -  " + $_.Exception.Message
        EmailIt –subject $subject –body $body
    }
 }
 
## for debugging:
##  
# GetFilePath -webserver ctyws-a69.ETDsoya.com -Domain www.Clienta.com -tempBackupPath E:\disenza\scripts\StoringBackups\temp\ -sqlSrvBackupLocal E:\Backups\ -sqlSrvBackupShare \\ctysql-a14r\backups\ -finalBackupPath \\prod-soya-f0071.disenza.com\iislogETD$\MonthlyArchives\Clienta\