$ProcExes = Get-WmiObject -Namespace rootcimv2 -Class CIM_ProcessExecutable


foreach ($item in $ProcExes)
{
    # Get the CIM_DataFile instance from the WMI path in Antecedent
    # Filter for only files that are NOT from Microsoft
    # Pass the CIM_DataFile object to the Select-Object cmdlet, and select only a few properties
    [wmi]"$($item.Antecedent)" | ? { $_.Manufacturer -ne 'Microsoft Corporation' } | select FileName,Extension,Manufacturer,Version
}