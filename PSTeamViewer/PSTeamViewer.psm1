<#
    Description: TeamViewer API Module
    Author: Marco Micozzi
    Requires Powershell 5
#>
#region Module Variables
[string] $script:fmt_AuthBearer = "Bearer {0}"
[string] $script:TOKEN_MISSING_ERROR = 'No AccessToken found, please supply the token or run Initialize-TeamViewerAPI with a valid token first'
[string] $script:TOKEN_INVALID = 'Invalid Token'
[hashtable] $script:TVConfig = @{
    BaseUrl = 'https://webapi.teamviewer.com'
    LoginUrl = 'https://login.teamviewer.com'
    ApiVersion = 'v1'
    AccessToken = ''
    TokenValid = $false
    Header = @{
        Authorization = ''
    }
}
#endregion

#region Classes

class TVToken{
    [ValidateNotNullOrEmpty()][string] $Access
    [ValidateNotNullOrEmpty()][string] $Type
    [ValidateNotNullOrEmpty()][string] $Refresh
    [ValidateNotNullOrEmpty()][int] $ExpiresIn
    [System.DateTime] $ExpireTime
    [bool] $Expired = $true
    [System.Timers.Timer] $Timer = $null

    TVToken($Access, $Type, $Refresh, $ExpiresIn){
        $this.Expired = $false
        $this.ExpireTime = (Get-Date).AddSeconds($ExpiresIn)
        $this.Access = $Access
        $this.ExpiresIn = $ExpiresIn
        $this.Refresh = $Refresh
        $this.Type = $Type
        $this.Timer = New-Object -TypeName System.Timers.Timer -Property @{Interval=$ExpiresIn*1000;AutoReset=$false}
        Register-ObjectEvent -InputObject $this.Timer -EventName 'Elapsed' -MessageData $this -Action {             
            Write-Verbose -Message ('The Elapsed event was raised at {0}' -f $EventArgs.SignalTime)    
            [TVToken] $token = $Event.MessageData
            $token.Expired = $true
        }
        $this.Timer.Enabled = $true   
    }
 }

class TVUserBase
{
    [ValidateNotNullOrEmpty()][string]$ID
    [ValidateNotNullOrEmpty()][string]$Name       
    TVUserBase($ID, $Name){
        $this.ID = $ID
        $this.Name = $Name
    }
}

class TVUser : TVUserBase
{
    [ValidateNotNullOrEmpty()][string[]]$Permissions
    [ValidateNotNullOrEmpty()][bool]$Active
    [bool]$LogSessions
    [bool]$ShowCommentWindow
    [string]$QuickSupportID
    [string]$QuickJoinID
    [string] $Email
    TVUser(
            $ID, 
            $Name, 
            $Permissions, 
            $Active, 
            $LogSessions, 
            $ShowCommentWindow, 
            $Email,
            $QuickSupportID, 
            $QuickJoinID
    ) 
    : base ($ID, $Name) 
    {        
       $this.Permissions = $Permissions
       $this.Active = $Active
       $this.QuickSupportID = $QuickSupportID
       $this.QuickJoinID = $QuickJoinID
       $this.ShowCommentWindow = $ShowCommentWindow
       $this.LogSessions = $LogSessions
       $this.Email = $Email
    }
    TVUser(
            $ID, 
            $Name, 
            $Permissions, 
            $Active, 
            $LogSessions, 
            $ShowCommentWindow,
            $Email
    ) 
    : base ($ID, $Name) 
    {
       $this.Permissions = $Permissions
       $this.Active = $Active
       $this.ShowCommentWindow = $ShowCommentWindow
       $this.LogSessions = $LogSessions
       $this.Email = $Email
    }
}

Class TVAccount : TVUserBase
{
    [string] $Email
    [string] $CompanyName
    TVAccount ( 
                [string] $ID, 
                [string] $Name, 
                [string] $Email, 
                [string] $CompanyName
    ) 
    : base ($ID, $Name)
    {
        $this.Email = $Email
        $this.CompanyName = $CompanyName
    }
}

Class TVGroupUser : TVUserBase
{
    [string] $Permissions = [string]::Empty
    [bool] $Pending = $false
    

    TVGroupUser ( $ID, $Name, $Permissions, $Pending) 
    : base ( $ID, $Name) 
    {
        $this.Permissions = $Permissions
        $this.Pending = $Pending
    }
    TVGroupUser ( $ID, $Name, $Permissions) 
    : base ( $ID, $Name) 
    {
        $this.Permissions = $Permissions
    }

    TVGroupUser ( $TVGroupUser)
    {
        $this = $TVGroupUser        
    }
}

Class TVUserGroup : TVGroupUser
{
    [string] $GroupID
    [string] $GroupName
    TVUserGroup ( $TVGroupUser, $ID, $Name) 
    : base ( $TVGroupUser.ID, $TVGroupUser.Name, $TVGroupUser.Permissions, $TVGroupUser.Pending) 
    {
        $this.GroupID = $ID
        $this.GroupName = $Name

    }
}

Class TVGroup 
{
    [ValidateNotNullOrEmpty()][string]$ID
    [ValidateNotNullOrEmpty()][string]$Name
    [TVUserBase] $Owner
    [ValidateNotNullOrEmpty()][string]$Permissions
    [ValidateNotNullOrEmpty()][string]$PolicyID
    [TVGroupUser[]] $SharedWith
    TVGroup ( 
                [string] $ID, 
                [string] $Name, 
                [TVUserBase] $Owner, 
                [string] $Permissions, 
                [TVGroupUser[]] $SharedWith
            )
    {
        $this.ID = $ID
        $this.Name = $Name
        $this.Owner = $Owner
        $this.Permissions = $Permissions
        $this.SharedWith = $SharedWith
    }
}

Class TVDevice
{
    [string] $RemoteControlID
    [string] $DeviceID
    [string] $Alias
    [string] $GroupID
    [string] $OnlineStatus
    [bool] $AssignedTo
    [string] $SupportedFeatures
    TVDevice ( [string] $RemoteControlID, 
               [string] $DeviceID, 
               [string] $Alias, 
               [string] $GroupID, 
               [string] $OnlineStatus, 
               [bool] $AssignedTo, 
               [string] $SupportedFeatures
            )
    {
        $this.Alias = $Alias
        $this.AssignedTo = $AssignedTo
        $this.DeviceID = $DeviceID
        $this.GroupID = $GroupID
        $this.OnlineStatus = $OnlineStatus
        $this.RemoteControlID = $RemoteControlID
        $this.SupportedFeatures = $SupportedFeatures
    }
}
#endregion
    
