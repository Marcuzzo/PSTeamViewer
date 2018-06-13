[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $true
    )]
    [string] $GroupName,
    
    [Parameter(
        Mandatory = $true
    )]
    [string] $Email

)

Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

# Store your token in an environment variable 
[string] $Token = $env:TVAccessToken

# Initialize the API
Initialize-TVAPI -Token $Token 

$group = Get-TVGroup -Token $Token -Name $GroupName
$user = Get-TVuser -Token $Token -Email $Email

Add-TVGroupMember -Group $group -User $user 
#Remove-TVGroupMember -Group $group -User $user 

Remove-Module -Name PSTeamViewer