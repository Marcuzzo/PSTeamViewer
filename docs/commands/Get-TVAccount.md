---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version: 
schema: 2.0.0
---

# Get-TVAccount

## SYNOPSIS
Get information about the current account.

## SYNTAX

```
Get-TVAccount [[-Token] <String>]
```

## DESCRIPTION
Retreives properties about the current account that made the API request.

## EXAMPLES

### Example 1
```
PS C:\> Get-TVAccount
```

Get the account details.
Note that an Initialize-TVAPI call is needed for this command to work without the Token Parameter.

### Example 2
```
PS C:\> Get-TVAccount -Token "TOKEN123"
```

Get the account details using a token.

## PARAMETERS

### -Token
The Access token for the TeamViewer API.

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

## INPUTS

### None

## OUTPUTS

### TVAccount

## NOTES
author: Marco Micozzi

## RELATED LINKS

