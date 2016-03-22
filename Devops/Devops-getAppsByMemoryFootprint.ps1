function EmailMe ($subject , $body , $attachment ) {   
[string[]]$to = ("DSE-Deployment <DSE-deployment@disenzaswamy.com>","disenza-paleo-vintage-BLR-Support@disenza.com")
    $smtp = "relay-disenza.disenza.com"; $from = "soya.LittleAppresetter@disenza.com"
    #$attachment | Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
	Send-MailMessage –From $from –To $to –Subject $subject –Body "$body" –SmtpServer $smtp   
}

function AppPoolAction ([string]$appPoolname, [string]$comp,[bool]$stop)
{
	$appPool = Get-WmiObject -Authentication PacketPrivacy -Impersonation Impersonate -ComputerName $comp -namespace "root/MicrosoftIISv2" -class IIsApplicationPool | Where-Object {$_.Name -eq "W3SVC/AppPools/$appPoolname" }
	
	if($appPool)
	{		
	   if($stop)
	   {	   		
	      	$appPool.Stop()			
			$msg = "`r`nStopped $appPoolname on $comp " 
			Write-Output $msg; Write-Host $msg
	   }
	   if(!($stop))
	   {	   		
	      	$appPool.Start()
			$msg = "`rStarted $appPoolname on $comp "			
			Write-Output $msg; Write-Host $msg
	   }
	}
}
function ServerState ($SiteStatus){
	switch($SiteStatus)
	{
    	1{ "Starting" }
    	2{ "Started"  }
    	3{ "Stopping" }
		4{ "Stopped" }
    	5{ "Pausing" }
    	6{ "Paused" }
    	7{ "Continuing" }
    	default { "Unknown" }	
	}
}

