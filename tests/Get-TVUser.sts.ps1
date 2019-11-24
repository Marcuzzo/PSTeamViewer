Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1" -Force


InModuleScope PSTeamViewer {

    Describe 'TVUser Management' {

        BeforeEach {
            [string] $TVUserTestData = '{"id":"u1111111","name":"firstname lastname","permissions":"EditConnections,EditFullProfile,ViewOwnAssets,EditOwnCustomModuleConfigs,ViewOwnConnections","active":false,"log_sessions":true,"show_comment_window":false}'
        }

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            if ( ( ! ( [string]::IsNullOrEmpty($Body.name))) -or ( ! ( [string]::IsNullOrEmpty($Body.email))))
            {
                return (  ('{{"users":[{0}]}}' -f $TVUserTestData) | ConvertFrom-Json )
            }
            else
            {
                return (  $TVUserTestData | ConvertFrom-Json )
            }

        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'Get'
        } -ModuleName PSTeamViewer

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            $json = $TVUserTestData | ConvertFrom-Json
            if ( ! ( [string]::IsNullOrEmpty($Body.name)))
            {
                $json.name = $Body.name
            }
            return $json;

        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'Put'
        } -ModuleName PSTeamViewer


        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            return (    $TVUserTestData | ConvertFrom-Json )
        } -ParameterFilter {
            $uri -match "/api/v1/account" -and $Method -eq 'Get'
        } -ModuleName PSTeamViewer

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            $user_id = ('u{0}' -f (Get-Random -Maximum 9999999 -Minimum 1000000) )

            $str = @'
            {{"id":"{0}",
            "name":"{1}",
            "permissions":"EditConnections,EditFullProfile,ViewOwnAssets,EditOwnCustomModuleConfigs,ViewOwnConnections",
            "active":true,
            "log_sessions":true,
            "show_comment_window":false}}
'@
            $TVUSerData = $str -f $user_id, $Name
            return (    $TVUSerData | ConvertFrom-Json )
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and $Method -eq 'Post'
        } -ModuleName PSTeamViewer

        Context 'Get-TVUser' {
            It 'Fetching TeamViewer user' {
                $TVUser = Get-TVUser -UserID 'u1111111' -Token "ABC123"
                $TVUser.GetType().Name | should be 'TVUser'
                $TVUser.ID | Should be 'u1111111'
                $TVUser.Name | should be 'firstname lastname'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }


        # When Set-TVUser call's Get-TVUser it will return an object wtith the same data...
        Context 'Set-TVUser' {
            It 'Updating TeamViewer user' {
                $TVUser = Set-TVUser -UserID 'u1111111' -Name 'Lastname, Firstname' -Token "ABC123" -Verbose
                $TVUser.GetType().Name | should be 'TVUser'
                $TVUser.ID | Should be 'u1111111'
                $TVUser.Name | should be 'Lastname, Firstname'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }


    }

}
