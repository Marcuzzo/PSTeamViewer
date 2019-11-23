<#
.SYNOPSIS
Remove old TVDevices
.DESCRIPTION
Remove old TVDevices based on a number of days or a given date
.PARAMETER Date
The date of the oldes allowed TVDevice
.PARAMETER Days
The numder of days that the computer is allowed to be offline
.EXAMPLE
Remove-StaleTVDevice -Date 2019-05-01
All TVDevices that have not been seen online since may 1, 2019 will be removed.
.EXAMPLE
Remove-StaleTVDevice -Days 255
All TVDevices that have not been seen online in the last 255 days will be removed.
.NOTES
Author: Marco Micozzi
Date: 23-11-2019
#>
[CmdLetBinding()]
param(
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'ByDate'
    )]
    [DateTime] $Date,

    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'ByDays'
    )]
    [int] $Days
)

begin
{

    # Import the PSTeamViewer module
    Import-Module $PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1 -Force

    # variable used to count the removed devices
    [int] $counter = 0

    # Get the datetime object based on the number of provided days
    if ( $PSCmdlet.ParameterSetName -eq 'ByDays')
    {
        $Date = (Get-Date).AddDays(-$Days)
    }

    # make sure that the date is at lease 2000-01-01.
    if ( $Date.Ticks -lt 630822816000000000)
    {
        Write-Error -Message 'An invalid DateTime parameter had been provided, aborting...' -ErrorAction Stop
        continue
    }
}

process
{

    Get-TVDevice -Token $env:TVAccessToken | Where-Object { $_.LastSeen -lt $Date } | ForEach-Object {
        if ( $null -ne $_.LastSeen )
        {
            Write-Verbose -Message ('Deleting device {0} with last date of {1}' -f $_.Alias, $_.LastSeen)
            $_ | Remove-TVDevice -Token $Token
            $counter++
        }
    }
}

end
{
    Write-Output -InputObject ('Deleted: {0} devices' -f $counter)
}