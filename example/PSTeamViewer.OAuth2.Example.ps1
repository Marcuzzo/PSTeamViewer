[CmdletBinding()]
param()

# Import the module
Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"


# This will open a popup window where you need to enter your TeamViewer credentials
# Copy the Token from this window after granting access
Get-TVOAuth2Authorization -ClientID $env:TVClientID -RedirectURI $env:TVRedirectURI

# Get the Access Token
[TVToken] $Token = Get-TVOauth2Token -AuthorizationCode 'TOKEN-SAVED-FROM-THE-POPUP' -RedirectURI $env:TVRedirectURI -ClientID $env:TVClientID -ClientSecret $env:TVClientSecret

if ( ! ( $Token.Expired) ) {
    Initialize-TVAPI -Token $Token.Access 
}

# after a while your token will have expired
if ( $Token.Expired)
{
    #refresh token
    $Token = Get-TVOauth2Token -RefreshToken $Token.Refresh -ClientID $env:TVClientID -ClientSecret $env:TVClientSecret

}

# Test if the token is Valid
Test-TVToken -Token $Token.Access