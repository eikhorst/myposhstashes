clear
###  Full list of servers
$servers = gc "\\ctyfs-a01s\dsw\mypow\AllServers.txt"
### for testing:
#$servers = @("ctyws-a21","ctyws-a76","ctywsp-a11")
### global vars:
$foundlistfile = $null
$addition = gc "\\ctyfs-a01s\dsw\mypow\DS\addition.txt"
$formsupdatedViaIIS = "E:\disenza\scripts\out\forms\AllUpdatedTodayViaIIS.txt"
clear-content $formsupdatedViaIIS 

"`tDomain`tFilePath`tIfSecured`tIsExpress`tActungRequired?" | out-file $formsupdatedViaIIS

function EmailMe ($subject , $body , $attachment ) {   
[string[]]$to = @("DSE-vintage <DSE-vintage@disenza.com>","terry@disenza.com","dublin@disenza.com","mac@disenza.com")
#[string[]]$to = @("firep@disenza.com")
    $smtp = "relay-disenza.disenza.com"; $from = "soya.ctyut-a10@disenzaswamy.com"
    if($attachment -ne $null){
        $attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
    }
    else{
        Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
    }
}

function Test-Site {
    param($URL)
    trap{
        write-host "Failed. Details: $($_.Exception)"        
        #exit 1
    }
    $proxy = "webproxy.disenza.com"
    $webclient = New-Object Net.WebClient
    write-host "`r`nTesting:  $URL"
    $T = "http://URL/uploadform.aspx?viewall=true"
    $T = $T -Replace "URL","$URL"
    #$webpage = $webclient.DownloadString($T)
    try{
        [net.httpWebRequest] $req = [net.webRequest]::create($T)
        $req.Proxy = new-object -typename system.net.webproxy -argumentlist "http://$proxy"
        $req.Method = "GET"; $req.ContentType = "text/html"; $req.Timeout = "15000"; $req.AllowAutoRedirect = $false;     
        [net.httpWebResponse] $res = $req.getResponse();
        $resst = $res.getResponseStream(); $sr = new-object IO.StreamReader($resst); $webpage = $sr.ReadToEnd(); $res.Close();        
        #$size = $webpage.Length    
                
        if(($res.StatusCode -eq 200) -AND ($webpage -imatch "delete")){
            return $true
        }
        else{
            return $false
        }
    }
    catch{ return $false }
}


