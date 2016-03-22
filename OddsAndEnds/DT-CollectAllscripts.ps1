. \\ctyut-a10\D$\disenza\scripts\getweb.configs\fRecurseFoldersMatchFullFileName.ps1 -ExecutionPolicy ByPass -force

$directoriesToSearch = gc "\\ctyfs-a01s\dsw\mypow\scriptsdirs.txt"
$source = "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\byServer"
Remove-Item $source -Recurse
New-Item $source -type Directory

foreach($folder in $directoriesToSearch){
    $server = (($folder -replace ("\\\\","")) -split "\\")[0]
    $extensions = @("*.ps1","*.bat","*.pga","*.pgr","*.pgf","*.vbs")
    foreach($extension in $extensions){
        Get-ChildItemRecurse -path $folder -fileglob $extension -levels 5 >> \\ctyfs-a01s.ETDsoya.com\dsw\mypow\byServer\$server.txt
    }
}


$allcontainers = gci "\\ctyfs-a01s.ETDsoya.com\dsw\mypow\byServer\"
$MainCapture = "\\ctyws-a79\ds\PS1Files"
foreach($f in $allcontainers){
    #Collect this data
    $server = (($f.name -replace ("\\\\","")) -split "\\")[0]
    $server = $server -replace("\.txt","")
    Write-host "working on $server" -f red -b blue
    $files = gc $f.Fullname

    foreach($file in $files){
        $subf = ""
        $subf = Join-Path $MainCapture $server; write-host $subf -f blue -b yellow
        #if(!(Test-Path $subf)){New-Item -Type Directory $subf}
        $psfileparent = ($file -split "\\")

        $psfileparentFolderName = $psfileparent[$psfileparent.length - 2]
        $psfileName = $psfileparent[$psfileparent.length - 1]
        $subf += "`_$psfileparentFoldername`_$psfileName"
        Write-host "Creating: "+ $subf
        Copy-Item $file $subf
    }

}