function Remove-TVGroupMember
{
    [CmdletBinding()]
    param(
        
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true            
        )]
        [TVGroup] $Group,

        [Parameter(
            Mandatory = $true
        )]
        [TVUser] $User
    )
    process
    {
        [hashtable] $Params = @{
            users = @(
                $User.ID                               
            )           
        }        
        Invoke-TVApiRequest -Token $Token -Resource groups -PrincipalID ('{0}/unshare_group' -f $Group.ID) -Method POST -RequestBody $Params -WhatIf
    }
}