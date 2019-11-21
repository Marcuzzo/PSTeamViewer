
Class TVAccount : TVPrincipal
{
    [string] $Email
    [string] $CompanyName
    [string] $email_language
    [bool] $email_validated = $false
    [TVLicense] $license = $null
    TVAccount (
        [string] $ID,
        [string] $Name,
        [string] $Email,
        [string] $CompanyName
    )
    : base ($ID, $Name)
    {
        $this.Email = $Email
        $this.CompanyName = $CompanyName
    }
}