#region Helpers
function Initialize-TVUserObject
{
    [CmdLetBinding()]
    [OutputType([TVUser])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Json
    )
    [string] $QuickSupportID = [System.String]::Empty
    if( $Json.custom_quicksupport_id -ne $null)
    {
        $QuickSupportID = $Json.custom_quicksupport_id
    }    
    [string] $QuickJoinID = [System.String]::Empty
    if( $Json.custom_quickjoin_id -ne $null)
    {
        $QuickJoinID = $Json.custom_quickjoin_id
    }    
    [string[]] $Permissions = $Json.permissions -split ','
    [TVUser] $TVUser = New-Object TVUser -ArgumentList $Json.id, `
                                                       $Json.name, `
                                                       $Permissions, `
                                                       $Json.active, `
                                                       $Json.log_sessions, `
                                                       $Json.show_comment_window, `
                                                       $Json.email, `
                                                       $QuickSupportID, `
                                                       $QuickJoinID
    Write-Output -InputObject $TVUser
}
#endregion Helpers

#region Initialization
function Initialize-TVAPI
{
    <#
    .SYNOPSIS
    Initialize the TeamViewer API wrapper
    
    .DESCRIPTION
    Initialize the TeamViewer API wrapper
    
    .PARAMETER Token
    The API token created on the management portal
    
    .EXAMPLE
    Initialize-TVAPI -Token "ABCD-1234"
    Initialize the TeamViewer API with the token "ABCD-1234"
    
    .NOTES
    Initializing the wrapper will allow all API call's to be made without having to specify the token in each call
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Initialize-TVAPI/'
    )]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('t')]
        [string] $Token
    )
    begin
    {
        [bool] $IsTokenValid = Test-TVToken -Token $Token
        if ( -not ( $IsTokenValid )) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_INVALID)            
        }
    }
    process
    {
        $script:TVConfig.TokenValid = $IsTokenValid 
        $script:TVConfig.AccessToken = $Token
        $script:TVConfig.Header.Authorization = ($script:fmt_AuthBearer -f $Token)
    }    
}
#endregion

#region Ping

function Test-TVToken
{
    <#
    .SYNOPSIS
    Test a TeamViewer API Token
    .DESCRIPTION
    Tests if a TeamViewer API token is valid
    .PARAMETER Token
    The token generated on the TeamViewer Management Console
    .EXAMPLE
    Test-TVToken -Token 'abc123def456ghi789'
    Tests if the token 'abc123def456ghi789' is valid
    .NOTES
    Author: Marco Micozzi
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Test-TVToken/'
    )]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Token 
    )
    begin
    {    
        [string] $RequestUrl = ('{0}/api/{1}/ping' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)
        Write-Verbose -Message ('Compiled TV API request URI: "{0}".' -f $RequestUrl)
    }
    process
    {
        $TVResponse = Invoke-RestMethod -Method Get `
                                        -Uri $RequestUrl `
                                        -Headers @{ Authorization = ($script:fmt_AuthBearer -f $Token)} 
        Write-Verbose -Message $TVResponse
    }
    end
    {
        Write-Verbose -Message ('TRUE: {0}' -f ($TVResponse.token_valid -eq 'true'))
        return ( $TVResponse.token_valid -eq 'true')
    }
}
#endregion

#region Authorization

function Get-TVOAuth2Authorization
{
    [CmdletBinding( PositionalBinding = $false ) ]
    param(
        [Parameter( Mandatory = $true )]
        [string] $ClientID,
        
        [Parameter( Mandatory = $false )]
        [string] $RedirectURI = [string]::Empty
    )

    begin{
        Add-Type -AssemblyName PresentationFramework
        [string] $fmt_loginUtl = '{0}/oauth2/authorize?response_type=code&client_id={1}&redirect_url={2}&display=popup'
        [string] $Url = $fmt_loginUtl -f $script:TVConfig.LoginUrl, $ClientID, $RedirectURI
    }
    
    process
    {
        [System.Windows.Window] $Window = New-Object Windows.Window -Property @{Width=440;Height=640}
        $Window.Title = 'TeamViewer oAuth2'
        $window.WindowStartupLocation="CenterScreen" 
        [System.Windows.Controls.Grid] $Grid = New-Object -TypeName System.Windows.Controls.Grid 
        [System.Windows.Controls.WebBrowser] $Browser = New-Object -TypeName System.Windows.Controls.WebBrowser `
                                                            -Property @{Source=($Url -f ($Scope -join "%20")) }
        $Browser.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $Browser.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
        $Grid.AddChild($Browser)
        $Window.Content = $Grid
        $window.ShowDialog() | Out-Null
    }
}


function Revoke-TVOauth2Token
{
    [OutputType([bool])]    
    [CmdLetBinding()]
    param(
        [string] $Token
    )


}

<#
    This function needs to be tested!!!
#>
function Get-TVOauth2Token
{
    [OutputType([TVToken])]    
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVOauth2Token/'
    )]
    param(

        [Parameter(
            Mandatory=$true, HelpMessage = 'Authorization code acquired from the /oauth2/authorize page.',
            ParameterSetName = 'Grant'
        )]
        [string] $AuthorizationCode,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Must be the same value as in the previous call to /oauth2/authorize',
            ParameterSetName = 'Grant'
        )]
        [string] $RedirectURI = [string]::Empty,
        
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Refresh-token from a previous call.',
            ParameterSetName = 'RefreshToken'
        )]
        [string] $RefreshToken,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Client ID, a unique string that identifies the application.',
            ParameterSetName = 'Grant'
        )]        
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Client ID, a unique string that identifies the application.',
            ParameterSetName = 'RefreshToken'
        )]
        [string] $ClientID,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The client secret, which is known only to the creator of the application.',
            ParameterSetName = 'Grant'
        )]        
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Client ID, a unique string that identifies the application.',
            ParameterSetName = 'RefreshToken'
        )]
        [string] $ClientSecret

    )

    Write-Warning -Message 'The function "Get-TVOauth2Token" needs proper testing!!!'

    [string] $RequestUrl = ('{0}/api/{1}/oauth2/token' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)

    Try
    {
        
        [System.Net.WebRequest] $Request = [System.Net.WebRequest]::Create($RequestUrl)
        $Request.Method = 'POST'
        $Request.ContentType = 'application/x-www-form-urlencoded'
    
        [string] $Parameters = ('client_id={0}&client_secret={1}' -f $ClientID, $ClientSecret )
        
        switch ( $PSCmdlet.ParameterSetName ){
            
            'Grant' {
                $Parameters += ('&grant_type=authorization_code&code={0}&redirect_uri={1}' -f $AuthorizationCode, $RedirectURI)
            }
            
            'RefreshToken' {
                $Parameters += ('&grant_type=refresh_token&refresh_token={0}' -f $RefreshToken)
            }
            
            Default{
                Write-Error -Message ('Unexpected ParameterSetname received: "{0}".' -f $PSCmdlet.ParameterSetName)
            }

        }
        
        Write-Verbose -Message ('Got Parameters: "{0}".' -f $Parameters)
        
        [byte[]] $Payload = [System.Text.Encoding]::UTF8.GetBytes($Parameters)
    
        Write-Verbose -Message ('Got Payload: "{0}".' -f $Payload)
    
        [System.IO.Stream] $RequestStream = $Request.GetRequestStream()
        $RequestStream.Write($Payload, 0, $Payload.Length)
        $RequestStream.Close()

        Write-Verbose -Message 'closing stream'

        [System.Net.WebResponse] $Response = $Request.GetResponse()
        Write-Verbose -Message 'Got repsonse'
        [string] $StatusString = $Response.StatusCode
        [int] $StatusCode = [int] $Response.StatusCode

        Write-Verbose -Message ('Got Status Code: "{0}" with message: "{1}".' -f $StatusCode, $StatusString)

        [System.IO.Stream] $ResponseStream = $Response.GetResponseStream()
        [System.IO.StreamReader] $StreamReader = New-Object -TypeName System.IO.StreamReader `
                                                            -ArgumentList $ResponseStream
        [string] $Result = $StreamReader.ReadToEnd()

        if ( $StatusCode -ne 200)
        {
            # false
            Write-Verbose -Message ( 'Status code {0}' -f $StatusCode)
            
        }
        else
        {
            $jsonResponse = ConvertFrom-Json -InputObject $result 
            
            [TVToken] $Token = New-Object -TypeName TVToken -ArgumentList $jsonResponse.access_token, $jsonResponse.token_type, $jsonResponse.refresh_token, $jsonResponse.expires_in
    
            Write-Output -InputObject $Token

        }       

    }
    catch
    {
        Write-Host ("Token: Request failed! The error was '{0}'" -f $_)
        $_.Exception
        #$resstream = $_.Exception.InnerException.Response.GetResponseStream()
        #$sr = new-object System.IO.StreamReader $resstream
        #$value = $sr.ReadToEnd()
		#Write-Host $value

    }
    finally
    {
        if ($Response)
        {
            Write-Verbose -Message ('Closing response')
            $Response.Close()
            Write-Verbose -Message ('Response closed')
        }
        
    }
    
}

