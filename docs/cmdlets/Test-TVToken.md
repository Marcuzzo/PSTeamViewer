---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Test-TVToken

## SYNOPSIS
Test a TeamViewer API Token

## SYNTAX

```
Test-TVToken [-Token] <String> [<CommonParameters>]
```

## DESCRIPTION
Tests if a TeamViewer API token is valid

## EXAMPLES

### EXAMPLE 1
```
Test-TVToken -Token 'abc123def456ghi789'
```

Tests if the token 'abc123def456ghi789' is valid

## PARAMETERS

### -Token
The token generated on the TeamViewer Management Console

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES
Author: Marco Micozzi

## RELATED LINKS
