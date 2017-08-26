<#
.SYNOPSIS
    Pester test file for Get-ARMAFileContent.ps1
.DESCRIPTION
    Pester test file for Get-ARMAFileContent.ps1
    >> This file has not yet been completed <<
.NOTES
    REQUIRES:
    . Pester

    VERSION:
    0.0 - Created 28 July 2017
.EXAMPLE
    .\Invoke-Pester

    -----
    This will run Pester, and run through this script to test Get-ARMAFileContent.ps1 
#>
[CmdletBinding()]
PARAM()
BREAK
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$Here\$Sut"

Describe "Run" {
    It "does something useful" {
        $true | Should Be $false
    }
}
