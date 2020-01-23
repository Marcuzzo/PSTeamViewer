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

        Initialize-TVDeviceData -Path $DataFile

        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {
            if ( $Uri -match '/devices/(.+)$')
            {
                Write-Verbose -Message ('Get-TVDevice Rest - Got URL: {0}' -f $Uri)
                $Data = Get-TVDeviceData -Path $DataFile -DeviceID $Matches[1]
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
                $Data = Get-TVDeviceData @ComputerDataParams
            }
            return $Data
        } -ParameterFilter {
            $uri -match "/api/v1/devices" -and $Method -eq 'GET'
        } -ModuleName PSTeamViewer

        # Mock PUT Http request for Set-TVDevice
        Mock -CommandName Invoke-RestMethod -Verifiable -MockWith {

            $BodyJson = $Body | ConvertFrom-Json
            Write-Verbose -Message ('MOCK Data - Set-TVDevice - BodyJson: {0}' -f $BodyJson)

            if ( $Uri -match '/devices/(.+)$')
            {

                $Param = @{
                    Path     = $DataFile
                    DeviceID = $Matches[1]
                }

                Write-Verbose -Message ('Mock Data - Set-TVDevice - DeviceID: {0}' -f $Param.DeviceID )

                if ( $null -ne $BodyJson.description)
                {
                    $Param.Description = $BodyJson.description
                }

                Write-Verbose -Message 'Mock Data - Set-TVDevice - Running Set-TVDeviceData'
                $Data = Set-TVDeviceData @Param
                Write-Verbose -Message ( 'Mock Data - Set-TVDevice - Got Data: {0}' -f $Data )
            }
            else
            {

            }

            return $Data

        } -ParameterFilter {
            $uri -match "api/v1/devices" -and $Method -eq 'PUT'
        } -ModuleName PSTeamViewer

        Context 'Get 2 TVDevices Group by ID' {

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

        Context 'Get-TVDevice by ID' {

            $Data = Get-TVDevice -Token $TVAPIToken -DeviceID 'd444443226'

            It 'Tests if only 1 computer was returned' {
                $Data.Count | Should be 1
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            it 'Checks the computername' {
                $Data.Alias | Should be 'Computer1'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Checks the RemoteControl ID' {
                $Data.RemoteControlID | Should be 'r345678890'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }

        Context 'Get TVDevice by Single Device Group' {

            $Data = Get-TVDevice -Token $TVAPIToken -GroupID 'g12345679'

            It 'Tests if only 1 computer was returned' {
                $Data.Count | Should be 1
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            It 'Tests the Device Alias' {
                $Data.Alias | Should be 'Laptop1'
            }

            It 'Checks the RemoteControl ID' {
                $Data.RemoteControlID | Should be 'r123456780'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

        }

        Context 'Modifying an existing TVDevice' {

            $TVDevice = Get-TVDevice -Token $TVAPIToken -DeviceID 'd345667567'

            It 'Tests if a test device is available' {
                $TVDevice.DeviceID | Should be 'd345667567'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }

            $TVDeviceData = @{
                Token       = $TVAPIToken
                Identity    = $TVDevice
                Description = 'Test laptop 1'
            }

            $Data = Set-TVDevice @TVDeviceData -PassThru -Verbose

            It 'Tests if the description has been modified' {
                $Data.Description | Should be 'Test laptop 1'
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName PSTeamviewer
            }
        }

    }

}