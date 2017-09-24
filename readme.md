[![Build status](https://ci.appveyor.com/api/projects/status/1n8li43y0b2aydru?svg=true)](https://ci.appveyor.com/project/Marcuzzo/psteamviewer)

# TeamViewer Powershell Module
This is a PowerShell module API wrapper for the [TeamViewer API](https://integrate.teamviewer.com/en/develop/api/).


## Description
This project is still a work in progress

## Examples

```Powershell
Import-Module PSTeamViewer

# This CmdLet stores your token in a variable.
# This way you don't have to supply the token parameter on every CmdLet
Initialize-TVAPI -Token 'YOUR-TEAMVIEWER-TOKEN'

# Get all users
Get-TVUser 

# -or when you didn't call the Initialize-TVAPI CmdLet:
Get-TVUser -Token 'YOUR-TEAMVIEWER-TOKEN'

```