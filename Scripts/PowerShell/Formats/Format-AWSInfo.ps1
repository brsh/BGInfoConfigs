function Format-AWSInfo {
	<#
    .SYNOPSIS
        Formats the output of Get-AWSInfo.ps1

    .EXAMPLE
        Get-AWSInfo.ps1 | Format-AWSInfo

        This script must be dot sourced (i.e., run '. .\Format-AWSInfo')
    #>


	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
		[string] $InstanceSize,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
		[string] $AvailabilityZone,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
		[string] $PublicIP,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
		[string] $NetworkPerformance,
		[Parameter(Mandatory = $false)]
		[switch] $BGInfo = $false
	)

	BEGIN {
		[string] $tab = "`t`t"
		if ($BGInfo) { $tab = "`t"}
		[string] $indent = "${Tab}`t"
	}

	PROCESS {
		if ($InstanceSize) {
			$Header = "Instance Size:`t"
			Write-Host $Header -NoNewLine
			Write-Host $InstanceSize
		}

		if ($AvailabilityZone) {
			$Header = "Avail Zone:`t"
			Write-Host $Header -NoNewLine
			Write-Host $AvailabilityZone
		}

		if ($NetworkPerformance) {
			$Header = "Network Perf:`t"
			Write-Host $Header -NoNewLine
			Write-Host $NetworkPerformance
		}

		if ($PublicIP) {
			$Header = "Public IP:`t"
			Write-Host $Header -NoNewLine
			write-host $PublicIP
		}

		Write-Host ""
	}

	END { }

}
