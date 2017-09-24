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
Get-TVUser [-Token <String>] [-Simple]
```

### ByID
```
Get-TVUser [-Token <String>] -UserID <String[]> [-Simple]
```

### ByName
```
Get-TVUser [-Token <String>] -Name <String> [-Simple]
```

### ByEmail
```
Get-TVUser [-Token <String>] -Email <String[]> [-Simple]
```

### ByPermission
```
Get-TVUser [-Token <String>] -Permission <String[]> [-Simple]
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

## INPUTS

## OUTPUTS

### TVUser[]

## NOTES

## RELATED LINKS

