function Get-TVPolicy
{
    <#
     .SYNOPSIS
    Get details of a Teamviewer policy
    .DESCRIPTION
    Get details of a Teamviewer policy
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER PolicyID
    The ID of the Teamviewer policy to fetch
    .PARAMETER Name
    The name of the Teamviewer policy to fetch
    .EXAMPLE
    Get-TVPolicy -Token $env:TVToken
    Gets all Teamviewer policies.
    .EXAMPLE
    Get-TVPolicy -Token $env:TVToken -PolicyID '1234567-abcd-1234-a1b1-abcdefghijkl'
    Gets details of the Teamviewer Policy with ID '1234567-abcd-1234-a1b1-abcdefghijkl'
    .EXAMPLE
    Get-TVPolicy -Token $env:TVToken -Name 'Test'
    Gets details of the Teamviewer Policy with name 'Test'
    .NOTES
    json output of the API request:
    {
    "policies": [
        {
        "settings": "",
        "name": "POLICY_NAME",
        "policy_id": "xxxxxxxx-xxxxx-xxxx-xxxx-xxxxxxxxxxxx"
        },
        {
            ...
        }
    ]
    }
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    [OutputType([TVPolicy])]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByPolicyID'
        )]
        [string] $PolicyID,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByName'
        )]
        [string] $Name

    )

    $Params = @{
        Token    = $Token
        Resource = 'teamviewerpolicies'
        Method   = 'GET'
    }

    if ($PSCmdlet.ParameterSetName -eq 'ByPolicyID')
    {
        $Params.PrincipalID = $PolicyID
    }

    $TeamViewerPolicies = Invoke-TVApiRequest @Params

    foreach ( $entry in $TeamViewerPolicies.policies )
    {

        [TVPolicy] $Policy = New-Object -TypeName TVPolicy -ArgumentList $entry.name, $entry.policy_id

        foreach ( $settingJson in $entry.settings)
        {

            [string] $SettingValue = $settingJson.Value

            if ( $settingJson.Value.GetType().Name -eq 'PSCustomObject' )
            {
                $SettingValue = ( $settingJson.Value | ConvertTo-Json )
            }

            [TVSetting] $Setting = New-Object -TypeName TVSetting -ArgumentList $settingJson.Key, $SettingValue, $settingJson.Enforce

            $Policy.settings += $Setting

        }

        Write-Debug -Message ('ParameterSetname: {0}' -f $PSCmdlet.ParameterSetName)
        if ( ( $PSCmdlet.ParameterSetName -ne 'ByName' ) -or ( ($PSCmdlet.ParameterSetName -eq 'ByName' ) -and ($Policy.Name -eq $Name)))
        {
            Write-Output -InputObject $Policy
        }

    }

}