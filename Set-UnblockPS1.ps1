<#
.SYNOPSIS
   Recursively trawls under current path for all PowerShell scripts and unblocks them.
.DESCRIPTION
   Recursively trawls under current path for all PowerShell scripts and unblocks them.
.EXAMPLE
    .\Set-Unblock.ps1

    ------------------------------------

    This runs the script, which will unblock all PowerShell Scripts in the current folder
    and all folders underneath (recursively)
.EXAMPLE
    .\Set-Unblock.ps1 -WhatIf

    ------------------------------------

    This runs the script, which will tell you which PowerShell Scripts in the current folder
    and all folders underneath (recursively) would be unblocked.
.PARAMETER WhatIf
    This optional switch parameter will allow you to review the actions that would be taken,
    if any.
.INPUTS
    [System.String]
        Script expects input to be provided via commandline. Pipeline not supported.
        Uses current working folder (and subfolder(s) if any) to check for PowerShell
        scripts.
.OUTPUTS
    [System.String]
        Scripts provides output via console.
.NOTES
    For change-notes, please consult GitHub.

    This script supports -Debug in case of error(s)/troubleshooting.
.LINK
    https://github.com/Aprazeth/majoraap/
#>
#Requires -version 2.0
[CmdletBinding()]
PARAM(
    [Switch]$WhatIf
    )
Try
    {
        (Get-ChildItem -Filter *.ps1 -Path ("$pwd.path") -Recurse ) | Unblock-File -WhatIf:$WhatIf
    } # END Try Get-ChildItem | Unblock-File
Catch
    {
        Write-Warning -Message "An unexpected error occured."
        Write-Debug -Message "($Error | Format-List -Force *)"
        Break
    } # END Catch Get-ChildItem | Unblock-File
Finally 
    {
        Write-Output -InputObject "Done, all PowerShell Scripts should be unblocked now."
    } # END Finally Get-ChildItem | Unblock-File