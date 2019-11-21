function Get-TVDevice
{
    <#
    .SYNOPSIS
    Modify an existing TVDevice
    .DESCRIPTION
    Modify an existing TVDevice
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
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

            [TVDevice] $TVDevice = New-Object -TypeName TVDevice -Property @{
                RemoteControlID   = $_.remotecontrol_id
                DeviceID          = $_.device_id
                Alias             = $_.alias
                GroupID           = $_.groupid
                OnlineStatus      = $_.online_state
                AssignedTo        = $_.assigned_to
                SupportedFeatures = $_.supported_features
                LastSeen          = $_.last_seen
                PolicyID          = $_.policy_id
                Description       = $_.description
            }
            Write-Output $TVDevice
        }
    }
}