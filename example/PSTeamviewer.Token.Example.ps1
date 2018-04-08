[CmdletBinding()]
param(
    # Store your token in an environment variable
    [Parameter()]
    [string] $Token = $env:TVAccessToken
)


Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

 


# Initialize the API
Initialize-TVAPI -Token $Token 

# Get the Active Directory users based 
Get-TVUser | Where-Object {  ( $_.name -like '*,*'  ) -and ( $_.active -eq $true) }| ForEach-Object {

    [string[]] $Name = $_.Name -split ', '
    [string] $Surname = $Name[0]
    [string] $Givenname = $Name[1]

    Write-Verbose -Message ('Fetching user with surname: "{0}" and givenname: "{1}".' -f $Surname, $Givenname)

    Get-ADUser -Filter { ( ( Surname -eq $Surname ) -and ( GivenName -eq $Givenname ) )} | Select-Object -Property Name, UserPrincipalName, Givenname

}

Remove-Module -Name PSTeamViewer