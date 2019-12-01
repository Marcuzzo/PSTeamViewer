<#
    TVDevice Class.
    This device represents the json data as returned by the Teamviewer API documentation (Version 13.2.0).
    See section 'Devices' on page 51 for more information.
#>
Class TVDevice
{

    #region Fields

    <#
        The ID that is unique for this entry of the computers & contacts list.
        - Values are always prefixed with a ‘d’.
    #>
    [string] $DeviceID

    <#
        The ID that is unique to this device and can be used to start a remote control session.
    #>
    [string] $RemoteControlID

    <#
        The ID of the group that this device is a member of.
    #>
    [string] $GroupID

    <#
        The alias that the current user has given to this device.
    #>
    [string] $Alias

    <#
        The description that the current user has entered for this device.
    #>
    [string] $Description

    <#
        The current online state of the device.
        * Possible values are: online, offline.
    #>
    [string] $OnlineStatus

    <#
        The features supported by the device.
        * Possible values are: chat, remote_control.
    #>
    [string] $SupportedFeatures

    <#
        Indicates whether the device is assigned to the current user.
        * Possible values are: true, false.
    #>
    [bool] $AssignedTo

    <#
        ID of the policy that is assigned to the device.
        * Possible values are: a policy_id, inherit.
        License restrictions apply, see chapter Licensing.
    #>
    [string] $PolicyID

    <#
        The timestamp of the last time, the device was online.
        Is not returned if the device is currently online.
        Only available if the device is assigned to the current user.
    #>
    [Nullable[DateTime]] $LastSeen

    #endregion

    <#
        Default constructor
    #>
    TVDevice() { }

    <#
        Constructor with arguments
    #>
    TVDevice ( [string] $RemoteControlID,
        [string] $DeviceID,
        [string] $Alias,
        [string] $GroupID,
        [string] $OnlineStatus,
        [bool] $AssignedTo,
        [string] $SupportedFeatures,
        [string] $Description,
        [string] $PolicyID,
        [Nullable[DateTime]] $LastSeen
    )
    {
        $this.Alias = $Alias
        $this.AssignedTo = $AssignedTo
        $this.DeviceID = $DeviceID
        $this.GroupID = $GroupID
        $this.OnlineStatus = $OnlineStatus
        $this.RemoteControlID = $RemoteControlID
        $this.SupportedFeatures = $SupportedFeatures
        $this.Description = $Description
        $this.PolicyID = $PolicyID
        $this.LastSeen = $LastSeen
    }
}