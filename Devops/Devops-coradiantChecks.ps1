. E:\disenza\scripts\CoradiantRpt\GetSqlQuery.ps1 -Executionpolicy RemoteSigned -force

#region 1. Invalidate Cache page requests
$r = GetSqlQuery -sqlsvr "ctybsql-a01\sqlp001" -db "coradiant" -q "select
       csHost, count(page_id) as PR, sum(sc_bytes) as DT
from coradiantpage
where url_stem_short = '/CommonPages/InvalidateCache.aspx'
and start_time_utc >=  CONVERT(varchar(10), DATEADD(day, -2, GETDATE()), 101)
and start_time_utc <   CONVERT(varchar(10), DATEADD(day, -1, GETDATE()), 101)
Group by csHost
order by PR desc
"

$results = "Invalidate Cache Requests
Host,Count,MB`r`n" 
if($r -ne $null){
    foreach ($Row in $r)
    { 
      $results += $($Row[0]) + "," + $($Row[1]) + "," + [math]::truncate($($Row[2])/1MB) + "`r`n"
    }
}
#endregion 1. Invalidate Cache page requests

#region 2. Email page summary requests
$r2 = GetSqlQuery -sqlsvr "ctybsql-a01\sqlp001" -db "coradiant" -q "select
       csHost, count(page_id) as PR, sum(sc_bytes) as DT
from coradiantpage
where
       ((url_stem_short like '%%email%%' or url_stem_short like '%%register%%') and url_stem_short not like '%%.gif%%' and url_stem_short not like '%%.js%%' and url_stem_short not like '%%.jpg%%' and url_stem_short not like '%%.png%%' and url_stem_short not like '%%.bmp%%' and url_stem_short not like '%%.cfm%%'and url_stem_short not like '%%.html%%'and url_stem_short not like '%%.pdf%%')
and start_time_utc >=  CONVERT(varchar(10), DATEADD(day, -2, GETDATE()), 101)
and start_time_utc <   CONVERT(varchar(10), DATEADD(day, -1, GETDATE()), 101)
and cs_method = 'post'	   
Group by csHost
having count(page_id) >100
order by PR desc
"

$results2 = "Email Page Summary
Host,Count,MB`r`n" 
if($r2 -ne $null){
    foreach ($Row2 in $r2)
    { 
      $results2 += $($Row2[0]) + "," + $($Row2[1]) + "," +  [math]::truncate($($Row2[2])/1MB) + "`r`n"  
    }
}
#endregion 2. Email page summary requests

#region 3. Email page requests
$r3 = GetSqlQuery -sqlsvr "ctybsql-a01\sqlp001" -db "coradiant" -q "select top 10
       csHost, url_stem_short, count(page_id) as PR, sum(sc_bytes) as DT
from coradiantpage
where ((url_stem_short like '%%email%%' or url_stem_short like '%%register%%') and url_stem_short not like '%%.gif%%' and url_stem_short not like '%%.js%%' and url_stem_short not like '%%.jpg%%' and url_stem_short not like '%%.png%%' and url_stem_short not like '%%.bmp%%' and url_stem_short not like '%%.cfm%%'and url_stem_short not like '%%.html%%'and url_stem_short not like '%%.pdf%%')
and  start_time_utc >=  CONVERT(varchar(10), DATEADD(day, -2, GETDATE()), 101)
and  start_time_utc <   CONVERT(varchar(10), DATEADD(day, -1, GETDATE()), 101)
and cs_method = 'post'	   
Group by csHost, url_stem_short
having count(page_id) >25
order by PR desc
"

$results3 = "Email Page Requests - problem children
Host,Stem,Count,MB`r`n" 
#if($Row3 -eq $null){$results3 = ""}
if($r3 -ne $null){
    foreach ($Row3 in $r3)
    { 
      $results3 += $($Row3[0]) + "," + $($Row3[1]) + "," + $($Row3[2]) + "," +  [math]::truncate($($Row3[3])/1MB) + "`r`n"
    }
}
#endregion 3. Email page requests

#region 4. Top Most Requests by site along with average data stansfer and number of requests
$r4 = GetSqlQuery -sqlsvr "ctybsql-a01\sqlp001" -db "coradiant" -q "select Top 10 cshost, Sum(sc_bytes) as [Total-DT], count(page_id) as PR from CoradiantPage
where  start_time_utc >=  CONVERT(varchar(10), DATEADD(day, -2, GETDATE()), 101)
and start_time_utc <   CONVERT(varchar(10), DATEADD(day, -1, GETDATE()), 101)
group by cshost
order by PR desc
"
$results4 = "Top Host by Page Requests`r`n
Host,DT(MB),Count`r`n"
if($r4 -ne $null){
    foreach ($Row4 in $r4)
    { 
      $results4 += $($Row4[0]) + "," + [math]::truncate($($Row4[1])/1MB) + "," + $($Row4[2]) + "`r`n"  
    }
}
#endregion Top Most Request

#___>

#region 5. Top IP addresses
$r5 = GetSqlQuery -sqlsvr "ctybsql-a01\sqlp001" -db "coradiant" -q "select top 15 c_ip, geo_organization, geo_dns_name, geo_metro_area, count(page_id) as PR, sum(sc_bytes) as DT
from coradiantpage
where  start_time_utc >=  CONVERT(varchar(10), DATEADD(day, -2, GETDATE()), 101)
and start_time_utc <   CONVERT(varchar(10), DATEADD(day, -1, GETDATE()), 101)
Group by c_ip, geo_organization, geo_dns_name, geo_metro_area
order by PR desc
"

$results5 = "Top IP addresses
`tIP, GeoOrg, dnsname, City, DT(MB), Count`r`n" 
if($r5 -ne $null){
    foreach ($Row5 in $r5)
    { 
      $results5 += "`t" + $($Row5[0]) + ", " + $($Row5[1]) + ", " + $($Row5[2]) + ", " + $($Row5[3]) + ", " + $($Row5[4]) + ", "+ [math]::truncate($($Row5[5])/1MB) + "`r`n"

    }
}
write-host $results5
#endregion 5 Top IP addresses


$dt  = Get-Date -Format "MM-dd-yyyy"
#EmailMe -To "firep@disenza.com" -From "HBAapps@disenza.com" -Subject "Coradiant Checks" -Body "$results"
Send-MailMessage –From "CoradiantChecksFromctybapp-a01@disenza.com" –To "DSE-deployment@disenza.com" –Subject "Coradiant Checks v5 $dt" –Body "$results

$results2

$results3

$results4

$results5
" –SmtpServer "internal.disenzahost.com" 