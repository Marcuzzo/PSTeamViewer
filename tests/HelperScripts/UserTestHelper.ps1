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
        users = @(
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
    $Obj = Get-UserData -Path $Path
    $obj.users += $UserData
    $obj | ConvertTo-Json | Out-File $Path
    Get-UserData -Path $Path -ID $ID
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
        [string] $Path,

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

    if ( Test-Path -Path $Path )
    {

        $JsonFileContent = Get-Content -Path $Path -Raw
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
        Write-Warning -Message ('The file: "{0}" was not found' -f $Path)
    }
}

function Set-UserData
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
        [string] $ID,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Email,

        [Parameter(
            Mandatory = $false
        )]
        [bool] $Active
    )

    $AllUserData = Get-UserData -Path $Path

    If ($PSCmdlet.ShouldProcess( ('Modify user: {0}' -f $Identity.Name)))
    {

        $UserData = $AllUserData.users | where { $_.id -eq $ID }

        if ( -not ( [string]::IsNullOrEmpty($Name)))
        {
            $UserData.name = $Name
        }

        if ( $PSBoundParameters.ContainsKey('Active'))
        {
            Write-Verbose -Message 'Adding active'
            $UserData.active = $Active
        }

        $AllUserData | ConvertTo-Json | Out-File $Path

        Get-UserData -Path $Path -ID $ID
    }
}
function Remove-UserData
{
    [CmdletBinding()]
    param()
}