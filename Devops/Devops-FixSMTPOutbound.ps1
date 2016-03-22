############################################
## Update SMTP Configuration Outbound Security
############################################
### Note: routeaction enables basic authentication
############################################

$ADSUtilPath = 'C:\inetpub\AdminScripts\adsutil.vbs'
$SMTPusername = "DSE-SendGrid-disenza-WEB@disenza.com"
[string]$SMTPpass = 'dFREYfJ4wjqDGyEBDzcaw7RK'
$SMTPaction = "264"

$ADSUtilExec1 = $ADSUtilPath + " set /smtpsvc/1/routeaction $SMTPaction" 
$ADSUtilExec2 = $ADSUtilPath + " set /smtpsvc/1/routeusername $SMTPusername"
$ADSUtilExec3 = $ADSUtilPath + " set /smtpsvc/1/routepassword $SMTPpass "
$CScript = 'C:\Windows\System32\CScript.exe'
	
		If (Test-Path $ADSUtilPath){
			Start-Process -FilePath $CScript -ArgumentList $ADSUtilExec1 -Wait
			Write-Host "  SMTP Outbound Security Username Parameter Has Been Updated To Basic Authentication" 

            Start-Sleep -Seconds 3

			Start-Process -FilePath $CScript -ArgumentList $ADSUtilExec2 -Wait
			Write-Host "  SMTP Outbound Security Username Parameter Has Been Updated To $SMTPusername" 

            Start-Sleep -Seconds 3
			
			#Start-Process -FilePath $CScript -ArgumentList $ADSUtilExec3 -Wait
			#Write-Host "  SMTP Outbound Security password parameter Has Been Updated $SMTPpass" 
		}
		Else{
			Write-Host "  Unable To Locate ADSUtil.vbs Script To Update Configuration"
		}