#endregion Authorization

#region Account
function Get-TVAccount
{
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVAccount/'
    )]
    [OutputType([TVAccount])]
    param(
        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken
    )
    begin
    {
        if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }   
    }    
    process
    {
        [string] $RequestUrl = ('{0}/api/{1}/account' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)        
        $Response = Invoke-RestMethod -Uri $RequestUrl `
                                      -Headers $script:TVConfig.Header `
                                      -Body $RequestBody `
                                      -Method 'Get'
        [TVAccount] $Account = New-Object -TypeName TVAccount `
                                          -ArgumentList $Response.userid, `
                                                        $Response.name, `
                                                        $Response.email, `
                                                        $Response.company_name
        Write-Output -InputObject $Account
    }
}
#endregion Account

#region Users

# TODO: Permissions 
# permissions (optional) – Comma-separated list of permissions that this user has. 
# See 1.6.2 for valid values and combinations. 
# If omitted the following default permissions will be set: ShareOwnGroups, ViewOwnConnections, EditConnections, EditFullProfile
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
    New-TVUser -Token $Env:TeamViewerToken -Name 'John Doe' -Email 'john.doe@domain.com' -Passwprd (ConvertTo-SecureString -String "P4ssW0rd!" -AsPlainText -Force)   
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
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/New-TVUser/'    
    )]
    [OutputType([TVUser])]
    param(
        
        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,
 
        [Parameter(
            Mandatory = $true, 
            HelpMessage = 'The name of the user to create.'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true, 
            HelpMessage = 'The email address of the user to create.'
        )]
        [ValidateScript({
            if ($_ -match "^([0-9a-zA-Z]([-\.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$") {
              $true
            }
            else {
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
        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }  
        [string] $RequestUrl = ('{0}/api/{1}/users' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)              
    }

    process 
    {      
        [hashtable] $Params = @{
            name = $Name
            email = $Email
            password =  (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
            language = $Language
        }  

        if ( -not ( [string]::IsNullOrEmpty($QuickJoinID)))
        {
            $Params.custom_quickjoin_id = $QuickJoinID
        }
        
        if ( -not ( [string]::IsNullOrEmpty($QuickSupportID)))
        {
            $Params.custom_quicksupport_id = $QuickSupportID
        }
        
        # TODO: Add permission support

        Write-Verbose -Message ('Running Request URl: "{0}"' -f $RequestUrl)
        
        Try
        {        
            $response = Invoke-RestMethod -Method Post `
                                          -Uri $RequestUrl `
                                          -Headers $script:TVConfig.Header `
                                          -Body ( $Params | ConvertTo-Json ) `
                                          -ContentType 'application/json' `
                                          -ErrorAction SilentlyContinue -ErrorVariable respError     
            # returns 204 on success                                          
            Write-Verbose -Message "Fetching..."
            Get-TVUser -Email $Email -Token $Token
        }
        catch
        {           
            Write-Output $_
            #$ErrJsonoutWrite-Output $_.ErrorDetails.Message | convertFrom-json 
            #Write-Error -Message $ErrJson.error_description
        }
    }
}

