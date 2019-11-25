function Get-TVDevice
{
    <#
    .SYNOPSIS
    Get a TVDevice
    .DESCRIPTION
    Get a TVDevice
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER OnlineState
    Get a list of devices with a specific online state. Online or Offline.
    .PARAMETER GroupID
    Get all devices that are member of a specific group using the GroupID
    .PARAMETER RemoteControlID
    Get a specific TVDevice by it's RemoteControlID
    .EXAMPLE
    Get-TVDevice -Token $env:TVAccessToken
    Get all devices
    .EXAMPLE
    Get-TVDevice -Token $env:TVAccessToken -OnlineState 'Online'
    Get a list of all devices that are Online.
    .EXAMPLE
    Get-TVDevice -Token $env:TVAccessToken -OnlineState 'Offline'
    Get a list of all devices that are Offline.
    .EXAMPLE
    Get-TVDevice -Token $env:TVAccessToken -GroupID 'g123456'
    Get a list of all devices that are member of the group with ID: 'g123456g.
    .EXAMPLE
    Get-TVDevice -Token $env:TVAccessToken -RemoteControlID '123456789'
    Get the device with remote control id: '123456789.
    .LINK
    Set-TVDevice
    .LINK
    Remove-TVDevice
    #>
    [OutputType([TVDevice])]
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('Online', 'Offline')]
        [string] $OnlineState = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $GroupID = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $RemoteControlID = [string]::Empty
    )

    begin
    {
        [hashtable] $RequestBody = @{ }
    }
    process
    {
        if ( ! ( [string]::IsNullOrEmpty($OnlineState)))
        {
            $RequestBody.online_state = $OnlineState
        }

        if ( ! ( [string]::IsNullOrEmpty($GroupID)))
        {
            $RequestBody.groupid = $GroupID
        }

        if ( ! ( [string]::IsNullOrEmpty($RemoteControlID ) ) )
        {
            $RequestBody.remotecontrol_id = $RemoteControlID
        }

        $Response = Invoke-TVApiRequest -Token $Token -Resource devices -Method GET -RequestBody $RequestBody

        $Response.devices | ForEach-Object {

            Write-Verbose -Message $_

            if ($null -eq $_.last_seen)
            {
                $LastSeen = $null
            }
            else
            {
                $LastSeen = Get-Date -Date $_.last_seen
            }

            Write-Verbose -Message ('Last Seen: {0}' -f $LastSeen)
            [TVDevice] $TVDevice = New-Object -TypeName TVDevice -Property @{
                RemoteControlID   = $_.remotecontrol_id
                DeviceID          = $_.device_id
                Alias             = $_.alias
                GroupID           = $_.groupid
                OnlineStatus      = $_.online_state
                AssignedTo        = $_.assigned_to
                SupportedFeatures = $_.supported_features
                LastSeen          = $LastSeen
                PolicyID          = $_.policy_id
                Description       = $_.description
            }
            Write-Output $TVDevice
        }
    }
}