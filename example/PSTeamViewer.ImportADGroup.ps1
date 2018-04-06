<#
.SYNOPSIS
Add Members of one or more groups to TeamViewer.

.DESCRIPTION
Add Members of one or more groups to TeamViewer.

.PARAMETER Token
The Access token as created on the TeamViewer Management Console.

.PARAMETER ADGroupName
One or more AD GroupNames of which it's members need to have a TeamViewer account.

.PARAMETER PasswordLength
The number of characters the random password should have.

.EXAMPLE
.\PSTeamViewer.ImportADGroup.ps1 -Token $env:TVAccessToken -ADGroupName 'DL_TeamViewer_Users'
Create a TeamViewer account for all members of the group 'DL_TeamViewer_Users' with a password length of 10 (default).

.EXAMPLE
.\PSTeamViewer.ImportADGroup.ps1 -Token $env:TVAccessToken -ADGroupName 'DL_TeamViewer_Users' -PasswordLength 12
Create a TeamViewer account for all members of the group 'DL_TeamViewer_Users' with a password length of 12.

.EXAMPLE
.\PSTeamViewer.ImportADGroup.ps1 -Token $env:TVAccessToken -ADGroupName 'DL_TeamViewer_Users', 'DL_TVUsers_Old' -PasswordLength 12
Create a TeamViewer account for all members of the group 'DL_TeamViewer_Users' and 'DL_TVUsers_Old' with a password length of 12.

.NOTES
    This code has not been tested!!!
    Author: Marco Micozzi
#>
[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $true
    )]
    [string] $Token,

    [Parameter(
        Mandatory = $true
    )]
    [string[]] $ADGroupName,

    [Parameter(
        Mandatory = $false
    )]
    [int] $PasswordLength = 10

)
begin{
    Write-Warning -Message 'This code has NOT been tested yet!!!'    
    Import-Module "$PSScriptRoot\..\PSTeamViewer\PSTeamViewer.psd1"
    Import-Module ActiveDirectory

    #region Password character range
    $CharacterRange = 33..126 
    $ExcludeRange = 34, 39, 95, 96
    $RandomRange = $CharacterRange | Where-Object { $ExcludeRange -notcontains $_ }
    #endregion

    # Initialize the API
    Initialize-TVAPI -Token $Token 
    
}
process{

    foreach ( $GroupName in $ADGroupName) 
    {
        
        if ( Get-ADGroup -Filter {SamAccountName -eq $GroupName })
        {
            # Recursively get all members of the requested AD Group
            # and add create the TeamViewer user
            Get-ADGroupMember -Identity $GroupName -Recursive | 
                Where-Object { $_.ObjectClass -eq 'User' } |
                    Get-ADUser -Properties DisplayName, Mail | ForEach-Object {
                        $CurrentUser = $_ 
                        $PasswordStr = ([char[]]$randomrange | Sort-Object {Get-Random})[0..$PasswordLength] -join ''
                        [securestring] $Password = ( ConvertTo-SecureString -String "$PasswordStr" -AsPlainText -Force)
                        New-TVUser -Name $CurrentUser.DisplayName -Email $CurrentUser.Mail -Password $Password
                    }

        }
        else
        {
            Write-Error -Message ('The group: "{0}" was not found!' -f $GroupName)
        }
    }
}
end{

}
