# TeamViewer Powershell Module

<!--
[![Build status](https://ci.appveyor.com/api/projects/status/1n8li43y0b2aydru?svg=true)](https://ci.appveyor.com/project/Marcuzzo/psteamviewer)
[![Documentation Status](https://readthedocs.org/projects/psteamviewer/badge/?version=latest)](http://psteamviewer.readthedocs.io/en/latest/?badge=latest)
-->

This is a PowerShell module API wrapper for the [TeamViewer API](https://integrate.teamviewer.com/en/develop/api/).

## Description

This is a Powershell module to interact with the TeamViewer API.  
> *This is still a work in progress and some functions have not been tested.*

## Installing

The 'old' module is available on [PowershellGallery](https://www.powershellgallery.com/packages/PSTeamViewer)

```powershell
Install-Module -Name PSTeamViewer
```

## Documentation

The documentation of the CmdLets can be viewed on the terminal with Get-Help and in the online [documentation](http://psteamviewer.readthedocs.io/en/latest/).

## Examples

```powershell
Import-Module PSTeamViewer

# I recommend storing your API Token in an environmentvariable

## Get All users
Get-TVUser -Token $env:TeamViewerToken

## Get a user by name
Get-TVUser -Token $env:TeamViewerToken -Name '[USERNAME]'

## Get user by UserID
Get-TVUser -Token $env:TeamViewerToken -UserID '[USERID]'


# Modify a user
$User = Get-TVUser -Token $env:TeamViewerToken -UserID '[USERID]'
$User | Set-TVUser -Token $env:TeamViewerToken -Name '[NEW_NAME]' -Active $false

# Disable a TVUser
$User | Set-TVUser -Token $env:TeamViewerToken -Active $false

# Get all TVGroups
Get-TVGroup -Token $env:TeamViewerToken

# Get a specific group by name
Get-TVGroup -Token $env:TeamViewerToken -Name '[GROUPNAME]'

# Get a specific group by ID
Get-TVGroup -Token $env:TeamViewerToken -GroupID '[GROUPID]'

# Create a new group
$Group = New-TVGroup -Token $env:TeamViewerToken -Name '[GROUPNAME]'

# Rename a Group
$Group = Get-TVGroup -Token $env:TeamViewerToken -GroupID '[GROUPID]'
$Group | Set-TVGroup -Token $env:TeamViewerToken -NewName '[NEW_GROUPNAME]'

# Delete a Group
$Group | Remove-TVGroup -Token $env:TeamViewerToken



```

Example scripts can be found in the [examples](./examples) directory.

## Contributing

This module is still under development but basic functionality is present and somewhat tested.
You are more then welcome contribute to this module. Check out the ( [online](http://psteamviewer.readthedocs.io/en/latest/) ) [documentation](./docs).
