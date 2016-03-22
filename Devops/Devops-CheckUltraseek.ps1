$cballeys = @("ctyut-a01","ctyut-a02","ctyut-a04","ctyut-a07","ctyut-a11","ctyut-a12","ctyut-a13")
$Serv = "cballey"
foreach($helix in $cballeys){
    get-service -ComputerName $helix -Name $Serv
}