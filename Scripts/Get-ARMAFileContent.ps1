<#
.SYNOPSIS
    PowerShell script to retrieve all ARMA classes, their quality, and price from all ItemList files.
.DESCRIPTION
    This PowerShell script can retrieve all ARMA classes, their quality, and price from all ItemList files in the
    folder and all subfolders underneath (which can be specified) and outputs them into a single CSV-file.

    This was created in particular for EXILE - and the Australia MOD. In part this output should allow to create
    the TraderCategories*.hpp file(s); which hopefully can be automated as well. This would avoid any errors with
    undefined or double defined classes while loading the game.

    The correctness of the output-file is in no way guaranteed - so as always, create proper backups before
    changing anything.
.PARAMETER Location
    This parameter is to provide the location of the ARMA files.
.PARAMETER OutputFileName
    This parameter is to provide the name and location of the outputfile.
.EXAMPLE
    Get-ARMAFileContent.ps1 -Location 'C:\MODS\EXILE' -OutputFileName 'C:\MODS\Output.csv'

    This will check the folder (and sub-folders) of 'C:\MODS\EXILE' for all ItemList*.hpp files and output the
    resulting information into the CSV-formatted file in 'C:\MODS\Output.csv'.
.INPUTS
    System.String
        Location of the ARMA files.
    System.String
        Location and filename of the output file.
.OUTPUTS
    System.String
        Output file.
.NOTES
    REQUIRES:
        1. PowerShell 3.0 or higher.
        2. (Read)Access to folder containing the ARMA ItemList*.hpp files.
        3. (Read/Write)Access to folder/file for output file.

    VERSION HISTORY:
    0.3 - Please check Github for changes

    TODO:
    - Add SupportShouldProcess support.
    - Add improved error-catching/detection.
    - Investigate finding 'Category Class' information.
    - Cleanup the script.
#>
#Requires -version 3.0
[CmdletBinding(
    HelpUri = 'https://github.com/Aprazeth/majoraap'
)]
PARAM(
    [Parameter(
        Mandatory = $True,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        Position = 0,
        Helpmessage = 'Please provide the path to the location of the ARMA files.'
    )]
    [ValidateScript(
        {
            If (-NOT (Test-Path -Path $_ -Pathtype Container)) {
                Throw 'Provided path is not a valid folder.'
            }
            $True
        }
    )]
    [String]$Location,

    [Parameter(
        Mandatory = $True,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False,
        Position = 1,
        Helpmessage = 'Please provide the path and filename where to store the output.'
    )]
    [ValidateScript(
        {
            If (Test-Path -Path $_ -PathType Container) {
                Throw 'Provided OutputFileName is not a file, but a folder.'
            }
            $True
        }
    )]
    [String]$OutputFileName
)
Write-Output -InputObject 'Script started.'
If (Test-Path -Path $OutputFileName) {
    [String]$Overwrite = Read-Host -Prompt "File $($OutputFileName) already exists; do you wish to overwrite it? [Y/N]"
    If ($Overwrite -NE 'y') {
        Write-Warning -Message "OutputFile already exists; not overwriting file."
        Exit 1
    } # END If Overwrite NE y
} # END If Test-Path OutputFileName
[String[]]$ARMALocation = (Get-ChildItem -Path $Location -Recurse -Filter ItemList*.hpp).FullName
If ($NULL -EQ $ARMALocation) {
    Write-Warning -Message "No ARMA files found in '$($Location)'."
    Exit 1
} # End If NULL EQ ARMALocation
ForEach ($FileName in $ARMALocation) {
    [String[]]$ItemList = ((Get-Content -Path $FileName) | Select-String -Pattern 'class' | Select-String -Pattern '//' -NotMatch)
    If ('', $NULL -CONTAINS $ItemList) {
        Write-Warning -Message "Skipping $($FileName) because it contains no data."
        Break;
    } # END If ItemList contains null ''
    ForEach ($Item in $ItemList) {
        [String]$ItemName = ($Item.Trim())
        [String]$Class = ((($ItemName.Split(' ', '3')[1]).Replace('{', '')).Trim(''))
        # If it looks stupid but it works...
        If ('', $NULL -CONTAINS $Class) {
            Write-Warning -Message 'Skipping current item because it contains no data'
            Write-Verbose -Message "$($ItemName)"
            Break
        } # If Class contains null ''
        Try {
            # TODO: ADD Category Class
            $Data = [Ordered]@{
                'FileName'       = ($FileName) ;
                'Category Class' = 'Unknown' ;
                'Class'          = $Class ;
                'Quality'        = ((($ItemName.Split(' ', '3')[2]).Split(';', '3').Trim()[0]).Split('=', '2').Trim())[1] ;
                'Price'          = ((($ItemName.Split(' ', '3')[2]).Split(';', '3').Trim()[1]).Split('=', '2').Trim())[1]
            } # END Data
            New-Object -TypeName PSObject -Property $Data | Export-Csv -Path $OutputFileName -NoTypeInformation -Append
        } # END Try Data
        Catch {
            Write-Warning -Message "Skipping $($FileName) because it contains no data."
            Write-Verbose -Message "Item = $($Item)"
            Write-Verbose -Message "FileName = $($FileName)"
            Write-Verbose -Message "Category Class = unknown"
            Write-Verbose -Message "Class = $($Class)"
            # Next line is where it usually breaks - so ItemName contains incorrect data when reading comment lines that contains 'class'.
            Write-Verbose -Message "Quality = $((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[0]).Split('=', "2").Trim())[1] "
            Write-Verbose -Message "Price = $((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[1]).Split('=', "2").Trim())[1] "
        } # END Catch Data
    } # END ForEach Item in ItemList
} # END ForEach FileName in ARMALocation
Write-Output -InputObject "Script completed; output saved at $($OutputFileName)."