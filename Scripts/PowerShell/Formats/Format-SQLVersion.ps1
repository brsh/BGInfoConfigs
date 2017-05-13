function Format-SQLVersion {
    <#
    .SYNOPSIS
        Formats the output of Get-SQLVersion.ps1

    .EXAMPLE
        Get-SQLVersion | Format-SQLVersion.ps1

        This script must be dot sourced (i.e., run '. .\Format-SQLVersion')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $InstanceName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Version,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string[]] $OwningNode,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [int] $i = 0
        [string] $Header = "SQL Instances:`t"
        [string] $tab = "`t`t`t"
        if ($BGInfo) { $tab = "`t`t"}
    }

    PROCESS {
        if ($i -gt 0 ) { $header = $tab -replace '.$' }
        $i = 99
        Write-Host "${Header}$InstanceName"
        if ($Version) { Write-Host "${tab}$Version" }
        if ($OwningNode -ne 'Not a Cluster Resource') {
            Write-Host "${tab}$OwningNode"
        }
    }

    END {
        Write-Host ""
    }

}