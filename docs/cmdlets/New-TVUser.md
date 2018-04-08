---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# New-TVUser

## SYNOPSIS
Create a new Teamviewer user.

## SYNTAX

```
New-TVUser [-Token <String>] -Name <String> -Email <String> -Password <SecureString> [-Language <String>]
 [-QuickSupportID <String>] [-QuickJoinID <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a new Teamviewer user

## EXAMPLES

### EXAMPLE 1
```
New-TVUser -Name 'John Doe' -Email 'john.doe@domain.com' -Passwprd (ConvertTo-SecureString -String "P4ssW0rd!" -AsPlainText -Force)
```

Creates a new user John Doe with email address john.doe@domain.com and password: P4ssW0rd!

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

### -Name
The name of the new Teamviewer user

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

### -Email
The email address of the new user.

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

### -Password
The password for the new user

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
2 Letter language code for the new user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: En
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuickSupportID
The QuickSupportID for the new user

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

### -QuickJoinID
The QuickJoinID for the new user

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TVUser

## NOTES
Author: Marco Micozzi

## RELATED LINKS

[Get-TVUser]()

[Set-TVUser]()

