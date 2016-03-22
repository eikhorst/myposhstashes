$r = Invoke-WebRequest http://sushigum-sgc-01:10784/_jojo/sites/edit/MILBERGLLP_WC65_L1
$r.Forms['site-form'].Fields.MaintenanceMessage = "Here is The Maintenance message" 
$r.Forms['site-form'].Fields.MaintenanceMode="3"
$r.Forms['site-form'].Fields.Sitename = "MILBERGLLP_WC65_L1"

 
Invoke-RestMethod http://sushigum-sgc-01:10784/_jojo/sites/edit/MILBERGLLP_WC65_L1 -Method POST -Body $r