#TODO: User or company access token. Scope: Users.ModifyUsers or Users.ModifyAdministrators.
function Set-TVUser
{
    <#
    .SYNOPSIS
    Modify an existing Teamviewer user
    .DESCRIPTION
    Modify an existing Teamviewer User
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Identity
    a TVUser Object fetched by Get-TVUser
    .PARAMETER UserID
    The userID of a Teamviewer user
    .PARAMETER Name 
    The new name of the Teamviewer user
    .PARAMETER Email
    The new email address of the Teamviewer user
    .PARAMETER Permissions
    a list of Permissions to add to the user account
    .PARAMETER Active
    Indicates that the user should be active or not
    .PARAMETER Password
    The password for the Teamviewer user
    .PARAMETER QuickSupportID 
    The QuickSupportID for the Teamviewer user
    .PARAMETER QuickJoinID 
    The QuickJoinID for the Teamviewer user 
    .EXAMPLE
    Set-TVUser -Token $Env:TeamViewerToken -UserID 'u123456789' -Name 'Doe, John'
    Sets the name of user with ID: u123456789 to 'Doe, John'
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -UserID 'u123456789' | Set-TVUser -Token $Env:TeamViewerToken -Name 'Solo, Han'
    Changes the name of user with ID: u123456789 to 'Solo, Han' 
    .INPUTS
    TVUser. The output of the Get-TVUser CmdLet.
    .OUTPUTS
    TVUser. The TVUser object that was modified.
    .LINK
    Get-TVUser
    .LINK
    New-TVUser
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Set-TVUser/'
    )]
    [OutputType([TVUser])]   
    param(

        [Parameter(
            Mandatory = $false
        )]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter(
            Mandatory = $true, 
            ParameterSetName = 'ByIdentity', 
            ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [TVUser] $Identity,

        [Parameter(
            Mandatory = $true, 
            ParameterSetName = 'ById')]
        [string] $UserID,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name = $null,
        
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Email = $null,
        
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('None', 'ManageAdmins', 'ManageUsers', 'ShareOwnGroups', 'ViewAllConnections', 
                     'ViewOwnConnections', 'EditConnections', 'DeleteConnections', 'EditFullProfile', 
                     'ManagePolicies', 'AssignPolicies', 'AcknowledgeAllAlerts', 'AcknowledgeOwnAlerts', 
                     'ViewAllAssets', 'ViewOwnAssets', 'EditAllCustomModuleConfigs', 'EditOwnCustomModuleConfigs')]
        [string[]] $Permissions = $null,
        
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [securestring] $Password = $null,
        
        [Parameter(
            Mandatory = $false
        )]
        [bool] $Active,
        
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $QuickJoinID = $null,
        
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string] $QuickSupportID = $null
    )
    begin
    {

        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }

        Write-Verbose -Message ('ParameterSet: {0}' -f $PSCmdlet.ParameterSetName)
        
        if ( $PSCmdlet.ParameterSetName -eq 'ById')
        {
            $Identity = Get-TVUser -UserID $UserID 
        }
    }
    process
    {

        [string] $RequestUrl = ('{0}/api/{1}/users/{2}' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $Identity.ID)

        [hashtable] $Params = @{}

        if ( -not ( [string]::IsNullOrEmpty($Name)))
        {
            $Params.name = $Name
        }

        if ( -not ( [string]::IsNullOrEmpty($Password)))
        {
            $Params.password =  (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
        }

        if ( -not ( [string]::IsNullOrEmpty($Email)))
        {
            $Params.email = $Email
        }

        if ( -not ( [string]::IsNullOrEmpty($QuickJoinID)))
        {
            $Params.custom_quickjoin_id = $QuickJoinID
        }
        
        if ( -not ( [string]::IsNullOrEmpty($QuickSupportID)))
        {
            $Params.custom_quicksupport_id = $QuickSupportID
        }
                    
        if ( $PSBoundParameters.ContainsKey( "Active" ) ) 
        {
            $Params.active = $Active
        }

        if ( $Permissions -ne $null )
        {
            Write-Verbose -Message 'not supported yed'
            #$Params.permissions = $Permissions -join ','
        }

        Write-Verbose -Message ('Running Request URl: "{0}"' -f $RequestUrl)

        Try
        {
            
            $response = Invoke-RestMethod -Method Put `
                                          -Uri $RequestUrl `
                                          -Headers $script:TVConfig.Header `
                                          -Body ( $Params | ConvertTo-Json ) `
                                          -ContentType 'application/json' `
                                          -ErrorVariable respError     

            Get-TVUser -UserID $Identity.ID -Token $Token
        
        }
        catch
        {           
            # Write-Host -Object ('Error: "{0}". - Description: "{1}". - Code: "{2}".' -f $_.error, $response.error_description, $response.error_code)
            # Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            # Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
            # Write-Host "StatusCode:" ([int]$_.Exception.Response.StatusCode)
            $ErrJson = $_.ErrorDetails.Message | convertFrom-json 
            Write-Error -Message ('Error: {0}' -f $ErrJson.error_description)
            #.Message.error_description
        }
        
    }
    end{}
}

function Get-TVUser 
{
    <#
    .SYNOPSIS
    Get Teamviewer user(s)
    .DESCRIPTION
    Get the details of one or more users from the Teamviewer management portal
    .PARAMETER Token
    The Teamviewer API token
    .PARAMETER UserID
    The ID of the user on the Teamviewer portal
    .PARAMETER Name
    The name of the user
    .PARAMETER Email
    The email address of the user
    .PARAMETER Permission
    Permissions assigned to a user
    .PARAMETER Simple
    minimize the output of the CmdLet
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken
    Gets all Teamviewer Users
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -Name 'John Doe'
    Gets the user or all users with the name 'John Doe'
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -Email 'john.doe@domain.com'
    Gets the user with the specified email address.
    .INPUTS
    None. You can't pipe objects to the Get-TVUser CmdLet
    .OUTPUTS
    TVUser. a TVUser object or an array of TVUser Objects
    .NOTES
    Author: Marco Micozzi
    .LINK 
    New-TVUSer
    .LINK
    Set-TVUser
    #>
    [CmdletBinding(
        HelpUri="http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVUser",
        PositionalBinding=$false,
        DefaultParameterSetName='All'
    )]
    [OutputType([TVUser[]])]    
    param(
        [Parameter(
            Mandatory = $false
        )]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter(
            Mandatory = $true, 
            ParameterSetName = 'ByID'
        )]
        [string[]] $UserID,

        [Parameter( 
            Mandatory = $true, 
            ParameterSetName = 'ByName'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true, 
            ParameterSetName = 'ByEmail'
        )]
        [string[]] $Email,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByPermission'
        )]
        [string[]] $Permission,

        [Parameter(
            Mandatory = $false
        )]
        [switch] $Simple
    )
    begin
    {
        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }
        [hashtable] $RequestBody = @{
            full_list = (!$Simple.IsPresent)
        }
        [string] $RequestUrl = ('{0}/api/{1}/users' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)   
    }
    process
    {
        Write-Debug -Message ('ParameterSetNamer: "{0}".' -f $PSCmdlet.ParameterSetName)
        switch ($PSCmdlet.ParameterSetName) 
        {
            'ByID' { 
                Write-Debug -Message 'Checking by ID'
                foreach ( $User in $UserID) {
                    Write-Verbose -Message ('Processing ID: "{0}".' -f $User)
                    $Json = Invoke-RestMethod -Uri ('{0}/{1}' -f $RequestUrl, $User) -Headers $script:TVConfig.Header -Body $RequestBody -Method 'Get'
                    Write-Verbose -Message ($Json | ConvertTo-Json)
                    Write-Output -InputObject ( Initialize-TVUserObject -Json $Json )
                }
              }
            { ( $_ -eq 'ByName' )  -or ( $_ -eq 'ByEmail' ) -or ( $_ -eq 'All') } {  
                Write-Debug -Message 'The received parameters are Name, Email or none'                
                if ( $PSCmdlet.ParameterSetName -eq 'ByName')
                {
                    Write-Verbose -Message ('Checking by name: "{0}".' -f $Name)                    
                    $RequestBody.name = $Name
                }
                if ( $PSCmdlet.ParameterSetName -eq 'ByEmail')
                {
                    $RequestBody.email = @{$true = $Email -join ', '; $false = $Email -join ''}[ ($Email.Count -ge 2)]   
                    Write-Verbose -Message ('Checking by mail: "{0}".' -f $RequestBody.email )    
                }
                Write-Verbose -Message ('Get-TVUser: Processing URL: "{0}".' -f $RequestUrl)
                $Response = Invoke-RestMethod -Uri $RequestUrl -Headers $script:TVConfig.Header -Body $RequestBody -Method 'Get'
                Write-Verbose -Message $response
                $Response.users | ForEach-Object {       
                    Write-Verbose -Message $_            
                    Write-Output -InputObject ( Initialize-TVUserObject -Json $_ )
                }
            }
            'ByPermission' { 
                throw New-Object -TypeName System.NotImplementedException -ArgumentList 'Search by Permission has not been implemented yet.'
            }            
            Default {
                throw New-Object -TypeName System.ArgumentException -ArgumentList ('Unexpected ParameterSet received: "{0}".' -f $PSCmdlet.ParameterSetName)
            }
        }
    }
}

#endregion Users

#region Devices

function Set-TVDevice
{
    [CmdletBinding(
        
    )]
    [OutputType([TVDevice])]
    param(
        [Parameter( Position = 0 )]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter( Mandatory = $true, Position = 1, ParameterSetName = 'ByDeviceIDPolicy' )]
        [Parameter( Mandatory = $true, Position = 1, ParameterSetName = 'ByDeviceIDGroup' )]
        [string] $DeviceID,

        [Parameter( Mandatory = $true, Position = 1, ParameterSetName = 'ByInputObjectPolicy' )]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByInputObjectGroup' )]
        [ValidateNotNull()]
        [TVDevice] $InputObject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Alias,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Passwd,

        [Parameter(ParameterSetName = 'ByDeviceIDPolicy')]
        [Parameter(ParameterSetName = 'ByInputObjectPolicy')]
        [ValidateNotNullOrEmpty()]
        [string] $PolicyID,

        [Parameter(ParameterSetName = 'ByInputObjectGroup')]
        [Parameter(ParameterSetName = 'ByDeviceIDGroup')]
        [ValidateNotNullOrEmpty()]
        [string] $GroupID,

        [Parameter()]
        [switch] $PassThru

    )

 
    
    begin
    {

        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }

        Write-Verbose -Message ('ParameterSet: {0}' -f $PSCmdlet.ParameterSetName)
        
        if ( $PSCmdlet.ParameterSetName -eq 'ById')
        {
            $InputObject = Get-TVDevice | Where-Object { $_.DeviceID -eq $DeviceID}
        }
    }
    process
    {
        [string] $RequestUrl = ('{0}/api/{1}/devices/{2}' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $InputObject.DeviceID)  
    
        [hashtable] $Params = @{}

        if ( -not ( [string]::IsNullOrEmpty($Alias)))
        {
            $Params.alias = $Alias
        }
        
        if ( -not ( [string]::IsNullOrEmpty($Description)))
        {
            $Params.description = $Description
        }
                    
        if ( -not ( [string]::IsNullOrEmpty($Passwd)))
        {
            $Params.password = $Passwd
        }
                    
        if ( -not ( [string]::IsNullOrEmpty($PolicyID)))
        {
            $Params.policy_id = $PolicyID
        }
                    
        if ( -not ( [string]::IsNullOrEmpty($GroupID)))
        {
            $Params.groupid = $GroupID
        }

        
        Try
        {
            Invoke-RestMethod -Method Put `
                                            -Uri $RequestUrl `
                                            -Headers $script:TVConfig.Header `
                                            -Body ( $Params | ConvertTo-Json ) `
                                            -ContentType 'application/json' `
                                            -ErrorVariable respError     

            #Get-TVUser -UserID $Identity.ID -Token $Token
    
        }
        catch
        {           
            $ErrJson = $_.ErrorDetails.Message | convertFrom-json 
            Write-Error -Message $ErrJson.error_description
        }
    }
}

