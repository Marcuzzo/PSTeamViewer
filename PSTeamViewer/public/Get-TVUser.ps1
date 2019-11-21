function Get-TVUser
{
    <#
    .SYNOPSIS
    Get details of a Teamviewer user
    .DESCRIPTION
    Get details of a Teamviewer user
    .PARAMETER Token
    The Teamviewer API token generated on the Teamviewer Management console (https://login.teamviewer.com)
    .PARAMETER UserID
    The userID of a Teamviewer user
    .PARAMETER Name
    The name of the Teamviewer user
    .PARAMETER Email
    The email address of the Teamviewer user
    .PARAMETER Permissions
    a list of Permissions of user accounts to fetch
    .PARAMETER Simple
    Indicates that a limited set of properties should be returned
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -UserID 'u123456789'
    Gets the TVUser object of user with ID: u123456789
    .EXAMPLE
    Get-TVUser -Token $Env:TeamViewerToken -Name 'Solo, Han'
    Gets the TVUser object of a user with the name 'Solo, Han'
    .INPUTS

    .OUTPUTS
    TVUser. The TVUser object.
    .LINK
    Set-TVUser
    .LINK
    New-TVUser
    #>
    [OutputType([TVUser])]
    [CmdletBinding(DefaultParameterSetName = "All")]
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
        [System.ObsoleteAttribute('The Permission parameter is not yet implemented')]
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
            'ByID'
            {
                Write-Debug -Message 'Checking by ID'
                foreach ( $ID in $UserID)
                {
                    Write-Verbose -Message ('Processing ID: "{0}".' -f $ID)

                    Try
                    {
                        $response = Invoke-TVApiRequest -Token $Token -Resource users -PrincipalID $ID -Method GET -RequestBody $RequestBody
                        Write-Output -InputObject ( Initialize-TVUserObject -Json $response )
                    }
                    catch
                    {
                        Write-Error -Message $_.Exception.Message
                    }
                }
            }

            { ( $_ -eq 'ByName' ) -or ( $_ -eq 'ByEmail' ) -or ( $_ -eq 'All') }
            {

                Write-Debug -Message 'The received parameters are Name, Email or none'
                if ( $PSCmdlet.ParameterSetName -eq 'ByName')
                {
                    Write-Verbose -Message ('Checking by name: "{0}".' -f $Name)
                    $RequestBody.name = $Name
                }
                if ( $PSCmdlet.ParameterSetName -eq 'ByEmail')
                {
                    $RequestBody.email = @{$true = $Email -join ', '; $false = $Email -join '' }[ ($Email.Count -ge 2)]
                    Write-Verbose -Message ('Checking by mail: "{0}".' -f $RequestBody.email )
                }

                $response = Invoke-TVApiRequest -Token $Token -Resource users -Method GET -RequestBody $RequestBody

                Write-Verbose -Message ('Response: "{0}".' -f $response )

                if ( $null -ne $response)
                {
                    $Response.users | ForEach-Object {
                        Write-Verbose -Message $_
                        Write-Output -InputObject ( Initialize-TVUserObject -Json $_ )
                    }
                }
                else
                {
                    Write-Verbose -Message 'No users found'
                }

            }

            'ByPermission'
            {
                throw New-Object -TypeName System.NotImplementedException -ArgumentList 'Search by Permission has not been implemented yet.'
            }
            Default
            {
                throw New-Object -TypeName System.ArgumentException -ArgumentList ('Unexpected ParameterSet received: "{0}".' -f $PSCmdlet.ParameterSetName)
            }
        }
    }
    end { }
}