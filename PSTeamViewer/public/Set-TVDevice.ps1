function Set-TVDevice
{
    <#
.SYNOPSIS
Modify an existing TVDevice.
.DESCRIPTION
Modify an existing TVDevice.
.PARAMETER Token
The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com).
.PARAMETER Identity
a TVDevice Object fetched by Get-TVDevice.
.PARAMETER Alias
The new name of the TVDevice.
.PARAMETER Description
The new Description of the TVDevice.
.PARAMETER Password
The new Password for the TVDevice.
.PARAMETER GroupID
The new Group ID to assign to the TVDevice.
.PARAMETER PolicyID
The new Policy ID to assign to the TVDevice.
.EXAMPLE
Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.DeviceID -eq 'g12345678'} | Set-TVDevice -Token $env:TVAccessToken -Alias 'New Alias'
Changes the Alias of TVDevice with DeviceId 'g12345678' to 'New Alias'.
.EXAMPLE
$TVDevice | Set-TVDevice -Token $env:TVAccessToken -Description 'This is a new Description'
$TVDevice is an object returned by "Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.DeviceID -eq 'g12345678'}"
Changes the Description of TVDevice with DeviceId 'g12345678' to 'This is a new Description'.
.EXAMPLE
$TVDevice | Set-TVDevice -Token $env:TVAccessToken -Password (ConvertTo-SecureString 'P@ssw0rd!' -asplaintext -force )
$TVDevice is an object returned by "Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.DeviceID -eq 'g12345678'}"
Sets the password required to connect to the device to 'P@ssw0rd!'.
.EXAMPLE
$TVDevice | Set-TVDevice -Token $env:TVAccessToken -GroupID 'g12345678'
$TVDevice is an object returned by "Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.DeviceID -eq 'g12345678'}"
Moves the computer object to group with ID: g12345678.
.EXAMPLE
$TVDevice | Set-TVDevice -Token $env:TVAccessToken -PolicyID '{29a8924628-0934-1f17-9a30-4c8fcfbf05ab}'
$TVDevice is an object returned by "Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.DeviceID -eq 'g12345678'}"
Assigns the policy with ID {29a8924628-0934-1f17-9a30-4c8fcfbf05ab} to the computer.
.LINK
Get-TVGevice
.LINK
Get-TVPolicy
.LINK
Get-TVGroup
.INPUTS
TVDevice. The TVDevice object returned by Get-TVDevice.
.NOTES
Author: Marco Micozzi
 #>
    [OutputType([TVDevice])]
    [CmdLetBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Set-TVDevice/',
        SupportsShouldProcess = $True,
        DefaultParameterSetName = 'None'
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [TVDevice] $Identity,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Alias,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [securestring] $Password,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByPolicyID'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PolicyID,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ByGroupID'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $GroupID,

        [Parameter(
            Mandatory = $false
        )]
        [switch] $PassThru
    )

    begin
    {
        # The hashtable containing the request parameters
        [hashtable] $RequestBody = @{ }

    }

    process
    {

        # Add the PolicyID if present
        if ( -not ( [string]::IsNullOrEmpty($PolicyID)))
        {

            if ( $PolicyID -eq 'inherit')
            {
                $RequestBody.policy_id = $PolicyID
            }
            else
            {
                # Make sure the policy exists.
                [TVPolicy] $Policy = Get-TVPolicy -Token $Token -PolicyID $PolicyID
                if ( $null -ne $Policy )
                {
                    $RequestBody.policy_id = $Policy.PolicyID
                }
                else
                {
                    Write-Error -Message ('The Policy with ID: "{0}" was not found!' -f $PolicyID)
                }

            }
        }

        # Add the GroupID if present
        if ( -not ( [string]::IsNullOrEmpty($GroupID)))
        {
            # Make sure the group exists
            [TVGroup] $Group = Get-TVGroup -Token $Token -GroupID $GroupID
            if ( $null -ne $Group )
            {
                $RequestBody.groupid = $GroupID
            }
            else
            {
                Write-Error -Message ('The Group with ID: "{0}" was not found!' -f $GroupID)
            }
        }

        # Add the Alias if present
        if ( -not ( [string]::IsNullOrEmpty($Alias)))
        {
            $RequestBody.alias = $Alias
        }

        # Add the Alias if present
        if ( -not ( [string]::IsNullOrEmpty($Description)))
        {
            $RequestBody.description = $Description
        }

        # Add the Password if present
        if ( -not ( [string]::IsNullOrEmpty($Password)))
        {
            $BinStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
            $RequestBody.password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BinStr)
        }

        If ($PSCmdlet.ShouldProcess( ('Modify device: {0}' -f $Identity.Alias)))
        {

            $Params = @{
                Token       = $Token
                Resource    = 'devices'
                PrincipalID = $Identity.DeviceID
                Method      = 'PUT'
                RequestBody = $RequestBody
            }
            $response = Invoke-TVApiRequest @Params

            if ( $null -ne $response)
            {
                if ( $PassThru.IsPresent)
                {
                    Write-Output -InputObject (Get-TVDevice -Token $Token | Where-Object { $_.DeviceID -eq $DeviceID } )
                }
            }
            else
            {
                Write-Error -Message ('Failed to modify userdata for user: {0}' -f $Identity.DeviceID)
            }

        }
    }

}