Import-Module MSOnline

 function Connect-ExchangeOnline
 {
 $O365Cred = Get-Credential
 $O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $O365Cred -Authentication Basic -AllowRedirection
 Import-PSSession $O365Session
 Connect-MsolService -Credential $O365Cred
 }

 function Disconnect-ExchangeOnline
 {
   Remove-PSSession $O365Session
 }

 set-alias subl 'C:\Program Files\Sublime Text Build 3047 x64\sublime_text.exe'
 #set-alias git '%ProgramFiles%\Git\cmd'

 # Load posh-git example profile
. 'C:\tools\poshgit\dahlbyk-posh-git-8aecd99\profile.example.ps1'
