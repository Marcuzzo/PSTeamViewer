Properties {
  # Find the build folder based on build system
      $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
      if(-not $ProjectRoot)
      {
          $ProjectRoot = $PSScriptRoot
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


Task default -Depends Deploy

Task Deploy -Depends Test {
   "Deploying..."
 }

Task Test -Depends Init{

  $lines
  "`n`tSTATUS: Testing with PowerShell $PSVersion"
  $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

  (New-Object 'System.Net.WebClient').UploadFile( "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$ProjectRoot\$TestFile" )

  Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue


    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:
    "`n"
}