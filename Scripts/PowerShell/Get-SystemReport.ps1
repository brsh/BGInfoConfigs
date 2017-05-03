<#
.SYNOPSIS
    Wrap several PowerShell scripts into output for BGInfo

.DESCRIPTION
    BGInfo only handles vbs (and not wsh!), so trying to run PowerShell scripts via BGInfo results in numerous command windows

.EXAMPLE
     Get-BGInfo.ps1 -Parameter

#>


[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [switch] $BGInfo = $false
)

BEGIN {
    [string] $DirCurrent = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
    $DirFormats = "$DirCurrent\Formats"
    $DirGets = "$DirCurrent\Scripts"
    # We need to load the format functions into memory to use them later
    Get-ChildItem $DirFormats -filter "Format-*.ps1" | ForEach-Object {
        if (-not $_.PSIsContainer) {
            . $_.FullName
            Write-Verbose "Loading: $_"
        }
    }

    ## Make sure these scripts appear in this order (the rest don't matter)
    $First = "Get-OSInfo.ps1"
    $Second = "Get-DriveInfo.ps1"
    $Third = "Get-NetworkInfo.ps1"
    $Fourth = "Get-ServerRole.ps1"

    [System.IO.FileInfo[]] $GetScripts = @()
    $GetScripts += Get-ChildItem "$DirGets\*" -Include $First
    $GetScripts += Get-ChildItem "$DirGets\*" -Include $Second
    $GetScripts += Get-ChildItem "$DirGets\*" -Include $Third
    $GetScripts += Get-ChildItem "$DirGets\*" -Include $Fourth
    $GetScripts += Get-ChildItem "$DirGets\*" -Filter "Get-*.ps1" -Exclude $First, $Second, $Third, $Fourth
}

PROCESS { }

END {
    $GetScripts | ForEach-Object {
        $Format = $_.BaseName -Replace("^Get-", 'Format-') -Replace(".ps1$", "")
        Try {
            if (Test-Path function:\$Format) {
                Write-Verbose "Found: function:\$Format"
                Write-Verbose "Trying: $_"
                $Response = & ($_.FullName)
                if ($Response) {
                        $Response | & $($format) -BGInfo:$BGInfo
                        #Write-Host " "
                    }
            }
        } catch { }
    }
}

