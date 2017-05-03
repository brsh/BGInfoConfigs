function Format-DriveInfo {
    <#
    .SYNOPSIS
        Formats the output of Get-DriveInfo.ps1

    .EXAMPLE
        Get-DriveInfo | Format-DriveInfo.ps1

        This script must be dot sourced (i.e., run '. .\Format-DriveInfo')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Drive,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $VolumeName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int] $FreeSpace,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int] $UsedSpace,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int] $FreePercent,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int] $UsedPercent,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int] $Size,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $FileSystem,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        [int] $i = 0
        $columns = "{0,-2}   {1,4} {2,9} {3,9}   {4,-7}  {5}"
        Write-Host "Drive Info:`t$($columns -f '', 'Free', 'Free', 'Total', 'Format', 'Label')"
        [string] $tab = "`t`t"
        if ($BGInfo) { $tab = "`t"}
     }

    PROCESS {
        [string] $Build = ""
        $Build = $tab + $columns -f $Drive, "$("{0:N0}" -f $FreePercent)%", "$("{0:N0}" -f $FreeSpace)GB", "$(("{0:N0}" -f $Size))GB", $FileSystem, $VolumeName
        Write-Host $Build
    }

    END {
        Write-Host ""
    }

}