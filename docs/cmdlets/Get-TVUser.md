---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Get-TVUser

## SYNOPSIS
Get Teamviewer user(s)

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
Get the details of one or more users from the Teamviewer management portal

## EXAMPLES

### EXAMPLE 1
```
Get-TVUser -Token $Env:TeamViewerToken
```

Gets all Teamviewer Users

### EXAMPLE 2
```
Get-TVUser -Token $Env:TeamViewerToken -Name 'John Doe'
```

Gets the user or all users with the name 'John Doe'

### EXAMPLE 3
```
Get-TVUser -Token $Env:TeamViewerToken -Email 'john.doe@domain.com'
```

Gets the user with the specified email address.

## PARAMETERS

### -Token
The Teamviewer API token

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
The ID of the user on the Teamviewer portal

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
The name of the user

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
The email address of the user

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
Permissions assigned to a user

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
minimize the output of the CmdLet

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You can't pipe objects to the Get-TVUser CmdLet

## OUTPUTS

### TVUser. a TVUser object or an array of TVUser Objects

## NOTES
Author: Marco Micozzi

## RELATED LINKS

[New-TVUSer]()

[Set-TVUser]()

