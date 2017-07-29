<#
.SYNOPSIS
    Pester test file for Set-UnblockPS1.ps1
.DESCRIPTION
    Pester test file for Set-UnblockPS1.ps1
    >> This file has not yet been completed <<
.NOTES
    REQUIRES:
    . Pester

    VERSION:
    0.1 - Created 29 July 2017

    TODO:
    * Test functionality when unblocking a file fails 
        * Unblocking a read-only file has a bug >> https://github.com/PowerShell/PowerShell/issues/4390
    * Test functionality when using -WhatIf
.EXAMPLE
    .\Invoke-Pester

    -----
    This will run Pester, and run through this script to test Set-UnblockPS1.ps1
.LINK
    https://github.com/Aprazeth/majoraap/
    Invoke-Pester
    https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/
#>
[CmdletBinding()]
PARAM()
Describe -Name 'Functionality' -Tag 'Functionality' {
    It 'unblocks blocked PowerShell Script' {
        $TestPath = "TestDrive:\test.ps1"
        Set-Content -Path $TestPath -value 'Break'
        $ZoneIdentifier = {
            [ZoneTransfer]
            ZoneId=3
        }
        Set-Content -Path $Testpath -Value $ZoneIdentifier -Stream 'Zone.Identifier'
        .\Set-UnblockPS1.ps1 -Path $Testpath
        $Result = Get-Item -Path $TestPath  -Stream 'Zone.Identifier' -ErrorAction SilentlyContinue
        $Result | Should benullorempty
    }
}
Describe -Name 'ErrorHandling' -Tag 'ErrorHandling' {
    It 'throws an error when providing an empty path' {
        $TestEmptyPath = ''
        {.\Set-UnblockPS1.ps1 -Path $TestEmptyPath} | Should Throw
    }
    It 'throws an error when providing an invalid path' {
        $TestInvalidPath = 'Invalid:\Path.ps1'
        {.\Set-UnblockPS1.ps1 -Path $TestInvalidPath} | Should Throw
    }    
    It 'Does not unblock a read-only script' {
        $TestROPath = "TestDrive:\testRO.ps1"
        Set-Content -Path $TestROPath -value 'Break'
        $ZoneIdentifier = {
            [ZoneTransfer]
            ZoneId=3
        }
        Set-Content -Path $TestROPath -Value $ZoneIdentifier -Stream 'Zone.Identifier'
        Set-ItemProperty -Path $TestROPath -Name IsReadOnly -Value $True
        .\Set-UnblockPS1.ps1 -Path $TestROPath
        [String[]]$ROResult = Get-Content -Path $TestROPath -Stream 'Zone.Identifier'
        $ROResult | Should not benullorempty
    }
}