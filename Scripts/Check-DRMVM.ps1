<#
.SYNOPSIS
    Checks your machine for known issues with certain software
.DESCRIPTION
    Checks your machine for known issues with certain software.

    At the end it will also output support information such as the model of your CPU, RAM, GPU, motherboard etc.
.EXAMPLE
    .\Check-DRMVM.ps1

    -----
    This will run the script and check your system for any known/conflicting issues.
.INPUTS
    None
.OUTPUTS
    System.String (displayed in console) if any
.LINK
    https://github.com/Aprazeth/majoraap
.NOTES
    VERSION
    0.1 - Original release created by Aprazeth
    0.2 - 27 July 2019 - Aprazeth
    - Added detection for CPU specific features
    - Added links if warnings get triggered (some)
    - Added detections for Windows 10 Sandbox, Windows Subsystem for Linux
    0.3 - 27 July 2019 - Aprazeth
    - Added detection for Oracle VM VirtualBox
    - Fixed a grammatical error in message for HyperVisorPresent
    0.4 - 27 July 2019 - Aprazeth
    - Added detection for manufacturer being set to Microsoft Corporation
    0.5 - 27 July 2019 - Aprazeth
    - Fixed a bug with detecting the Manufacturer registry-key if there was OEM-information set, but not manufacturer
    0.6 - 27 July 2019 - Aprazeth
    - Added some system information output (CPU, RAM, GPU, resolution)
    0.7 - 27 July 2019 - Aprazeth
    - Added several other Windows Optional Features as potential cause (after checking a list of those)
    - Changed variable OriginalList to only record the FeatureName
    - Added check for Core Isolation Memory Integrity in Windows Defender
    0.7.1 - 28 July 2019 - Aprazeth
    - Commented out line that created the log-file for installed Windows Features
    - Added motherboard manufacturer and model to support information
    - Added example to script
    - Added CmdletBinding and PARAM block (script now supports -Debug and -Verbose)
    - Expanded description a bit
    - Changed capitalization to be consistent throughout script
    0.7.2 - 28 July 2019 - Aprazeth
    - Modified the Warning message for the ComputerName containing DESKTOP to clarify it is currently an unconfirmed cause.
    - Modified the WMI Class used to retrieve motherboard information (should give better/more accurate results)
    0.7.3 28 July 2019 - Aprazeth
    - Added to personal GitHub repository https://github.com/Aprazeth/majoraap (also in link)
    - Changed capitalization of username throughout notes for consistency
    0.7.4 28 July 2019 - Aprazeth
    - Changed Write-Host to Write-Output for increased compatibility (best practices)
    - Removed commented out line to export installed Windows Optional Features to a file
#>
#requires -version 5.0
#requires -RunAsAdministrator
[CmdletBinding()]
PARAM()
$OriginalList = Get-WindowsOptionalFeature -Online | Where-Object {$_.State -NE 'Disabled'} | Select-Object -ExpandProperty FeatureName
$HyperV = $OriginalList | Where-Object {$_.FeatureName -LIKE "*Hyper-V*"}
If ($NULL -NE $HyperV) {
    Write-Warning -Message "Hyper-V has been installed on your machine ! `r`nVisit 'https://answers.microsoft.com/en-us/windows/forum/windows_8-windows_install/how-do-i-uninstall-hyper-v/7d268911-47cd-4c52-bfe5-ea41e58067ab' to see how to remove the feature (or Google it)."
} # END If NULL NE HyperV
$WDAG = $OriginalList | Where-Object {$_.FeatureName -EQ 'Windows-Defender-ApplicationGuard'}
If ($NULL -NE $WDAG) {
    Write-Warning -Message "Windows Defender Application Guard has been installed on your machine !"
} # END If NULL NE WDAG
$WSL = $OriginalList | Where-Object { $_.FeatureName -EQ "Microsoft-Windows-Subsystem-Linux" }
If ($NULL -NE $WSL) {
    Write-Warning -Message "Windows Subsystem for Linux has been installed on your machine !"
} # END If NULL NE WSL
$SandBox = $OriginalList | Where-Object { $_.FeatureName -EQ "Containers-DisposableClientVM" }
If ($NULL -NE $SandBox) {
    Write-Warning -Message "Windows 10 sandbox has been installed on your machine !"
} # END If NULL NE SandBox
Try {
    $CoreIsolationMemoryIntegrity = Get-ItemProperty -Path HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\ -Name HypervisorEnforcedCodeIntegrity -ErrorAction Stop
    If ($NULL -EQ $CoreIsolationMemoryIntegrity) {
        Write-Warning -Message "Core Isolation - Memory Integrity is enabled !`r`nSee https://www.tenforums.com/tutorials/104025-turn-off-core-isolation-memory-integrity-windows-10-a.html on how to turn it off (or Google it)."
    } # END If NULL EQ CoreIsolationMemoryIntegrity
} # END Try Get-ItemProperty HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\ HypervisorEnforcedCodeIntegrity
Catch {
    $Error.Remove($Error[0])
} # END Catch  Get-ItemProperty HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\ HypervisorEnforcedCodeIntegrity
$UnconfirmedList =
    'HypervisorPlatform',
    'HostGuardian',
    'VirtualMachinePlatform'
