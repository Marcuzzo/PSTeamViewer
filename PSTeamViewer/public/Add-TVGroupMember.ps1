function Add-TVGroupMember
{
    [CmdLetBinding()]
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
        [TVUser[]] $TVUser,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('read', 'readwrite')]
        [string] $Permission = 'read'
    )

    begin
    {
        [hashtable] $Params = @{
            users = @(
            )           
        }  
    }
    process
    {
        foreach ( $User in $TVUser)
        {
            $TVUserObject = @{
                userid      = $User.ID
                permissions = $Permission
            }
            $Params.users += $TVUserObject
        }
        Invoke-TVApiRequest -Token $Token -Resource groups -PrincipalID ('{0}/share_group' -f $Group.ID) -Method POST -RequestBody $Params 
    }
}