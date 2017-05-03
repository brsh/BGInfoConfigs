<#
.SYNOPSIS
    Pulls Operating System info from all over the place

.DESCRIPTION
    Pulls Operating System info from all over the place

.EXAMPLE
     Get-OSInfo.ps1

#>


[CmdletBinding()]
param ( )

Try {
    $CPU = @(Get-WmiObject -Class Win32_Processor)
    $OS = Get-WmiObject -Class Win32_OperatingSystem
    $SYS = Get-WmiObject -Class Win32_ComputerSystem
    $BIOS = Get-WmiObject -Class Win32_Bios
    try {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $USER = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current
    } catch { }

    $out = New-Object psobject

    # Who are we?
    [string] $UserName = $SYS.UserName
    if ($UserName.Length -eq 0) { $UserName = "$env:USERDOMAIN\$env:USERNAME" }
    [string] $HostName= $SYS.Name
    [string] $HostDomain = ([string] $SYS.Domain).ToLower()
    [string] $HostDomainNBT = (net config workstation) -match 'Workstation domain\s+\S+$' -replace '.+?(\S+)$','$1'
    [string] $Comment = $OS.Description
    [string] $LogonServer = $env:LOGONSERVER.ToString().Replace("\", "")

    if ($USER) {
        Switch ($User.ContextType) {
            "Machine"               { [string] $UserContext = "Local"; break }
            "Domain"                { [string] $UserContext = "Domain"; break }
            "\\MicrosoftAccount"    { [string] $UserContext = "Microsoft"; break }
            Default                 { [string] $UserContext = "Unknown"; break }
        }
        $PwdLastSet = $User.LastPasswordSet
    }

    Add-Member -InputObject $out -MemberType NoteProperty -Name "UserName" -Value $UserName
    Add-Member -InputObject $out -MemberType NoteProperty -Name "HostName" -Value $HostName
    Add-Member -InputObject $out -MemberType NoteProperty -Name "HostDomain" -Value $HostDomain
    Add-Member -InputObject $out -MemberType NoteProperty -Name "HostDomainNetBIOS" -Value $HostDomainNBT
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Comment" -Value $Comment
    Add-Member -InputObject $out -MemberType NoteProperty -Name "LogonServer" -Value $LogonServer
    Add-Member -InputObject $out -MemberType NoteProperty -Name "UserContext" -Value $UserContext

    # What is our OS?
    [string] $OSCaption = $OS.Caption -replace "Microsoft[ ]", ""
    $OSCaption = $OSCaption -replace "\(R\)", ""
    $OSCaption = $OSCaption -replace "\(C\)", ""
    $OSCaption = $OSCaption -replace ",", ""
    if ($OSCaption -match "Server") { $OSCaption = $OSCaption -replace "Windows[ ]", ""}
    $OSCaption = $OSCaption.Trim()
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Caption" -Value $OSCaption

    # and the version?
    [string] $OSVersion = ($OS.Version).Trim()
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Version" -Value $OSVersion

    # Service Pack ??
    [string] $OSSP = ""
    if ($OS.ServicePackMajorVersion -gt 0) {
        $OSSP = $OS.ServicePackMajorVersion
        if ($OS.ServicePackMinorVersion -gt 0) {
            $OSSP += "."
            $OSSP += $OS.ServicePackMinorVersion
        }
    } else {
        $OSSP = "No Service Pack"
    }
    Add-Member -InputObject $out -MemberType NoteProperty -Name "ServicePack" -Value $OSSP

    # and misc dates
    [datetime] $BootTime = $OS.ConvertToDateTime($OS.LastBootUpTime) 
    [datetime] $CurrentTime = $OS.ConvertToDateTime($OS.LocalDateTime)
    [timespan] $Uptime = $CurrentTime - $boottime

    Add-Member -InputObject $out -MemberType NoteProperty -Name "InstallDate" -Value ([System.Management.ManagementDateTimeConverter]::ToDateTime($OS.InstallDate))
    Add-Member -InputObject $out -MemberType NoteProperty -Name "BootDate" -Value $BootTime
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Uptime" -Value $Uptime
    Add-Member -InputObject $out -MemberType NoteProperty -Name "SnapshotTime" -Value $CurrentTime

    # our bit-level (32, 64, itanic...)
    [string] $CPUArch = $CPU[0].Architecture
    [string] $CPUWidth = $CPU[0].AddressWidth

    switch ($CPUArch) {
        "0"     { $CPUArch = "x86"; break }
        "5"     { $CPUArch = "ARM"; break }
        "6"     { $CPUArch = "Itanium"; break }
        "9"     { $CPUArch = "x64"; break }
        Default { $CPUArch = "Unknown"; break }
    }

    Add-Member -InputObject $out -MemberType NoteProperty -Name "OSBitness" -Value $CPUArch
    Add-Member -InputObject $out -MemberType NoteProperty -Name "CPUBitness" -Value $CPUWidth

    # Processor Name
    [string] $CPUName = $CPU[0].Name
    $CPUName = $CPUName -replace "\(R\)"
    $CPUName = $CPUName -replace "\(C\)"
    $CPUName = $CPUName -replace "\(TM\)"
    $CPUName = $CPUName -replace "Intel"
    $CPUName = $CPUName -replace "CPU"
    $CPUName = ($CPUName -split "@")[0]

    $CPUName = $CPUName -replace "\s+", " "
    $CPUName = $CPUName.Trim()

    Add-Member -InputObject $out -MemberType NoteProperty -Name "CPUName" -Value $CPUName

    [double] $MaxSpeed = [math]::Round($CPU[0].MaxClockSpeed / 1000, 2)
    Add-Member -InputObject $out -MemberType NoteProperty -Name "MaxSpeed" -Value $MaxSpeed

    [string] $Manufacturer = $SYS.Manufacturer
    [string] $Model = $SYS.Model
    [string] $Serial = $BIOS.SerialNumber -replace "VMWare[-| ]", ""
    [string] $SystemFamily = $SYS.SystemFamily
    if ($SystemFamily.Trim() -eq "") {
        if ($Model -match "VMware") { $SystemFamily = "VMware VM"}
    }
    [double] $MemoryTotal = (Get-WMIObject -class Win32_PhysicalMemory |Measure-Object -Property capacity -Sum  | % {[Math]::Round(($_.sum / 1MB),2)})

    Add-Member -InputObject $out -MemberType NoteProperty -Name "Manufacturer" -Value $Manufacturer
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Model" -Value $Model
    Add-Member -InputObject $out -MemberType NoteProperty -Name "System" -Value $SystemFamily
    Add-Member -InputObject $out -MemberType NoteProperty -Name "MemoryMB" -Value $MemoryTotal
    Add-Member -InputObject $out -MemberType NoteProperty -Name "SerialNumber" -Value $Serial

    [int] $NumOfPhysicalProcs = $SYS.NumberOfProcessors
    [int] $NumOfLogicalProcs = $SYS.NumberOfLogicalProcessors
    [int] $NumOfCores = $CPU.Count

    Add-Member -InputObject $out -MemberType NoteProperty -Name "Processors" -Value $NumOfPhysicalProcs
    Add-Member -InputObject $out -MemberType NoteProperty -Name "LogicalProcessors" -Value $NumOfLogicalProcs
    Add-Member -InputObject $out -MemberType NoteProperty -Name "Sockets" -Value $NumOfCores

    [int] $MaxPwdAge = -1
    if ($UserContext -eq "Domain") {
        try {
            # get domain password policy (max pw age)
            $D = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            $Domain = [ADSI]"LDAP://$D"
            $MPA = $Domain.maxPwdAge.Value

            # get Int64 (100-nanosecond intervals).
            $lngMaxPwdAge = $Domain.ConvertLargeIntegerToInt64($MPA)

            # get days
            $MaxPwdAge = -$lngMaxPwdAge/(600000000 * 1440)
        }
        catch { }
    }
    Add-Member -InputObject $out -MemberType NoteProperty -Name "MaxPwdAge" -Value $MaxPwdAge
    Add-Member -InputObject $out -MemberType NoteProperty -Name "PasswordLastSet" -Value $PwdLastSet

    [datetime] $PasswordExpires = "1/1/1971"
    if ($MaxPwdAge -gt -1) {
        $PasswordExpires = ($PwdLastSet).AddDays($MaxPwdAge)
    }
    Add-Member -InputObject $out -MemberType NoteProperty -Name "PasswordExpires" -Value $PasswordExpires


    $out
}
catch { }

