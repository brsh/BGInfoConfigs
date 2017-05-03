<#
.SYNOPSIS
    Pulls Network info from WMI

.DESCRIPTION
    Pulls Network info from WMI

.EXAMPLE
     Get-NetworkInfo.ps1

#>


[CmdletBinding()]
param ( )

#Try {
    $Adapter = Get-WmiObject -Class Win32_NetworkAdapter -filter "Netconnectionstatus=2 or NetconnectionStatus=7"
    $Adapter = $Adapter | Sort-Object -Property @{Expression={$_.NetEnabled}; Ascending = $false}, NetConnectionStatus,  NetConnectionID
    $Config = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = TRUE"

    $Adapter | ForEach-Object {
        $out = New-Object psobject

        [string] $NICMac = $_.MACAddress
        Add-Member -InputObject $out -MemberType NoteProperty -Name "MACAddress" -Value $NICMac

        [string] $NICNameRaw = $_.Name
        [string] $NICName = $NICNameRaw -replace ("\(R\)") -replace "\(C\)", "" -replace ",", "" -replace "\s+", " "

        Add-Member -InputObject $out -MemberType NoteProperty -Name "NICName" -Value $NICName

        [string] $NICManufacturer = $_.Manufacturer
        Add-Member -InputObject $out -MemberType NoteProperty -Name "Manufacturer" -Value $NICManufacturer

        $NICID = $_.NetConnectionID
        Add-Member -InputObject $out -MemberType NoteProperty -Name "ConnectionID" -Value $NICID

        $DeviceID = $_.DeviceID
        Add-Member -InputObject $out -MemberType NoteProperty -Name "DeviceID" -Value $DeviceID

        $NetConnectionStatuses = @{
            '0' = "Disconnected"
            '1' = "Connecting"
            '2' = "Connected"
            '3' = "Disconnecting"
            '4' = "Hardware Not Present"
            '5' = "Hardware Disabled"
            '6' = "Hardware Malfunction"
            '7' = "Disconnected"
            '8' = "Authenticating"
            '9' = "Authentication Succeeded"
            '10' = "Authentication Failed"
            '11' = "Invalid Address"
            '12' = "Credentials Required"
        }
        [string] $stat = [string] $_.NetConnectionStatus
        Add-Member -InputObject $out -MemberType NoteProperty -Name "NetConnectionStatus" -Value $NetConnectionStatuses.$($stat)

        [string] $NetEnabled = $_.NetEnabled
        if ($NetEnabled -eq 'True') { $NetEnabled = "Enabled" } else { $NetEnabled = "Disabled" }
        Add-Member -InputObject $out -MemberType NoteProperty -Name "NICEnabled" -Value $NetEnabled

        [string] $ServiceName = $_.ServiceName
        Add-Member -InputObject $out -MemberType NoteProperty -Name "ServiceName" -Value $ServiceName

        [long] $NICSpeed = ($_.Speed /1000) / 1000
        if ($stat -eq '7') { $NICSpeed = 0 }
        Add-Member -InputObject $out -MemberType NoteProperty -Name "NICSpeedmbits" -Value ([long] $NICSpeed)
        Add-Member -InputObject $out -MemberType NoteProperty -Name "NICSpeedmbytes" -Value ([long] ($NICSpeed / 8))

        $Config | Where-Object { ($_.Description -eq $NICNameRaw) -and ($_.MACAddress -eq $NICMac) } | ForEach-Object {
            if ($_.IPAddress) {
                [string[]] $IPAddress = $_.IPAddress
                Add-Member -InputObject $out -MemberType NoteProperty -Name "IPAddress" -Value $IPAddress
                [string[]] $IPSubnet = $_.IPSubnet
                Add-Member -InputObject $out -MemberType NoteProperty -Name "SubnetMask" -Value $IPSubnet
                [string[]] $DefaultGateway = $_.DefaultIPGateway
                Add-Member -InputObject $out -MemberType NoteProperty -Name "Gateway" -Value $DefaultGateway
                [datetime] $DHCPExpires = "1/1/01"
                if ($_.DHCPLeaseExpires) {
                    [datetime] $DHCPExpires = $_.ConvertToDateTime($_.DHCPLeaseExpires)
                }
                [bool] $DHCPEnabled = $_.DHCPEnabled
                [string] $DHCPServer = $_.DHCPServer
                [string[]] $DNSSearchOrder = $_.DNSServerSearchOrder

                Add-Member -InputObject $out -MemberType NoteProperty -Name "DHCPEnabled" -Value $DHCPEnabled
                Add-Member -InputObject $out -MemberType NoteProperty -Name "DHCPServer" -Value $DHCPServer
                Add-Member -InputObject $out -MemberType NoteProperty -Name "DHCPExpires" -Value $DHCPExpires
                Add-Member -InputObject $out -MemberType NoteProperty -Name "DNSServerSearchOrder" -Value $DNSSearchOrder
            }
        }

        $out
    }



#}
#catch { }

