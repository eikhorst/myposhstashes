. c:\powershell\parts\emailme.ps1 -Executionpolicy RemoteSigned -force

Function GetCalData ( $serv, $mbox, $startd, $endd, $out ){
  
  $Service.ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $mbox);

        $FolderID = New-Object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar,$mbox)
        $CalendarFolder = [Microsoft.Exchange.WebServices.Data.CalendarFolder]::Bind($serv,$FolderID)
        $CalendarView = New-Object Microsoft.Exchange.WebServices.Data.CalendarView($startd,$endd,2013)
        $Calendarview.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
        $CalendarResult = $CalendarFolder.FindAppointments($CalendarView)
                
        #--> number of appts total
        $NumOfAppts = $CalendarResult.TotalCount        
        $Appointments = @()                    

        $Sum1 = $Sum2 = 0

        foreach ($Appointment in $CalendarResult.Items)
        {
            $Propset = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
            $Appointment.load($Propset)            
            #$reqattendees = $Appointment.RequiredAttendees.Address
           <# $internal = $true
            foreach($reqattendee in $reqattendees){     
                if($reqattendee -inotmatch "@disenza.com"){$internal = $false; }#write-host $reqattendee}                
            }
            if(!$internal){
            #--> each appt duration
                $Sum1 = $Sum1 + $Appointment.Duration }
            else{
                $Sum2 = $Sum2 + $Appointment.Duration } #>
                
        write-host $mbox ":::" $mbox -f yellow -b black # $reqattendees 
        $orgEmail = $Appointment.Organizer.ToString().Split(':',2)
        $orgEmail = $orgEmail.TrimEnd('\u003e')        

        #$orgstuff = $orgEmail | GM -MemberType Property

        Write-host $orgEmail[0].split('<')[0]
        $newline = New-Object Object 
        $newline | add-member -membertype noteproperty -name "Mailbox" -value $mbox
        $newline | add-member -membertype noteproperty -name "Organizer" -value $orgEmail[0].split('<')[0]
        $newline | add-member -membertype noteproperty -name "Start" -value $Appointment.Start.ToString() 
        if (([DateTime]$Appointment.Start -[DateTime]$Appointment.End).Days -eq "-1"){
            $newline | add-member -membertype noteproperty -name "Duration" -value "All Day Event"
        }else{
            $newline | add-member -membertype noteproperty -name "Duration" -value $Appointment.Duration.ToString()
        }
        
            $Appointments += $newline
        }        

        return $Appointments
}
                        
    ######====== Introduce Impersonator =====##########
    $MailboxName = "firep@disenza.com"
    #$iput = "c:\today\SMTP.txt"
    $iput = "c:\today\icrooms.txt"
    $oput = "c:\today\ocrooms.txt"
    
    $username = "svc1@disenza.com"
    $password = cat c:\temp\service365ss.txt | ConvertTo-SecureString    
    $PlainTextPassword= [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($password) ))
    #$svcAuth = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

    #Assign all date vars
    $StartDate = (Get-Date).AddDays(-1)    
    $EndDate = (Get-Date).AddDays(4)    
    $array = @()
    $DllPath = 'C:\Program Files\Microsoft\Exchange\Web Services\2.0\Microsoft.Exchange.WebServices.dll'
    [void][Reflection.Assembly]::LoadFile($DllPath)
    #just update it when you run this:
    # Using Get-Credential does not work, I don't think, so boohoo
    $Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($username,$PlainTextPassword)
    #$Credentials = $svcAuth
    $Service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP1)    
    $Service.Credentials = $Credentials
    #$Service.Url            

    $TestUrlCallback = {
        param ([string] $url)
        if ($url -eq "https://autodiscover-s.outlook.com/autodiscover/autodiscover.xml") {$true} else {$false}
    }
    $Service.AutodiscoverUrl($MailboxName, $TestUrlCallback)         
    
    #####  Read all mailboxes from csv
    $users = Get-content $iput
        $time = Measure-Command{
        
        Foreach($user in $users){                
        Write-host "Start - $user" -ForegroundColor DarkCyan
        $row = GetCalData -serv $Service -mbox $user -startd $StartDate -endd $EndDate -out $oput    
        $array += $row; $row = $null 
        Write-host "End - $user" -ForegroundColor DarkCyan
#            break        
        }

        $array = $array | sort-object @{Expression={$_[3]}; Ascending=$false;}
        $array | export-csv $oput -notypeinformation             
        $outfileoput = "c:\today\crooms_csv.txt"
        $outjsonfileoput = "c:\today\crooms_json.txt"

        $array | out-file $outfileoput          
       $array | ConvertTo-Json | Out-File $outjsonfileoput
       #$test | Out-File $oput
    }
    

    

EmailMe -To "firep@disenza.com" -From "webmaster@disenzaone.com" -Subject "the conference room schedules" -Body "$time" -Attachment $oput, $outjsonfileoput

