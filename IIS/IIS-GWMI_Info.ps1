
$webservers = @("ctyut-a01"); $Domain = "kie"

foreach($webserver in $webservers){
Out-file -FilePath "\\ctyut-a04\d$\disenza\www\ErrorLogging\LoggingUI\support\iis\$webserver.txt"
$sites = get-wmiobject -computer $webserver -namespace "root\MicrosoftIISv2" -class "IIsWebServerSetting" -Authentication 6 
$ports = @()
Write-Host $webserver
    foreach($site in $sites){    
    #Write-Host $site -ForegroundColor DarkBlue
        foreach($binding in $site.ServerBindings)#.Tostring() -ForegroundColor darkgreen
        {            
            $ports += $binding.port
            if($binding.hostname -match $Domain){##>> check if site is running too?            
                Write-Host "`r`n IIS Servercomment :" $site.ServerComment "`r`n IIS ID :" $site.Name "`r`n Domain :" $binding.hostname -ForegroundColor DarkRed
                #write-host $binding.hostname
                #find this Site's VirDirs.
                $exactSiteServerComment = $site.ServerComment    
                
                if($host.Version.Major -eq '3'){
                #### get dns for this Domain                
                Resolve-DnsName $binding.hostname -type A
                Resolve-DnsName $binding.hostname -type NS
                }
                
                $filepath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/files'").Path
                $portletfiles = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/portletfiles'").Path            
                
                ## - this is much slower than the other way gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" | ? {$_.Name -eq "$site.Name`/ROOT`/files"} | %{$_.Path}
                
                $sitePath = (gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root'").Path
                Write-Host "`t--> Files    :" $filepath -ForegroundColor DarkMagenta
                Write-Host "`t--> Portlet  :" $portletfiles -ForegroundColor DarkMagenta
                Write-Host "`t--> Root     :" $sitePath -ForegroundColor DarkMagenta
                
                $vdirs = gwmi -computer $webserver -namespace "root\microsoftiisv2" -authentication 6 -Class "IIsWebVirtualDirSetting" -filter "Name='$($site.Name)/root/'"            
                $vdirs.Count
                foreach($vdir in $vdirs){                    
                Write-Host "`t==> Virtual Directories: " $vdir.Name  $vdir.Path
                }
            }
        }                        
    }
    
} 

#$ports | unique | sort -descending