function Get-TVDevice
{
    <#
    .SYNOPSIS
    Get Device information fom the Teamviewer portal
    
    .DESCRIPTION
    Get Device information fom the Teamviewer portal
    
    .PARAMETER Token
    The API token generated on the portal
    
    .PARAMETER OnlineState
    include online or offline devices
    
    .PARAMETER GroupID
    Get all devices of a specific GroupID
    
    .PARAMETER RemoteControlID
    Get the device with a specific RemotecontrolID
    
    .EXAMPLE
    Get-TVDevice -OnlineState Online
       
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVDevice/'
    )]
    [OutputType([TVDevice[]])]
    param(

        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Online', 'Offline')]
        [string] $OnlineState = [string]::Empty,

        [Parameter(Mandatory=$false)]
        [string] $GroupID = [string]::Empty,    
        
        [Parameter(Mandatory=$false)]
        [string] $RemoteControlID = [string]::Empty
    )
    
    begin
    {
                
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }
                
        [string] $RequestUrl = ('{0}/api/{1}/devices' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion)  
        
        [hashtable] $RequestBody = @{}
    }

    process
    {

        if ( ! ( [string]::IsNullOrEmpty($OnlineState)))
        {
            $RequestBody.online_state = $OnlineState
        }

        if ( ! ( [string]::IsNullOrEmpty($GroupID)))
        {
            $RequestBody.groupid = $GroupID
        }

        if ( ! ( [string]::IsNullOrEmpty($RemoteControlID ) ) ) 
        {
            $RequestBody.remotecontrol_id = $RemoteControlID
        }

        $Response = Invoke-RestMethod -Uri $RequestUrl -Headers $script:TVConfig.Header -Body $RequestBody

        $Response.devices | ForEach-Object {
                        
            [TVDevice] $TVDevice = New-Object -TypeName TVDevice `
                                            -ArgumentList $_.remotecontrol_id, $_.device_id, $_.alias, 
                                                          $_.groupid, $_.online_state, $_.assigned_to, 
                                                          $_.supported_features
            Write-Output $TVDevice                                                          

        }

    }

}

function New-TVDevice
{
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory=$false
        )]
        [string] $RemoteControlID = [string]::Empty, 

        [Parameter(
            Mandatory=$false
        )]
        [string] $GroupID = [string]::Empty,  

        [Parameter(
            Mandatory = $false
        )]
        [string] $Description = [string]::Empty,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Alias = [string]::Empty,
 
        [Parameter(
            Mandatory = $false
        )]
        [securestring] $Password = $null
    )
}

function Remove-TVDevice
{
    [CmdletBinding(
        SupportsShouldProcess=$true
    )]
    param(
        [Parameter( Position = 0 )]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter( Mandatory = $true, Position = 1, ParameterSetName = 'ByDeviceID' )]
        [string] $DeviceID,

        [Parameter(
            Mandatory = $true, 
            Position = 1, 
            ParameterSetName = 'ByInputObject',
            ValueFromPipeline = $true
        )]
        [ValidateNotNull()]
        [TVDevice] $InputObject
    )

    begin
    {
                
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }
        
        Write-Verbose -Message ('ParameterSet: {0}' -f $PSCmdlet.ParameterSetName)
        
        if ( $PSCmdlet.ParameterSetName -eq 'ByDeviceID')
        {
            $InputObject = Get-TVDevice | Where-Object { $_.DeviceID -eq $DeviceID}
        }
    }

    process
    {


        [string] $RequestUrl = ('{0}/api/{1}/devices/{2}' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $InputObject.DeviceID)  
    
                
        Try
        {

            Write-Verbose -Message ('Removing device: {0} with deviceID: {1}' -f $InputObject.Alias, $InputObject.DeviceID)
            Invoke-RestMethod -Method DELETE `
                                            -Uri $RequestUrl `
                                            -Headers $script:TVConfig.Header `
                                            -ContentType 'application/json' `
                                            -ErrorVariable respError     

            #Get-TVUser -UserID $Identity.ID -Token $Token
    
        }
        catch
        {           
            $ErrJson = $_.ErrorDetails.Message | convertFrom-json 
            Write-Error -Message $ErrJson.error_description
        }
    }
    

}


#endregion Devices

#region Groups

function Remove-TVGroup
{
    <#
    .SYNOPSIS
    Remove a Teamviewer group
    .DESCRIPTION
    Remove a Teamviewer group 
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER InputObject
    an instance of TVGroup returned by Get-TVGroup
    .PARAMETER Name
    The name of the TVGroup to be removed
    .PARAMETER GroupID
    The ID of the group to be removed
    .PARAMETER CompanyUserID
    The ID of the administrator to remove a company group instead of a user group.
    .EXAMPLE
    Remove-TVGroup -Name 'TestGroup'
    Removes the group "TestGroup" by name
    .EXAMPLE
    Get-TVGroup -Name 'TestGroup' | Remove-TVGroup
    Removes the group 'TestGroup' by InputObject
    .EXAMPLE
    Remove-TVGroup -GroupID 'GRP1'
    Removes the group with GroupID 'GRP1'
    .INPUTS
    TVGroup. The objects returned by the Get-TVGroup can be piped to the Remove-TVGroup CmdLet.
    .OUTPUTS
    None. This CmdLet doesn't produce any output
    .NOTES
    Author: Marco Micozzi
    .LINK
    Get-TVGroup
    .LINK
    New-TVGroup
    #>
    [CmdletBinding(
        SupportsShouldProcess=$true
    )]
    param(

        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline = $true,
            ParameterSetName = 'ByInputObject'
        )]
        [ValidateNotNull()]
        [TVGroup] $InputObject,

        [Parameter(
            Mandatory=$true, 
            HelpMessage = 'The name of the group to delete.',
            ParameterSetName = 'ByName'    
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true, 
            HelpMessage = 'The Group ID of the group to delete.',
            ParameterSetName = 'ByID'
        )]
        [string] $GroupID,

        [Parameter()]
        [string] $CompanyUserID = [string]::Empty
    )

    begin{
        
        # Check token
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }
        
        [string] $AdminParam = @{$true=('/users/{0}' -f $CompanyUserID);$false=[string]::Empty}[(!( [string]::IsNullOrEmpty($CompanyUserID)))]
        
        [string] $RequestUrl = ('{0}/api/{1}{2}/groups' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $AdminParam)  
                       
    }
    
    process{
       
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $InputObject = Get-TVGroup -Name $Name
              }
            'ByInputObject' {}
            'ByID' {
                $InputObject = Get-TVGroup | Where-Object { $_.ID -eq $GroupID }    
            }
            Default {}
        }

        if(!($InputObject)){
            throw 'Invalid groupname received.'
        }

        $RequestUrl += ('/{0}' -f $InputObject.ID)
        Write-Verbose -Message ('Processing RequestURL: {0}' -f $RequestUrl)
                   
        Try{
            if ( $PSCmdlet.ShouldProcess($InputObject.Name, 'Remove Group') ){
                $Response = Invoke-RestMethod -Method Delete `
                                              -Uri $RequestUrl `
                                              -Headers $script:TVConfig.Header `
                                              -ContentType 'application/json' `
                                              -ErrorAction SilentlyContinue -ErrorVariable respError     
                return ( (Get-TVGroup -Token $Token -Name $InputObject.Name) -eq $null )                                
            }
        }
        catch{           
            Write-Host $_
            $ErrJson = $_ | convertFrom-json 
            Write-Error -Message ("err: {0}" -f $ErrJson.message    )
            return $false
        }

    }

}
function New-TVGroup
{
    <#
    .SYNOPSIS 
    Create a new TeamViewer Group
    .DESCRIPTION
    Create a new TeamViewer Group
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Name
    The name of the new group
    .PARAMETER CompanyUserID 
    Administrator user ID
    .EXAMPLE
    New-TVGroup -Token $env:TeamviewerToken -Name 'MyTestGroup'
    Creates the group MyTestGroup
    .INPUTS
    None. You cannot pipe objects to New-TVGroup
    .OUTPUTS
    TVGroup. New-TVGroup will return the newly created TVGroup object  
    .NOTES 
    Author: Marco Micozzi
    .LINK
    Get-TVGroup
    .LINK
    Remove-TVGroup
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/New-TVGroup/'
    )]
    [OutputType([TVGroup])]
    param(

        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter(Mandatory=$true, HelpMessage = 'The name of the group to create.')]
        [string[]] $Name,

        [Parameter()]
        [string] $CompanyUserID = [string]::Empty
    )

    begin{

        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }

        [string] $AdminParam = @{$true=('/users/{0}' -f $CompanyUserID);$false=[string]::Empty}[(!( [string]::IsNullOrEmpty($CompanyUserID)))]

        [string] $RequestUrl = ('{0}/api/{1}{2}/groups' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $AdminParam)  
        
        Write-Verbose -Message ('Processing RequestURL: {0}' -f $RequestUrl)

    }

    process 
    {

        foreach ( $GroupName in $Name)
        {
            
            [hashtable] $Params = @{
                name = $GroupName
                # policy_id = ''
            }  
    
            Try{
            
                $response = Invoke-RestMethod -Method Post `
                                              -Uri $RequestUrl `
                                              -Headers $script:TVConfig.Header `
                                              -Body ( $Params | ConvertTo-Json ) `
                                              -ContentType 'application/json' `
                                              -ErrorAction SilentlyContinue -ErrorVariable respError     
                
                Get-TVGroup -Name $response.name -Token $Token
            
            }
            catch{

            }
        }

    }

}
function Get-TVGroup
{
    <#
    .SYNOPSIS
    Get TeamViewer group information
    .DESCRIPTION
    Get information about a teamviewer group via the API
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER Name
    The name of the group to fetch
    .PARAMETER Shared
    Wether or not to list shared groups.
    .PARAMETER CompanyUserID
    The admin ID
    .EXAMPLE
    Get-TVGroup -Token $Env:TeamViewerToken
    Get all Teamviewer groups
    .EXAMPLE
    Get-TVGroup -Token $ENV:TeamviewerToken -Name "TestGrp"
    Get a group with the name 'TestGrp'
    .NOTES
    Author: Marco Micozzi
    .LINK
    New-TVGroup
    .LINK
    Remove-TVGroup
    #>
    [CmdletBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Get-TVGroup/'
    )]
    [OutputType([TVGroup])]
    param(
        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [bool] $Shared, 

        [Parameter(Mandatory = $false)]
        [string] $CompanyUserID = [string]::Empty

    )

    begin
    {
        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }

        [string] $AdminParam = @{$true=('/users/{0}' -f $CompanyUserID);$false=[string]::Empty}[(!( [string]::IsNullOrEmpty($CompanyUserID)))]
        [string] $RequestUrl = ('{0}/api/{1}{2}/groups' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $AdminParam)  
        
        Write-Verbose -Message ('Processing RequestURL: {0}' -f $RequestUrl)
        
    }

    process
    {
        [hashtable] $Params = @{}
        if ( -not ( [string]::IsNullOrEmpty($Name)))
        {
            $Params.name = $Name
        }
        if ( $PSBoundParameters.ContainsKey( "Shared" ) ) 
        {
            $Params.shared = $Shared
        }
        # Fetch the groups from the API
        $Response = Invoke-RestMethod -Uri $RequestUrl -Headers $script:TVConfig.Header -Body $Params -ErrorVariable RestError -ErrorAction SilentlyContinue
        
        $RestError

        # Iterate over the groups
        $Response.groups | ForEach-Object {                
            $CurrentGroup = $_
            [TVGroupUser[]] $SharedWith = @()
            #Write-Verbose -Message ('not Shared?: "{0}".' -f [string]::IsNullOrEmpty($CurrentGroup.shared_with))
            # Make sure that the group is shared first
            if ( -not ( [string]::IsNullOrEmpty($CurrentGroup.shared_with)) ) 
            {
                $CurrentGroup.shared_with |  ForEach-Object {
                    [TVGroupUser] $CurrentUser = New-Object -TypeName TVGroupUser -ArgumentList $_.userid, $_.name, $_.permissions, $_.pending
                    $SharedWith += $CurrentUser 
                }
               
            }

            [TVUserBase] $Owner = $null
            if ($CurrentGroup.owner -ne $null)
            {
                $Owner = New-Object -TypeName TVUserBase -ArgumentList $CurrentGroup.owner.userid, $CurrentGroup.owner.name
            }

            [TVGroup] $Group = New-Object -TypeName TVGroup -ArgumentList $CurrentGroup.ID, $CurrentGroup.Name, $Owner, $CurrentGroup.permissions, $SharedWith
            Write-Output -InputObject $Group 
        }
    }
    end {}
}

