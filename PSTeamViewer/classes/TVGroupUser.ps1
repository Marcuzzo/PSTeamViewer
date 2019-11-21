Class TVGroupUser : TVPrincipal
{
    [string] $Permissions = [string]::Empty
    [bool] $Pending = $false

    TVGroupUser() { }

    TVGroupUser ( $ID, $Name, $Permissions, $Pending)
    : base ( $ID, $Name)
    {
        $this.Permissions = $Permissions
        $this.Pending = $Pending
    }
    TVGroupUser ( $ID, $Name, $Permissions)
    : base ( $ID, $Name)
    {
        $this.Permissions = $Permissions
    }
}
