---
external help file: PSTeamViewer-help.xml
Module Name: PSTeamViewer
online version:
schema: 2.0.0
---

# Start-TVRemoteControl

## SYNOPSIS
Start a remote control session.

## SYNTAX

### ByRemoteControlID
```
Start-TVRemoteControl -RemoteControlID <String> [-Password <SecureString>] [-Mode <String>]
 [<CommonParameters>]
```

### ByInputObject
```
Start-TVRemoteControl -InputObject <TVDevice> [-Password <SecureString>] [-Mode <String>] [<CommonParameters>]
```

## DESCRIPTION
Start a remote control session.

## EXAMPLES

### EXAMPLE 1
```
Start-TVRemoteControl -RemoteControlID 'abc123'
```

Starts a session to the device with remotecontrol ID abc123 and prompts for a password

### EXAMPLE 2
```
Get-TVDevice | Where-Object {$_.Alias -eq 'PC0001'} |  Start-TVRemoteControl
```

Start a remote control session to the computer with name PC0001

## PARAMETERS

### -RemoteControlID
The remote control ID of a computer

```yaml
Type: String
Parameter Sets: ByRemoteControlID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
The TVDevice Object returned by the Get-TVDevice CmdLet

```yaml
Type: TVDevice
Parameter Sets: ByInputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
The password to connect to this computer.

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

### -Mode
The mode to connect to the remote computer.
Defaults to 'Remote Control' if omitted.
Valid values are 'vpn' or 'FileTransfer'

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

## NOTES
Author: Marco Micozzi

## RELATED LINKS
