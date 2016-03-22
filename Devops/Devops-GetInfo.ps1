#$tests = [adsi]"IIS://paleo-chqaws13.tlr.disenza.com/W3SVC/AppPools"
##############################
#Test if IIS6 or IIS7
#If IsIIS6 - use anonymoususer/password
#If !IsIIS6 - Use UNCUserName/Password
$servers = @("paleo-chdevws11","paleo-chdevws12","paleo-chdevws13","paleo-chqaws11","paleo-chqaws12","paleo-chqaws13")
$arrPasses = @()
$run = (get-date -format g).ToString().Replace("/","-").Replace(" ","_").Replace(":","_")
$outfile = "C:\Documents and Settings\m0060011\Desktop\FullSiteUsers $run.csv"

foreach($server in $servers){

    $isIIS6 = $false;
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\InetStp")
    $IISVer = $RegKey.GetValue("MajorVersion")
    if($IISVer -eq 6) {
        $isIIS6 = $true;
    }
    try{        
    $sites = get-wmiobject -ComputerName $server -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Authentication 6 #-Filter "ServerComment='$($websiteName)'"  
    foreach($site in $sites){
    $webdir = Get-WMIObject -ComputerName $server -namespace "root\microsoftiisv2" -class "IIsWebVirtualDirSetting" -Authentication 6 -Filter "Name = '$($site.Name)/root'"

                $tmpObj = New-Object Object 
                $tmpObj | add-member -membertype noteproperty -name "Server" -value $server 
                $tmpObj | add-member -membertype noteproperty -name "SiteName" -value $site.ServerComment 
                if($isIIS6){
                    $tmpObj | add-member -membertype noteproperty -name "Username" -value $webdir.AnonymousUserName
                    $tmpObj | add-member -membertype noteproperty -name "Pass" -value $webdir.AnonymousPassword
                }else{
                    $tmpObj | add-member -membertype noteproperty -name "Username" -value $webdir.UNCUsername
                    $tmpObj | add-member -membertype noteproperty -name "Pass" -value $webdir.UNCPassword
                }
                $arrPasses += $tmpObj
                                <#                           
                                #blue - uses IIS7 : dev13,qa13
                                #red - uses IIS6 : qa12,qa11,dev11,dev12
                                 
                                Write-host $site.ServerComment -ForegroundColor Green
                                Write-host $webdir.UNCUsername -ForegroundColor Blue
                                Write-host $webdir.UNCPassword -ForegroundColor Blue

                                Write-host $webdir.AnonymousUserName -ForegroundColor Red
                                Write-host $webdir.AnonymousUserPass -ForegroundColor Red

                                #break #>
    }
    }catch{Write-Host "$server :: $error[0]" -ForeGround Red}

}
$arrPasses | export-csv $outfile -notypeinformation                       