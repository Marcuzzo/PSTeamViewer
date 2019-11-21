function Get-TVUserGroups
{
    <#
    .SYNOPSIS
    Get the groups a user is member of.
    .DESCRIPTION
    Get a list of groups the user is member of
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER User
    The TeamViewer User as retreived by Get-TVUser
    .PARAMETER Name
    The Name of the user to fetch the groups for.
    .EXAMPLE
    Get-TVUserGroups -Token $ENV:TeamviewerToken -Name "JohnDoe"
    Get all groups of which the user 'JohnDoe' is member of.
    .EXAMPLE
    Get-TVUserGroups -Token $ENV:TeamviewerToken -User (Get-TVUser -Token $ENV:TeamviewerToken -Name "JohnDoe" )
    Get all groups of which the user 'JohnDoe' is member of.
    .NOTES
    Author: Marco Micozzi
    
#>
    [CmdletBinding()]
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
        [TVUser] $User,

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
            $User = Get-TVUser -Token $Token -Name $Name
        }
    }
    process
    {
        # TODO: Add check if $User is $Null
        Get-TVGroup -Token $Token | ForEach-Object {
            $Group = $_
            $Group.SharedWith | 
            Where-Object { $_.ID -eq $User.ID } | ForEach-Object {
                Write-Verbose -Message ('Got group: {0} with ID: {1}' -f $Group.Name, $Group.ID)
                [TVUserGroup]::new($_, $Group.ID, $Group.Name)                        
            }
        }
    }
}