function Initialize-DeviceData
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    $DefaultTestJsonData = @{
        devices = @(
            @{
                remotecontrol_id = 'r345678890'
                device_id        = 'd444443226'
                alias            = 'Computer1'
                groupid          = 'g12345678'
                online_state     = 'Online'
                assigned_to      = 'true'
                last_seen        = '2019-07-11T15:54:45Z'
            },
            @{
                remotecontrol_id   = 'r123456780'
                device_id          = 'd345667567'
                alias              = 'Laptop1'
                groupid            = 'g12345679'
                online_state       = 'Offline'
                supported_features = 'remote_control'
            },
            @{
                remotecontrol_id   = 'r123456781'
                device_id          = 'd345667568'
                alias              = 'Computer2'
                groupid            = 'g12345678'
                online_state       = 'Online'
                supported_features = 'remote_control'
            }
        )
    }
    $DefaultTestJsonData | ConvertTo-Json | Out-File $Path
}

function Get-ComputerData
{
    [CmdletBinding(
        DefaultParameterSetName = 'none'
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('Online', 'Offline')]
        [string] $OnlineState = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $GroupID = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $RemoteControlID = [string]::Empty
    )

    Write-Verbose -Message 'Reading json data'

    if ( Test-Path -Path $Path )
    {

        # Read the json data
        $JsonFileContent = Get-Content -Path $Path -Raw

        Write-Verbose -Message ('JSOn content: {0}' -f $JsonFileContent)

        # Parse json
        $Json = $JsonFileContent | ConvertFrom-Json

        $DeviceJson = @{
            devices = @()
        }
        Write-Verbose -Message 'Selecting TVDevice output...'

        $FilterArray = @()

        if ( -not [string]::IsNullOrEmpty($OnlineState ))
        {
            $FilterArray += "`$_.online_state -eq '$OnlineState'"
        }

        Write-Verbose -Message 'Checking for GroupID parameter..'

        if ( -not [string]::IsNullOrEmpty($GroupID))
        {
            Write-Verbose -Message ('Adding groupID: {0}' -f $GroupID)
            $FilterArray += "`$_.groupid -eq '$GroupID'"
        }

        Write-Verbose -Message 'Checking for RemoteControlID parameter..'
        if ( -not [string]::IsNullOrEmpty($RemoteControlID))
        {
            $FilterArray += '$_.remotecontrol_id -eq $RemoteControlID'
        }

        Write-Verbose -Message ('Filter array length: {0}' -f $FilterArray.Length)

        if ( $FilterArray.Length -ge 2 )
        {
            $FilterString = $FilterArray -join ' -and '
        }
        else
        {
            $FilterString = $FilterArray[0]
        }

        $WhereBlock = [scriptblock]::Create($FilterString)

        Write-Verbose -Message ('WhereBlock AST: {0}' -f $WhereBlock.ast.Extent.Text)
        $Data = $Json.devices | Where-Object $WhereBlock

        Write-Verbose -Message ('Returned Data: {0}' -f $data )

        $DeviceJson.devices += $data

        $JsonData = ($DeviceJson | ConvertTo-Json )
        Write-Verbose -Message ('Mocked JSON data: {0}' -f $JsonData)
        Write-Output -InputObject $DeviceJson
    }
    else
    {
        Write-Warning -Message ('The file: "{0}" was not found' -f $Path)
    }
}

