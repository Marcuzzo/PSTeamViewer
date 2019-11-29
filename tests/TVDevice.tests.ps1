# Import the PSTeamViewer Module
Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1" -Force

# Limit the scope to the PSTeamViewer Module
InModuleScope PSTeamViewer {

    # This token will not actually be used as the Invoke-RestMethod is mocked.
    [string] $TVAPIToken = 'ABC12345'

    # dotsource the helperscripts
    . $PSScriptRoot\HelperScripts\DeviceTestHelper.ps1

    Describe "TVDevice Tests" {

        # The path to the temp jsson file
        $DataFile = 'TestDrive:\devices.json'

        Initialize-DeviceData -Path $DataFile

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            if ( $Uri -match '/devices/(.+)$')
            {
                Write-Verbose -Message ('Get-TVDevice Rest - Got URL: {0}' -f $Uri)
                #$Data = Get-UserData -Path $DataFile -ID $Matches[1]
            }
            else
            {
                $ComputerDataParams = @{
                    Path = $DataFile
                }
                if (-not ( [string]::IsNullOrEmpty($Body.groupid)) )
                {
                    $ComputerDataParams.GroupID = $Body.groupid
                }
                if (-not ( [string]::IsNullOrEmpty($Body.online_state)) )
                {
                    $ComputerDataParams.OnlineState = $Body.online_state
                }
                if (-not ( [string]::IsNullOrEmpty($Body.remotecontrol_id)) )
                {
                    $ComputerDataParams.RemoteControlID = $Body.remotecontrol_id
                }
                $Data = Get-ComputerData @ComputerDataParams
            }
            return $Data
        } -ParameterFilter {
            $uri -match "/api/v1/devices" -and $Method -eq 'GET'
        } -ModuleName PSTeamViewer


        Context 'Get TVDevice by 2 Computer Group by ID' {

            $Data = Get-TVDevice -Token $TVAPIToken -GroupID 'g12345678'

            It 'Tests if devices of the correct group have been returned' {
                $Data.Count | Should be 2
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the GroupID of the devices' {
                $Data | ForEach-Object {
                    $_.GroupID | should be 'g12345678'
                }
            }

        }

        Context 'Get TVDevice by Single Device Group' {
            $Data = Get-ComputerData -Path $DataFile -GroupID 'g12345679' -verbose
            It 'Tests the Device Alias' {
                $Data.Alias | Should be 'Laptop1'
            }
        }
    }

}