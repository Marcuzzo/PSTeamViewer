[CmdletBinding()]
param()


Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

# Store your token in an environment variable 
[string] $Token = $env:TVAccessToken

# Initialize the API
Initialize-TVAPI -Token $Token 

# Get the Active Directory users based 
#Get-TVUser | Where-Object {  ( $_.name -notlike '*,*'  ) -and ( $_.active -eq $true) }| ForEach-Object {
Get-TVUser | Where-Object {  $_.active -eq $true }| ForEach-Object {

	
    # This obviously only works if the names in 
    # the TeamViewer management console is correct
    [string[]] $Name = $_.Name -split ', '
    [string] $Surname = $Name[0]
    [string] $Givenname = $Name[1]

    Write-Verbose -Message ('Fetching user with surname: "{0}" and givenname: "{1}".' -f $Surname, $Givenname)

    Get-ADUser -Filter { ( ( Surname -eq $Surname ) -and ( GivenName -eq $Givenname ) )} | Select-Object -Property Name, UserPrincipalName, Givenname

}

