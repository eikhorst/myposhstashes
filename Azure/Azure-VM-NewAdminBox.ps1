Import-Module Servermanager

Add-WindowsFeature RSAT, Web-WebServer, Web-Mgmt-Tools, GPMC, UpdateServices

iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

choco install Conemu curl fiddler4 Firefox git git.install msysgit poshgit SourceTree winmerge winscp filezilla windowsazurepowershell