function ApplyLittleAppresetterTo ($server, $Domain ){
    $objSites = [adsi]"IIS://$server/W3SVC"
	$strAppPoolID = ""
    $arrTempPaths = @()
	$LittleAppresetterHelper = "\\$server\d$\disenza\scripts\paleo-Appresetterhelper.csv"	
	$nl = [Environment]::NewLine
	$msg = "`rFound $server and searching IIS for $Domain"
	Write-Output $msg ; Write-Host $msg
	#region GetAppPool to recycle
    foreach ($objChild in $objSites.Psbase.children)
    {  
        if($objChild.KeyType -eq "IIsWebServer"){
        #    $objChild.Name # is an id 
     #Write-Output   "Gathering site info for: " $objChild.ServerComment # is the description                
            #$objChild.ServerState
            $objBindings = $objChild.ServerBindings
            $strBindings = ""
			#Write-Output "Looping through bindings"
            foreach($objBinding in $objBindings)
            {
                $arrBindings = $objBinding.Split(':')
                $strPort = $arrBindings[1]
                $strSite = $arrBindings[2]
        		$root = $objChild.Adspath + "/root" # is the root of the website directory
        		$site = [adsi]$root

				if(($strSite -imatch $Domain) -or ($strPort -imatch $Domain)){
	$msg = "`rFound $Domain on $server  "
	Write-Output $msg ; Write-Host $msg	
					##todo: got to here to match on the Domain, now get its appPool and the other sites' codegendirs                		                        					
					$strAppPoolID = $site.AppPoolId  
					$msg = "`rAppPool: $strAppPoolID  "
					Write-Output $msg ; Write-Host $msg	
                }
				
				#$strSiteState = ServerState -SiteStatus $objChild.ServerState.ToString()
				#Write-Output "The status of site:  "  $strSiteState
			}			
        }
    }
	#endregion GetAppPool to recycle
	
	#region Recycle AppPool & Delete Temp Paths
	$arrTempPaths = @()	
	$arrTempPaths = import-csv $LittleAppresetterHelper | where-object{$_.AppPool -match $strAppPoolID} | foreach {$_.CodeGenDir}
	if(($arrTempPaths -eq $null) -or($arrTempPaths -eq "")){ #now just recycle the appPool since there is nothing to delete
		$msg = "`rNo temp paths found "
		Write-Output $msg ; Write-Host $msg	
		$arrFindPaths = import-csv $LittleAppresetterHelper | where-object{$_.AppPool -match $strAppPoolID} | foreach{$_.Port}
		foreach($arrFindPath in $arrFindPaths){
			$try1 = "http://$server`:$arrFindPath/commonpages/iistp.aspx"
			$try2 = "http://$server`:$arrFindPath/webservices/api/iistp.aspx"
			$msg = " 
			`r$try1 
			`r$try2
			"
			Write-Output $msg; Write-Host $msg
		}
		#region stop appPool
		#$msg = "`rAttempting to stop appPool $strAppPoolID"
		#Write-Output $msg;Write-Host $msg		
		AppPoolAction -appPoolname $strAppPoolID -comp $server -stop $true	
		#endregion 	
		
		#region start appPool
		#$msg ="`rAttempting to start appPool $strAppPoolID  "
		#Write-Output $msg;Write-Host $msg
		AppPoolAction -appPoolname $strAppPoolID -comp $server -stop $false
		
		#endregion 		
	}
	else{
		$msg = "`r###These temp paths were found ### `r $arrTempPaths"
		Write-Output $msg;Write-Host $msg
		#region stop appPool
		$msg = "`rAttempting to stop appPool $strAppPoolID"
		Write-Output $msg;Write-Host $msg		
		AppPoolAction -appPoolname $strAppPoolID -comp $server -stop $true	
		#endregion 	
	$msg ="`rRemoving:"
Write-Output $msg; Write-Host $msg -foregroundcolor red
		foreach ($arrTempPath in $arrTempPaths){	
			$RemovePath = $arrTempPath -replace "C:", "\\$server\C$"		
			if(test-path $RemovePath){
				$msg = "`r'$RemovePath'"
				Write-Output $msg; Write-Host $msg -foregroundcolor red
				remove-item -Path $RemovePath -Force -Recurse
			}
		}    
	
		#region start appPool
		$msg ="`rAttempting to start appPool $strAppPoolID"
		Write-Output $msg;Write-Host $msg
		AppPoolAction -appPoolname $strAppPoolID -comp $server -stop $false
		
		#endregion 
		}
	#endregion		
		
	#region Get the PID Information
		
$msg= "
`r++++  $server  AppPools ++++ `r`n "
Write-Output $msg;Write-Host $msg
$ErrorActionPreference = "silentlycontinue"
#cd \\ctyfs-a01s\dsw\Misc
#cd E:\powershell
$r=""; $s="";
$r = .\psexec.exe /acceptEula \\$server c:\windows\system32\inetsrv\appcmd.exe list wp /xml
$xr = [xml]($r)
$xml = $xr.appcmd.WP

$s = .\psexec.exe /acceptEula \\$server cscript.exe iisapp.vbs

if($r -eq ""){$msg = $xml | foreach {$_.{WP.NAME}  + " : " + $_.{Apppool.name} + "`r`n"}}
elseif($s -eq ""){$msg = $s}
	
Write-Output $msg;Write-Host $msg

	
$procs = get-process w3wp -computername $server | sort "WorkingSet"
#@(
$i=0
$t = @()
$msg = "`r`n++++  w3wp Processes ++++`r`nNum, Server, Process, WorkingSet, NonPagedMem, Handle, PID `r`n" + $t
Write-Output $msg;Write-Host $msg
@(foreach($proc in $procs)
{	
   $NonPagedMem = [int]($proc.NPM/1024)
   $WorkingSet = [int64]($proc.WorkingSet64/1024)
   $VirtualMem = [int]($proc.VM/1MB)
   $handle = [int]($proc.handles)
   $ptime = [int]($proc.userprocessortime)
   $id= $proc.Id
   $machine = $proc.MachineName
   $process = $proc.ProcessName
   $procdata = new-object psobject
   $procdata | add-member noteproperty NonPagedMem $NonPagedMem
   $procdata | add-member noteproperty WorkingSet $WorkingSet 
   $procdata | add-member noteproperty machine $machine
   $procdata | add-member noteproperty process $process
   $procdata | add-member noteproperty handle $handle
   $procdata | add-member noteproperty PID $id

$t += $procdata | % { "#$i" +", "+$_.machine + ", " + $_.process + ", " + $_.WorkingSet + ", " + $_.NonPagedMem + ", " + $_.handle + ", " + $_.PID + "`r `n"; $i++ }		

})
$msg = "`n " + $t		
Write-Output $msg;Write-Host $msg
#$t += $procdata | % {$i=0} { "#$i" +", "+$_.machine + ", " + $_.process + ", " + $_.WorkingSet + ", " + $_.NonPagedMem + ", " + $_.handle + ", " + $_.PID + "`r`n"; $i++ }		

	#endregion Get the PID Information
	d
}
	

	$input1 = Read-Host "Enter Server:"
	$input2 = Read-Host "Enter Domain or Port:"
	$output = ""
	$outlog = "E:\disenza\scripts\LHOut_$input2.txt"
	$utility = gc env:computername
	$invoker = ([Environment]::UserDomainName + "\" + [Environment]::UserName)	
	
	$v = [Environment]::UserName; $v = $v.Replace("u","").Replace("m",""); $rname = $null
	$peeps = @{"key"="value"}
	foreach($peep in ($peeps.GetEnumerator() | Where-Object {$_.Value -eq $v} ) )
	{$rname = $peep.name}
	if($rname -ne $null){$invoker += " =  $rname"}
	
if(Test-Connection -Cn $input1 -BufferSize 16 -Count 1 -ea 0 -quiet){
    $msg = $Startruntime = Get-Date
    Write-Output $msg;Write-Host $msg
	$output  = ApplyLittleAppresetterTo -server $input1 -Domain $input2 
	$output > $outlog
}
else
{
	$msg =  "`rServer is unreachable, it did not respond to ping  "
	Write-Output $msg; Write-Host $msg -foregroundcolor red
}

#$out2 = gc $output
$msg = $Endruntime = Get-Date
Write-Output $msg;Write-Host $msg
EmailMe -subject "SSManual: LittleAppresetter : $input1 : $input2 " -body "
+++Time Start:      $Startruntime +++
$output

+++Time EnE:      $Endruntime +++
##################################
This job was run on 
Server:`t$utility 
Invoker:`t$invoker 
Location:`tE:\disenza\scripts\Appresetters\LittleAppresetter.ps1
" # -attachment $output

