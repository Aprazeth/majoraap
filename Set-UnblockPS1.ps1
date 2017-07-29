<#
.SYNOPSIS
   Recursively trawls under current path for all PowerShell scripts and unblocks them.
.DESCRIPTION
   Recursively trawls under a provided path for all PowerShell scripts and unblocks them.

   This script primarily acts as a wrapper for the cmdlet 'Unblock-File'.

   Please note; that the downloaded scripts should **always** be checked first before using them,
   or unblocking them.
.EXAMPLE
    .\Set-Unblock.ps1

    -----

    This runs the script, which will unblock all PowerShell Scripts in the current folder and all folders
    underneath (recursively)
.EXAMPLE
    .\Set-Unblock.ps1 -Path 'C:\PS1'

    -----

    This runs the script, which will unblock all PowerShell Scripts in the folder 'C:\PS1' and all folders 
    underneath (recursively)
.INPUTS
    System.String
        Script expects input to be provided via commandline, via pipeline as well.
        If none is provided, it uses current working folder (and subfolder(s) if any) to check for PowerShell
        scripts and unblocks them.
.OUTPUTS
    System.String
        Scripts provides output via console.
.NOTES
    REQUIRES:
    * PowerShell Version 3.0 or higher
    * File-access to unblock the scripts

    VERSION:
    2.0 - Updated 29 July 2017
    * Added SupportsShouldProcess, HelpUri.
    * Added ForEach for all the files found to be unblocked.
    * Added Try/Catch to the ForEach per file.
    * Added parameter Path
    * Changed Required PowerShell to version 3.0
    * Formatted script with VS code (auto-format; to follow best practices for code formatting)
    * Removed parameter WhatIf
    * Removed Finally block
    * Removed Break from Catch

    TODO:
    * Include a check to ensure the file is not set as:
        * ReadOnly
        * System
.LINK
    https://github.com/Aprazeth/majoraap/
    Unblock-File
#>
#Requires -version 3.0
[CmdletBinding(
    SupportsShouldProcess = $True,
    HelpUri = 'https://github.com/Aprazeth/majoraap/'
)]
PARAM(
   # Provide the path to the folder where the PowerShell scripts are stored. All sub-folders are checked as well.
    [Parameter(
        Position = 0,
        Mandatory = $False,
        ValueFromPipelineByPropertyName = $True,
        ValueFromPipeline = $True
    )]
    [ValidateScript(
        {
            If (-NOT (Test-Path -Path $_ -IsValid))
                {
                    Throw 'Invalid path'
                }
            $True
        }
    )]
    $Path = $PWD
)
Try {
    $FileList = Get-ChildItem -Filter '*.ps1' -Path $Path -Recurse 
    ForEach ($FileItem in $FileList) {
        Try {
            Unblock-File -Path $FileItem
        } # END Try Unblock-File FileItem
        Catch {
            Write-Warning -Message "Failed to unblock $($FileItem)"
        } # END Catch Unblock-File FileItem
    } # END ForEach FileItem in FileList
} # END Try Get-ChildItem Unblock-File
Catch {
    Write-Warning -Message 'An unexpected error occured.'
} # END Catch Get-ChildItem Unblock-File