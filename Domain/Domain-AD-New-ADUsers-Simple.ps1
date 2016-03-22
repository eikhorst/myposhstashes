$users = gc 'C:\Users\da-firep\Desktop\AD user creates\adusers.txt'  ## for all users
#$users = @('CNH_iusr','WEIL_iusr')   ## for testing
$outfile = 'C:\Users\da-firep\Desktop\AD user creates\Newusers-testadscript.txt'
clear-content $outfile

foreach($user in $users){

    #$user = "SALESDEMO_IUSR"

    [Reflection.Assembly]::LoadWithPartialName(“System.Web”)
    $newpass = ([System.Web.Security.Membership]::GeneratePassword(24,5))
    write-host $newpass
    $newpass2 = (ConvertTo-SecureString -AsPlainText $newpass -Force)
    write-host $newpass2

    #####
    #   Adding new users
    #####

    ## Test if they exist first:
    if(!(Get-ADUser -Filter {SamAccountName -eq $user})){
        New-ADUser -Name $user -DisplayName $user -SamAccountName $user -PATH "OU=AppUsers,OU=Applications,DC=disenza,DC=com" -AccountPassword $newpass2 -Enabled $true -CannotChangePassword $true -PasswordNeverExpires $true
        
    }

    #####
    #   Adding users to group
    #####
    $group = ($user -split '_')[0]+"_Users"

    if(!(Get-ADGroup -Filter {SamAccountName -eq $group})){

        New-ADGroup -Name $group -SamAccountName $group -GroupScope Global -GroupCategory Security -PATH "OU=Groups,OU=Applications,DC=disenza,DC=com"

    }
    Add-ADGroupMember -Identity $group -Members $user
    "$user, $newpass, $group " | Out-File $outfile -Append

  
}


get-adgroup -Filter {SamAccountName -eq "CNH_users"}
get-adgroup -Filter {SamAccountName -eq "WEIL_users"}

cat $outfile