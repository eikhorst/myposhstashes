$vm = Read-host
Enter-PSSession –ComputerName $vm -Credential disenza\da-firep
wuauclt /reportnow
Exit-PSSession