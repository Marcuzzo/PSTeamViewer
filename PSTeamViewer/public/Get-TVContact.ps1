function Get-TVContact
{
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Name = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Email = [string]::Empty
    )


    begin
    {
        [hashtable] $RequestBody = @{
            full_list = (!$Simple.IsPresent)
        }
    }

    process
    {

        if ( -not [string]::IsNullOrEmpty($Name))
        {
            $RequestBody.name = $Name
        }

        if ( -not [string]::IsNullOrEmpty($Email))
        {
            $RequestBody.email = $Email
        }

        Invoke-TVApiRequest -Token $Token -Resource contacts -Method GET -RequestBody $RequestBody
    }

}