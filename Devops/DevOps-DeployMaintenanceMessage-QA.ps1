#region
#get the list of servers and sites
#$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'bacon'} | select -Expand Name | sort
$servers = @("primqa1-web-01")

#endregion

foreach($server in $servers){

    $s = New-PSSession -ComputerName $server 
    write-output "====== $server ======"
    #region Setup the command
    $command ={

#region Setup the Maintenance Message
$text = @("`
        ""DisableFrameProtection"": true,
        ""MaintenanceBlockedPaths"": [],
        ""MaintenanceBlockedRedirect"": ""http://maintenance.disenza.com/maintenance.html"",
        ""MaintenanceMessage"": ""This is the QA environment: All changes will appear on the QA environment."",
        ""MaintenanceMode"": 7,
        ""SiteName"": ""{0}""

")
#endregion

        $outfile = "c:\bds.requestblocker.json"
        copy-item $outfile "c:\$($server)_bds.requestblocker.json.bak"
        $tempstring = ""
        clear-content $outfile

        ###################################
        ##
        ##   Setup the IIS information
        ##
        ###################################

        Import-Module WebAdministration; 
        $sites = Get-ChildItem IIS:\Sites; 
        $sites = Get-ChildItem IIS:\Sites # same line as before doing this once has some problems and we were missing lots of data.
    
        #now loop through the sites to get all the names
        foreach($site in $sites){
        write-output $site.Name
            if($site.name -notmatch "CacheInvalidation"){
            $outputready = $null
            $sitename = $site.Name ##whatever the IIS comment is
            $outputready  = $text -f $sitename 
            
            $tempstring += "{" + $outputready + "},"
            }
        }

        ###################################
        ##
        ##   Setup Output of BDSRequestBlocker
        ##
        ###################################    
        
        "`{`"Sites`"`: [" > $outfile ## prepend the expected json by BdsRequestBlocker
        ## remove the trailing comma                
        $tempstring.Substring(0,$tempstring.Length-1) >> $outfile
        
        ## End the json as expected
        "]}" >> $outfile 
    }
    #endregion Setup the command

    invoke-command -Session $s -scriptblock $command -ThrottleLimit 5


}
Get-PSSession | Remove-PSSession

        #region Reload the configuration
        ## todo


        #endregion
