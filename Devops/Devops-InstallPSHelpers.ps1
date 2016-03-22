(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

install-module posh-git
Import-Module sqlps -DisableNameChecking