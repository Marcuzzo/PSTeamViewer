---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# New-TVGroup

## SYNOPSIS
Create a new TeamViewer Group

## SYNTAX

```
New-TVGroup [[-Token] <String>] [-Name] <String[]> [[-CompanyUserID] <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a new TeamViewer Group

## EXAMPLES

### EXAMPLE 1
```
New-TVGroup -Token $env:TeamviewerToken -Name 'MyTestGroup'
```

Creates the group MyTestGroup

## PARAMETERS

### -Token
The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $script:TVConfig.AccessToken
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the new group

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompanyUserID
Administrator user ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: [string]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to New-TVGroup

## OUTPUTS

### TVGroup. New-TVGroup will return the newly created TVGroup object

## NOTES
Author: Marco Micozzi

## RELATED LINKS

[Get-TVGroup]()

[Remove-TVGroup]()

