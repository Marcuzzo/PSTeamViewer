---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Get-TVAccount

## SYNOPSIS
Get information about the current account.

## SYNTAX

```
Get-TVAccount [[-Token] <String>] [<CommonParameters>]
```

## DESCRIPTION
Retreives properties about the current account that made the API request.

## EXAMPLES

### Example 1
```
PS C:\> Get-TVAccount
```

Get the account details.
Note that an Initialize-TVAPI call is needed for this command to work without the Token Parameter.

### Example 2
```
PS C:\> Get-TVAccount -Token "TOKEN123"
```

Get the account details using a token.

## PARAMETERS

### -Token
The Access token for the TeamViewer API.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### TVAccount

## NOTES
author: Marco Micozzi

## RELATED LINKS
