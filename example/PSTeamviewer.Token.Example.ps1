[CmdletBinding()]
param()


Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"

# Store your token in an environment variable 
[string] $Token = $env:TVAccessToken

# Initialize the API
Initialize-TVAPI -Token $Token 

# Get the Active Directory users based 
Get-TVUser | ForEach-Object {

    # This obviously only works if the names in 
    # the TeamViewer management console is correct
    Get-ADUser -Filter {Name -like "*$_*"} | Select-Object -Property Name, UserPrincipalName

}

