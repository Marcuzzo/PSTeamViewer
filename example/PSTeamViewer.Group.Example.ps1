[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $true
    )]
    [string] $GroupName,
    
    [Parameter(
        Mandatory = $true
    )]
    [string[]] $Email, 

    [Parameter()]
    [switch] $Remove

)

Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

# Store your token in an environment variable 
[string] $Token = $env:TVAccessToken

# Initialize the API
Initialize-TVAPI -Token $Token 

# Get the group object
$group = Get-TVGroup -Token $Token -Name $GroupName


foreach ( $EmailAddress in $Email )
{
    $user = Get-TVuser -Token $Token -Email $EmailAddress

    if ( $Remove.IsPresent)
    {
        Remove-TVGroupMember -Group $group -User $user 
    }
    else
    {
        Add-TVGroupMember -Group $group -TVUser $user 
    }

}


Remove-Module -Name PSTeamViewer