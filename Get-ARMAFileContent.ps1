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

    Version 0.1 - Created 22 February 2017
    - Initial version.

    TODO:
    - Add proper help information to parameters.
    - Add SupportShouldProcess support.
    - Add improved error-catching/detection.
    - Investigate finding 'Category Class' information.
    - Cleanup the script.
    - Rename some of the variables.
    - Upload to GitHub.
#>
#Requires -version 3.0
[CmdletBinding(
    HelpUri = 'https://github.com/Aprazeth/majoraap'
    )]
PARAM(
    [Parameter(Mandatory = $True,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True, 
        Position = 0,
        Helpmessage = 'Please provide the path to the location of the ARMA files.')]
    [ValidateScript({
        $True
        })]
    # ValidateScript for Test-Path goes here that the folder can be reached/found.
    [String]$Location,

    [Parameter(Mandatory = $True,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False, 
        Position = 1,
        Helpmessage = 'Please provide the path and filename where to store the output.')]
    [ValidateScript({
        $True
        })]
    # ValidateScript for Test-Path goes here to ensure it's not a folder/container.
    [String]$OutputFileName
    )
<#
function Verb-Noun
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("p1")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
    }
    End
    {
    }
}
#>
[String[]]$ARMALocation = (Get-ChildItem -Path $Location -Recurse -Filter ItemList*.hpp).FullName
ForEach ($FileName in $ARMALocation)
    {
        [String[]]$ItemList = ((Get-Content -Path $FileName) | Select-String -Pattern class)
        If ('',$NULL -contains $ItemList)
            {
                Write-Warning -Message "Yeah, skipping $($FileName)."
                Break;
            } # END If ItemList contains null ''
        ForEach($Item in $ItemList)
            {
                [String]$ItemName = ($Item.Trim())
                [String]$Class = ((($ItemName.Split(' ', "3")[1]).Replace('{','')).Trim(''))
                # If it looks stupid but it works...
                If ('',$NULL -CONTAINS $Class)
                    {
                        Write-Warning -Message 'Yeah, skipping this one because it has no data'
                        Write-Verbose -Message "$($ItemName)"
                        Break
                    } # If Class contains null ''
                Try
                    {
                        # TODO: ADD Category Class
                        $Data = [Ordered]@{
                            "FileName" = ($FileName) ;
                            "Category Class" = "Unknown" ;
                            "Class" = $Class ;
                            "Quality" = ((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[0]).Split('=', "2").Trim())[1] ;
                            "Price" = ((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[1]).Split('=', "2").Trim())[1]
                            } # END Data
                        New-Object -TypeName PSObject -Property $Data | Export-Csv -Path $OutputFileName -NoTypeInformation -Append
                    } # END Try Data 
                Catch
                    {
                        Write-Warning -Message "Yeah, skipping $($FileName) because of no data."
                        Write-Verbose -Message "Item = $($Item)"
                        Write-Verbose -Message "FileName = $($FileName)"
                        Write-Verbose -Message "Category Class = unknown"
                        Write-Verbose -Message "Class = $($Class)"
                        # Next line is where it usually break - so ItemName contains incorrect data when reading comment lines that contains 'class'.
                        Write-Verbose -Message "Quality = $((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[0]).Split('=', "2").Trim())[1] "
                        Write-Verbose -Message "Price = $((($ItemName.Split(' ', "3")[2]).Split(';', "3").Trim()[1]).Split('=', "2").Trim())[1] "
                    } # END Catch Data
            } # END ForEach Item in ItemList
    } # END ForEach FileName in ARMALocation