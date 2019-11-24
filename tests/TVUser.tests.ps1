# Import the PSTeamViewer Module
Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1" -Force

# dotsource the helperscripts
. $PSScriptRoot\HelperScripts\UserTestHelper.ps1

# This token will not actually be used as the Invoke-RestMethod is mocked.
[string] $TVAPIToken = 'ABC12345'

# Limit the scope to the PSTeamViewer Module
InModuleScope PSTeamViewer {

    Describe "TVUser Tests" {

        # The path to the temp jsson file
        $DataFile = 'TestDrive:\users.json'

        Initialize-UserData -Path $DataFile

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {

            Write-Verbose -Message ('Got URL: {0}' -f $Uri)
            Write-Verbose -Message ('Got Body: {0}' -f $Body)

            if ( $Uri -match '/users/(.+)$')
            {
                Write-Verbose -Message ('Got request for user with ID: {0}' -f $Matches[1])
                $Data = Get-UserData -JsonDataFile $DataFile -ID $Matches[1]
            }
            else
            {
                Write-Verbose -Message ('GOT URI: {0}' -f $Uri)
                if (-not ( [string]::IsNullOrEmpty($Body.name)) )
                {
                    $Data = Get-UserData -JsonDataFile $DataFile -Name $Body.name
                }
                elseif (-not ( [string]::IsNullOrEmpty($Body.email)))
                {
                    $Data = Get-UserData -JsonDataFile $DataFile -Email $Body.email
                }
            }
            Write-Verbose -Message ('returned data: {0}' -f $Data)

            return $Data

        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'Get'
        } -ModuleName PSTeamViewer


        Context 'Getting User by UserID' {

            $TVUser = Get-TVUser -UserID 'u0000001' -Token $TVAPIToken

            It 'Tests the type of returned object' {
                $TVUser.GetType().Name | should be 'TVUser'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the user ID' {
                $TVUser.ID | Should be 'u0000001'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the name of the user' {
                $TVUser.Name | should be 'Mighty Administrator'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

        }

        Context 'Getting User by email' {

            $TVUser = Get-TVUser -Token $TVAPIToken -Email 'admin@example.com'

            It 'Tests the type of returned object' {
                $TVUser.GetType().Name | should be 'TVUser'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the user ID' {
                $TVUser.ID | Should be 'u0000001'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the name of the user' {
                $TVUser.Name | should be 'Mighty Administrator'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

        }

        Context 'Getting User by name' {

            $TVUser = Get-TVUser -Token $TVAPIToken -Name 'Mighty Administrator'

            It 'Tests the type of returned object' {
                $TVUser.GetType().Name | should be 'TVUser'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the user ID' {
                $TVUser.ID | Should be 'u0000001'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the name of the user' {
                $TVUser.Name | should be 'Mighty Administrator'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

        }

    }
}