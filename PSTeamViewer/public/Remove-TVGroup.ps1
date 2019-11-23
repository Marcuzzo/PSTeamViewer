function Remove-TVGroup
{
    <#
    .SYNOPSIS
    Remove a Teamviewer group
    .DESCRIPTION
    Remove a Teamviewer group
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER InputObject
    an instance of TVGroup returned by Get-TVGroup
    .PARAMETER Name
    The name of the TVGroup to be removed
    .PARAMETER GroupID
    The ID of the group to be removed
    .PARAMETER CompanyUserID
    The ID of the administrator to remove a company group instead of a user group.
    .EXAMPLE
    Remove-TVGroup -Name 'TestGroup'
    Removes the group "TestGroup" by name
    .EXAMPLE
    Get-TVGroup -Name 'TestGroup' | Remove-TVGroup
    Removes the group 'TestGroup' by InputObject
    .EXAMPLE
    Remove-TVGroup -GroupID 'GRP1'
    Removes the group with GroupID 'GRP1'
    .INPUTS
    TVGroup. The objects returned by the Get-TVGroup can be piped to the Remove-TVGroup CmdLet.
    .OUTPUTS
    None. This CmdLet doesn't produce any output
    .NOTES
    Author: Marco Micozzi
    .LINK
    Get-TVGroup
    .LINK
    New-TVGroup
    #>
    [OutputType([bool])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'ByInputObject'
        )]
        [ValidateNotNull()]
        [TVGroup] $InputObject,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The name of the group to delete.',
            ParameterSetName = 'ByName'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The Group ID of the group to delete.',
            ParameterSetName = 'ByID'
        )]
        [string] $GroupID,

        [Parameter()]
        [string] $CompanyUserID = [string]::Empty
    )

    begin
    {

    }

    process
    {
        [hashtable] $RequestBody = @{
            Token = $Token
        }
        switch ($PSCmdlet.ParameterSetName)
        {
            'ByName'
            {
                $RequestBody.Name = $Name
            }
            'ByID'
            {
                $RequestBody.GroupID = $GroupID
            }
        }

        Write-Verbose -Message ('Setname: {0}' -f $PSCmdlet.ParameterSetName)
        if ( $PSCmdlet.ParameterSetName -ne 'ByInputObject')
        {
            $InputObject = Get-TVGroup @RequestBody -Verbose
        }

        if (!($InputObject))
        {
            throw 'Invalid groupname received.'
        }

        if ( $PSCmdlet.ShouldProcess($InputObject.Name, 'Remove Group') )
        {
            Try
            {

                $Param = @{
                    Token  = $Token
                    Method = 'Delete'
                }

                if ( [string]::IsNullOrEmpty($CompanyUserID) )
                {
                    $Param.Resource = 'groups'
                    $Param.PrincipalID = $InputObject.ID
                }
                else
                {
                    $Param.Resource = 'users'
                    $Param.PrincipalID = ('{0}/groups/{1}' -f $CompanyUserID, $InputObject.ID)
                }

                Invoke-TVApiRequest @Param

                # return ( $null -eq (Get-TVGroup -Token $Token -Name $InputObject.Name) )
            }
            catch
            {
                $_.Exception.Message
                #$ErrJson = $_ | convertFrom-json
                Write-Error -Message ("err: {0}" -f $ErrJson.message    )
                return $false
            }
        }
    }
}