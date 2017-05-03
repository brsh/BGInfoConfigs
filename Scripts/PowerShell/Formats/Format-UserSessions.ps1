function Format-UserSessions {
    <#
    .SYNOPSIS
        Formats the output of Get-UserSessions.ps1

    .EXAMPLE
        Get-UserSessions.ps1 | Format-UserSessions

        This script must be dot sourced (i.e., run '. .\Format-UserSessions')
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $UserName,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $Session,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $State,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $IdleTime,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string] $LogonTime,
        [Parameter(Mandatory=$false)]
        [switch] $BGInfo = $false
    )

    BEGIN {
        $columns = "{0,-15} {1,-8}  {2,14}   {3}"
        Write-Host $($columns -f "UserName", "State", "Idle Time", "LogonTime") }

    PROCESS {
        Write-Host $($columns -f $UserName, $State, $IdleTime, $LogonTime)
    }

    END {
        Write-Host ""
    }

}