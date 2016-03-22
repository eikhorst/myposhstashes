
## Data gets copied to here:  \\sushisftp-01\c$\DSE\www\azurelinks\data 
## Job runs every 4 hours on sushisched-env-01> DSE Reports - MakeAzureLinks
## Powershell Files are here: \\sushisched-env-01\Operations\Scripts\Reports\MakeAzureLinks.ps1

$timetaken = Measure-Command{
    #to filter:
    cd C:\git\repos\azure\Maintenance\
    $servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'bacon'} | select -Expand Name | sort
    #$servers = get-adcomputer -SearchBase 'OU=Web,OU=Servers,dc=disenza,dc=com' -Filter '*' | select -Expand Name | sort
    $servers = $servers -join ','
    ###### Call the script you want to use
    write-host "Will Run through $servers to install scripts in ServerSetup" -f DarkCyan

    .\2RunScript.ps1 -vms $servers 
               
}

write-host $timetaken