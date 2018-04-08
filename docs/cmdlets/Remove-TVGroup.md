---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Remove-TVGroup

## SYNOPSIS
Remove a Teamviewer group

## SYNTAX

### ByInputObject
```
Remove-TVGroup [-Token <String>] -InputObject <TVGroup> [-CompanyUserID <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByName
```
Remove-TVGroup [-Token <String>] -Name <String> [-CompanyUserID <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByID
```
Remove-TVGroup [-Token <String>] -GroupID <String> [-CompanyUserID <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove a Teamviewer group

## EXAMPLES

### EXAMPLE 1
```
Remove-TVGroup -Name 'TestGroup'
```

Removes the group "TestGroup" by name

### EXAMPLE 2
```
Get-TVGroup -Name 'TestGroup' | Remove-TVGroup
```

Removes the group 'TestGroup' by InputObject

### EXAMPLE 3
```
Remove-TVGroup -GroupID 'GRP1'
```

Removes the group with GroupID 'GRP1'

## PARAMETERS

### -Token
The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $script:TVConfig.AccessToken
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
an instance of TVGroup returned by Get-TVGroup

```yaml
Type: TVGroup
Parameter Sets: ByInputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The name of the TVGroup to be removed

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupID
The ID of the group to be removed

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompanyUserID
The ID of the administrator to remove a company group instead of a user group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: [string]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### TVGroup. The objects returned by the Get-TVGroup can be piped to the Remove-TVGroup CmdLet.

## OUTPUTS

### None. This CmdLet doesn't produce any output

## NOTES
Author: Marco Micozzi

## RELATED LINKS

[Get-TVGroup]()

[New-TVGroup]()

