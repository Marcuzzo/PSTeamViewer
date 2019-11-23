function Set-TVUser
{
    <#
    .SYNOPSIS
    Modify an existing Teamviewer user.
    .DESCRIPTION
    Modify an existing Teamviewer User.
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com).
    .PARAMETER Identity
    a TVUser Object fetched by Get-TVUser.
    .PARAMETER UserID
    The userID of a Teamviewer user.
    .PARAMETER Name
    The new name of the Teamviewer user.
    .PARAMETER Email
    The new email address of the Teamviewer user.
    .PARAMETER Permissions
    a list of Permissions to add to the user account.
    .PARAMETER Active
    Indicates that the user should be active or not.
    .PARAMETER Password
    The password for the Teamviewer user.
    .PARAMETER QuickSupportID
    The QuickSupportID for the Teamviewer user.
    .PARAMETER QuickJoinID
    The QuickJoinID for the Teamviewer user.
    .PARAMETER PassThru
    Outputs the TVUser Object.
    .EXAMPLE
    Set-TVUser -Token $Env:TeamViewerToken -UserID 'u123456789' -Name 'Doe, John'
    Sets the name of user with ID: u123456789 to 'Doe, John'.
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -UserID 'u123456789' | Set-TVUser -Token $Env:TeamViewerToken -Name 'Solo, Han'
    Changes the name of user with ID: u123456789 to 'Solo, Han'.
    .INPUTS
    TVUser. The output of the Get-TVUser CmdLet.
    UserID. The userid of the user to modify.
    .OUTPUTS
    TVUser. The TVUser object that was modified.
    .LINK
    Get-TVUser
    .LINK
    New-TVUser
    .NOTES
    Author: Marco Micozzi
    #>
    [OutputType([TVUser])]
    [CmdLetBinding(
        HelpUri = 'http://psteamviewer.readthedocs.io/en/latest/cmdlets/Set-TVUser/',
        SupportsShouldProcess = $True
    )]
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

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
        [ValidateSet(
            'None', 'ManageAdmins', 'ManageUsers', 'ShareOwnGroups', 'ViewAllConnections',
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
        [string] $QuickSupportID = $null,

        [Parameter()]
        [switch] $PassThru

    )

    begin
    {

        if ( $PSCmdlet.ParameterSetName -eq 'ById')
        {
            $Identity = Get-TVUser -UserID $UserID -Token $Token
        }

        Write-Verbose -Message ('ParameterSet: {0}' -f $PSCmdlet.ParameterSetName)
    }

    process
    {

        # The hashtable containing the request parameters
        [hashtable] $RequestBody = @{ }

        if ( -not ( [string]::IsNullOrEmpty($Name)))
        {
            $RequestBody.name = $Name
        }

        if ( -not ( [string]::IsNullOrEmpty($Password)))
        {
            $RequestBody.password = (New-Object PSCredential 'user', $Password).GetNetworkCredential().Password
        }

        if ( -not ( [string]::IsNullOrEmpty($Email)))
        {
            $RequestBody.email = $Email
        }

        if ( -not ( [string]::IsNullOrEmpty($QuickJoinID)))
        {
            $RequestBody.custom_quickjoin_id = $QuickJoinID
        }

        if ( -not ( [string]::IsNullOrEmpty($QuickSupportID)))
        {
            $RequestBody.custom_quicksupport_id = $QuickSupportID
        }

        if ( $PSBoundParameters.ContainsKey('Active'))
        {
            $RequestBody.active = $Active
        }

        if ( $null -ne $Permissions )
        {
            Write-Verbose -Message 'not supported yed'
            #$RequestBody.permissions = $Permissions -join ','
        }

        If ($PSCmdlet.ShouldProcess( ('Modify user: {0}' -f $Identity.Name)))
        {
            $Params = @{
                Token       = $Token
                Resource    = 'users'
                PrincipalID = $Identity.ID
                Method      = 'PUT'
                RequestBody = $RequestBody
            }
            $response = Invoke-TVApiRequest @Params

            if ( $null -ne $response)
            {
                if ( $PassThru.IsPresent)
                {
                    Write-Output -InputObject (Get-TVUser -UserID $Identity.ID -Token $Token | Select-Object -Property * )
                }
            }
            else
            {
                Write-Error -Message ('Failed to modify userdata for user: {0}' -f $Identity.Name)
            }
        }
    }
}