# Import the PSTeamViewer Module
Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1" -Force

# Limit the scope to the PSTeamViewer Module
InModuleScope PSTeamViewer {

    # This token will not actually be used as the Invoke-RestMethod is mocked.
    [string] $TVAPIToken = 'ABC12345'

    # dotsource the helperscripts
    . $PSScriptRoot\HelperScripts\UserTestHelper.ps1

    Describe "TVUser Tests" {

        # The path to the temp jsson file
        $DataFile = 'TestDrive:\users.json'

        Initialize-UserData -Path $DataFile

        # Mock fetching users
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            if ( $Uri -match '/users/(.+)$')
            {
                $Data = Get-UserData -Path $DataFile -ID $Matches[1]
            }
            else
            {
                if (-not ( [string]::IsNullOrEmpty($Body.name)) )
                {
                    $Data = Get-UserData -Path $DataFile -Name $Body.name
                }
                elseif (-not ( [string]::IsNullOrEmpty($Body.email)))
                {
                    $Data = Get-UserData -Path $DataFile -Email $Body.email
                }
            }
            return $Data
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'GET'
        } -ModuleName PSTeamViewer

        # Mock Creating users
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            $BodyJson = $Body | ConvertFrom-Json

            Write-Verbose -Message ('Adding user with name: {0}' -f $BodyJson.name)
            $Data = Add-UserData -Path $DataFile -Name $BodyJson.name -Email $BodyJson.email
            Write-Verbose -Message ('Data: {0}' -f $Data)
            return $Data
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'POST'
        } -ModuleName PSTeamViewer

        # Mock Updating users
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            $BodyJson = $Body | ConvertFrom-Json
            Write-Verbose -Message ('MOCK Data - Set-TVUser BodyJson: {0}' -f $BodyJson)

            if ( $Uri -match '/users/(.+)$')
            {
                Write-Verbose -Message ('MOCK - Set-TVUser Name: {0}' -f $BodyJson.name)
                Write-Verbose -Message ('MOCK - Set-TVUser active: {0} - {1}' -f $BodyJson.active, ( $null -ne $BodyJson.active))
                Write-Verbose -Message ('MOCK - Set-TVUser ID: {0}' -f $Matches[1])

                $Param = @{
                    Path = $DataFile
                    ID   = $Matches[1]
                    Name = $BodyJson.name
                }

                if ( $null -ne $BodyJson.active)
                {
                    $Param.Active = $BodyJson.active
                }

                $Data = Set-UserData @Param
                # Path $DataFile -ID $Matches[1] -Name $BodyJson.name

            }
            else
            {
                if (-not ( [string]::IsNullOrEmpty($Body.name)) )
                {
                    #$Data = Get-UserData -Path $DataFile -Name $Body.name
                }
                elseif (-not ( [string]::IsNullOrEmpty($Body.email)))
                {
                    #$Data = Get-UserData -Path $DataFile -Email $Body.email
                }
            }

            Write-Verbose -Message ('MOCK - Set-TVUser Data: {0}' -f $Data)
            return $Data

        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'PUT'
        } -ModuleName PSTeamViewer

        # Removing of users is not implemented directly.
        # Users are instead disabled via Set-TVUser

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

        Context 'Adding a user' {

            $TVUserData = @{
                Token    = $TVAPIToken
                Name     = 'John Doe'
                Email    = 'john.doe@domain.com'
                Password = (ConvertTo-SecureString -String "P4ssW0rd!" -AsPlainText -Force)
            }
            $TVUser = New-TVUser @TVUserData

            It 'Tests the type of returned object' {
                $TVUser.GetType().Name | should be 'TVUser'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the user ID' {
                $TVUser.ID | Should be 'u0000002'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the name of the user' {
                $TVUser.Name | should be 'John Doe'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the email of the user' {
                $TVUser.Email | should be 'john.doe@domain.com'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }

        Context 'Modify an existing user' {
            $TVUserData = @{
                Token  = $TVAPIToken
                UserID = 'u0000002'
                Name   = 'Doe, John'
                Active = $false
            }
            $TVUser = Set-TVUser @TVUserData -PassThru

            It 'Test the modified name' {
                $TVUser.Name | Should be 'Doe, John'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            IT 'Test the modified status' {
                $TVUser.Active | Should be $false
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }
    }
}