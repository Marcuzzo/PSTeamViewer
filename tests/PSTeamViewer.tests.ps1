
#handle PS2
if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1" -Force


InModuleScope PSTeamViewer {

    Describe "Initialize-TeamViewerAPI" {

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {   
                         
            [string] $tokenCheck = ('"token_valid":"{0}"' -f ($Headers.Authorization -ne "Bearer FAKETOKEN")).tolower()
            
            return (  "{$tokenCheck}" | ConvertFrom-Json  )

        } -ParameterFilter {
            $uri -match "/api/v1/ping" -and  $Method -eq 'Get'
        } -ModuleName PSTeamViewer

        Context 'Mandatory Parameters' {
            It 'Token' {
                (Get-Command Initialize-TVAPI).Parameters['Token'].Attributes.Mandatory | Should be $true
            }
        }

        Context 'Verify Token' {
            It 'tests invalid token' {            
                { Initialize-TVAPI -Token "FAKETOKEN" }| Should throw 'Invalid Token'
            }

            It 'Tests valid Teamviewer Token' {                
                {Initialize-TVAPI -Token 'VALIDTOKEN'} | Should not throw
            }

        }
        
    }

    Describe 'User Management' {
        
        BeforeEach {
            [string] $TVUserTestData = '{"id":"u1111111","name":"firstname lastname","permissions":"EditConnections,EditFullProfile,ViewOwnAssets,EditOwnCustomModuleConfigs,ViewOwnConnections","active":false,"log_sessions":true,"show_comment_window":false}'
        }
        
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            if ( ( ! ( [string]::IsNullOrEmpty($Body.name))) -or ( ! ( [string]::IsNullOrEmpty($Body.email)))) {
                return (  "{`"users`":[$TVUserTestData]}" | ConvertFrom-Json )
            }
            else{
                return (  $TVUserTestData | ConvertFrom-Json )
            }
            
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and  $Method -eq 'Get'
        } -ModuleName PSTeamViewer

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {                
            return (    $TVUserTestData| ConvertFrom-Json )
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and  $Method -eq 'Put'
        } -ModuleName PSTeamViewer

        
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {                
            return (    $TVUserTestData| ConvertFrom-Json )
        } -ParameterFilter {
            $uri -match "/api/v1/account" -and  $Method -eq 'Get'
        } -ModuleName PSTeamViewer

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            $user_id = ('u{0}' -f (Get-Random -Maximum 999999999 -Minimum 1000000) )
            
            $str = @'
            "id":"u{0}",
            "name":"{1}",
            "permissions":"EditConnections,EditFullProfile,ViewOwnAssets,EditOwnCustomModuleConfigs,ViewOwnConnections",
            "active":true,
            "log_sessions":true,
            "show_comment_window":false
'@
            $TVUSerData = $str -f $user_id, $Name
            return (    $TVUserTestData| ConvertFrom-Json )
        } -ParameterFilter {
            $uri -match "/api/v1/users" -and  $Method -eq 'Post'
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
                $TVUser = Set-TVUser -UserID 'u1111111' -Name 'Lastname, Firstname' -Token "ABC123"                   
                $TVUser.GetType().Name | should be 'TVUser'
                $TVUser.ID | Should be 'u1111111'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer                    
            }                    
        }

        Context 'New-TVUser' {
            It 'Test invalid Email address 1' {
                { New-TVUser -Name 'TEST USER' -Email 'faulty@mail' -Password 'P@ssw0rd' -Language 'en' } | Should throw "faulty@mail is  not a valid email address"                    
            }
            It 'Test invalid Email address 2' {
                { New-TVUser -Name 'TEST USER' -Email 'faultymail' -Password 'P@ssw0rd' -Language 'en' } | Should throw "faultymail is  not a valid email address"                    
            }                
            It 'Creates a new user' {
                [TVUser] $TVUser = New-TVUser -Name 'TEST USER' -Email 'Some@mail.com' -Password 'P@ssw0rd' -Language 'en' -Token "ABC123"
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer             
            }

        }

      
        
    }

}
