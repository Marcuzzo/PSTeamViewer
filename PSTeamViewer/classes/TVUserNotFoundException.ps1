class TVUserNotFoundException : System.Exception
{
    [string] $ErrorMessage
    [string] $Description
    [int] $Code
    TVUserNotFoundException($ErrorMessage, $Description, $Code )
    : base ( $Description )
    {
        $this.ErrorMessage = $ErrorMessage
        $this.Description = $Description
        $this.Code = $Code
    }
}