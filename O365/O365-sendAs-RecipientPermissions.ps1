Get-RecipientPermission -Identity feds@disenza.com | Select Trustee, AccessControlType, AccessRights

Add-RecipientPermission -Identity feds@disenza.com -Trustee ppiekarczyk@disenza.com -AccessRights SendAs -Confirm:$false