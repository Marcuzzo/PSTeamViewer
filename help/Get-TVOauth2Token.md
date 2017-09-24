---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version: 
schema: 2.0.0
---

# Get-TVOauth2Token

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### Grant
```
Get-TVOauth2Token -AuthorizationCode <String> [-RedirectURI <String>] -ClientID <String> -ClientSecret <String>
```

### RefreshToken
```
Get-TVOauth2Token -RefreshToken <String> -ClientID <String> -ClientSecret <String>
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AuthorizationCode
Authorization code acquired from the /oauth2/authorize page.

```yaml
Type: String
Parameter Sets: Grant
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientID
Client ID, a unique string that identifies the application.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Client ID, a unique string that identifies the application.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectURI
Must be the same value as in the previous call to /oauth2/authorize

```yaml
Type: String
Parameter Sets: Grant
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshToken
Refresh-token from a previous call.

```yaml
Type: String
Parameter Sets: RefreshToken
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