function Get-TVUserGroups
{
<#
    .SYNOPSIS
    Get the groups a user is member of.
    .DESCRIPTION
    Get a list of groups the user is member of
     .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER User
    The TeamViewer User as retreived by Get-TVUser
    .PARAMETER Name
    The Name of the user to fetch the groups for.
    .EXAMPLE
    Get-TVGroup -Token $Env:TeamViewerToken
    Get all Teamviewer groups
    .EXAMPLE
    Get-TVUserGroups -Token $ENV:TeamviewerToken -Name "JohnDoe"
    Get all groups of which the user 'JohnDoe' is member of.
    .EXAMPLE
    Get-TVUserGroups -Token $ENV:TeamviewerToken -User (Get-TVUser -Token $ENV:TeamviewerToken -Name "JohnDoe" )
    Get all groups of which the user 'JohnDoe' is member of.
    .NOTES
    Author: Marco Micozzi
    .LINK
    New-TVGroup
    .LINK
    Remove-TVGroup
#>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByInputObject'    
        )]
        [TVUser] $User,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByName'
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $false
        )]
        [string] $Token = $script:TVConfig.AccessToken
    )
    begin
    {
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }    

        if ( $PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $User = Get-TVUser -Token $Token -Name $Name
        }
    }
    process{
        Get-TVGroup -Token $Token | ForEach-Object {
            $Group = $_
            $Group.SharedWith | 
                Where-Object { $_.ID -eq $User.ID } | ForEach-Object {
                        Write-Verbose -Message ('Got group: {0} with ID: {1}' -f $Group.Name, $Group.ID)
                        [TVUserGroup]::new($_, $Group.ID, $Group.Name)                        
                    }
                }
    }
}

