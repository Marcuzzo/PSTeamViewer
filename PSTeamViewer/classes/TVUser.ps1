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
