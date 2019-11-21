function Invoke-TVApiRequest
{
    <#
.PARAMETER Token
The API token generated on the TeamViewer console
.PARAMETER Resource
The resource to process. can be account, users, devices, groups, contacts, sessions, ping or teamviewerpolicies
.PARAMETER Method
The http method to use, defaults to GET
.PARAMETER RequestBody
Additional parameters in json format to pass to the request
.PARAMETER PrincipalID
The specific UserID, DeviceID, GroupID, ContactID or SessionID to process
#>
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet('account', 'users', 'devices', 'groups', 'contacts', 'sessions', 'ping', 'teamviewerpolicies')]
        [string] $Resource,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('GET', 'PUT', 'POST', 'DELETE')]
        [string] $Method = 'GET',

        [Parameter()]
        [hashtable] $RequestBody = @{ },

        [Parameter()]
        [string] $PrincipalID = [string]::Empty

    )

    begin
    {
        [string] $BaseUrl = 'https://webapi.teamviewer.com'
        [string] $ApiVersion = 'v1'

        [hashtable] $Header = @{
            Authorization = ("Bearer {0}" -f $Token)
        }

        [string] $RequestUrl = ('{0}/api/{1}/{2}' -f $BaseUrl, $ApiVersion, $Resource)

        if ( -not ( [string]::IsNullOrEmpty($PrincipalID)))
        {
            $RequestUrl += ('/{0}' -f $PrincipalID)
        }
    }

    process
    {

        [hashtable] $Parameters = @{
            Uri     = $RequestUrl
            Headers = $Header
            Body    = $RequestBody
            Method  = $Method
        }

        if ( $Method -ne 'GET' )
        {
            $Parameters.ContentType = 'application/json; charset=utf-8'
            $Parameters.Body = ($RequestBody | ConvertTo-Json)
        }

        Write-Verbose -Message ('Request URL: "{0}".' -f $RequestUrl)
        try
        {

            if ( $PSCmdlet.ShouldProcess($Resource, $Method))
            {
                $response = Invoke-RestMethod @Parameters
                Write-Verbose -Message 'Returning TVObject...'
                Write-Verbose -Message $response
                Write-Output -InputObject $response
            }
        }
        catch
        {
            $ErrJson = $_ | convertFrom-json
            throw New-Object -TypeName TVException -ArgumentList $ErrJson.error, $ErrJson.error_description, $ErrJson.error_code
        }
    }

}
