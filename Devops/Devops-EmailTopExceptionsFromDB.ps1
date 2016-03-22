. E:\disenza\scripts\dailyExceptions\GetSqlQuery.ps1 -Executionpolicy RemoteSigned -force

#region 1.  Top 10 WC errors
$r = GetSqlQuery -sqlsvr "ctysql-a05r" -db "ErrorLogs" -q "select top 10 ApplicationName, sum(Frequency) as [NumOfErrors]
from exceptions
where DateLogged > DATEADD(hh, -24, GETDATE()) and (applicationname not like '%marketing%' and applicationname not like '%/_mc%' ESCAPE '/' and applicationname not like '% MC%')
group by APPLICATIONNAME
order by [NumOfErrors] desc
"

$results = "Top WC 10 apps with the most exceptions `t`r`n
ApplicationName, Number Of errors `t`r`n" 

foreach ($Row in $r)
{ 
  
  $star = ""
if($Row[1] -gt "10000"){$star = "**"}; if($Row[1] -gt "100000"){$star = "***"}
  
  $results +=  $($Row[0]) + ", " + $($Row[1]) + $star +" `t`r`n"
}

#endregion 1. Top 10 WC errors

#region 2. Top 10 MC errors
$r2 = GetSqlQuery -sqlsvr "ctysql-a05r" -db "ErrorLogs" -q "select top 10 APPLICATIONNAME,  sum(Frequency) as [NumOfErrors]
from exceptions
where DateLogged > DATEADD(hh, -24, GETDATE()) and (applicationname not like '%wapp%')and (applicationname like '%marketing%' or applicationname like '%mc%')
group by APPLICATIONNAME
order by [NumOfErrors] desc
"

$results2 = "Top MC 10 apps with the most exceptions `t`r`n
ApplicationName, Number Of errors `t`r`n" 

foreach ($Row2 in $r2)
{ 
  $star = ""
  if($Row2[1] -gt "10000"){$star = "**"}; if($Row2[1] -gt "100000"){$star = "***"}
  
  $results2 += $($Row2[0]) + "," + $($Row2[1]) + $star +" `t`r`n"
  
}
#endregion 2. Top 10 MC errors

$results

$results2

$dt  = Get-Date -Format "MM-dd-yyyy"
$fromname = $env:COMPUTERNAME +"-TopExceptions@disenzaone.com"
$archs = @("pamundson@disenza.com","efrus@disenza.com","molaughlin@disenza.com","ryan.schultz@disenza.com", "DSE-deployment@disenza.com","rhorner@disenza.com")
#$archs = "firep@disenza.com"
Send-MailMessage –From $fromname –To $archs –Subject "Top soya Exceptions $dt" –Body "$results

$results2

" –SmtpServer "relay-disenza.disenza.com" 