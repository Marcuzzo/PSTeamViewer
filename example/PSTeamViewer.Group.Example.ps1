[CmdletBinding()]
param()


Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

# Store your token in an environment variable 
[string] $Token = $env:TVAccessToken

# Initialize the API
Initialize-TVAPI -Token $Token 

Get-TVGroup -Token $Token -Name 'GroupName' 


Remove-Module -Name PSTeamViewer