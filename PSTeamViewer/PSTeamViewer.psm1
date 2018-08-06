#region Classes

class TVTokenException : System.Exception
{
    [string] $Error
    [string] $Description
    [int] $Code
    TVTokenException($Error, $Description, $Code )
    : base ( $Description )
    {
        $this.Error = $Error
        $this.Description = $Description
        $this.Code = $Code    
    }
}

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

class TVPrincipal
{
    [ValidateNotNullOrEmpty()][string]$ID
    [ValidateNotNullOrEmpty()][string]$Name       
    TVUserBase($ID, $Name){
        $this.ID = $ID
        $this.Name = $Name
    }
}

class TVUser : TVPrincipal
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
            $QuickSupportID, 
            $QuickJoinID,
            $Email
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

Class TVAccount : TVPrincipal
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

Class TVGroupUser : TVPrincipal
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

Class TVGroup : TVPrincipal
{
    [TVPrincipal] $Owner
    [ValidateNotNullOrEmpty()][string]$Permissions
    [ValidateNotNullOrEmpty()][string]$PolicyID
    [TVGroupUser[]] $SharedWith
    TVGroup ( 
                [string] $ID, 
                [string] $Name, 
                [TVPrincipal] $Owner, 
                [string] $Permissions, 
                [TVGroupUser[]] $SharedWith
            ) : base ( $ID, $Name )
    {
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
#endregion Classes

#region API call

function Invoke-TVApiRequest
{
    [CmdletBinding()]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,
    
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet('account', 'users', 'devices', 'groups', 'contacts', 'sessions', 'ping')]
        [string] $Resource, 

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('GET', 'PUT', 'POST')]
        [string] $Method = 'GET',

        [Parameter()]
        [hashtable] $RequestBody = @{}
    )

    begin
    {        
        [string] $BaseUrl = 'https://webapi.teamviewer.com'
        [string] $ApiVersion = 'v1'
           
        [hashtable] $Header = @{
            Authorization = ("Bearer {0}" -f $Token)
        }            
        [string] $RequestUrl = ('{0}/api/{1}/{2}' -f $BaseUrl, $ApiVersion, $Resource)   
    }
    
    process
    {
        Write-Verbose -Message ('Request URL: "{0}".' -f $RequestUrl)
        try{        
            $response = Invoke-RestMethod -Uri $RequestUrl -Headers $Header -Body $RequestBody -Method $Method 
            Write-Verbose -Message 'returning tvobject'
            Write-Output -InputObject $response
        }
        catch {
            $ErrJson = $_ | convertFrom-json
            throw New-Object -TypeName TVTokenException -ArgumentList $ErrJson.error, $ErrJson.error_description, $ErrJson.error_code
        }
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
    if ( $Json.custom_quicksupport_id -ne $null )
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

#endregion 

#public interface

#region Test
function Test-TVApi
{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Token 
    )
    $response = Invoke-TVApiRequest -Token $Token -Resource ping
    return ( $response.token_valid -eq 'true')
}
#endregion

#region Users


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
        
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token ,
 
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

        try
        {
            $response = Invoke-TVApiRequest -Token $Token -Resource users -Method POST -RequestBody $Params 
            
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
        finally
        {
            Write-Verbose $response
        }

        
    }
}

function Get-TVUser{
    [OutputType([TVUser])]  
    [CmdletBinding(DefaultParameterSetName="All")]  
    param(
        
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,
        
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
        
        [Parameter()]
        [switch] $Simple

    )

    begin
    {        
        [hashtable] $RequestBody = @{
            full_list = (!$Simple.IsPresent)
        }
    }
    process
    {

        Write-Debug -Message ('ParameterSetNamer: "{0}".' -f $PSCmdlet.ParameterSetName)

        switch ($PSCmdlet.ParameterSetName) 
        {
            'ByID' { 
                Write-Debug -Message 'Checking by ID'                
                foreach ( $User in $UserID) 
                {
                    Write-Verbose -Message ('Processing ID: "{0}".' -f $User)
                    $response = Invoke-TVApiRequest -Token $Token -Resource "users/$User" -Method GET -RequestBody $RequestBody -Verbose
                    Write-Output -InputObject ( Initialize-TVUserObject -Json $response )                    
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
                $response = Invoke-TVApiRequest -Token $Token -Resource "users" -Method GET -RequestBody $RequestBody -Verbose 
                Write-Verbose -Message ('Response: "{0}".' -f $response.users )
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
    end{}
}

# Get all groups for a user
function Get-TVUserGroupMembership
{
    [CmdletBinding()]
    param(
        
        [Parameter()]
        [TVUserBase] $TVPrincipal
    )
}

#endregion

#region Devices
function Get-TVDevice{
    [OutputType([TVDevice])]
    [CmdletBinding()]
    param(
        
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token
    )
    
    $Response = Invoke-TVApiRequest -Token $Token -Resource devices -Method GET

    $Response.devices | ForEach-Object {
    
        [TVDevice] $TVDevice = New-Object -TypeName TVDevice `
                                          -ArgumentList $_.remotecontrol_id, $_.device_id, $_.alias, 
                                          $_.groupid, $_.online_state, $_.assigned_to, 
                                          $_.supported_features
        Write-Output $TVDevice                                                          

    }

}
#endregion devices

#endregion