function Remove-TVGroupMember{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true            
        )]
        [TVGroup] $Group,

        [Parameter(
            Mandatory = $true
        )]
        [TVUser] $User
    )

    begin
    {        
        # Make sure to have a token
       # if ( [string]::IsNullOrEmpty($Token) ) 
       # {
       #     throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
       # }  
        [string] $RequestUrl = ('{0}/api/{1}/groups/{2}/unshare_group' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $Group.ID)              
    }

    process
    {
        [hashtable] $Params = @{
            users = @(
                $User.ID                               
            )           
        }  
        
        Invoke-RestMethod -Method Post `
                            -Uri $RequestUrl `
                            -Headers $script:TVConfig.Header `
                            -Body ($Params | ConvertTo-Json) `
                            -ContentType 'application/json' `
                            -ErrorAction SilentlyContinue `
                            -ErrorVariable respError
    
        
    }
}

function Add-TVGroupMember
{
    [CmdLetBinding()]
    param(

        [Parameter(
            Mandatory = $true            
        )]
        [TVGroup] $Group,

        [Parameter(
            Mandatory = $true
        )]
        [TVUser[]] $TVUser,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('read', 'readwrite')]
        [string] $Permission = 'read'
    )

    begin
    {
    
        # Make sure to have a token
        if ( -not ( $script:TVConfig.TokenValid ) )
        # if ( [string]::IsNullOrEmpty($Token) ) 
        {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }  
        [string] $RequestUrl = ('{0}/api/{1}/groups/{2}/share_group' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $Group.ID)              

        [hashtable] $Params = @{
            users = @(
            )           
        }  
    }

    process {

        foreach ( $User in $TVUser)
        {
            $TVUserObject = @{
                userid = $User.ID
                permissions = $Permission
            }

            $Params.users += $TVUserObject
        }
        
        Invoke-RestMethod -Method Post `
                          -Uri $RequestUrl `
                          -Headers $script:TVConfig.Header `
                          -Body ($Params | ConvertTo-Json) `
                          -ContentType 'application/json' `
                          -ErrorAction SilentlyContinue `
                          -ErrorVariable respError

    }
    
}

