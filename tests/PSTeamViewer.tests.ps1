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
            It 'Tests the mandatory parameter "Token".' {
                (Get-Command Initialize-TVAPI).Parameters['Token'].Attributes.Mandatory | Should be $true
            }
        }

        Context 'Verify Token' {
            It 'tests invalid token' {            
                { Initialize-TVAPI -Token "FAKETOKEN" }| Should throw 'Invalid Token'
            }

            It 'Tests "valid" Teamviewer Token' {                
                {Initialize-TVAPI -Token 'VALIDTOKEN'} | Should not throw
            }

        }
        
    }

}