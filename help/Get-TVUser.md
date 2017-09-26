---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version: 
schema: 2.0.0
---

# Get-TVUser

## SYNOPSIS
Get Teamviewer User

## SYNTAX

### All (Default)
```
Get-TVUser [-Token <String>] [-Simple] [<CommonParameters>]
```

### ByID
```
Get-TVUser [-Token <String>] -UserID <String[]> [-Simple] [<CommonParameters>]
```

### ByName
```
Get-TVUser [-Token <String>] -Name <String> [-Simple] [<CommonParameters>]
```

### ByEmail
```
Get-TVUser [-Token <String>] -Email <String[]> [-Simple] [<CommonParameters>]
```

### ByPermission
```
Get-TVUser [-Token <String>] -Permission <String[]> [-Simple] [<CommonParameters>]
```

## DESCRIPTION
Get Teamviewer User

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-TVUser -Verbose | Where-Object { $_.Active -eq $false }
```

## PARAMETERS

### -Token
{{Fill Token Description}}

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

### -UserID
{{Fill UserID Description}}

```yaml
Type: String[]
Parameter Sets: ByID
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{Fill Name Description}}

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

### -Email
{{Fill Email Description}}

```yaml
Type: String[]
Parameter Sets: ByEmail
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Permission
{{Fill Permission Description}}

```yaml
Type: String[]
Parameter Sets: ByPermission
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Simple
{{Fill Simple Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TVUser[]

## NOTES

## RELATED LINKS

