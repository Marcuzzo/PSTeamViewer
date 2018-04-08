---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Get-TVGroup

## SYNOPSIS
Get TeamViewer group information

## SYNTAX

```
Get-TVGroup [[-Token] <String>] [[-Name] <String>] [[-Shared] <Boolean>] [[-CompanyUserID] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get information about a teamviewer group via the API

## EXAMPLES

### EXAMPLE 1
```
Get-TVGroup -Token $Env:
```

## PARAMETERS

### -Token
The API token generated on the Teamviewer Management Console

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
The name of the group to fetch

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Shared
Wether or not to list shared groups.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompanyUserID
The admin ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: [string]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TVGroup

## NOTES

## RELATED LINKS
