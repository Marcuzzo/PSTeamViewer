function Add-TVGroupMember
{
    <#
    .SYNOPSIS
    Add one or more TVUsers to a TVGroup.
    .DESCRIPTION
    Add one or more TVUsers to a TVGroup.
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com).
    .PARAMETER Group
    An instance of TVGroup returned by Get-TVGroup.
    .PARAMETER TVUser
    An array of TVUSer Objects as returned by Get-TVUser.
    .PARAMETER Permission
    The permission to assign to the user. Valid values are 'read' or 'readwrite'
    .NOTES
    Author: Marco Micozzi
    .LINK
    Remove-TVGroupMember
    #>
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

        $ApiParams = @{
            Token       = $Token
            Resource    = 'groups'
            PrincipalID = ('{0}/share_group' -f $Group.ID)
            Method      = 'POST'
            RequestBody = $Params
        }
        #Invoke-TVApiRequest -Token $Token -Resource groups -PrincipalID ('{0}/share_group' -f $Group.ID) -Method POST -RequestBody $Params
        Invoke-TVApiRequest @ApiParams
    }
}