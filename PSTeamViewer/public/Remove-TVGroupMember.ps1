function Remove-TVGroupMember
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
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
        if ( $PSCmdlet.ShouldProcess($User.Name, 'Remove GroupMember') )
        {

            $ApiParams = @{
                Token       = $Token
                Resource    = 'groups'
                PrincipalID = ('{0}/unshare_group' -f $Group.ID)
                Method      = 'POST'
                RequestBody = $Params
            }
            #Invoke-TVApiRequest -Token $Token -Resource groups -PrincipalID ('{0}/unshare_group' -f $Group.ID) -Method POST -RequestBody $Params -WhatIf
            Invoke-TVApiRequest @ApiParams
        }
    }
}