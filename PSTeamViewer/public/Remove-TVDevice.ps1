function Remove-TVDevice
{
    <#
    .SYNOPSIS
    Remove a TVDevice.
    .DESCRIPTION
    Remove a TVDevice.
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER InputObject
    The TVDevice Object as returned by Get-TVDevice.
    .PARAMETER DeviceID
    The ID of the TVDevice to remove.
    .EXAMPLE
    Remove-TVDevice -Token $env:TVAccessToken -DeviceID 'g1234567'
    Removes the device with ID: g1234567
    .EXAMPLE
    Get-TVDevice -Token $envTVAccessToken -DeviceID 'g7654321' | Remove-TVDevice -Token $env:TVAccessToken
    Removes the device with ID g7654321.
    .INPUTS
    TVDevice. The TVDevice object returned by Get-TVDevice.
    .OUTPUTS
    bool. False if the removal failed
    .LINK
    Get-TVDevice
    .NOTES
    Author: Marco Micozzi
    #>
    [OutputType([bool])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'ByInputObject'
        )]
        [ValidateNotNull()]
        [TVDevice] $InputObject,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The DeviceID of the Device to delete.',
            ParameterSetName = 'ByID'
        )]
        [string] $DeviceID
    )

    process
    {

        if ( $PSCmdlet.ParameterSetName -ne 'ByInputObject')
        {
            $InputObject = Get-TVDevice -Token $Token | Where-Object { $_.DeviceID -eq $DeviceID }
        }

        if (!($InputObject))
        {
            throw 'Invalid groupname received.'
        }

        if ( $PSCmdlet.ShouldProcess($InputObject.Alias, 'Remove Device') )
        {
            Try
            {

                $Param = @{
                    Token       = $Token
                    Method      = 'Delete'
                    Resource    = 'devices'
                    PrincipalID = $InputObject.DeviceID
                }

                Invoke-TVApiRequest @Param

            }
            catch
            {
                $_.Exception.Message
                #$ErrJson = $_ | convertFrom-json
                Write-Error -Message ("err: {0}" -f $ErrJson.message    )
                return $false
            }
        }
    }
}