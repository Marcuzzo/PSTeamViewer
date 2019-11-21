class TVTokenException : System.Exception
{
    [string] $ErrorMessage
    [string] $Description
    [int] $Code
    TVTokenException($ErrorMessage, $Description, $Code )
    : base ( $Description )
    {
        $this.ErrorMessage = $ErrorMessage
        $this.Description = $Description
        $this.Code = $Code
    }
}