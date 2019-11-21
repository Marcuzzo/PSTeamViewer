function Initialize-TVUserObject
{
    [CmdLetBinding()]
    [OutputType([TVUser])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Json
    )
    [string] $QuickSupportID = [System.String]::Empty
    if ( $null -ne $Json.custom_quicksupport_id)
    {
        $QuickSupportID = $Json.custom_quicksupport_id
    }

    [string] $QuickJoinID = [System.String]::Empty
    if ( $null -ne $Json.custom_quickjoin_id )
    {
        $QuickJoinID = $Json.custom_quickjoin_id
    }

    [string[]] $Permissions = $Json.permissions -split ','
    [TVUser] $TVUser = New-Object TVUser -ArgumentList $Json.id, $Json.name, $Permissions, $Json.active, $Json.log_sessions, $Json.show_comment_window, $QuickSupportID, $QuickJoinID, $Json.email
    Write-Output -InputObject $TVUser
}