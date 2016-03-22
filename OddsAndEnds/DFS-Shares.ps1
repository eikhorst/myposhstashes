$servers = @("primqa1-fil-01")
#$EnvBasket = Read-host -Prompt "examples: 'primrqa' or 'baconfig' "
$ClientShare = Read-host -Prompt "Provide the clientshare name"
$Remove = Read-Host -Prompt "Remove the share only - Y or N"
#  CASSIDAYSC_IUSR 
#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\dtss.txt
#$username = "disenza\da-firep"
#$password = cat c:\temp\dtss.txt | ConvertTo-SecureString
#$dtcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

foreach($server in $servers){
    #write the file local so it can be 
    write-host $ClientShare -f Blue
    if($Remove -eq "Y"){    
        $commandout = $ClientShare +"+RemoveY"
    }else{
        $commandout = $ClientShare +"+RemoveN"    
    }
    $cmdfile = "\\$($server)\g$\data\dfssharesetup.txt"
    write-host "\\$($server)\g$\data\dfssharesetup.txt" -f cyan
    $commandout > $cmdfile
    gc $cmdfile

    ##Connect to the server
    if(Test-Path "\\$($server)\g$\data"){
        $f1 = New-PSSession -ComputerName $server  #-Credential $dtcred # -UseSSL
       
       # Create the server share
        $command = { 

        #Setup initial variables
            $ClientShare = (cat "g:\data\dfssharesetup.txt").split('+')[0]            
            $remove = (cat "g:\data\dfssharesetup.txt").split('+')[1]
            $clientname = $ClientShare.Split('_')[0]
            $appPoolUser = "disenza\"+$clientname+"_Users"

                    #remove the share if Typed Y before
            if($remove -eq "RemoveY"){
                $removeshare = GWMI Win32_Share | ?{$_.Name -eq $ClientShare} 
                $removeshare.Delete()
            }
            else{
                #which g or f has fewer shares?
                $localsharepath = "G:\$($ClientShare)"
                if((dir g:).Count -gt (dir f:).Count){
                    $localsharepath = "F:\$($ClientShare)"
                }
            
                $ServerSharePath = "\\$($env:Computername)\$ClientShare\"
                write-host "******************" -f Yellow
                Write-host $ServerSharePath -f Yellow
                write-host $localsharepath  -f Yellow
                write-host "******************" -f Yellow
            #create the local client path
                write-host "creating: $($localsharepath)"
                if(!(test-path $localsharepath)){
                    new-item -Path $localsharepath -ItemType Directory
                }
            
                $comp=[WMICLASS]"Win32_share"

            # Create a new share
                write-host "making the share"            
                $comp.create("$($localsharepath)",$ClientShare,0)


            #Set up the permissions on the share        

                $acl = Get-Acl $localsharepath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($appPoolUser,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
                $acl.AddAccessRule($rule);
                $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
                $acl.AddAccessRule($rule2);
                Write-Host "Giving Modify access to $appPoolUser for $localsharepath"
                <#foreach($right in @('ReadAndExecute','Write','Modify')) {
	                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", $right, "ContainerInherit, ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule);
                }#>
                Set-Acl $localsharepath $acl

                get-acl $localsharepath | FL 
                
                ## now set up the share permissions
                #remove everyone's permissions
                Revoke-SmbShareAccess -Name $client -AccountName "EveryOne" -Force 
                 Grant-SmbShareAccess -Name $client -AccountName "Authenticated Users" -AccessRight Change -Force
                 Grant-SmbShareAccess -Name $client -AccountName "baconSFTP-01\BvSsh_VirtualUsers" -AccessRight Full -Force

            }

        }
        
        ## used for creating the DFS share & members
        ##
        $command2 = {
        #Setup initial variables
            $ClientShare = (cat "g:\data\dfssharesetup.txt").split('+')[0]            
            $remove = (cat "g:\data\dfssharesetup.txt").split('+')[1]
            $clientname = $ClientShare.Split('_')[0]
            $appPoolUser = "disenza\"+$clientname+"_Users"        
            
            ## remove everyone

            ## + Authenticated users Modify access & leave admins the same

            ## + ACL for appPoolUsers group with Moodify access

        }
        
        # creates the fil server shares
        invoke-command -Session $f1 -scriptblock $command            

        # create the dfs shares and members
        invoke-command -Session $s1 -scriptblock $command2            


        # Remove # On next line if you want to delete a Session
        Get-PSSession | Remove-PSSession
    }

}