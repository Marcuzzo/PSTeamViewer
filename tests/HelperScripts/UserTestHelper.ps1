<#
Helper script for the TVUser CmdLets
#>
function Initialize-UserData
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    $DefaultTestJsonData = @{
        Users = @(
            @{
                id                     = ("u{0:0000000}" -f 1)
                name                   = 'Mighty Administrator'
                email                  = 'admin@example.com'
                permissions            = 'ManageAdmins, ManageUsers, ShareOwnGroups, EditFullProfile, ViewAllConnections, ViewOwnConnections, EditConnections, DeleteConnections, ManagePolicies, AssignPolicies, AcknowledgeAllAlerts,AcknowledgeOwnAlerts, ViewAllAssets, ViewOwnAssets, EditAllCustomModuleConfigs, EditOwnCustomModuleConfigs'
                active                 = $true
                custom_quicksupport_id = 'auto'
                custom_quickjoin_id    = 'auto'
            }
        )
    }
    $DefaultTestJsonData | ConvertTo-Json | Out-File $Path
}

function Get-NewUserID
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $Path
    )
    $Json = Get-Content -Path $Path -Raw | ConvertFrom-Json
    $ID = ($Json.users | Sort-Object -Property id | Select-Object -Last 1 -Property id).id
    if ( $null -eq $ID )
    {
        [int] $newID = 0
    }
    else
    {
        [int] $newID = [int]($ID -replace 'u', '')
    }
    return "u{0:0000000}" -f ($newID + 1)
}

function Add-UserData
{
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Email,


        [Parameter()]
        [string] $Language = 'en',

        [Parameter(
            Mandatory = $false
        )]
        [string] $Permissions = 'ShareOwnGroups, ViewOwnConnections, EditConnections, EditFullProfile',

        [Parameter()]
        [string] $QuickSupportID = 'auto',

        [Parameter()]
        [string] $QuickJoinID = 'auto'

    )

    $ID = Get-NewUserID -Path $Path

    $UserData = @{
        id                     = $ID
        name                   = $Name
        permissions            = $Permissions
        active                 = $true
        email                  = $Email
        custom_quicksupport_id = $QuickSupportID
        custom_quickjoin_id    = $QuickJoinID
    }
    $Obj = Get-UserData -JsonDataFile $Path
    $obj.users += $UserData
    $obj | ConvertTo-Json | Out-File $Path
}

function Get-UserData
{
    [CmdletBinding(
        DefaultParameterSetName = 'none'
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $JsonDataFile,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByID'
        )]
        [string] $ID,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByName'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByEmail'
        )]
        [string] $Email

    )

    Write-Verbose -Message 'Reading json data'

    if ( Test-Path -Path $JsonDataFile )
    {

        $JsonFileContent = Get-Content -Path $JsonDataFile -Raw
        Write-Verbose -Message ('JSON Content: {0}' -f $JsonFileContent)
        $Json = $JsonFileContent | ConvertFrom-Json

        $UserJson = @{
            users = @()
        }
        Write-Verbose -Message 'Selecting output...'
        switch ($PSCmdlet.ParameterSetName)
        {
            'ByID'
            {
                Write-Verbose -Message ('Returning json for ID: {0}' -f $ID)
                $Json.users | where { $_.id -eq $ID }
            }
            'ByName'
            {
                $data = $Json.users | where { $_.name -like "*$Name*" }
                $UserJson.users += $data
                Write-Output -InputObject $UserJson
            }
            'ByEmail'
            {
                $data = $Json.users | where { $_.email -like "*$Email*" }
                $UserJson.users += $data
                Write-Output -InputObject $UserJson
            }
            default
            {
                $Json
            }
        }
    }
    else
    {
        Write-Warning -Message ('The file: "{0}" was not found' -f $JsonDataFile)
    }
}

function Set-UserData
{
    [CmdletBinding()]
    param()
}
function Remove-UserData
{
    [CmdletBinding()]
    param()
}