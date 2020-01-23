
function Get-TVAccount
{
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVAccount/'
    )]
    [OutputType([TVAccount])]
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token
    )
    process
    {

        $Response = Invoke-TVApiRequest -Token $Token -Resource account -Method GET -Verbose

        # userid needs to be renamed to ID because the TVPrincipal class uses ID and not UserID
        $json = ($Response | ConvertTo-Json) -replace 'userid', 'id'

        Write-Output -InputObject ([TVAccount]( $json | ConvertFrom-Json ) )

    }

}