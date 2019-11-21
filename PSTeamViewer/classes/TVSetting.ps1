class TVSetting
{
    [string] $Key
    [string] $Value
    [bool] $Enforce

    TVSetting ( [string] $Key, [string] $Value, [bool] $Enforce)
    {
        $this.Enforce = $Enforce
        $this.Key = $Key
        $this.Value = $Value
    }
}