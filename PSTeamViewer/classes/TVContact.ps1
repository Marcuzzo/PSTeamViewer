<#
#>
Class TVContact
{

    <#
        contact_id
        The ID that is unique for this entry of the computers & contacts list.
        * Values are always prefixed with a ‘c’.
    #>
    [string] $ContactID

    <#
        the User ID of the contact.
        * Prefixed with a ‘u’.
    #>
    [string] $UserID

    <#
        The name of the contact.
    #>
    [string] $Name

    <#
        The email address of the contact.
        This is only returned if the parameter email was provided when calling the function.
    #>
    [string] $Email

    <#
        The ID of the group that this contact is a member of.
    #>
    [string] $GroupID

    <#
        The description that the current user has entered for this contact.
    #>
    [string] $Description

    <#
        The current online state of the contact.
        * Possible values are: online, busy, away, offline.
    #>
    [string] $OnlineState

    <#
        The profile picture of the contact.
        Contains the URL at which the profile picture can be found.
        The URL contains the string “[size]” as placeholder for the size of the picture,
            which needs to be replaced by an integer to retrieve the picture of that size.
        Valid sizes are 16, 32, 64, 128 and 256.
        Omitted if a contact has no profile picture set.
    #>
    [string] $ProfilePictureURL

    <#
        The features supported by the contact.
        * Possible values are: chat, remote_control, meeting, videocall.
    #>
    [string] $SupportedFeatures


    <#
    invitations (optional) List of all pending invitations.
        o groupId – The ID of the group this contact will be a member of.
        o email – The email address of the invitee
    #>


    # Dummy constuctor... needed?
    TVContact() { }
}