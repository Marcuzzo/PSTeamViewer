---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Get-TVDevice

## SYNOPSIS
Get Device information fom the Teamviewer portal

## SYNTAX

```
Get-TVDevice [[-Token] <String>] [[-OnlineState] <String>] [[-GroupID] <String>] [[-RemoteControlID] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get Device information fom the Teamviewer portal

## EXAMPLES

### EXAMPLE 1
```
Get-TVDevice -OnlineState Online
```

## PARAMETERS

### -Token
The API token generated on the portal

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

### -OnlineState
include online or offline devices

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: [string]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupID
Get all devices of a specific GroupID

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

### -RemoteControlID
Get the device with a specific RemotecontrolID

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TVDevice[]

## NOTES

## RELATED LINKS
