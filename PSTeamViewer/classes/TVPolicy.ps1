class TVPolicy
{
    [string] $Name
    [string] $PolicyID
    [TVSetting[]] $Settings

    TVPolicy( [string] $Name, [string] $PolicyID)
    {
        $this.Name = $Name
        $this.PolicyID = $PolicyID
        $this.Settings = @()
    }

}