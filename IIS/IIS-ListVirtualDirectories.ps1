$sourceSiteName = Read-Host -Prompt "Enter Source Site name";
if ($sourceSiteName.ToString() -eq "") {
    Write-Error "Blank sourceSiteName is no good.";
}

$sourceSite = get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Filter "ServerComment='$($sourceSiteName)'" -Authentication 6

$vdirsettings = (Get-WMIObject -namespace "root\microsoftiisv2" -class "IIsWebVirtualDirSetting" -Authentication 6 | Where-Object { $_.name -like "$($sourceSite.Name)/root/*" })

foreach($vdir in $vdirsettings) {

    $found = $false

    foreach($bdsDir in @("ControlTemplateFiles","files","PortletFiles","SnapshotFiles","TemplateFiles")) {
        if($vdir.Name.ToLower() -eq "$($sourceSite.Name)/root/$($bdsDir)".ToLower()) {
         $found = $true
        }
    }

    if($found -eq $false) {
	    if($vdir.HttpRedirect) {
            Write-Host "$($vdir.Name) - $($vdir.HttpRedirect)"
        } elseif($vdir.AppFriendlyName -ne "Default Application") {
	        Write-Host "**APP** - $($vdir.Name) - $($vdir.Path)"
        } else {
	        Write-Host "$($vdir.Name) - $($vdir.Path)"
	    }
    }
}