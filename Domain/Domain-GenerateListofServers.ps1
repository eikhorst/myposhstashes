$servers = get-adcomputer -SearchBase 'dc=disenza,dc=com' -Filter '*' | ?{$_.Name -match '(A|B)P-'} | sort | select -ExpandProperty Name

#region Comma Separated
$txt = ""
$servers | %{$txt+= "$_, "}
$txt > Servers-CSV.txt
#endregion


#region Tab Separated
$txt = ""
$servers | %{$txt+= "$_`t"}
$txt > Servers-TabDelimited.txt
#endregion


#region Server Per Line
$txt = ""
$txt = $servers
$txt > Servers-LineDelimited.txt
#endregion

