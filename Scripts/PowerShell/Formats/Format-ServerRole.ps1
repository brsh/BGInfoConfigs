function Format-ServerRole {
    <#
    .SYNOPSIS
        Formats the output of Get-ServerRole.ps1

    .EXAMPLE
        Get-ServerRole | Format-ServerRole.ps1

        This script must be dot sourced (i.e., run '. .\Format-ServerRole')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Qualified,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [string] $Header = "Server Role:`t"
        [string[]] $out = @()
        [string] $tab = "`t`t"
        if ($BGInfo) { $tab = "`t"}
    }

    PROCESS {
        if ($Qualified) {
            $out += $Qualified
        }
    }

    END {
        if ($out.Count -gt 0) {
            $Header = $Header + $($out -join ", ")
            Write-Host $Header
            Write-Host ""
        }
     }
}