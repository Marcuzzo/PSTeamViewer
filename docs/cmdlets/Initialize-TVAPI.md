---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Initialize-TVAPI

## SYNOPSIS
Initialize the TeamViewer API wrapper

## SYNTAX

```
Initialize-TVAPI [-Token] <String> [<CommonParameters>]
```

## DESCRIPTION
Initialize the TeamViewer API wrapper

## EXAMPLES

### EXAMPLE 1
```
Initialize-TVAPI -Token "ABCD-1234"
```

Initialize the TeamViewer API with the token "ABCD-1234"

## PARAMETERS

### -Token
The API token created on the management portal

```yaml
Type: String
Parameter Sets: (All)
Aliases: t

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
Initializing the wrapper will allow all API call's to be made without having to specify the token in each call

## RELATED LINKS
