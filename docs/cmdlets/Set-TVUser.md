---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Set-TVUser

## SYNOPSIS
Modify an existing Teamviewer user

## SYNTAX

### ByIdentity
```
Set-TVUser [-Token <String>] -Identity <TVUser> [-Name <String>] [-Email <String>] [-Permissions <String[]>]
 [-Password <SecureString>] [-Active <Boolean>] [-QuickJoinID <String>] [-QuickSupportID <String>]
 [<CommonParameters>]
```

### ById
```
Set-TVUser [-Token <String>] -UserID <String> [-Name <String>] [-Email <String>] [-Permissions <String[]>]
 [-Password <SecureString>] [-Active <Boolean>] [-QuickJoinID <String>] [-QuickSupportID <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Modify an existing Teamviewer User

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### -Identity
a TVUser Object fetched by Get-TVUser

```yaml
Type: TVUser
Parameter Sets: ByIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserID
The userID of a Teamviewer user

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The new name of the Teamviewer user

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

### -Email
The new email address of the Teamviewer user

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

### -Permissions
{{Fill Permissions Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
The password for the Teamviewer user

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Active
Indicates that the user should be active or not

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuickJoinID
The QuickJoinID for the Teamviewer user

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

### -QuickSupportID
The QuickSupportID for the Teamviewer user

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TVUser

## NOTES

## RELATED LINKS

[Get-TVUser]()

[New-TVUser]()

