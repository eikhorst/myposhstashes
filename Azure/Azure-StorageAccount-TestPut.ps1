
$servers = get-adcomputer -SearchBase 'OU=Servers,dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match 'sushi(FIG|GUM|HAM|ICE|1st)-(FIL|SQL)'} | select -Expand Name | sort
$myCtx=New-AzureStorageContext skiapperfmonlogs rM+hEVsAURETDuviE2W9dv26HdU9diTseUf6NNSYVrM4KseJV/qt2470/Ka//Uq0ISMeHcWnXETX8tFA5d6Kbtw==


#write-host $servers -f DarkYellow

foreach($vm in $servers){
$serverpath = "\\"+$vm+"\c$\Perflogs\"
    if(Test-Path $serverpath){
        #backit up
        $files = gci $serverpath
        cd $serverpath
        foreach($file in $files){
            if(!$file.PSIsContainer){

                $nameblob = $file.Name
                Set-AzureStorageBlobContent -Blob $nameblob -Container 'filesql' -File $file.FullName -Context $myCtx
            }
        }
    }
}

#Set-AzureStorageBlobContent -Blob 'sushi1ST-FIL-01_Perflog_02011707.blg' -Container 'filesql' -File $file.FullName -Context $myCtx
