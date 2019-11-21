function Get-TVGroupMember
{
    <#
    .SYNOPSIS
    Get the Users of a TVGroup.
    .DESCRIPTION
    Get the Users of a TVGroup.
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Group
    The TeamViewer Group as retreived by Get-TVGroup
    .PARAMETER Name
    The Name of the group to fetch the members for.
    .EXAMPLE
    Get-TVGroupMember -Token $ENV:TeamviewerToken -Name "SomeGroup"
    Get all Members of the group 'SomeGroup'.
    .EXAMPLE
    Get-TVGroupMember -Token $ENV:TeamviewerToken -Group (Get-TVGroup -Token $ENV:TeamviewerToken -Name "SomeGroup" )
    Get all Members of the group 'Somegroup'.
    .NOTES
    Author: Marco Micozzi
    #>
    [CmdletBinding()]
    [OutputType([TVUser[]])]
    param(
        
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByInputObject'         
        )]
        [TVGroup] $Group,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByName'
        )]
        [string] $Name
    )
    begin 
    {
        if ( $PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $Group = Get-TVGroup -Token $Token -Name $Name
        }
        else
        {
            # This is needed to refresh the Group information
            Write-Verbose -Message ('Refreshing group: {0}' -f $Group.Name)
            $Group = Get-TVGroup -Token $Token -GroupID $Group.ID
        }
    }
    process
    {
        $Group.SharedWith | ForEach-Object {
            Write-Verbose -Message ('Getting user with ID: {0} and name: {1}' -f $_.ID, $_.Name)
            Get-TVUser -Token $Token -UserID $_.ID             
        }
    }
    end { }
}