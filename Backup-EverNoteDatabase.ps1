<#
.SYNOPSIS
    This PowerShell Script can be scheduled (or run manually) to sync your
    EverNote local database, and then export a backup locally. Lastly, it then
    starts your Cloud storage software to store those files in the cloud.
.DESCRIPTION
	The script was created based of a CMD file I wrote some time ago, that
    would allow me to have a local EverNote backup. After searching the
    internet I did find some example scripts but none that did what I wanted.

    So I went about and created the first version, as a CMD-file. As I recently
    got started in using PowerShell I figured it would be a great candidate
    to get converted into a PowerShell script.

    The script sets several variables, that you can alter via parameters, such as 
    the install-path of EverNote, the cloud software you want to use, 
    as well as the location of exported EverNote database.
.PARAMETER EverNotePath
	This variable needs to be set to where your EverNote installation is. By
    default it will be in C:\Program Files (x86)\Evernote\Evernote\ so you 
    most likely won't need to provide this. Observe that the ENscript.exe 
    must be at the end!

    A default value is provided if none is specified.
.PARAMETER CloudStorageProvider
    This variable needs to be configured to whereever your cloud storage
    provider software is installed. Whether this is DropBox, Box, OneDrive
    OwnCloud, SpiderOak, etc. - be sure to include the executable's name of 
    the software!

    A default value is provided if none is specified.
.PARAMETER BackupPath
    This variable needs to be provided to where you want your files to be
    stored. It is absolutely VITAL that you use a folder that you have defined
    in your cloud storage software to be backed up!

    A default value is provided if none is specified.
.EXAMPLE
	This script can be used with the Task scheduler in Windows, to run as a 
    scheduled task OR you can run it manually whenever you want or need it.

    The commandline you will need to enter for the Script to run as a scheduled
    task is:

        PowerShell -file "location and name of this script"

    So an example would be:

        PowerShell -file "C:\OwnCloud\EverNote\Backup-EverNoteDatabase.ps1"
.LINK
    https://github.com/Aprazeth/majoraap
.INPUTS
    [System.String]
        Input provided by parameters (if specified)
.OUTPUTS
    [System.String]
        Output provided via console; 
        (file) Extracted EverNote database in BackupPath
        (file) logfile(s) in BackupPath
#>
#requires -version 2.0
[CmdletBinding()]
PARAM(
    [Parameter(Mandatory=$False,
                ValueFromPipelineByPropertyName=$True,
                Position=0)]
    [String]$EverNotePath = "${env:ProgramFiles(x86)}\Evernote\Evernote\ENScript.exe",

    [Parameter(Mandatory=$False,
                ValueFromPipelineByPropertyName=$True,
                Position=1)]
    [String]$CloudStorageProvider = "${env:ProgramFiles(x86)}\ownCloud\owncloud.exe",
    
    [Parameter(Mandatory=$False,
                ValueFromPipelineByPropertyName=$True,
                Position=2)]
    [String]$BackupPath = "C:\OwnCloud\EverNote\"
    )
Write-Output -InputObject "Script started at $(Get-Date)"
If (-NOT ($EverNotePath).EndsWith("ENScript.exe"))
    {
        Write-Debug -Message "Provided EverNotePath does not end with ENScript.exe - checking if it is a folder"
        If (Test-Path -LiteralPath $EverNotePath -PathType Container)
            {
                Write-Debug -Message "Confirmed it's a folder"
                If (($EverNotePath).EndsWith("\"))
                    {
                        Write-Debug -Message "EverNotePath ends with \ - appending ENScript.exe"
                        $EverNotePath = ($EverNotePath) + "ENScript.exe"
                        Write-Debug -Message "`$EverNotePath value is now $($EverNotePath)"
                    } # END If $EverNotePath end with \
                Else
                    {
                        Write-Debug -Message "EverNotePath ends with \ - appending ENScript.exe"
                        $EverNotePath = ($EverNotePath) + "\ENScript.exe"
                        Write-Debug -Message "`$EverNotePath value is now $($EverNotePath)"
                    } # END Else $EverNotePath end with \
            } # END If Test-Path $EverNotePath Container
    } # END If NOT $EverNotePath endswith ENScript.exe
If (-NOT (Test-Path -LiteralPath $EverNotePath -PathType Leaf))
    {
        Write-Warning -Message "Path to EverNote is not valid, please provide the correct path via -EverNotePath - Aborting script."
        Break
    } # END If NOT Test-Path $EverNotePath
If (-NOT (Test-Path -LiteralPath $CloudStorageProvider -PathType Leaf))
    {
        Write-Warning -Message "Path to EverNote is not valid, please provide the correct path via -CloudStorageProvider - Aborting script."
        Break
    } # END If NOT Test-Path $CloudStorageProvider
If (-NOT (Test-Path -LiteralPath $BackupPath -PathType Container))
    {
        Write-Warning -Message "Path to backup-folder is not valid, please provide the correct path via -BackupPath - Aborting script."
        Break
    } # END If NOT Test-Path $BackupPath
[String]$RunTime = (Get-Date -Uformat "%Y-%m-%d_%H-%M")
[String]$LogFile = $BackupPath + "EverNote" + $RunTime + "_sync.log"
[String]$EverNoteBackup = $BackupPath + $RunTime + "_bkp_Evernote.enex"
[String]$EverNoteExport = $BackupPath + "EverNote_" + $RunTime + "_export.log"
[String]$Arguments = "exportNotes /q any:* /f $EverNoteBackup"
Try
    {
        Start-Process -FilePath "$EverNotePath" -ArgumentList 'syncdatabase' -RedirectStandardOutput "$LogFile" -WindowStyle Hidden -Wait
    } # END Try Start-Process $EverNotePath syncdatabase
Catch
    {
        Write-Warning -Message "Failed to start Evernote sync - please check if you have the necessary permissions - Aborting script."
        Write-Debug -Message "($Error) | Format-List -Force"
        Break
    } # END Catch Start-Process $EverNotePath syncdatabase
Try
    {
        Start-Process -FilePath "$EverNotePath" -ArgumentList "$Arguments" -RedirectStandardOutput "$EverNoteExport" -WindowStyle Hidden -Wait
    } # END Try Start-Process $EverNotePath $Arguments
Catch
    {
        Write-Warning -Message "Failed to export Evernote database - please check if you have the necessary permissions - Aborting script."
        Write-Debug -Message "($Error) | Format-List -Force"
        Break
    } # END Catch Start-Process $EverNotePath $Arguments
Try
    {
        Start-Process -FilePath "$CloudStorageProvider" -WindowStyle Minimized
    } # END Try Start-Process $CloudStorageProvider
Catch
    {
        Write-Warning -Message "Failed to start your CloudStorageProvider - please check if you have the necessary permissions - Aborting script."
        Write-Debug -Message "($Error) | Format-List -Force"
        Break
    } # END Catch Start-Process $CloudStorageProvider
Finally
    {
        Write-Output -InputObject "Script completed at $(Get-Date)"
    } # END Finally