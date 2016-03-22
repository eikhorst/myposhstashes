#Accept input parameters 
Param( 
    [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $Office365Username, 
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $Office365Password 
) 
 
#Constant Variables 
$OutputFile = "MessageTrace.csv"   #The CSV Output file that is created, change for your purposes 
 
#Remove all existing Powershell sessions 
Get-PSSession | Remove-PSSession 
 
#Did they provide creds?  If not, ask them for it.
if (([string]::IsNullOrEmpty($Office365Username) -eq $false) -and ([string]::IsNullOrEmpty($Office365Password) -eq $false))
{
    $SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365Password -Force     
     
    #Build credentials object 
    $Office365Credentials  = New-Object System.Management.Automation.PSCredential $Office365Username, $SecureOffice365Password 
}
else
{
    #Build credentials object 
    $Office365Credentials  = Get-Credential
}
#Create remote Powershell session 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365credentials -Authentication Basic -AllowRedirection         

#Import the session 
Import-PSSession $Session -AllowClobber | Out-Null          
 
#Prepare Output file with headers 
Out-File -FilePath $OutputFile -InputObject "Received,SenderAddress,RecipientAddress,Subject,Status,ToIP,FromIP,Size" -Encoding UTF8
 
$dateEnd = get-date 
$dateStart = $dateEnd.AddDays(-14)
#$recipient = "ryan.schulz@disenza.com"

#Get all Mailboxes from Office 365 
$mailboxes = Get-Mailbox -ResultSize Unlimited 
write-host "Total # of Mailboxes: $($mailboxes.Count)"
#Iterate through all mailboxes, one at a time     
Foreach ($objmailbox in $mailboxes) 
{     
    #$objmailbox | Get-Member 
    #break;
    write-host $objmailbox.Name    
    write-host "Processing $($objmailbox.Name)..." 

    $failedmessages = Get-MessageTrace -StartDate $dateStart -EndDate $dateEnd -RecipientAddress $objmailbox.PrimarySmtpAddress | ?{$_.Status -eq "Failed"} 

    $Count = $failedmessages.Count

    write-host "Failed Message Count: $($Count) ..."
    
    Foreach ($failedmsg in $failedmessages) 
    {
      Out-File -FilePath $OutputFile -InputObject "$($failedmsg.Received),$($failedmsg.SenderAddress),$($failedmsg.RecipientAddress),$($failedmsg.Subject),$($failedmsg.Status),$($failedmsg.ToIP),$($failedmsg.FromIP),$($failedmsg.Size)" -Encoding UTF8 -append 
      write-host  " `t $($failedmsg.Received),$($failedmsg.SenderAddress),$($failedmsg.RecipientAddress),$($failedmsg.Subject),$($failedmsg.Status),$($failedmsg.ToIP),$($failedmsg.FromIP),$($failedmsg.Size) "
    }

    sleep 90
} 

#Clean up session 
Get-PSSession | Remove-PSSession 
