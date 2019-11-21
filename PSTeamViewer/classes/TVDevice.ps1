Class TVDevice
{
    [string] $RemoteControlID
    [string] $DeviceID
    [string] $Alias
    [string] $GroupID
    [string] $OnlineStatus
    [bool] $AssignedTo
    [string] $SupportedFeatures
    [string] $Description
    [string] $PolicyID
    [string] $LastSeen

    # Dummy constructor
    TVDevice() { }

    TVDevice ( [string] $RemoteControlID,
        [string] $DeviceID,
        [string] $Alias,
        [string] $GroupID,
        [string] $OnlineStatus,
        [bool] $AssignedTo,
        [string] $SupportedFeatures,
        [string] $Description,
        [string] $PolicyID,
        [string] $LastSeen
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