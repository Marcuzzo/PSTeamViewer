Task default -Depends Deploy

Properties {
    
    $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
    
    if( ( -not $ProjectRoot ) ) 
    {
        [ValidateNotNullOrEmpty()]$ProjectRoot = $Psake.build_script_dir 
    }

    $ProjectName = $ENV:APPVEYOR_PROJECT_NAME
    if(-not $ProjectName) { 
        [ValidateNotNullOrEmpty()]$ProjectName = (Get-ChildItem -Include *.psd1 -Recurse)[0].BaseName
    }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'
    $Verbose = @{}
    $CommitMsg =  "$env:APPVEYOR_REPO_COMMIT_MESSAGE $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED"
    if($CommitMsg -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:APPVEYOR*
    "`n"
}

Task Analyze -depends Init {    
    "$lines`n`n`tSTATUS: Scanning for PSScriptAnalyzer Errors"

    $ScanResults = Invoke-ScriptAnalyzer -Path "$ProjectRoot\$ProjectName" -Recurse -Severity Error

    If ($ScanResults.count -gt 0)
    {
        Throw "Failed PSScriptAnalyzer Tests"
    }
}

Task Help -depends Analyze {
    
    "$lines`n`n`tSTATUS: Building Module Help"
    
    Import-Module "$ProjectRoot\$ProjectName\$ProjectName.psd1"	-Force

    Try
    {
          New-ExternalHelp 'docs\cmdlets' -OutputPath "$ProjectName\en-US" -Force -ErrorAction Stop
          Import-Module "$ProjectRoot\$ProjectName\$ProjectName.psd1" -Force
    }
    Catch
    {
        Throw
    }        

}


Task Test -Depends Help {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
  
    if ( $env:APPVEYOR_JOB_ID )
    {
        (New-Object 'System.Net.WebClient').UploadFile( "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$ProjectRoot\$TestFile" )
    }
  
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
  
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Deploy -Depends Test {
    
    # Make sure we're using the Master branch and that it's not a pull request
    # Environmental Variables Guide: https://www.appveyor.com/docs/environment-variables/
    if ($env:APPVEYOR_REPO_BRANCH -ne 'master') 
    {
        Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
    }
    elseif ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0)
    {
        Write-Warning -Message "Skipping version increment and publish for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
    }
    else
    {
        Try 
        {
            # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
            $PM = @{
                Path        = '.\PSTeamViewer'
                NuGetApiKey = $env:NuGetApiKey
                ErrorAction = 'Stop'
            }
            Publish-Module @PM
            Write-Host "TeamViewer Module published to the PowerShell Gallery." -ForegroundColor Cyan
        }
        Catch 
        {
            
            Write-Warning "Publishing to the PowerShell Gallery failed."
            throw $_
        }
    }
}
