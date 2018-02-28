---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Set-TVDevice

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### ByDeviceIDGroup
```
Set-TVDevice [[-Token] <String>] [-DeviceID] <String> [-Alias <String>] [-Description <String>]
 [-Passwd <String>] [-GroupID <String>] [-PassThru] [<CommonParameters>]
```

### ByDeviceIDPolicy
```
Set-TVDevice [[-Token] <String>] [-DeviceID] <String> [-Alias <String>] [-Description <String>]
 [-Passwd <String>] [-PolicyID <String>] [-PassThru] [<CommonParameters>]
```

### ByInputObjectGroup
```
Set-TVDevice [[-Token] <String>] [-InputObject] <TVDevice> [-Alias <String>] [-Description <String>]
 [-Passwd <String>] [-GroupID <String>] [-PassThru] [<CommonParameters>]
```

### ByInputObjectPolicy
```
Set-TVDevice [[-Token] <String>] [-InputObject] <TVDevice> [-Alias <String>] [-Description <String>]
 [-Passwd <String>] [-PolicyID <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Alias
{{Fill Alias Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{Fill Description Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceID
{{Fill DeviceID Description}}

```yaml
Type: String
Parameter Sets: ByDeviceIDGroup, ByDeviceIDPolicy
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupID
{{Fill GroupID Description}}

```yaml
Type: String
Parameter Sets: ByDeviceIDGroup, ByInputObjectGroup
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
{{Fill InputObject Description}}

```yaml
Type: TVDevice
Parameter Sets: ByInputObjectGroup, ByInputObjectPolicy
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
{{Fill PassThru Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passwd
{{Fill Passwd Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyID
{{Fill PolicyID Description}}

```yaml
Type: String
Parameter Sets: ByDeviceIDPolicy, ByInputObjectPolicy
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
{{Fill Token Description}}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None


## OUTPUTS

### TVDevice


## NOTES

## RELATED LINKS
