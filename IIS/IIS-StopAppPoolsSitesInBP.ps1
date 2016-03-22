
$timetaken = Measure-Command{
    
    ###  filter on just fil/sql servers:  -match 'sushi(1st|FIG|GUM|HAM|ICE)-(SQL|FIL)-')
    #$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{($_.Name -match 'sushi(1st|FIG|GUM|HAM|ICE)-(SQL|FIL)-')} | select -Expand Name | sort
    $servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'bacon'} | select -Expand Name | sort
    #$servers = $servers -join ','
    ###### Call the script you want to use
    
    foreach($vm in $servers){
        if(Test-connection -Computername $vm){
            write-host "Stopping sites -- $vm" -f DarkCyan
            #stop all sites that are started
            Invoke-Command -ComputerName $vm -ScriptBlock { cmd /c 'c:\windows\system32\inetsrv\appcmd.exe list site /xml /state:"$=started" | c:\windows\system32\inetsrv\appcmd.exe stop site /in'; $test = cmd /c 'c:\windows\system32\inetsrv\appcmd.exe list site'; write-host $test}

            #stop all apppools 
            write-host "Stopping pools -- $vm" -f DarkCyan
            Invoke-Command -ComputerName $vm -ScriptBlock { cmd /c 'c:\windows\system32\inetsrv\appcmd.exe list apppool /xml | c:\windows\system32\inetsrv\appcmd.exe stop apppool /in'; $test = cmd /c 'c:\windows\system32\inetsrv\appcmd.exe list apppool'; write-host $test }

            #stop sendgrid service    
            write-host "Stopping Sendgrid -- $vm" -f DarkCyan        
            (get-service -ComputerName $vm -DisplayName BDS.sendgrid).Stop()
            set-service -StartupType Manual -ComputerName $vm -DisplayName BDS.Sendgrid

        }
    }               
}

write-host $timetaken

