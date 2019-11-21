function Initialize-TVGroupObject
{
    [CmdLetBinding()]
    [OutputType([TVGroup])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Json
    )

    begin
    {
        [TVPrincipal] $Owner = $null
        [TVGroupUser[]] $SharedWith = @()
        Write-Debug -Message $Json
    }

    process
    {
        if ( $null -ne $Json.shared_with)
        {
            $Json.shared_with | ForEach-Object {
                # [TVGroupUser] $CurrentUser = New-Object -TypeName TVGroupUser -ArgumentList $_.userid, $_.name, $_.permissions, $_.pending
                # $SharedWith += $CurrentUser
                $SharedWith += [TVGroupUser](New-Object -TypeName TVGroupUser -ArgumentList $_.userid, $_.name, $_.permissions, $_.pending)
            }
        }
        else
        {
            Write-Verbose -Message ('The group: {0} is not shared!' -f $Json.Name)
        }

        Write-Debug -Message ('Owner: {0}' -f $Json.owner)
        if ( $null -ne $Json.owner )
        {
            Write-Verbose -Message ('Setting owner of group: {0} to user: {1} with ID: {2}' -f $Json.Name, $Json.owner.name, $Json.owner.userid)
            $Owner = New-Object -TypeName TVPrincipal -ArgumentList $Json.owner.userid, $Json.owner.name
        }

        [TVGroup] $Group = New-Object -TypeName TVGroup -ArgumentList $Json.ID, $Json.Name, $Owner, $Json.permissions, $SharedWith

        # Add the policy ID if any
        if ( ! ( [System.String]::IsNullOrEmpty($Json.policy_id)))
        {
            $Group.PolicyID = $Json.policy_id
        }

    }

    end
    {
        Write-Output -InputObject $Group
    }

}