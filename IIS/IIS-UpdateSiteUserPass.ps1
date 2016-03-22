$websiteName = "Hinshaw_BDS wapp 6.4 (8495)"

$site = get-wmiobject -ComputerName "paleo-chqaws11" -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Filter "ServerComment='$($websiteName)'" -Authentication 6

    if ($site) { 
        Write-Host " -> Site already exists...";
    } else {
        Write-Host " -> !!! Site does not exist, creating...";
        $service = get-wmiobject -namespace "root/MicrosoftIISv2" -class "IIsWebService"
        $bindingClass = [wmiclass]'root\MicrosoftIISv2:ServerBinding'
        $bindings = $bindingClass.CreateInstance()
        $bindings.IP = $ipAddress
        $bindings.Port = $adminPort
        $bindings.Hostname = $adminHost
        $service.CreateNewSite($websiteName, $bindings, (resolve-path .), $siteId)

        $site = get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Filter "ServerComment='$($websiteName)'" -Authentication 6
        
    }

    $webdir = Get-WMIObject -namespace "root\microsoftiisv2" -class "IIsWebVirtualDirSetting" -Filter "Name = '$($site.Name)/root'" -Authentication 6

    $webdir.UNCUserName = $iisUser;
    #$webdir.UNCPassword = $iisPasswordClear;
    #$webdir.AuthAnonymous = 1;
    $webdir.AnonymousUserName = $iisUser;
    #$webdir.AnonymousUserPass = $iisPasswordClear;
    #$webdir.AccessScript = 1;
    #$webdir.AppFriendlyName = $websiteName;
<#    $httpErrors = $webdir.HttpErrors
    foreach($http_error in $httpErrors) {
        if(($http_error.HttpErrorCode -eq 404) -and ($http_error.HttpErrorSubcode -eq '*')) {
            $http_error.HandlerLocation = "/404.aspx"
            $http_error.HandlerType = "URL"
            break
        }
    }
    $webdir.HttpErrors = $httpErrors
    
    $scriptMapClass = [wmiclass]'root\MicrosoftIISv2:ScriptMap'
    $scriptMap = $scriptMapClass.CreateInstance()
    $scriptMap.Extensions = ".snapshot";
    $scriptMap.Flags = 1;
    $scriptMap.ScriptProcessor = "$($dotnetPath)aspnet_isapi.dll"
    $webdir.ScriptMaps = $webdir.ScriptMaps + ([System.Management.ManagementBaseObject]$scriptMap);

    Write-Host " -> Configure App Pool"
    $webdir.AppPoolId = $appPoolName
    #>
    $webdir.Put() #<------  and Set-ItemProperty for IIS 2008

    $service = get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsWebServer" -Filter "Name='$($site.Name)'" -Authentication 6

    $service.Start()
    