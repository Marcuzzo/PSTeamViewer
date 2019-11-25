function New-TVUser
{
    <#
    .SYNOPSIS
    Create a new Teamviewer user.
    .DESCRIPTION
    Create a new Teamviewer user
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Name
    The name of the new Teamviewer user
    .PARAMETER Email
    The email address of the new user.
    .PARAMETER Password
    The password for the new user
    .PARAMETER Language
    2 Letter language code for the new user
    .PARAMETER QuickSupportID
    The QuickSupportID for the new user
    .PARAMETER QuickJoinID
    The QuickJoinID for the new user
    .EXAMPLE
    New-TVUser -Token $Env:TeamViewerToken -Name 'John Doe' -Email 'john.doe@domain.com' -Password (ConvertTo-SecureString -String "P4ssW0rd!" -AsPlainText -Force)
    Creates a new user John Doe with email address john.doe@domain.com and password: P4ssW0rd!
    .NOTES
    Author: Marco Micozzi
    .LINK
    Get-TVUser
    .LINK
    Set-TVUser
    #>
    [CmdletBinding(
        PositionalBinding = $false,
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/New-TVUser/',
        SupportsShouldProcess = $True
    )]
    [OutputType([TVUser])]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The name of the user to create.'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The email address of the user to create.'
        )]
        [ValidateScript( {
                if ($_ -match "^([0-9a-zA-Z]([-\.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$")
                {
                    $true
                }
                else
                {
                    Throw "$_ is  not a valid email address"
                }
            })]
        [string] $Email,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The password of the user to create.'
        )]
        [securestring]$Password,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('en', 'nl', 'fr', 'es')]
        [string] $Language = 'en',

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $QuickSupportID = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $QuickJoinID = [string]::Empty

    )

    begin
    {
    }
    process
    {
        [hashtable] $RequestBody = @{
            name     = $Name
            email    = $Email
            password = (New-Object -TypeName PSCredential -ArgumentList 'user', $Password).GetNetworkCredential().Password
            language = $Language
        }

        if ( -not ( [string]::IsNullOrEmpty($QuickJoinID)))
        {
            $RequestBody.custom_quickjoin_id = $QuickJoinID
        }

        if ( -not ( [string]::IsNullOrEmpty($QuickSupportID)))
        {
            $RequestBody.custom_quicksupport_id = $QuickSupportID
        }

        If ($PSCmdlet.ShouldProcess( ('Create user with name: {0}?' -f $Name)))
        {
            try
            {
                $Params = @{
                    Token       = $Token
                    Resource    = 'users'
                    Method      = 'POST'
                    RequestBody = $RequestBody
                }

                $response = Invoke-TVApiRequest @Params

                # returns 204 on success
                Write-Verbose -Message ('Fetching TVUser with email: "{0}".' -f $Email)

            }
            catch [TVException]
            {
                #$ErrJsonout
                return $_.Exception.Message
                #Write-Error -Message $ErrJson.error_description
            }
            finally
            {
                if ( $null -ne $response)
                {
                    Write-Verbose -Message ('Got Response: "{0}"' -f $response )
                    #Get-TVUser -Email $Email -Token $Token
                    Get-TVUser -Token $Token -UserID $response.id
                }
            }
        }
    }
}
