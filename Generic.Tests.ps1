<#
.SYNOPSIS
    Pester file to test all scripts for Get-Help compliance and ScriptAnalyzer
.DESCRIPTION
    Pester file to test all scripts for Get-Help compliance and ScriptAnalyzer
.NOTES
    REQUIRES:
    . Pester
    . ScriptAnalyzer

    VERSION:
    0.1 - Created 28 July 2017

    Credits go out to https://www.tomsitpro.com/articles/setting-up-visual-studio-code-tasks,1-3514.html
    for creating the original draft, upon which I've expanded by adding ScriptAnalyzer, adding the
    commentblock etc.
.EXAMPLE
    .\Invoke-Pester.ps1

    -----
    This will run pester, and by using this file all PS1 and PSM1 files will be scanned for:

    . Get-Help functionality
        . Synopsis
        . Description
        . Example
    . ScriptAnalyzer compliance
        . Error
        . Warning
        . Information
#>
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Get-ChildItem -Path $Here\* -Include '*.ps1', '*.psm1' -Recurse | ForEach-Object {
    Describe 'ScriptAnalyzer' -Tags 'ScriptAnalyzer' {
        Context "Messages - $_" {
            It 'Errors should be 0' {
                (Invoke-ScriptAnalyzer -Path $_.FullName -Severity 'Error').Count | Should Be 0
            }
            It 'Warning should be 0' {
                (Invoke-ScriptAnalyzer -Path $_.FullName -Severity 'Warning').Count | Should Be 0
            }
            It 'Information should be 0' {
                (Invoke-ScriptAnalyzer -Path $_.FullName -Severity 'Information').Count | Should Be 0
            }
        }
    }
    Describe 'Help' -Tags 'Help' {
        Context "Function - $_" {
            It 'Synopsis' {
                Get-Help -Name $_.FullName | Select-Object -ExpandProperty synopsis -ErrorAction SilentlyContinue | should not benullorempty
            }
            It 'Description' {
                Get-Help -Name $_.FullName | Select-Object -ExpandProperty Description -ErrorAction SilentlyContinue | should not benullorempty
            }
            It 'Examples' {

                $Examples = Get-Help -Name $_.FullName | Select-Object -ExpandProperty Examples -ErrorAction SilentlyContinue | Measure-Object
                $Examples.Count -gt 0 | Should be $true
            }
        }
    }
}