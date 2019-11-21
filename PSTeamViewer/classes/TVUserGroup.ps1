Class TVUserGroup : TVGroupUser
{
    [string] $GroupID
    [string] $GroupName
    TVUserGroup ( $TVGroupUser, $ID, $Name) 
    : base ( $TVGroupUser.ID, $TVGroupUser.Name, $TVGroupUser.Permissions, $TVGroupUser.Pending) 
    {
        $this.GroupID = $ID
        $this.GroupName = $Name

    }
}