function Remove-TVDevice
{
    <#
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

                # return ( $null -eq (Get-TVGroup -Token $Token -Name $InputObject.Name) )
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