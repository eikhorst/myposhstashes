$webservers = @("ctyws-a80","ctyws-a81","ctyws-a37","ctyws-a38"); $Domain = "www.bakerbotts.com"
foreach($webserver in $webservers){
$sites = get-wmiobject -computer $webserver -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Authentication 6 

    foreach($site in $sites){    
    #write-host $site.ServerState -ForegroundColor DarkMagenta
        foreach($binding in $site.ServerBindings)#.Tostring() -ForegroundColor darkgreen
        {
            if($binding.hostname -eq $Domain){##>> check if site is running too?            
                Write-host $webserver $site.ServerComment $site.Name  $binding.hostname -ForegroundColor DarkRed
                #find this Site's VirDirs.
                $exactSiteServerComment = $site.ServerComment    
                
                $filepath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/files'").Path
                $portletfiles = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/portletfiles'").Path            
                
                ## - this is much slower than the other way gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" | ? {$_.Name -eq "$site.Name`/ROOT`/files"} | %{$_.Path}
                
                $sitePath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root'").Path
                write-host "--> Files    " $filepath -ForegroundColor DarkMagenta
                write-host "--> Portlet  " $portletfiles -ForegroundColor DarkMagenta
                write-host "-->  Root    " $sitePath -ForegroundColor DarkMagenta
                
                $vdirs = gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name LIKE'$($site.Name)/root/%'" #| Select -ExpandProperty NAME           
                $vdirs.Count 
                foreach($vdir in $vdirs){
                    
                Write-host "--> $vdir    " $vdir.Path -ForegroundColor DarkGreen
                }
            }
        }                        
    }
    
}