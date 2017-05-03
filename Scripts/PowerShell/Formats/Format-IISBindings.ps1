function Format-IISBindings {
    <#
    .SYNOPSIS
        Formats the output of Get-IISBindings.ps1

    .EXAMPLE
        Get-IISBindings | Format-IISBindings.ps1

        This script must be dot sourced (i.e., run '. .\Format-UserSessions')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Site,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Path,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string[]] $Bindings,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [int] $i = 0
        [string] $Header = "IIS Sites:`t"
        [string] $tab = "`t`t`t"
        if ($BGInfo) { $tab = "`t`t"}
    }

    PROCESS {
        if ($i -gt 0 ) { $header = $tab -replace '.$' }
        $i = 99
        Write-Host "${Header}$Site ($Path)"
        if ($Bindings.Count -gt 0) {
            $Binding = $Bindings -join ", "
            Write-Host "${tab}$Binding"
        }
    }

    END {
        Write-Host ""
     }

}