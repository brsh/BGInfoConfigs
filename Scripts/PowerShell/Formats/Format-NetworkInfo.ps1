function Format-NetworkInfo {
    <#
    .SYNOPSIS
        Formats the output of Get-NetworkInfo.ps1

    .EXAMPLE
        Get-OSInfo | Format-NetworkInfo.ps1

        This script must be dot sourced (i.e., run '. .\Format-NetworkInfo')
    #>


    [CmdletBinding()]
        param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [psobject[]] $NICs,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [string] $tab = "`t`t"
        if ($BGInfo) { $tab = "`t"}
        [string] $indent = "${Tab}`t"
        $Header = "Network:`t"

        function PadIP {
            param ([string] $IP)
            if ($IP -match '.') {
                [string[]] $build = @()
                [string[]] $Octs = $IP -split "\."
                ForEach ($oct in $Octs) {
                    $build += $oct.PadLeft(3)
                }
                $retval = $build -join "."
            } else { $retval = $IP.PadLeft(3) }
            $retval
        }
    }

    PROCESS {
        foreach ($NIC in $NICs) {
            Write-Host $Header -NoNewline
            $Header = $Tab
            Write-Host $NIC.ConnectionID -NoNewline
            if ($NIC.NICName) { Write-Host "  [$($NIC.NICName)]" -NoNewline }
            Write-Host ""
            Write-Host $Tab -NoNewline

            if ($NIC.MACAddress) { Write-Host "$($NIC.MACAddress) | " -NoNewline }
            Write-Host "$($NIC.NICEnabled) | " -NoNewline
            Write-Host "$($NIC.NetConnectionStatus)" -NoNewline
            If (($NIC.NetConnectionStatus -eq "Connected") -and ($NIC.NICSpeedMBits -gt 0)) {
                Write-Host " | $($NIC.NICSpeedMBits / 1000)gbps / $($NIC.NICSpeedMBytes / 1000)GBps" -NoNewline
            }
            Write-Host ""

            If ($NIC.IPAddress) {
                Write-Host $Indent -NoNewline
                Write-Host "IP Address:`t" -NoNewline
                For ([int] $i = 0; $i -lt ($NIC.IPAddress).Count; $i++) {
                    # This regex is for IPv4 addresses only
                    if ($NIC.IPAddress[$i] -match '^(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)$') {
                        if ($i -gt 0) { Write-Host "${Indent}`t`t" -NoNewline }
                        Write-Host $([string] ($NIC.IPAddress[$i]).PadRight(16)) -NoNewline
                        if ($NIC.SubnetMask[$i]) { Write-Host  " / $($NIC.SubnetMask[$i])" } else { Write-Host "" }
                    }
                }
                if ($NIC.DHCPEnabled) {
                    Write-Host $Indent -NoNewline
                    Write-Host "DHCP Server:`t" -NoNewline
                    Write-Host $NIC.DHCPServer -NoNewline
                    if ($NIC.DHCPExpires) { Write-Host " (Expires: $($NIC.DHCPExpires))" } else { Write-Host "" }
                }
                if ($NIC.Gateway) {
                    Write-Host $Indent -NoNewline
                    Write-Host "Gateway:`t" -NoNewline
                    # [string[]] $GWs = @()
                    # foreach ($gw in $NIC.Gateway) {
                    #     $GWs += PadIP $gw
                    # }
                    Write-Host $($NIC.Gateway -join ", ")
                }
                if ($NIC.DNSServerSearchOrder) {
                    Write-Host $Indent -NoNewline
                    Write-Host "DNS Servers:`t" -NoNewline
                    # [string[]] $DNSs = @()
                    # foreach ($dns in $NIC.DNSServerSearchOrder) {
                    #     $DNSs += PadIP $dns
                    # }
                    Write-Host $($NIC.DNSServerSearchOrder -join ", ")
                }
                #Write-Host ""
            }

            Write-Host ""
        }
    }

    END { }

}