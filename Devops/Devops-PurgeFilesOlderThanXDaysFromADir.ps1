#$fulldir = "\\sushiocto\c$\Octopus\OctopusServer\Repository\Packages"
$fulldir = "E:\Temp"
$keep = 3 
clear-content E:\temp\purgejobs.log
<# Create 12 test files, 1 second after each other
1..12 | % {
    Remove-Item -Path "$fulldir\$_.txt" -ea SilentlyContinue
    $_ | Out-File "$fulldir\$_.txt"
    Start-Sleep -Seconds 1
}#>


if(Test-path $fulldir){  
  
    $firstlevelfolders = gci $fulldir | ? { $_.PSIsContainer } 
    #write-host $firstlevelfolders; break;
    $firstlevelfolders | %{ $files = ( gci $_.FullName -Recurse -force | ?{!$_.PSIsContainer})
        if($files.Count -gt $keep){
            $files | Sort-Object CreationTime| select-object -first ($files.Count - $keep) | Remove-item -force
        }
     }      
}
