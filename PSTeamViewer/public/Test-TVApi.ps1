function Test-TVApi
{
    <#
    .SYNOPSIS
    Tests the validity of the Teamviewer Token
    .DESCRIPTION
    Tests the validity of the Teamviewer Token
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .EXAMPLE
    Test-TVApi -Token $env:TVToken
    Tests if the token stored in te TVToken Environment variable is valid
    .NOTES
    Author: Marco Micozzi
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Token
    )
    $response = Invoke-TVApiRequest -Token $Token -Resource ping
    return ( $response.token_valid -eq 'true')
}