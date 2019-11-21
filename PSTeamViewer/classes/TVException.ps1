class TVException : System.Exception
{
    [string] $ErrorMessage
    [string] $Description
    [int] $Code
    TVException($ErrorMessage, $Description, $Code )
    : base ( $Description )
    {
        $this.ErrorMessage = $ErrorMessage
        $this.Description = $Description
        $this.Code = $Code
    }
}