#endregion Groups

#region Local

function Get-TVClientID{
    <#
    .SYNOPSIS
    Get the clientID from one or more (remote) computers
    .DESCRIPTION
    Retreives the CLientID registry value from one or more computers in the same LAN.
    .PARAMETER ComputerName
    The name(s) of the computer(s) to fetch the ClientID from.
    .EXAMPLE
    Get-TVClientID -ComputerName MarcoPC01
    Retreives the ClientID from the computer MarcoPC01 in the current LAN
    .NOTES
    This CmdLet will only work on computers in the same LAN.
    A Test-Connection will check if the remote computer(s) is/are available.
    Remote Registry has to be enabled to make this work.
    Author: Marco Micozzi
    
    #>
    #TODO: Test the Get-TVClientID CmdLet
    [CmdLetBinding()]
    param(        
        [Parameter(
            Mandatory = $false
        )]
        [string[]] $ComputerName = $env:COMPUTERNAME    
    )
    begin
    {
        [string] $KeyPath = 'SOFTWARE\\WOW6432Node\\TeamViewer'
    }
    process
    {        
        foreach ( $Computer in $ComputerName )
        {
            if ( Test-Connection -ComputerName $Computer -Count 1 -Quiet ) 
            {
                [Microsoft.Win32.RegistryKey] $HKEY_LM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                [Microsoft.Win32.RegistryKey] $TeamViewerKey = $HKEY_LM.OpenSubKey($KeyPath)
                if ( $TeamViewerKey -ne $null )
                {
                    [hashtable] $Properties = @{
                        ComputerName = $Computer
                        ClientID = $TeamViewerKey.GetValue('ClientID')
                    }
                    New-Object -TypeName PSObject -Property $Properties                
                }
                else
                {
                    Write-Error -Message ('The key: "HKLM:\{0}" was not found on computer: "{1}"!' -f $KeyPath, $Computer)
                }
            }
            else
            {
                Write-Error -Message ('The computer: "{0}" is offline!' -f $Computer)
            }
        }
    }
}

function Get-TVInstallDir
{
    <#
    Get-Package -ProviderName Programs | Where-Object {$_.Name -like 'TeamViewer*'}
    #>
    [CmdletBinding()]
    param()

    $ProgramFilesX86 = @{$true=${env:ProgramFiles(x86)};$false=$env:ProgramFiles}[(${env:ProgramFiles(x86)} -ne $null)]
    
    "$ProgramFilesX86\TeamViewer\TeamViewer.exe" | ForEach-Object {
        if ( Test-Path -Path $_ ) 
        {
            return $_
        }
        else
        {
            return $null
        }
    }
}
function Start-TVRemoteControl
{
    <#
    .SYNOPSIS
    Start a remote control session.
    .DESCRIPTION
    Start a remote control session.
    .PARAMETER RemoteControlID
    The remote control ID of a computer
    .PARAMETER InputObject
    The TVDevice Object returned by the Get-TVDevice CmdLet
    .PARAMETER Password
    The password to connect to this computer.
    .PARAMETER Mode
    The mode to connect to the remote computer.
    Defaults to 'Remote Control' if omitted.
    Valid values are 'vpn' or 'FileTransfer'
    .EXAMPLE
    Start-TVRemoteControl -RemoteControlID 'abc123'
    Starts a session to the device with remotecontrol ID abc123 and prompts for a password
    .EXAMPLE
    Get-TVDevice | Where-Object {$_.Alias -eq 'PC0001'} |  Start-TVRemoteControl 
    Start a remote control session to the computer with name PC0001
    .NOTES
    Author: Marco Micozzi

    #>
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByRemoteControlID'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $RemoteControlID, 


        [Parameter(
            Mandatory = $true, 
            ParameterSetName = 'ByInputObject'
        )]
        [ValidateNotNull()]
        [TVDevice] $InputObject,

        [Parameter(
            Mandatory = $false
        )]
        [securestring] $Password = $Null,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet("FileTransfer", "vpn")]
        [ValidateNotNullOrEmpty()]
        [string] $Mode = $null
    )

    $InstallDir = Get-TVInstallDir

    # Make sure Teamviewer is installed
    if ( $InstallDir -ne $null )
    {       

        # If the TVDevice was passed as an argument, get the RemoteControlID value.
        if ( $PSCmdlet.ParameterSetName -eq 'ByInputObject')
        {
            $RemoteControlID = $InputObject.RemoteControlID
        }

        # Create the argument string
        [string] $Arguments = ('-i {0}' -f $RemoteControlID)

        # Add the password if supplied
        if ( -not ( [string]::IsNullOrEmpty($Password)))
        {
            $Arguments += (' -P {0}' -f (New-Object PSCredential "user",$Password).GetNetworkCredential().Password)
        }

        # add the mode if supplied
        if ( -not ( [string]::IsNullOrEmpty($Mode)))
        {
            $Arguments += (' -m {0}' -f $Mode)
        }

        # Start the session
        Start-Process -FilePath $InstallDir -ArgumentList $Arguments

        # not sure about this one...
        #Invoke-WebRequest -Uri ('https://start.teamviewer.com/device/{0}' -f $RemoteControlID)

    }
}

#endregion

    