#while ($true){

measure-command{

    $interval = 5
    $servers = gc "\\ctyfs-a01s\dsw\mypow\AllsoyaServers.txt" #  AlldisenzaServersInAll3Domains.txt"
    $date = ((Get-Date).AddDays(1)).ToString("yyMMdd")
    foreach($server in $servers){
        $server = "\\"+$server
        
        $sizelog = "E:\disenza\scripts\smtp\$server`_$date.txt"
        $sizelog = $sizelog.replace("\\\","\")
        write-host $sizelog
        $smtpfolder = join-path $server -ChildPath "d$\disenza\logfiles\smtpsvc1\"
        if(test-path $smtpfolder){
            write-host $smtpfolder -BackgroundColor DarkGreen -ForegroundColor White
            #cd $smtpfolder    
            $currentsmtplog = gci $smtpfolder | ?{-not $_.PsIsContainer} | sort CreationTime | select -last 1                      
            
            $lastlines = 0; $gcilength = 0
            
            
            $gclines = ( gc $currentsmtplog | measure-object -line).Lines
            if(test-path $sizelog) { $lastlines =  ((gc $sizelog | select -last 1).Split(' '))[4] }
            
            $deltalines = $gclines - $lastlines
            
            if(test-path $currentsmtplog){ 
                $gcilength = (gci $currentsmtplog).Length 
            } 
            
            $timestamp = get-date -format hh:mm
         
            $currentsmtplog.Name.ToString() +" "+ $deltalines +" "+ $timestamp.ToString()+" "+ $gcilength + " " + $gclines | out-file $sizelog -Append
            
            if($deltalines -gt "5"){        
                $smtp = "relay-disenza.disenza.com"
                $body = "File LinesAdded Timestamp FileLength TotalLines`t`r`n" + $currentsmtplog.Name.ToString() +" "+ $deltalines +" "+ $timestamp.ToString()+" "+ $gcilength + " " + $gclines
                $to = @("firep@disenza.com","msnbc@disenza.com"); $from = $server+"_soyaLogSizeMonitor@disenzaone.com"
                $subject = "SSWarn (soya-" +  $server + ") 500 lines (~50emails) in the last 5 minutes"
                Send-MailMessage –From $from –To $to –Subject "$subject" –Body "$body" –SmtpServer $smtp 
                write-host "Mail sent from " $server
            }
        }
        else
        {
            Write-host "this server does not have an smtp folder"
        }
    }
    }
    
    [GC]::Collect()
    #sleep -seconds (60 * $interval) 
#}
