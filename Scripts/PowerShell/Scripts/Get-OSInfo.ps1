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
	$CPU = @(Get-CIMInstance -Class Win32_Processor)
	$OS = Get-CIMInstance -Class Win32_OperatingSystem
	$SYS = Get-CIMInstance -Class Win32_ComputerSystem
	$BIOS = Get-CIMInstance -Class Win32_Bios
	try {
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		$USER = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current
	} catch {
		Write-Verbose 'Could not pull User Account Information'
		Write-Verbose $_.Exception.Message
	}

	$out = New-Object psobject

	# Who are we?
	[string] $UserName = $SYS.UserName
	if ($UserName.Length -eq 0) { $UserName = "$env:USERDOMAIN\$env:USERNAME" }
	[string] $HostName = $SYS.Name
	[string] $HostDomain = ([string] $SYS.Domain).ToLower()
	[string] $HostDomainNBT = (net config workstation) -match 'Workstation domain\s+\S+$' -replace '.+?(\S+)$', '$1'
	[string] $Comment = $OS.Description
	[string] $LogonServer = $env:LOGONSERVER.ToString().Replace("\", "")

	Switch ($User.ContextType) {
		"Machine" { [string] $UserContext = "Local"; break }
		"Domain" { [string] $UserContext = "Domain"; break }
		"\\MicrosoftAccount" { [string] $UserContext = "Microsoft"; break }
		Default { [string] $UserContext = "Unknown"; break }
	}
	[datetime] $PwdLastSet = [datetime] "1/1/1971"
	if ($USER) { $PwdLastSet = $User.LastPasswordSet }

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

	# and the version?
	[string] $OSVersion = ($OS.Version).Trim()
	Add-Member -InputObject $out -MemberType NoteProperty -Name "Version" -Value $OSVersion

	if ($OSVersion -match '^10') {
		try {
			$ReleaseID = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' ReleaseID).ReleaseID
			if ($ReleaseID) { $OSCaption = "${OSCaption}, Rel. $ReleaseID"}
		} catch {
			Write-Verbose "Couldn't pull the ReleaseID from the registry"
			Write-Verbose $_.Exception.Message
		}
	}
	Add-Member -InputObject $out -MemberType NoteProperty -Name "Caption" -Value $OSCaption


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
	[datetime] $BootTime = $OS.LastBootUpTime
	[datetime] $CurrentTime = $OS.LocalDateTime
	[timespan] $Uptime = $CurrentTime - $boottime

	Add-Member -InputObject $out -MemberType NoteProperty -Name "InstallDate" -Value $os.InstallDate.ToString('MM/dd/yyyy HH:mm')
	Add-Member -InputObject $out -MemberType NoteProperty -Name "BootDate" -Value $BootTime.ToString('MM/dd/yyyy HH:mm')
	Add-Member -InputObject $out -MemberType NoteProperty -Name "Uptime" -Value $Uptime
	Add-Member -InputObject $out -MemberType NoteProperty -Name "SnapshotTime" -Value $CurrentTime.ToString('MM/dd/yyyy HH:mm')

	# our bit-level (32, 64, itanic...)
	[string] $CPUArch = $CPU[0].Architecture
	[string] $CPUWidth = $CPU[0].AddressWidth

	switch ($CPUArch) {
		"0" { $CPUArch = "x86"; break }
		"5" { $CPUArch = "ARM"; break }
		"6" { $CPUArch = "Itanium"; break }
		"9" { $CPUArch = "x64"; break }
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
	[double] $MemoryTotal = (Get-CimInstance -class Win32_PhysicalMemory |Measure-Object -Property capacity -Sum  | % {[Math]::Round(($_.sum / 1MB), 2)})

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

			if ($PSVersionTable.PSVersion.Major -ge 6) {
				#Yes, I could use this in PS v>6, but I don't trust it yet :)
				$highPart = $MPA.GetType().InvokeMember("HighPart", [System.Reflection.BindingFlags]::GetProperty, $null, $wkval, $null)
				$lowPart = $MPA.GetType().InvokeMember("LowPart", [System.Reflection.BindingFlags]::GetProperty, $null, $wkval, $null)

				$bytes = [System.BitConverter]::GetBytes($highPart)
				$tmp = [System.Byte[]]@(0, 0, 0, 0, 0, 0, 0, 0)
				[System.Array]::Copy($bytes, 0, $tmp, 4, 4)
				$highPart = [System.BitConverter]::ToInt64($tmp, 0)

				$bytes = [System.BitConverter]::GetBytes($lowPart)
				$lowPart = [System.BitConverter]::ToUInt32($bytes, 0)
				$lngMaxPwdAge = $highPart + $lowPart
			} else {
				# get Int64 (100-nanosecond intervals).
				$lngMaxPwdAge = $Domain.ConvertLargeIntegerToInt64($MPA)
			}
			# get days
			$MaxPwdAge = - $lngMaxPwdAge / (600000000 * 1440)
		} catch {
			Write-Verbose 'Could not calc MaxPwdAge'
			Write-Verbose $_.Exception.Message
		}
	}
	Add-Member -InputObject $out -MemberType NoteProperty -Name "MaxPwdAge" -Value $MaxPwdAge
	Add-Member -InputObject $out -MemberType NoteProperty -Name "PasswordLastSet" -Value $PwdLastSet

	[datetime] $PasswordExpires = "1/1/1971"
	if ($MaxPwdAge -gt -1) {
		$PasswordExpires = ($PwdLastSet).AddDays($MaxPwdAge)
	}
	Add-Member -InputObject $out -MemberType NoteProperty -Name "PasswordExpires" -Value $PasswordExpires

	$out
} catch {
	Write-Verbose 'Could not do something...'
	Write-Verbose $_.Exception.Message
}

