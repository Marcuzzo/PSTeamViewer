function Initialize-TVDeviceData
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
                description        = 'This is a test laptop'
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

function Get-TVDeviceData
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
            Mandatory = $false,
            ParameterSetName = 'ByOtherProps'
        )]
        [ValidateSet('Online', 'Offline')]
        [string] $OnlineState = [string]::Empty,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByOtherProps'
        )]
        [string] $GroupID = [string]::Empty,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByOtherProps'
        )]
        [string] $RemoteControlID = [string]::Empty,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByDeviceID'
        )]
        [string] $DeviceID
    )

    Write-Verbose -Message 'Get-TVDeviceData - Reading json data'

    if ( Test-Path -Path $Path )
    {

        # Read the json data
        $JsonFileContent = Get-Content -Path $Path -Raw

        Write-Verbose -Message ('Get-TVDeviceData - JSON content: {0}' -f $JsonFileContent)

        # Parse json
        $Json = $JsonFileContent | ConvertFrom-Json

        $DeviceJson = @{
            devices = @()
        }
        Write-Verbose -Message 'Get-TVDeviceData - Selecting TVDevice output...'

        $FilterArray = @()

        if ( $PSCmdlet.ParameterSetName -eq 'ByDeviceID' )
        {
            $FilterArray += "`$_.device_id -eq '$DeviceID'"
        }
        else
        {

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

        }

        if ( $FilterArray.Length -ge 2 )
        {
            $FilterString = $FilterArray -join ' -and '
        }
        else
        {
            $FilterString = $FilterArray[0]
        }

        Write-Verbose -Message ('Get-TVDeviceData FilterString: {0}' -f $FilterString)

        $WhereBlock = [scriptblock]::Create($FilterString)

        Write-Verbose -Message ('WhereBlock AST: {0}' -f $WhereBlock.ast.Extent.Text)

        # make sure to return all if no parameters were provided?
        if ( [string]::IsNullOrEmpty($FilterString) )
        {
            $Data = $Json.devices
        }
        else
        {
            $Data = $Json.devices | Where-Object $WhereBlock
        }

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

function Set-TVDeviceData
{

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $true
        )]
        [string] $DeviceID,

        [Parameter(
            Mandatory = $false
        )]
        [string] $PolicyID = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $GroupID = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Alias = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Description = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Pswd = [string]::Empty

    )

    $AllDeviceData = Get-TVDeviceData -Path $Path

    If ($PSCmdlet.ShouldProcess( ('Modify user: {0}' -f $Identity.Name)))
    {

        #foreach ($key in $AllDeviceData.devices.Keys)
        #{
        #    Write-Verbose -Message ('Set-TVDeviceData - All Device Data - Key: {0} - Value: "{1}".' -f $Key, $AllDeviceData[$Key])
        #}

        $DeviceData = $AllDeviceData.devices | where { $_.device_id -eq $DeviceID }

        Write-Verbose -Message ('Set-TVDeviceData DeviceData: {0}' -f $DeviceData)
        if ( -not ( [string]::IsNullOrEmpty($Description)))
        {
            $DeviceData.description = $Description
        }

        Write-Verbose -Message ('Set-TVDeviceData Json output: {0}' -f ( $AllDeviceData | ConvertTo-Json))

        $AllDeviceData | ConvertTo-Json | Out-File $Path

        Get-TVDeviceData -Path $Path -DeviceID $DeviceID

    }
}
