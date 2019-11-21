function Set-TVGroup
{
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(

        [Parameter(
            Mandatory = $true
        )]
        [string] $Token,

        [Parameter(
            Mandatory = $true, 
            ValueFromPipeline = $true,
            ParameterSetName = 'ByInputObject'
        )]
        [ValidateNotNull()]
        [TVGroup] $InputObject,

        [Parameter(
            Mandatory = $true, 
            HelpMessage = 'The name of the group to delete.',
            ParameterSetName = 'ByName'    
        )]
        [string] $Name,

        [Parameter(
            Mandatory = $true, 
            HelpMessage = 'The Group ID of the group to delete.',
            ParameterSetName = 'ByID'
        )]
        [string] $GroupID,

        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $NewName,

        #       [Parameter()]
        #       [string] $PolicyID,

        [Parameter(
            Mandatory = $false
        )]
        [string] $CompanyUserID = [string]::Empty
    )

    begin
    {
        [hashtable] $Params = @{ }
    }

    process
    {
    
    
        switch ($PSCmdlet.ParameterSetName) 
        {
            'ByName'
            {
                $InputObject = Get-TVGroup -Token $Token -Name $Name -Verbose:$IsVerbose
            }
            
            'ByInputObject' { }
            
            'ByID'
            {
                $InputObject = Get-TVGroup -Token $Token -GroupID $GroupID -Verbose:$IsVerbose 
            }
            
            Default { }
        
        }

        if (!($InputObject))
        {
            throw 'Invalid groupname received.'
        }

        $Params.name = $NewName

        Try
        {

            if ( $PSCmdlet.ShouldProcess($InputObject.Name, 'Set Group') )
            {
                if ( [string]::IsNullOrEmpty($CompanyUserID) )
                {
                    Invoke-TVApiRequest -Token $Token -Resource groups -Method PUT -PrincipalID $InputObject.ID -RequestBody $Params
                }
                else
                {
                    Invoke-TVApiRequest -Token $Token -Resource users -Method PUT -PrincipalID ('{0}/groups/{1}' -f $CompanyUserID, $InputObject.ID ) -RequestBody $Params
                }
                Get-TVGroup -Token $Token -Name $InputObject.Name
            }
        }
        catch
        {           
            Write-Host $_
            $ErrJson = $_ | convertFrom-json 
            Write-Error -Message ("err: {0}" -f $ErrJson.message    )
            return $false
        }


    }

}