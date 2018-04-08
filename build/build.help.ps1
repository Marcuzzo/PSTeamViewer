[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet('Build', 'Update')]
    [string] $Mode = 'Update',

    [Parameter()]
    [switch] $Compile
)

#region Variables
if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

[string] $Script:HelpDirectory = "$PSScriptRoot/../docs/cmdlets/"
[string] $Script:OutputDirectory = "$PSScriptRoot/../PSTeamViewer/en-US/"
#endregion

#region Init

# Install PlatyPS is not installed
if ( ! ( Get-Module -Name platyPS -ListAvailable )) 
{
    Install-Module -Name platyPS -Scope CurrentUser -Force
}

# Import the platyPS module
if ( ! ( Get-Module -Name platyPS ))
{
    Import-Module -Name platyPS    
}

# Import the PSTeamViewer Module
Import-Module $PSScriptRoot/../PSTeamViewer/PSTeamViewer.psd1 -Force
#endregion


if ( ! ( Test-Path -Path $Script:HelpDirectory)) {
    $Mode = 'Build'
}

switch( $Mode )
{
    
    'Build' {
        New-MarkdownHelp -Module PSTeamViewer -OutputFolder $Script:HelpDirectory -Force -WithModulePage
    }

    'Update' {
        Update-MarkdownHelpModule -Path $Script:HelpDirectory -RefreshModulePage
    }
    
    Default {}

}

if ( $Compile.IsPresent ) 
{
    New-ExternalHelp -Path $Script:HelpDirectory -OutputPath $Script:OutputDirectory -Force
}