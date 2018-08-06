# TeamViewer Powershell Module

[![Build status](https://ci.appveyor.com/api/projects/status/1n8li43y0b2aydru?svg=true)](https://ci.appveyor.com/project/Marcuzzo/psteamviewer)
[![Documentation Status](https://readthedocs.org/projects/psteamviewer/badge/?version=latest)](http://psteamviewer.readthedocs.io/en/latest/?badge=latest)

This is a PowerShell module API wrapper for the [TeamViewer API](https://integrate.teamviewer.com/en/develop/api/).

## Description

This is a Powershell module to interact with the TeamViewer API.  
*This is still a work in progress*

## Installing

The module is available on [PowershellGallery](https://www.powershellgallery.com/packages/PSTeamViewer)

```powershell
Install-Module -Name PSTeamViewer 
```

## Documentation

The documentation of the CmdLets can be viewed on the terminal with Get-Help and in the online [documentation](http://psteamviewer.readthedocs.io/en/latest/).

## Examples

```powershell
Import-Module PSTeamViewer

# This CmdLet stores your token in a variable.
# This way you don't have to supply the token parameter on every CmdLet
Initialize-TVAPI -Token 'YOUR-TEAMVIEWER-TOKEN'

# Get all users
Get-TVUser

# -or when you didn't call the Initialize-TVAPI CmdLet:
Get-TVUser -Token 'YOUR-TEAMVIEWER-TOKEN'

```

Example scripts can be found in the [example](./example) directory.

## Contributing

This module is still under development but basic functionality is present and somewhat tested.
You are more then welcome contribute to this module. Check out the ( [online](http://psteamviewer.readthedocs.io/en/latest/) ) [documentation](./docs).
