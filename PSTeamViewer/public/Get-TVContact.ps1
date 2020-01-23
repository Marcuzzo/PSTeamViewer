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
        [string] $Email = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $OnlineState,

        [Parameter(
            Mandatory = $false
        )]
        [string] $GroupID,

        [Parameter()]
        [bool] $IncludeInvitations
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

        if ( -not [string]::IsNullOrEmpty($GroupID))
        {
            $RequestBody.groupid = $GroupID
        }

        if ( $IncludeInvitations)
        {
            $RequestBody.include_invitations = 'true'
        }

        $Response = Invoke-TVApiRequest -Token $Token -Resource contacts -Method GET -RequestBody $RequestBody

        if ( $null -ne $Response)
        {
            $Response.contacts | ForEach-Object {

                [TVContact] $Contact = New-Object -TypeName TVContact -Property @{
                    ContactID   = $_.contact_id
                    Name        = $_.name
                    GroupID     = $_.groupid
                    OnlineState = $_.online_state
                    UserID      = $_.user_id
                }

                Write-Output -InputObject $Contact

            }

        }

    }

}