$timetaken = measure-command{
    foreach($server in $servers)
    {
    
        if((Test-Path "\\$server\logfiles\") -AND ($server -notmatch "ctyws-a79") -AND ($server -notmatch "ctyws-a67") -AND ($server -notmatch "ctyws-a68")){
            
            $objSites = [adsi]"IIS://$server/W3SVC"
            Write-host $server ":::::::Start:::::::::::::::" -f Green -b Blue
            
            foreach ($objChild in $objSites.Psbase.children)
            {
                $fixneeded = $false
                if($objChild.KeyType -eq "IIsWebServer"){
                #Write-host $objChild.Name  # is an id 
                    Write-host $objChild.ServerComment # is the description                
                    $objChild.ServerState
                    $objBindings = $objChild.ServerBindings
                    $strSite = ""
                    foreach($objBinding in $objBindings)
                    {
                        $strSite = ""
                        $arrBindings = $objBinding.Split(':')
                        $strPort = $arrBindings[1]
                        $strSite = $arrBindings[2]
                        ## email link
                        $strEmailLink = "http://$($strSite)/uploadform.aspx"
                        
                        if(($strSite -notmatch 'ETDsoya.com') -and ($strSite -ne "")){ 
                        ##..........................
                        write-host $strSite -f Red
                        ### now here is where we start collecting data and testing this Domain.
                        ##..........................
                        ##         
                                          
                            ### NOW TEST IF THEY HAVE UPLOADS, if true, get out of loop and log the path and fix the directory:
                            $fixneeded =  Test-Site -URL $strSite; 
                            if($fixneeded){
                                
                                $root = $objChild.Adspath + "/root" # is the root of the website directory
                                $site = [adsi]$root            
                                
                               write-host $site.Path
                               ## >>>>>>>>>>>>>>>>>>>>>>> UPLOADFILE FIX BEGIN
                               if($site.Path -notmatch "`\`\*"){$uploadfile = "`\`\"+$server+"\"+($site.Path -Replace ":", "$")+"\uploadfile.aspx"}
                               else{$uploadfile = $site.Path.ToString()+"\uploadfile.aspx"}
                               Write-host $upload
                               if(Test-Path $uploadfile){rename-item -Path $uploadfile -NewName "$uploadfile.txt"}
                               ## >>>>>>>>>>>>>>>>>>>>>>> UPLOADFILE FIX END
                               
                                ## now inject that code to the file in this path
                                $secured = $false
                                if($site.Path -match ":"){
                                    $formpath = "`\`\"+$server+"\"+($site.Path -Replace ":", "$")+"\FCWSite\Features\General\uploadform.aspx"                                
                                }
                                else
                                {
                                    $formpath = $site.Path.ToString()+"\FCWSite\Features\General\uploadform.aspx"                                
                                }                            
                                    
                                $isExpress =$false
                                if(Test-Path($formpath -replace "General\\uploadform.aspx","_xpress\")){
                                    $isExpress = $true
                                } 
                                
                                if(test-path $formpath){ ## we need to check if it exists
                                    write-host "$formpath exists" ;       
                                    $seccheck = gc $formpath #| select -First 3
                                    
                                    if($seccheck -match "security"){write-host "$formpath found worE:security in file already, skipping"; $secured = $true}
                                    
                                    $formcontent = gc $formpath 
                                    ## we should gc the file also to grep through them.    
                                    $formcontent = $formcontent -replace "<!", "$addition`r`n<!"
                                    if(!$secured){
                                        
                                        write-host ">>> $strEmailLink  <<<" -f Blue -b Yellow
                                        $formsupdated += "`t$strEmailLink`t$formpath`tNotSecured"
                                        
                                        write-host "securing $formpath" -f red
                                        $formcontent | out-file $formpath
                                        
                                    }    
                                    else{
                                       $formsupdated += "`t$strEmailLink`t$formpath`tFileSecured"
                                    }  
                                    
                                    $formsupdated += "`t$isExpress"
                                        
                                    # test again to see if the update fixed it:
                                    $fixneeded2 =  Test-Site -URL $strSite;
                                    if($fixneeded2){
                                        Write-host "must investigate further http://$strSite/uploadform.aspx" -f red -b black
                                        $formsupdated += "`tFixStillNeeded`r" 
                                    } 
                                    else { $formsupdated += "`tFixWorked`r" } 
                                    
                                    if($formsupdated -ne ""){
                                        $formsupdated | out-file $formsupdatedViaIIS -Append
                                        $formsupdated = "" 
                                    }

                                    #break;
                                    
                                    #write-host $formcontent -f Red 
                                } ## END IF formpath file exists
                            if($formsupdated -ne ""){
                                $formsupdated | out-file $formsupdatedViaIIS -Append
                                $formsupdated = ""    
                            }
                                
                            } ## END IF FIXNEEDED
                        } ## END if check for external site
                    

                    }  ### Efor each Domain binding                                               
                } ## Eif webserver       
            } ## Eforeach site
 
        } ## EIf Server exists       
        
     
    }
    
    
}
$emailedresults = gc $formsupdatedViaIIS 
#if($emailedresults -eq ""){ $emailedresults = "Dells-soya is secured" }
EmailMe -subject "UploadForm Details" -body "This job is on 
Server:              \\ctyut-a10\D$\disenza\scripts\GetIISSites\FixUploadFormSites.ps1
Output attachment:   $formsupdatedViaIIS
Report Runtime:      $timetaken
Results:
$emailedresults" -attachment  $formsupdatedViaIIS
