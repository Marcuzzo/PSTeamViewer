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
    TVUser(
            $ID, 
            $Name, 
            $Permissions, 
            $Active, 
            $LogSessions, 
            $ShowCommentWindow, 
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
    }
    TVUser(
            $ID, 
            $Name, 
            $Permissions, 
            $Active, 
            $LogSessions, 
            $ShowCommentWindow
    ) 
    : base ($ID, $Name) 
    {
       $this.Permissions = $Permissions
       $this.Active = $Active
       $this.ShowCommentWindow = $ShowCommentWindow
       $this.LogSessions = $LogSessions
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
                                                       $QuickSupportID, `
                                                       $QuickJoinID
    Write-Output -InputObject $TVUser
}
#endregion Helpers

#region Initialization
function Initialize-TVAPI
{
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [CmdletBinding( PositionalBinding = $false ) ]
    [OutputType([TVUser])]
    param(
        
        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,
 
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the user to create.')]
        [string] $Name,

        [Parameter(Mandatory = $true, HelpMessage = 'The email address of the user to create.')]
        [ValidateScript({
            if ($_ -match "^([0-9a-zA-Z]([-\.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$") {
              $true
            }
            else {
              Throw "$_ is  not a valid email address"
            }
          })]
          [string] $Email,

          [Parameter(Mandatory = $true, HelpMessage = 'The password of the user to create.')]
          [securestring]$Password,

          [Parameter(Mandatory = $false)]
          [ValidateSet('en', 'nl', 'fr', 'es')]
          [string] $Language = 'en',

          [Parameter(Mandatory = $false)]
          [ValidateNotNullOrEmpty()]
          [string] $QuickSupportID = [string]::Empty,

          [Parameter(Mandatory = $false)]
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
    [CmdletBinding()]
    [OutputType([TVUser])]   
    param(

        [Parameter()]
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Name = $null,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Email = $null,
        
        [Parameter()]
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
        
        [Parameter()]
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
            Write-Error -Message $ErrJson.error_description
            #.Message.error_description
        }
        
    }
    end{}
}

function Get-TVUser 
{
<#
    .Synopsis
   Get Teamviewer User
    .DESCRIPTION
   Get Teamviewer User
    .EXAMPLE
   Get-TVUser -Verbose | Where-Object { $_.Active -eq $false }
#>
    [CmdletBinding(PositionalBinding=$false, DefaultParameterSetName="All")]
    [OutputType([TVUser[]])]    
    param(
        [Parameter()]
        [string] $Token = $script:TVConfig.AccessToken,
        [Parameter( Mandatory = $true, ParameterSetName = 'ByID')]
        [string[]] $UserID,
        [Parameter( Mandatory = $true, ParameterSetName = 'ByName')]
        [string] $Name,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByEmail')]
        [string[]] $Email,
        [Parameter(Mandatory = $true,ParameterSetName = 'ByPermission')]
        [string[]] $Permission,
        [Parameter()]
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
    [CmdletBinding()]
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
            $response = Invoke-RestMethod -Method Put `
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
    [CmdletBinding()]
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
#endregion Devices

#region Groups

function Remove-TVGroup
{
    [CmdletBinding(SupportsShouldProcess=$true)]
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
                $response = Invoke-RestMethod -Method Delete `
                                              -Uri $RequestUrl `
                                              -Headers $script:TVConfig.Header `
                                              -ContentType 'application/json' `
                                              -ErrorAction SilentlyContinue -ErrorVariable respError     
                return $true                                    
            }
        }
        catch{           
            Write-Host $_
            $ErrJson = $_ | convertFrom-json 
            Write-Error -Message ("err: {0}" -f $ErrJson.message    )
        }

    }

}

function New-TVGroup
{
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    begin{
        # Make sure to have a token
        if ( [string]::IsNullOrEmpty($Token) ) {
            throw (New-Object -TypeName System.Exception -ArgumentList $script:TOKEN_MISSING_ERROR)
        }

        [string] $AdminParam = @{$true=('/users/{0}' -f $CompanyUserID);$false=[string]::Empty}[(!( [string]::IsNullOrEmpty($CompanyUserID)))]
        [string] $RequestUrl = ('{0}/api/{1}{2}/groups' -f $script:TVConfig.BaseUrl, $script:TVConfig.ApiVersion, $AdminParam)  
        
        Write-Verbose -Message ('Processing RequestURL: {0}' -f $RequestUrl)
        
    }
    process {
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
        $Response = Invoke-RestMethod -Uri $RequestUrl -Headers $script:TVConfig.Header -Body $Params
         
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

#endregion Groups

#region Local
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
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $RemoteControlID
    )

    $InstallDir = Get-TVInstallDir

    if ( $InstallDir -ne $null )
    {

        Start-Process -FilePath $InstallDir -ArgumentList ('-i {0}' -f $RemoteControlID)
        #Invoke-WebRequest -Uri ('https://start.teamviewer.com/device/{0}' -f $RemoteControlID)

    }

}

#endregion