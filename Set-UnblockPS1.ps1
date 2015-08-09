<#
.Synopsis
   Recursively trawls under current path for all PowerShell scripts and unblocks them.
.DESCRIPTION
   Recursively trawls under current path for all PowerShell scripts and unblocks them.
.EXAMPLE
    .\Set-Unblock.ps1
.NOTES
    Nothing too fancy, nothing too complex.
.LINK
    https://github.com/Aprazeth/majoraap/
#>
(Get-ChildItem -Filter *.ps1 -Path ("$pwd.path") -Recurse ) | Unblock-File
Write-Output "Done, all files should be unblocked now."