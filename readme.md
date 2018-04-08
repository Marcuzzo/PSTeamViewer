# TeamViewer Powershell Module

[![Build status](https://ci.appveyor.com/api/projects/status/1n8li43y0b2aydru?svg=true)](https://ci.appveyor.com/project/Marcuzzo/psteamviewer)
[![Documentation Status](https://readthedocs.org/projects/psteamviewer/badge/?version=latest)](http://psteamviewer.readthedocs.io/en/latest/?badge=latest)

This is a PowerShell module API wrapper for the [TeamViewer API](https://integrate.teamviewer.com/en/develop/api/).

## Description

This project is still a work in progress

## Install

The module is available on [PowershellGallery](https://www.powershellgallery.com/packages/PSTeamViewer)

```powershell
Install-Module -Name PSTeamViewer 
```

## Available CmdLets

* Initialize-TVAPI
* Test-TVToken
* Get-TVOauth2Token
* Get-TVAccount
* Get-TVUser
* Set-TVUser
* New-TVUser
* Get-TVGroup
* New-TVGroup
* Remove-TVGroup
* Get-TVDevice

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

Example scripts can be found in the `example` directory