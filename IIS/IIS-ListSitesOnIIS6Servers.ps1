$servers = gc @("\\ctyfs-a01s\dsw\mypow\AllServers.txt")
foreach($server in $servers){
    $isIIS6 = $false;
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\InetStp")
    $IISVer = $RegKey.GetValue("MajorVersion")
    if($IISVer -eq 6) {
        $isIIS6 = $true;
    }
    
    if($isIIS6){
        #write-host -f green 'IIS 6' $server
       $objSites = [adsi]"IIS://$server/W3SVC"
    	$nl = [Environment]::NewLine
    	#region GetAppPool to recycle
        foreach ($objChild in $objSites.Psbase.children)
        {  
            if($objChild.KeyType -eq "IIsWebServer"){
            Write-host -f blue  $objChild.ServerComment 
            }
            
        }
    }
}