$cred = Get-Credential #Read credentials
 $username = $cred.username
 $password = $cred.GetNetworkCredential().password

 # Get current Domain using logged-on user's credentials
 $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
 $Domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

if ($Domain.name -eq $null)
{
 write-host "Authentication failed - please verify your username and password."
 exit #terminate the script.
}
else
{
 write-host "Successfully authenticated with Domain $Domain.name"
}