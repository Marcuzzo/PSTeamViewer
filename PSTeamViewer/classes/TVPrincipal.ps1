class TVPrincipal
{
    [ValidateNotNullOrEmpty()][string]$ID
    [ValidateNotNullOrEmpty()][string]$Name
    TVPrincipal($ID, $Name)
    {
        $this.ID = $ID
        $this.Name = $Name
    }
}