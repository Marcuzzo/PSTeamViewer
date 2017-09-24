[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet('Build', 'Update')]
    [string] $Mode = 'Build',

    [Parameter()]
    [switch] $Compile
)

Install-Module -Name platyPS -Scope CurrentUser -Force

Import-Module -Name platyPS

Import-Module $PSScriptRoot/../PSTeamViewer/PSTeamViewer.psd1 -Force

if ( $Mode -eq 'Build' )
{
    New-MarkdownHelp -Module PSTeamViewer -OutputFolder $PSScriptRoot/../help -Force
}
elseif ($Mode -eq 'Update' )
{
    Update-MarkdownHelp -Path ..\help
}
else
{
}

if ( $Compile.IsPresent ) 
{
    New-ExternalHelp -Path $PSScriptRoot/../help -OutputPath $PSScriptRoot/../PSTeamViewer/en-US/ -Force
}