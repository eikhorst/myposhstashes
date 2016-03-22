Get-ADObject -filter 'objectclass -eq "user"' -properties * | select | export-csv -NoTypeInformation "c:\ADUsers.csv"


[Reflection.Assembly]::LoadWithPartialName(“System.Web”)
[System.Web.Security.Membership]::GeneratePassword(24,5)