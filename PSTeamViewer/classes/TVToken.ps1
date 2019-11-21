class TVToken
{
    [ValidateNotNullOrEmpty()][string] $Access
    [ValidateNotNullOrEmpty()][string] $Type
    [ValidateNotNullOrEmpty()][string] $Refresh
    [ValidateNotNullOrEmpty()][int] $ExpiresIn
    [System.DateTime] $ExpireTime
    [bool] $Expired = $true
    [System.Timers.Timer] $Timer = $null
    TVToken($Access, $Type, $Refresh, $ExpiresIn)
    {
        $this.Expired = $false
        $this.ExpireTime = (Get-Date).AddSeconds($ExpiresIn)
        $this.Access = $Access
        $this.ExpiresIn = $ExpiresIn
        $this.Refresh = $Refresh
        $this.Type = $Type
        $this.Timer = New-Object -TypeName System.Timers.Timer -Property @{Interval = $ExpiresIn * 1000; AutoReset = $false }
        Register-ObjectEvent -InputObject $this.Timer -EventName 'Elapsed' -MessageData $this -Action {
            Write-Verbose -Message ('The Elapsed event was raised at {0}' -f $EventArgs.SignalTime)
            [TVToken] $token = $Event.MessageData
            $token.Expired = $true
        }
        $this.Timer.Enabled = $true
    }
}