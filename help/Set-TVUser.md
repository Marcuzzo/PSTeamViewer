---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version: 
schema: 2.0.0
---

# Set-TVUser

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### ByIdentity
```
Set-TVUser [-Token <String>] -Identity <TVUser> [-Name <String>] [-Email <String>] [-Permissions <String[]>]
 [-Password <String>] [-Active <Boolean>] [-QuickJoinID <String>] [-QuickSupportID <String>]
 [<CommonParameters>]
```

### ById
```
Set-TVUser [-Token <String>] -UserID <String> [-Name <String>] [-Email <String>] [-Permissions <String[]>]
 [-Password <String>] [-Active <Boolean>] [-QuickJoinID <String>] [-QuickSupportID <String>]
 [<CommonParameters>]
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

### -Active
{{Fill Active Description}}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
{{Fill Email Description}}

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

### -Identity
{{Fill Identity Description}}

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

### -Name
{{Fill Name Description}}

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

### -Password
{{Fill Password Description}}

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
Accepted values: None, ManageAdmins, ManageUsers, ShareOwnGroups, ViewAllConnections, ViewOwnConnections, EditConnections, DeleteConnections, EditFullProfile, ManagePolicies, AssignPolicies, AcknowledgeAllAlerts, AcknowledgeOwnAlerts, ViewAllAssets, ViewOwnAssets, EditAllCustomModuleConfigs, EditOwnCustomModuleConfigs

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuickJoinID
{{Fill QuickJoinID Description}}

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
{{Fill QuickSupportID Description}}

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

### -Token
{{Fill Token Description}}

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

### -UserID
{{Fill UserID Description}}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### TVUser

## OUTPUTS

### TVUser

## NOTES

## RELATED LINKS

