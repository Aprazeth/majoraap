<#
.SYNOPSIS
	This PowerShell Script can be scheduled (or run manually) to sync your
    EverNote local database, and then export a backup locally. Lastly, it then
    starts your Cloud storage software to store those files in the cloud

.DESCRIPTION
    Created by: Mochtar van de Griendt
    Version: 0.1
    Date: 17 May 2015

	The script was created based of a CMD file I wrote some time ago, that
    would allow me to have a local EverNote backup. After searching the
    internet I did find some example scripts but none that did what I wanted.

    So I went about and created the first version, as a CMD-file. As I recently
    got started in using PowerShell I figured it would be a great candidate
    to get converted into a PowerShell script.

    The script sets several variables, that you can alter, such as the install-
    path of EverNote, the cloud software you want to use, as well as the format
    of the file names of the logfiles and export files.

    Please note that currently it doesn't have any error handling (maybe later?)

.PARAMETER  $evernotepath
	This variable needs to be set to where your EverNote installation is. By
    default it will be in C:\Program Files (x86)\Evernote\Evernote\ so you 
    most likely won't need to change this. Observe that the ENscript.exe 
    must be at the end!

.PARAMETER  $cloudstorageprovider
    This variable needs to be configured to whereever your cloud storage
    provider software is installed. Whether this is DropBox, Box, OneDrive
    OwnCloud, SpiderOak, etc. - be sure to include the executable's name of 
    the software!

.PARAMETER  $backuppath
    This variable needs to be configured to where you want your files to be
    stored. It is absolutely VITAL that you use a folder that you have defined
    in your cloud storage software to be backed up!

.PARAMETER  $runtime
    This variable gets the date and time when the script is run, which is then
    used to append to the file-names. That makes it easy to see which files were
    created when.

    Since the variable is used in file-names the usual restrictions apply in terms
    of formatting. If you wish to change the formatting to for example month-day-
    year the variable would need to be altered to:

        $runtime = (Get-Date -Uformat "%m-%d-%Y_%H-%M")

    For more formatting options, please run help Get-Date in a PowerShell window.

.PARAMETER  $logfile
    This variable takes the output from the ENScript.exe and stores it into a 
    logfile. The variable is built using $runtime.


.PARAMETER  $evernotebackup
    This variable is used as the location and name of the exported EverNote
    database. As it is a folder-path and file-name, the usual restrictions apply
    in terms of naming conventions for file-systems.
    
.PARAMETER  $evernoteexport
    This variable is used as the location and name of the location of the 
    ENScript export log-file. As it is a folder-path and file-name, the usual 
    restrictions apply in terms of naming conventions for file-systems.

    Note; it is normal for the file to be 0 bytes.
    
.PARAMETER  $arguments
    This variable is used to parse the command-line options to ENScript, which
    tell it to export the local database to the location as specified in the
    variable $evernotebackup.


.EXAMPLE
	This script can be used with the Task scheduler in Windows, to run as a 
    scheduled task OR you can run it manually whenever you want or need it.

    The commandline you will need to enter for the Script to run as a scheduled
    task is:

        PowerShell -file "location and name of this script"

    So an example would be:

        PowerShell -file "C:\OwnCloud\EverNote\EverNoteBackup.ps1"
#>


$evernotepath = "C:\Program Files (x86)\Evernote\Evernote\ENScript.exe"
$cloudstorageprovider = "c:\Program Files (x86)\ownCloud\owncloud.exe"
$backuppath = "C:\OwnCloud\EverNote\"

$runtime = (Get-Date -Uformat "%Y-%m-%d_%H-%M")

$logfile = $backuppath + "EverNote" + $runtime + "_sync.log"
$evernotebackup = $backuppath + $runtime + "_bkp_Evernote.enex"
$evernoteexport = $backuppath + "EverNote_" + $runtime + "_export.log"
$arguments = "exportNotes /q any:* /f $evernotebackup"

Start-Process -FilePath "$evernotepath" -ArgumentList 'syncdatabase' -RedirectStandardOutput "$logfile" -WindowStyle Hidden

Start-Process -FilePath "$evernotepath" -ArgumentList "$arguments" -RedirectStandardOutput "$evernoteexport" -WindowStyle Hidden

Start-Process -FilePath "$cloudstorageprovider" -WindowStyle Minimized