ForEach ($UnconfirmedListItem in $UnconfirmedList) {
    If ($UnconfirmedListItem -IN $OriginalList) {
        Write-Output -InputObject "Detected $UnconfirmedListItem - this is a currently unconfirmed but suspected cause !"
    } # END If UnconfirmedListItem in OriginalList
} # END ForEach UnconfirmedListItem in UnconfirmedList
$VirtualBox = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -LIKE "VirtualBox" }
If ($NULL -NE $VirtualBox) {
    Write-Warning -Message "Oracle VM VirtualBox is installed on your machine !"
} # END If NULL NE VirtualBox
If ($env:COMPUTERNAME -LIKE "*desktop*") {
    Write-Warning -Message "Detected that the computer-name contains 'DESKTOP' !`r`nAlthough this not yet conclusively confirmed as cause, you can visit 'https://answers.microsoft.com/en-us/windows/forum/all/how-can-i-change-computer-name/be902cac-db1e-4b9d-8bc0-15a719e5950d' to see how to rename your computer (or Google it)."
} # END If EnvComputerName like desktop
# Source: https://devblogs.microsoft.com/scripting/use-powershell-to-detect-if-hypervisor-is-present/
[Bool]$HyperVisorPresent = (Get-CimInstance -ClassName Win32_ComputerSystem).HypervisorPresent
If ($HyperVisorPresent -EQ $TRUE) {
    Write-Warning -Message "Detected an active hypervisor on your machine !"
} # END IF HyperVisorPresent EQ TRUE
$CPUDetails = Get-CimInstance -ClassName Win32_Processor
If ($CPUDetails.VirtualizationFirmwareEnabled -EQ $TRUE) {
    Write-Warning -Message "Virtualization support enabled in BIOS/UEFI on your machine !"
} # END If CPUDetails.VirtualizationFirmwareEnabled EQ TRUE
If ($CPUDetails.VMMonitorModeExtensions -EQ $True) {
    Write-Warning -Message "VM monitor extensions are enabled on your machine !"
} # END IF CPUDetails.VMMonitorModeExtensions EQ TRUE
$OEMInformation = Get-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation\
If ($NULL -NE $OEMInformation) {
    Try {
        $Manufacturer = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation\ -Name Manufacturer -ErrorAction Stop
        If ($Manufacturer -LIKE "*Microsoft Corporation*") {
            Write-Warning -Message "Computer manufacturer set to 'Microsoft Corporation'.`r`nVisit https://www.thewindowsclub.com/add-change-oem-information-windows to see how to change it."
        } # END IF Manufacturer like Microsoft Corporation
    } # END Try
    Catch {
        $Error.Remove($Error[0])
    } # END Catch
} # END If NULL NE OEMInformation
# Support information
# Reference: https://blogs.technet.microsoft.com/askpfeplat/2017/07/19/viewing-memory-in-powershell/
$Vid = Get-CimInstance -ClassName Win32_VideoController
Write-Output -InputObject -Object "`r`nSupport information:
`tCPU : $((Get-CimInstance -ClassName Win32_Processor).Name)
`tRAM : $([INT]((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory) / 1GB)) GB
`tMotherboard Manufacturer: $((Get-CimInstance -ClassName Win32_BaseBoard).Manufacturer)
`tMotherboard Model : $((Get-CimInstance -ClassName Win32_BaseBoard).Product)
`tGPU : $($Vid | Select-Object -ExpandProperty Name)
`tResolution : $($Vid | Select-Object -ExpandProperty CurrentHorizontalResolution) by $($Vid | Select-Object -ExpandProperty CurrentVerticalResolution) at $($Vid | Select-Object -ExpandProperty CurrentBitsPerPixel)
`tRefreshRate: $($Vid | Select-Object -ExpandProperty CurrentRefreshRate) bits
`tDriver-version : $($Vid | Select-Object -ExpandProperty DriverVersion) dated $($Vid | Select-Object -ExpandProperty  DriverDate)"