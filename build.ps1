
#----------------------------------------------------------#
#    Nuget
#----------------------------------------------------------#
Write-Host -Object 'Installing Nuget'
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null


#----------------------------------------------------------#
# Install Modules
#----------------------------------------------------------#

Write-Host -Object 'Starting the installation of modules...'

'psake', 'Pester', 'PSScriptAnalyzer', 'platyPS' | ForEach-Object {

    $ModuleName = $_

    Write-Host -Object ('Installing module "{0}".' -f $ModuleName)
    Install-Module -Name $ModuleName -Repository PSGallery -Force

    Write-Host -Object ('Importing module: "{0}".' -f $ModuleName)
    Import-Module -Name $ModuleName

}
Write-Host -Object 'Done installing modules.'


#----------------------------------------------------------#
#----------------------------------------------------------#

Invoke-psake .\psake.ps1
exit ( [int]( -not $psake.build_success ) )