
function Get-TVGroup
{
    <#
    .SYNOPSIS
    Get TeamViewer group information
    .DESCRIPTION
    Get information about a teamviewer group via the API
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Name
    The name of the group to fetch
    .PARAMETER Shared
    Wether or not to list shared groups.
    True: list only shared groups, i. e. groups where the current user is not the owner. False: list only not shared groups, i. e. groups owned by the current user. If left out both types will be in the list.
    .PARAMETER GroupID
    The groupId of the group to fetch
    .EXAMPLE
    Get-TVGroup -Token $Env:TVToken
    Gets all Teamviewer groups
    .EXAMPLE
    Get-TVGroup -Token $ENV:TVToken -Name "TestGrp"
    Gets the details of the group with the name 'TestGrp'
    .EXAMPLE
    Get-TVGroup -Token $env:TVToken -GroupID 'g123456789'
    Gets the details of the group with ID: g123456789
    .NOTES
    Author: Marco Micozzi
    .LINK
    New-TVGroup
    .LINK
    Remove-TVGroup
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVGroup/',
        DefaultParameterSetName = 'All'
    )]
    [OutputType([TVGroup])]
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByProperty'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByProperty'
        )]
        [bool] $Shared,

        [Parameter(
            ParameterSetName = 'ByGroupID'
        )]
        [string] $GroupID,

        [Parameter(Mandatory = $false)]
        [string] $CompanyUserID = [string]::Empty

    )

    process
    {

        # Empty hashtable declaration for request body
        [hashtable] $RequestBody = @{ }

        # Add the Name property if supplied
        if ( -not ( [string]::IsNullOrEmpty($Name)))
        {
            $RequestBody.name = $Name
        }

        # Add the Shared property if true
        if ( $PSBoundParameters.ContainsKey( "Shared" ) )
        {
            $RequestBody.shared = $Shared
        }

        # TV API request splat
        $Params = @{
            Token       = $Token
            Resource    = 'groups'
            Method      = 'GET'
            RequestBody = $RequestBody
        }

        # Add the Group ID if provided
        if ( $PSCmdlet.ParameterSetName -eq 'ByGroupID')
        {
            $Params.PrincipalID = $GroupID
        }

        # Fetch the groups from the API
        $Response = Invoke-TVApiRequest @Params

        Write-Verbose -Message ('parsing response: {0}' -f $Response)

        if ( $null -ne $Response )
        {
            $groups = @{ $true = $Response.groups; $false = $Response }[($null -ne $Response.groups)]
            $groups | ForEach-Object {
                Write-Output -InputObject ( Initialize-TVGroupObject -Json $_)
            }
        }
        else
        {
            Write-Verbose -Message 'the response was null'
        }
    }
    end { }
}