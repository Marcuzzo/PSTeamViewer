Class TVGroup : TVPrincipal
{
    [TVPrincipal] $Owner
    [ValidateNotNullOrEmpty()][string]$Permissions
    [ValidateNotNullOrEmpty()][string]$PolicyID
    [TVGroupUser[]] $SharedWith
    TVGroup (
        [string] $ID,
        [string] $Name,
        [TVPrincipal] $Owner,
        [string] $Permissions,
        [TVGroupUser[]] $SharedWith
    ) : base ( $ID, $Name )
    {
        $this.Owner = $Owner
        $this.Permissions = $Permissions
        $this.SharedWith = $SharedWith
    }
}