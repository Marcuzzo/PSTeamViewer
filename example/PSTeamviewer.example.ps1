[CmdletBinding()]
param()

Write-Verbose -Message ('PSScriptRoot: "{0}".' -f $PSScriptRoot)
Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

[string] $Token = $env:TVAccessToken

Initialize-TVAPI -Token $Token 


#Get-TVUser 