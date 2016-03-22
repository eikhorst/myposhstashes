$time = Measure-Command{
#$servers = Read-host -prompt "VM e.g(sushiice-sia-01)" #@('sushiice-sia-02')
#$servers = @('sushigum-sfe-01','sushifig-sfe-02')
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match '(B|A)P-(fig|gum|ham|ice|jam|kix|lox|bkr)-'} |  ?{$_.Name -notmatch '-(fil|sql|dbs)-'} | sort Name | select -expand Name

$ErrorActionPreference = "SilentlyContinue"
$body = @()
#$servers = @('sushifig-sfa-01','baconfig-sfa-01','sushifig-sfa-02','baconfig-sfa-02','sushigum-sga-01','bacongum-sga-01','sushigum-sga-02','bacongum-sga-02')
#region Initialize global variables
$localcompare = "E:\temp\comparewebconfigs\" ## Set the Local Comparison root dir
cd $localcompare
gci $localcompare | ?{(gi $_) -isnot [System.IO.DirectoryInfo]} | remove-item -force

#$localcompare = $localcompare+"$(get-date -f "yyyyMMdd")"
$thiscomparison = get-date -f "yyyyMMdd"
mkdir $thiscomparison -Force


#endregion


foreach($server in $servers){
  

    #region Initialize all the server variables
    $comp = $env:ComputerName
    $comp = $server    
    $odroot = "\\$($comp)\c$\oni\od\" ## Set the standard OD Dir
    $array = $comp.Substring(0,$comp.Length-3) ## Set the array
    $folder = $null
    $config = $null

    if($comp -match "bacon"){
        $array = $array.Replace("bacon","sushi")
    }
    
    
    $arrayroot = $odroot + $array 
    #write-output $arrayroot -f Cyan
    write-host $server $arrayroot -f darkblue -verbose
    if(test-path $arrayroot){

    #get the MC & WC directories
    $serverapps = gci $arrayroot | ?{$_.Name -match "(M|W)C$"}
           
    #endregion
        
    #region AP/BP get config
    #copy the latest web.config from AP to a folder that is "$folder=$array.$app.$ODversion" > file named sushi$($folder).web.config
    #copy-item

        #region # foreach app set the latest app location and get the version
        #$appconfigs = $serverapps | %{ (gci $_.FullName | %{$($_.FullName)}) }  ## this gets all the web.configs for ever version - might take a long time
        $appconfigs = $serverapps | %{ (gci $_.FullName | sort LastWriteTime -Descending | select-object -First 1 ) | %{$($_.FullName)} }  ## this gets just the latest version based on last write time
        $appconfigs | %{ $folder = $_.ToString().Replace($($odroot),"").Replace('\','..'); $folder = $folder.Replace("$($array)","$($server)");  `
        $config = $_+"\web.config" ; cp $config "$($folder).web.config" }  #cp $config ".\$($folder).web.config"; break;}
        #endregion
    
    #endregion

        
    }
    else
    {
        #Exit 55
        continue;
    }

}

    #region Now Compare the files - 
    # get the list of AP files and find it's counterpart
    $apfiles = gci . | ?{$_.psiscontainer -eq $false} | ?{$_.Name -match "^AP"}


    foreach($apfile in $apfiles){
        # if the counterpart does not exist - we may need to track this - start a missing config in BP list

        $bpfile = $apfile.Name.ToUpper().Replace('sushi','bacon')
        $bpfilepath = $apfile.FullName.ToUpper().Replace('sushi','bacon')
        $missingBPfiles = @()
        $differences = @{}
        $body = $null
        
        $diffcount = $null; $replacementfile = $null; $diffcountAfterReplacement = $null;
        $diff2s = $null; $differences = $null
        $currentfileoutput = $null
        #$differences.mailto = "CN_"+($apfile.Name -split "\.")[1]+"@disenzaswamy.com"
        
        if(test-path $bpfilepath){
                       
        }
        else # find something else that matches the server/app
        {            
            $bpfile = gci . | ?{$_.Name -match (($bpfilepath -split "C\.") -split "\\")[3]}
            $bpfilepath = $bpfile.FullName
            
            write-output "No match for $($apfile.Name), `rFound  $($bpfilepath) " -Debug  >> $currentfileoutput              
        }
        # if the counterpart exists now do the compare and track the diffs
        #Compare-Object (gc .\sushifig-sfg-01.bradleyara.wc.1.0.0.74.web.config) (gc .\baconfig-sfg-01.bradleyara.wc.1.0.0.74.web.config)
        #now that we have have our files to compare let's see what we have:
        #renull everything
        
        $diffcount = (Compare-Object (gc $apfile) (gc $bpfile)).Count
        if($diffcount -gt 0){
   

            #region Replacement to remove "bacon"
            # cat .\baconfig-sfg-01.bradleyara.wc.1.0.0.74.web.config | %{$_ -replace "bacon",""} > bpnew.txt
            ### no need to use this sed -i.bak 's/bacon//g' $bpFile
            $replacementfile = "$($bpfile.Name)__"
            cat $bpfile | %{$_ -replace "bacon",""} > $replacementfile
            $diff2s = (Compare-Object (gc $apfile) (gc $replacementfile)|sort InputObject)
            $diffcountAfterReplacement = (Compare-Object (gc $apfile) (gc $replacementfile)).Count
            if($diffcountAfterReplacement -gt 0){
                
                ##now check if the diff has something to do with the FileInfo DefaultRootFilePath - which makes sense since the directory is differents
                ## check if there are only 2 diffs if there are then we can ignore the ones for DefaultRootFilePath
                
                $currentfileoutput = $localcompare + $thiscomparison + "\"+(((($apfile.Name) -split '\.\.')[1]+"__"+(($apfile.Name) -split '\.\.')[0])+"__"+(($apfile.Name) -split '\.\.')[2]) -replace ".web.config",".diffs"   
                write-output "====== $($apfile.Name) <<<<======>>> $bpfile ======" >> $currentfileoutput              
                    
                #write-output  "     MoreThan2Diffs "  
                write-output  "`t`t$($bpfile.Name)__ has ** $($diffcountAfterReplacement) ** diffs"  >> $currentfileoutput              
                #write-output $diff2s | sort InputObject | fl 
                foreach($d in ($diff2s | sort InputObject)){
                    
                    write-output "`t`t$($d.SideIndicator) $($d.InputObject)" >> $currentfileoutput              
                    
                }
                write-output "===================================="
                    ## report the diffs
                    $differences.apfile = $apfile.Name
                    $differences.bpfile = $replacementfile
                    $differences.diffcount = $diffcountAfterReplacement
                    $differences.raw = $diff2s.InputObject
                
                #write-output $differences.raw[0]
            }
            #endregion    
        }
        
      #  $body = $body | Out-String
        #write-host $body
        
        #$body >> $currentfileoutput       

    }#foreach end

    #endregion 

}

write-host $time

<#

$MailMessage  = @{
From = "sushiju-firep@disenza.com"
To = "firep@disenza.com"
Subject = "Web.config Comparison"
SMTPServer = "smtp.disenza.com"
Body = $body
}

Send-MailMessage @MailMessage

#>
