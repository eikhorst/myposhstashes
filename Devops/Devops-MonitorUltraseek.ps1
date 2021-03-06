function Monitorcballey {
  Param([Parameter(Mandatory = $false,
                   ValueFromPipeLine = $false,
                   Position = 0)]
        [string]$svr = '.',
          [Parameter(Mandatory = $false,
                   ValueFromPipeLine = $false,
                   Position = 1)]
        [string]$jobcheck = '.')
     
    #this takes the list of directories in cballey data and builds the webservice urls
    $url = "http://{0}:8765/query.html?qt=law&col={1}"
    #$svr = "sushihelix-01.disenza.com"
    $to = @("DSE-vintage@disenza.com"); 
    $from = "$env:computername@disenza.com"
	#$to = @("disenzaOne.paleo-vintage-Pager-Primary-US@disenza.com","disenzaOne.paleo-vintage-Pager-Secondary@disenza.com","DSE-vintage-Pager-Primary@disenzaswamy.com"); $from = "cballey.ut13@disenzaone.com"
    $smtp = "localhost"
    #$proxy = "webproxy.disenza.com"
    $errorslog = Get-Content "C:\DSE\scripts\getMonitorcballey\errors_$svr.txt"
    $errorslogpath = "C:\DSE\scripts\getMonitorcballey\errors_$svr.txt"
    $outlogpath = "C:\DSE\scripts\getMonitorcballey\outs\"
    $errorslogTmpPath = "C:\DSE\scripts\getMonitorcballey\TMP.txt"    
    $lastCheckOut = "C:\DSE\scripts\getMonitorcballey\outs\last.txt"
    Remove-Item  $lastCheckOut 
    New-Item $lastCheckOut -type File   
    $DATE = get-date -format g
    $exclude = Get-Content "\\disenza.com\dfs\Operations\Scripts\Powershell\verity\getMonitorcballey\excluded.txt" ##TODO: might want to exclude this from even being added to the directory list as those are standard, but we can keep this in case we need to exclude other bad profiles
    $catalogs = Get-content "\\sushisched-env-01\Operations\Scripts\Powershell\verity\$svr.txt" #| Get-RanMax -count 5
     if($jobcheck -eq $true){
          Send-MailMessage –From $from –To "DSE-vintage@disenza.com" –Subject "Monitorcballey Exclusions:: " –Body "Exclusions are in place for logs, sample, tmp, and language to stop spamming, If there is anything else in this list should they be?:  $exclude
          
Go fix it here:  http`:`/`/$svr`:8765/admin/
          
		  If you need to just turn off the pager please go here to exclude the collection from monitoring:  \\disenza.com\dfs\Operations\Scripts\Powershell\verity\getMonitorcballey\excluded.txt" –SmtpServer $smtp   
     }
     else{     
	 New-Item -ItemType file $errorslogTmpPath
          foreach($catalog in $catalogs){
             if($exclude -notcontains $catalog ){
               $strOut = $url -f $svr, $catalog.TrimEnd();    #Write-Output $strOut
               #this part takes a url and can check the response
## check if the catalog is in the log so we can decide to              
##now we need to add the logging here, so we can track first
               try {
                    
                    $wc = New-Object System.Net.WebClient; 
                    #$wc.Proxy = new-object -typename system.net.webproxy -argumentlist "http://$proxy"
                    $result = $wc.DownloadString($strOut)          
                    Clear-Variable wc       
                    Write-output $strOut -ForegroundColor DarkYellow
                    $outnow = $outlogpath + $catalog + ".txt"
                    $result | out-file $outnow
                    if( [regex]::IsMatch($result, "No results were found for your search.") ){
                    ##TODO: We need to find a way to log what catalogs have had errors the last time it was tested.
                    #Easiest way is to pipe the catalog name to a file on error,
                         foreach($err in $errorslog){
                              if($catalog -eq $err){
Send-MailMessage –From $from –To $to –Subject "Monitorcballey:: $svr $catalog : 0 results" –Body "$strOut - $DATE - No results were found for law in $catalog.
Exclusions: $exclude

Go fix it here:  http`:`/`/$svr`:8765/admin/

If you need to exclude this catalog from paging, please put the name of the catalog to the end of this list in a new line:  \\disenza.com\dfs\Operations\Scripts\Powershell\verity\getMonitorcballey\excluded.txt" –SmtpServer $smtp                             
                              
                              $strOut | out-file $lastCheckOut -Append
                              }
                         }# check log for the catalog in error, is it in the log?
                         Add-Content $errorslogTmpPath $catalog
                    }
                    else{
                         #if([regex]::IsMatch($result, "error")){
                         #Send-MailMessage –From $from –To $to –Subject "$strOut contains the word error" –Body "$catalog - $DATE - The word error appears in the response." –SmtpServer $smtp
                         #}
                         #else{## if all is well:      
                         #Send-MailMessage –From $from –To $to –Subject "**$strOut is all good" –Body "$svr - $DATE" –SmtpServer $smtp
                         #}
                    }
               }
               catch {
               Write-output $errorslog -ForegroundColor DarkRed
                   if( (Get-Item $errorslogpath).Length -gt 0){#contains data
                  Write-output $strOut -ForegroundColor DarkRed
					   foreach($err in $errorslog){
								  if($catalog -eq $err){
						Send-MailMessage –From $from –To $to –Subject "Monitorcballey:: $svr $catalog resolved to an internal server error" –Body "$strOut - $DATE had a 500 error.  Go fix it here:  http`:`/`/$svr`:8765/admin/ " –SmtpServer $smtp                   
							 }
					}# check log for the catalog in error, is it in the log?
					}
					Add-Content $errorslogTmpPath $catalog
               }
             }          
          }
          Remove-Item $errorslogpath
          Rename-Item $errorslogTmpPath "errors_$svr.txt"
     }
}


