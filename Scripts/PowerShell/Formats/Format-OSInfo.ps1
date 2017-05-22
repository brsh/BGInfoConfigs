function Format-OSInfo {
    <#
    .SYNOPSIS
        Formats the output of Get-OSInfo.ps1

    .EXAMPLE
        Get-OSInfo | Format-OSInfo.ps1

        This script must be dot sourced (i.e., run '. .\Format-OSInfo')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $UserName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $HostName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $HostDomain,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $HostDomainNetBIOS,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Comment,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $LogonServer,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $UserContext,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Caption,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Version,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $ServicePack,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [datetime] $InstallDate,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [datetime] $BootDate,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [timespan] $Uptime,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [datetime] $SnapshotTime,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $OSBitness,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $CPUBitness,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $CPUName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $MaxSpeed,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Manufacturer,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Model,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $System,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [long] $MemoryMB,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $SerialNumber,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int16] $Processors,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int16] $LogicalProcessors,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int16] $Sockets,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [datetime] $PasswordLastSet,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int16] $MaxPwdAge,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [datetime] $PasswordExpires,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [int] $i = 0
        [string] $tab = "`t"
        if ($BGInfo) { $tab = "`t"}
    }

    PROCESS {
        Write-Host "Host Name:${tab}" -NoNewline
        Write-Host "${HostName}"
        Write-Host "System Domain:${tab}" -NoNewline
        if ($HostDomain.ToUpper() -eq $HostDomainNetBIOS.ToUpper()) {
            Write-Host "${HostDomainNetBIOS}"
        }
        else { Write-Host "${HostDomain} (${HostDomainNetBIOS})" }

        if ($Comment) {
            Write-Host "Comment:${tab}" -NoNewline
            Write-Host "${Comment}"
        }
        Write-Host "UserName:${tab}" -NoNewline
        Write-Host "${UserName}   " -NoNewline
        if ($UserContext -ne 'Unknown') { Write-Host "(${UserContext} User)" } else { Write-Host "" }
        if ($UserContext -eq "Domain") {
            Write-Host "Logon Server:${tab}" -NoNewline
            Write-Host "${LogonServer}"
        }
        if ($PasswordLastSet -ne ([datetime] '1/1/1971')) {
            Write-Host "Password Set:${tab}" -NoNewline
            if ($MaxPwdAge -gt -1) {
                [timespan] $InDays = $PasswordExpires - $(get-date)
                Write-Host "$(${PasswordLastSet}.ToShortDateString())  (expires in $(${InDays}.Days) days)"
            } else { Write-Host "$(${PasswordLastSet}.ToShortDateString())" }
        }

		Write-Host ""

        Write-Host "OS Info:${tab}" -NoNewline
        if ($ServicePack -eq "No Service Pack") {
            Write-Host "${Caption}, ${OSBitness}, v.${Version}"
        }
        else { Write-Host "${Caption}, ${OSBitness}, SP${ServicePack}, v.${Version}"}
        #Call Get-ServerRoles.ps1

        Write-Host "Install Date:${Tab}" -NoNewline
        Write-Host "${InstallDate}"
        [string] $UptimeString = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
        Write-Host "Boot Date:${Tab}" -NoNewline
        Write-Host "${BootDate}   (up for ${UptimeString})"
        Write-Host "Report Run:${tab}" -NoNewline
        Write-Host "${SnapshotTime}"

		Write-Host ""

        if ($System -notmatch "VMware") {
            Write-Host "Hardware:${Tab}" -NoNewline
            Write-Host "${Manufacturer} " -NoNewline
            if ($System) { Write-Host "${System} " -NoNewline }
            if ($Model) { Write-Host "${Model}  " -NoNewline }
            if ($SerialNumber) {Write-Host "S/N: ${SerialNumber}" -NoNewline}
            Write-Host ""
        }
        Write-Host "CPU Type:${tab}" -NoNewline
        Write-Host "${CPUName} " -NoNewline
        if ($MaxSpeed) { Write-Host "(max ${MaxSpeed}ghz) " -NoNewline }
        if ($System -notmatch "VMware") { Write-Host "in ${Sockets} sockets" -NoNewline }
        Write-Host ""
        Write-Host "CPU Count:${tab}" -NoNewline
        Write-Host "${Processors} physical / ${LogicalProcessors} (total) logical cores"
        Write-Host "Memory:  ${Tab}" -NoNewline
        Write-Host ("{0:N3} GB" -f ($MemoryMB / 1000))
    }

    END {
                Write-Host ""
    }

}