
function New-TVGroup
{
    <#
    .SYNOPSIS
    Create a new TeamViewer Group
    .DESCRIPTION
    Create a new TeamViewer Group
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Name
    The name of the new group
    .PARAMETER CompanyUserID
    Administrator user ID
    .EXAMPLE
    New-TVGroup -Token $env:TeamviewerToken -Name 'MyTestGroup'
    Creates the group MyTestGroup
    .INPUTS
    None. You cannot pipe objects to New-TVGroup
    .OUTPUTS
    TVGroup. New-TVGroup will return the newly created TVGroup object
    .NOTES
    Author: Marco Micozzi
    .LINK
    Get-TVGroup
    .LINK
    Remove-TVGroup
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/New-TVGroup/',
        SupportsShouldProcess = $True
    )]
    [OutputType([TVGroup])]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The name of the group to create.'
        )]
        [string[]] $Name,

        [Parameter()]
        [string] $CompanyUserID = [string]::Empty
    )

    begin
    {
        [hashtable] $RequestBody = @{ }
    }

    process
    {
        foreach ( $GroupName in $Name)
        {

            $RequestBody.name = $GroupName

            If ($PSCmdlet.ShouldProcess( ('Create Group with name: {0}?' -f $GroupName)))
            {

                try
                {
                    $Params = @{
                        Token       = $Token
                        Resource    = 'groups'
                        Method      = 'POST'
                        RequestBody = $RequestBody
                    }

                    if ( -not ( [string]::IsNullOrEmpty($CompanyUserID) ))
                    {
                        $Params.PrincipalID = ('{0}/groups' -f $CompanyUserID)
                    }

                    $response = Invoke-TVApiRequest @Params

                    # returns 204 on success
                    Write-Verbose -Message ('Fetching TVGroup with Name: "{0}".' -f $Name)

                }
                catch [TVException]
                {
                    #$ErrJsonout
                    return $_.Exception.Message
                    #Write-Error -Message $ErrJson.error_description
                }
                finally
                {
                    if ( $null -ne $response)
                    {
                        Write-Verbose -Message ('Got Response: "{0}"' -f $response )
                        Get-TVGroup -Token $Token -GroupID $response.id
                    }
                }

            }

        }
    }

}